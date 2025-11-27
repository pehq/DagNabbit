local CollectionService = game:GetService("CollectionService")
--Pehq
--Due to Lua's arrays starting at 1, this will pay respect to that.
--i = (y - 1) * Width + (x - 1) + 1  --> This formula is the main principle this module runs on. Try to simplify it as much as possible.
--i = (z - 1) * (Width * Height) + (y - 1) * Width + (x - 1) + 1 --> This is what a 3d psudo array would be expressed.

--For now you shouldn't worry about this module even though the alternative is very costly.

local Dag = script:FindFirstAncestor("DagNabbit")

local CharSet = require(Dag.Data.CharSet)
local DeepCopy = require(Dag.Utils.DeepCopy)
local Vector2Args = require(Dag.Utils.Vector2Args)
local Directions = require(Dag.Data.Directions)
local RectArgs = require(Dag.Utils.RectArgs)
local ConnectMod = require(Dag.Connectors)

local Matrix = {}
Matrix.__index = Matrix

local function BuildMatrix(dims:Vector2)
	local matrixVal = table.create(dims.X * dims.Y, false)
	
	return matrixVal
end

local function DimIndex(x, y, w)
    return (y - 1) * w + x
end

local function ReverseIndex(i, w)
    --Every index represents an x and y, thus it should be reversable.
    local y = (i - 1) // w + 1
    local x = i - (y - 1) * w
    return x, y
end

function Matrix.new(...)
    local args:Vector2 = Vector2Args(...)
    
    local self = setmetatable({}, Matrix)
    self.Dimensions = args
    self.Value = BuildMatrix(args)
    self.Connectors = ConnectMod.new()

    return self
end

function Matrix.fromRawMatrix(mat)
    local self = setmetatable({}, Matrix)
    self.Dimensions = Vector2.new(#mat[1], #mat) --let's assume it's a square
    
    local w = #mat[1]
    
    self.Value = {}
    for y = 1, #mat do
        for x = 1, #mat[y] do
            self.Value[DimIndex(x, y, w)] = false
        end
    end
    
    self.Connectors = ConnectMod.new()
    
    return self
end

function Matrix:SetAll(v)
    for i = 1, #self.Value do
        self.Value[i] = v
    end
end

function Matrix:RectSet(r:Rect, v)
    for y = math.clamp(r.Min.Y, 1, self.Dimensions.Y), math.clamp(r.Max.Y, 1, self.Dimensions.Y) do
		for x = math.clamp(r.Min.X, 1, self.Dimensions.X), math.clamp(r.Max.X, 1, self.Dimensions.X) do
			self.Value[DimIndex(x, y, self.Dimensions.X)] = v
		end
	end
end

function Matrix:SetByChar(c, v)
    for i = 1, #self.Value do
        if self.Value[i] == c then
            self.Value[i] = v
        end
    end
end

function Matrix:SetByObject(obj, v)
    local Char = CharSet.AssignCharFromObject(obj)
    
    if Char == nil then
        warn("Obj not found or char not found.")
		return
    end
    
    self:SetByChar(Char, v)
end

function Matrix:SetRandomBool()
    for i = 1, #self.Value do
        self.Value[i] = Random.new():NextInteger(0, 1) == 1
    end
end

function Matrix:Clone()
    local clone = setmetatable({}, getmetatable(self))
    clone.Dimensions = self.Dimensions
    clone.Value = DeepCopy(self.Value)
    clone.Connectors = DeepCopy(self.Connectors)
    
    return clone
end

function Matrix:GetMatrixArea()
    return #self.Value
end

function Matrix:AddOn(otherMatrix, offset:Vector2)
    if offset == nil then
        offset = Vector2.zero
    end
    
    --Offset the other matrix
    --remember the formula
    local offsettedMatrix = {}
    for i = 1, #otherMatrix.Value do
    --Gotta consider it doesn't go out of bounds so that it doesn't mess with the other values.
        local rx, ry = ReverseIndex(i, otherMatrix.Dimensions.X) 
        if not otherMatrix.Value[i]
            or rx > self.Dimensions.X or ry > self.Dimensions.Y --Check if out of bounds
            or rx + offset.X > self.Dimensions.X or ry + offset.Y > self.Dimensions then --Or if offsetted positions are out of bounds
                continue
            end
    
        offsettedMatrix[
            i + --Simply shifting the original position positively (x+, y+)
            (offset.Y - 1) * self.Dimensions.X --How much to shift the y axis by. 
            + offset.X --How much to shift the x axis by
        ] = otherMatrix.Value 
    end
    
    local Base = self:Clone()
    for i, v in pairs(offsettedMatrix) do
        Base.Value[i] = v
    end
    
    return Base
end

function Matrix:Extract(...)
    local args:Rect = RectArgs(...)

    local Exted = {}
    local newCons = {}
    
    local p1, p2 = args.Min, args.Max
        
    for i = 1, #self.Value do
        local x, y = ReverseIndex(i, self.Dimensions.X)
        if x < p1.X or x > p2.X or y < p1.Y or y > p2.Y then
            continue
        end
        local dx, dy = x - p1.X + 1, y - p1.Y + 1
        Exted[(dy - 1) * args.Width + dx] = self.Value[i]
    end
    
    for i, c in ipairs(self.Connectors) do
		
		local function inBounds(p)
			return p.X >= p1.X and p.X <= p2.X and p.Y >= p1.Y and p.Y <= p2.Y
		end
		
		if inBounds(c[1] and c[2]) then
			local offsetA = Vector2.new(c[1].X - p1.X + 1, c[1].Y - p1.Y + 1)
			local offsetB = Vector2.new(c[2].X - p1.X + 1, c[2].Y - p1.Y + 1)
			
			table.insert(newCons, {
				offsetA,
				offsetB
			})
		end	
	end
    
    local NewMat = Matrix.new(args.Width + 1, args.Height + 1)
    NewMat.Value = Exted
    NewMat.Connectors = newCons
    NewMat.Dimensions = Vector2.new(args.Width + 1, args.Height + 1)
    
    return NewMat
end

function Matrix:FlipHorizontally()
    local w = self.Dimensions.X
    
    for y = 1, self.Dimensions.Y do
        for x = 1, self.Dimensions.X / 2 do
            self.Value[DimIndex(x,y,w)], self.Value[DimIndex(w - x + 1, y, w)] = self.Value[DimIndex(w - x + 1, y, w)], self.Value[DimIndex(x,y,w)];

        end
    end
    
	for i = 1, #self.Connectors do
		local CurConnector:Rect = self.Connectors[i]
		self.Connectors[i] = {
			Vector2.new(CurConnector[2].X, CurConnector[1].Y),
			Vector2.new(CurConnector[1].X, CurConnector[2].Y)
		}
	end
end

function Matrix:FlipVertically()
    local numRows = #self.Value
    local w = self.Dimensions.X
    
    for x = 1, w do
        for y = 1, self.Dimensions.Y / 2 do
            self.Value[DimIndex(x,y,w)], self.Value[DimIndex(w - x + 1, y, w)] = self.Value[DimIndex(w - x + 1, y, w)], self.Value[DimIndex(x,y,w)];        
        end
    end
    
    for i = 1, #self.Connectors do
		local CurConnector:Rect = self.Connectors[i]
		self.Connectors[i] = {
			Vector2.new(CurConnector[1].X, CurConnector[2].Y),
			Vector2.new(CurConnector[2].X, CurConnector[1].Y)
		}
	end
end

function Matrix:Rotate90Clockwise()
    local res = {}
    
    local w, h = self.Dimensions.X, self.Dimensions.Y
    
    for y = 1, h do
        for x = 1, w do
            --I've had quite a day figuring this one out....
            res[DimIndex(x, y, w)] = self.Value[DimIndex(h - x + 1, y, w)]
        end
    end
    
    for i = 1, #self.Connectors do
		local CurRect:Rect = self.Connectors[i]
		self.Connectors[i] = {
			Vector2.new(h - CurRect[1].Y + 1, CurRect[1].X),
			Vector2.new(h - CurRect[2].Y + 1, CurRect[2].X)
		}
	end
    
    self.Dimensions = Vector2.new(h, w)
	self.Value = res
end

---Flips the values in the Matrix upside down.
function Matrix:Rotate180()
	self:Rotate90Clockwise()
	self:Rotate90Clockwise()
end

---Flips the values in the Matrix 90 degrees counter-clockwise.
function Matrix:Rotate90CounterClockwise()
	self:Rotate180()
	self:Rotate90Clockwise()
end

---Inverts all booleans contained within the Matrix.
function Matrix:Invert()
	for i = 1, #self.Value do
        self.Value = not self.Value[i]
    end
end

function Matrix:Cull()
    local Min_X, Min_Y, Max_X, Max_Y = nil, nil, nil, nil
    
    for i = 1, #self.Value do
        local x, y = ReverseIndex(i, self.Dimensions.X)
        local curVal = self.Value[i]
        
        if curVal == false then
            continue
        end
        
        if Min_X == nil or Min_X > x then
			Min_X = x
		end
		
		if Min_Y == nil or Min_Y > y then
			Min_Y = y
		end
		
		if Max_X == nil or Max_X < x then
			Max_X = x
		end
		
		if Max_Y == nil or Max_Y < y then
			Max_Y = y
		end
    end
    
    return self:Extract(Min_X, Min_Y, Max_X, Max_Y)
end

function Matrix:SetFromStartingConnectors(val:Vector2)
    if not val then
        return
    end
    
    for i = 1, #self.Connectors do
		local CurConnector = self.Connectors[i]
		
		self.Value[CurConnector[1].Y][CurConnector[1].X] = val
	end
end

return Matrix