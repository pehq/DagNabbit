local Dag = script:FindFirstAncestor("DagNabbit")

local CharSet = require(Dag.Data.CharSet)
local DeepCopy = require(Dag.Utils.DeepCopy)

local Matrix = {}
Matrix.__index = Matrix

Matrix.Algorithms = {}

for _, v in pairs(script:GetChildren()) do
	if v:IsA("ModuleScript") then
		Matrix.Algorithms[v.Name] = require(v)
	end
end


local ArgsToVector2 = {
	["number"] = function(args:number)
		return Vector2.new(args, args)
	end,
	["Vector2"] = function(args:Vector2)
		return args
	end,
	["Vector2int16"] = function(args:Vector2int16) --If you encounter a bug while using Vector2int16s then contact me.
		return args
	end,
	["Vector3"] = function(args:Vector3)
		return Vector2.new(args.X, args.Y) --Z is simply excluded
	end,
	["Vector3int16"] = function(args:Vector3int16)
		return Vector2int16.new(args.X, args.Y)
	end,
	["nil"] = function()
		return Vector2.zero
	end,
	["table"] = function(args:{})
			
		if args[1] ~= nil and args[2] ~= nil then
			return Vector2.new(args[1], args[2])
		elseif args[1] ~= nil and args[2] == nil then
			return Vector2.new(args[1], args[1])
		else
			return Vector2.zero
		end
	end,
	["boolean"] = function(args:boolean)
		print(args)
		local Val = args and 1 or 0
		return Vector2.new(Val, Val)
	end,
}

local Direction = {
	Vector2.new(-1,-1), --North-West
	Vector2.new(-1, 0), --North
	Vector2.new(-1, 1), --NorthEast
	Vector2.new( 0, 1), --East
	Vector2.new( 1,-1), --SouthWest
	Vector2.new( 1, 0), --South
	Vector2.new( 1, 1), --SouthEast
	Vector2.new( 0,-1), --West
	Vector2.new(-1,-1), --NorthWest
}

local function BuildMatrix(dims:Vector2)
	local matrixVal = {}
	
	for i = 1, dims.Y do
		matrixVal[i] = {}
		for j = 1, dims.X do
			matrixVal[i][j] = false
		end
	end
	
	return matrixVal
end

function Matrix.new(...)
	if ... == nil then
		return Matrix.new(5,5)
	end
	local args = typeof(...) == "table" or #{...} <= 1 and ... or {...}
	args = ArgsToVector2[typeof(args)](args)
	
	
	local self = setmetatable({}, Matrix)
	self.Dimensions = args
	self.Value = BuildMatrix(args)
	self.GridScale = Vector2.new(5,5)  --x, y
	self.Connectors = {}
	
	return self
end

function Matrix.fromMatrix(matrixVal)
	local self = setmetatable({}, Matrix)
	self.Value = DeepCopy(matrixVal)
	self.Dimensions = Vector2.new(#matrixVal[1], #matrixVal)
	self.GridScale = Vector2.new(5,5) 
	self.Connectors = {}
	
	return self
end

function Matrix:SetAll(val)
	for i = 1, self.Dimensions.Y do
		for j = 1, self.Dimensions.X do
			self.Value[i][j] = val
		end
	end
end

function Matrix:RectSet(rectVal:Rect, val)
	for y = math.clamp(rectVal.Min.Y, 1, self.Dimensions.Y), math.clamp(rectVal.Max.Y, 1, self.Dimensions.Y) do
		for x = math.clamp(rectVal.Min.X, 1, self.Dimensions.X), math.clamp(rectVal.Max.X, 1, self.Dimensions.X) do
			self.Value[y][x] = val
		end
	end
end

function Matrix:SetByChar(Char, val)
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			local CurSelection = self.Value[y][x]
			if CurSelection == Char then
				self.Value[y][x] = val
			end
		end
	end
end

function Matrix:SetByObject(str, val)
	local Char = CharSet.AssignCharFromObject(str)
	
	if Char == nil then
		warn("Obj not found or char not found.")
		return
	end
	
	self:SetByChar(Char, val)
end

function Matrix:SetRandomBool()
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			self.Value[y][x] = Random.new():NextInteger(0,1) == 1
		end
	end
end

function Matrix:SetMultipleChars(chars, val)
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			local curVal = self.Value[y][x]
			local Found = table.find(chars, curVal)
			if Found then
				self.Value[y][x] = val
			end
		end
	end
end

function Matrix:GetNumOfChars(val)
	local count = 0
	
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			if self.Value[y][x] == val then
				count += 1
			end
		end
	end
	
	return count
end

--if out of bounds then it gets cut-off
--No exclusion
function Matrix:AddOn(otherMatrix, offset:Vector2)
	if offset == nil then
		offset = Vector2.zero
	end
	
	for y = 1, #otherMatrix.Value do
		for x = 1, #otherMatrix.Value[y] do
			local CurChar = otherMatrix.Value[y][x]
			if self.Value[y + offset.Y] == nil or self.Value[y + offset.Y][x + offset.X] == nil then
				continue
			end
			
			self.Value[y + offset.Y][x + offset.X] = CurChar
		end
	end
end

function Matrix:Overlay(otherMatrix, offset:Vector2)
	if offset == nil then
		offset = Vector2.zero
	end
	
	for y = 1, #otherMatrix.Value do
		for x = 1, #otherMatrix.Value[y] do
			local CurChar = otherMatrix.Value[y][x]
			if not CurChar or self.Value[y + offset.Y] == nil or self.Value[y + offset.Y][x + offset.X] == nil then
				continue
			end
			self.Value[y + offset.Y][x + offset.X] = CurChar
		end
	end
end

--This one works with nil but at the cost of performance
function Matrix:Mask(otherMatrix, offset:Vector2)
	if offset == nil then
		print("setted missing")
		offset = Vector2.zero
	end
	
	for y, v in pairs(otherMatrix.Value) do
		for x, c in pairs(v) do
			if self.Value[y + offset.Y] == nil or self.Value[y + offset.Y][x + offset.X] == nil then
				continue
			end
			
			self.Value[y + offset.Y][x + offset.X] = c
		end
	end
end

function Matrix:Extract(p1:Vector2, p2:Vector2)
	local ExtractedMatrix = {}
	local newConnectors = {}
	
	for y = p1.Y, p2.Y do
		local dy = y - p1.Y + 1
		ExtractedMatrix[dy] = {}
		for x = p1.X, p2.X do
			local dx = x - p1.X + 1
			ExtractedMatrix[dy][dx] = self.Value[y][x]
		end
	end
	
	for i, c in ipairs(self.Connectors) do
		
		local function inBounds(p)
			return p.X >= p1.X and p.X <= p2.X and p.Y >= p1.Y and p.Y <= p2.Y
		end
		
		if inBounds(c[1] and c[2]) then
			local offsetA = Vector2.new(c[1].X - p1.X + 1, c[1].Y - p1.Y + 1)
			local offsetB = Vector2.new(c[2].X - p1.X + 1, c[2].Y - p1.Y + 1)
			
			table.insert(newConnectors, {
				offsetA,
				offsetB
			})
		end	
	end
	
	local newMatrix = Matrix.fromMatrix(ExtractedMatrix)
	newMatrix.Connectors = newConnectors
	
	return newMatrix
end

function Matrix:FlipHorizontally()
	for y = 1, #self.Value do
		local row = self.Value[y]
		local numCols = #row
		
		for x = 1, numCols / 2 do
			row[x], row[numCols - x + 1] = row[numCols - x + 1], row[x]
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
	for y = 1, numRows / 2 do
		self.Value[y], self.Value[numRows - y + 1] = self.Value[numRows - y + 1], self.Value[y]
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
	local numRows = self.Dimensions.Y
	local numCols = self.Dimensions.X
	local result = {}

	for y = 1, numCols do
		result[y] = {}
		for x = 1, numRows do
			result[y][x] = self.Value[numRows - x + 1][y]
		end
	end
	
	for i = 1, #self.Connectors do
		local CurRect:Rect = self.Connectors[i]
		self.Connectors[i] = {
			Vector2.new(numRows - CurRect[1].Y + 1, CurRect[1].X),
			Vector2.new(numRows - CurRect[2].Y + 1, CurRect[2].X)
		}
	end
	
	self.Dimensions = Vector2.new(numRows, numCols)
	self.Value = result
end

function Matrix:Rotate180()
	self:Rotate90Clockwise()
	self:Rotate90Clockwise()
end

function Matrix:Rotate90CounterClockwise()
	self:Rotate180()
	self:Rotate90Clockwise()
end

function Matrix:Invert()
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			local curVal = self.Value[y][x]
			if typeof(curVal) == "boolean" then
				self.Value[y][x] = not curVal
			end
		end
	end
end

function Matrix:FlipNeighbors()
	local ToAdd = Matrix.new(self.Dimensions)
	
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			local CurVal = self.Value[y][x]
			
			if CurVal ~= true then
				continue
			end
			
			for _, v in ipairs(Direction) do
				local dy, dx = y + v.Y, x + v.X
				if self.Value[dy] ~= nil
					and self.Value[dy][dx] ~= nil 
					and self.Value[dy][dx] == false then
					ToAdd.Value[dy][dx] = true
				end
			end
		end
	end
	
	self:Overlay(ToAdd)
end

function Matrix:Cull()
	local Min_X, Min_Y, Max_X, Max_Y = nil, nil, nil, nil
	
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			local CurVal = self.Value[y][x]
			
			if CurVal == false then
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
	end
	
	--print(Min_X, Min_Y, Max_X, Max_Y)
	
	return self:Extract(Vector2.new(Min_X, Min_Y), Vector2.new(Max_X, Max_Y))
end

--Connectors
function Matrix:InsertConnector(p1, p2)
	table.insert(self.Connectors, {p1, p2})
end

function Matrix:ShowConnectors(StartChar, EndChar)
	if not StartChar then
		StartChar = "S"
	end
	if not EndChar then
		EndChar = "E"
	end
	
	for i = 1, #self.Connectors do
		local CurConenctor = self.Connectors[i]
		
		self.Value[CurConenctor[1].Y][CurConenctor[1].X] = StartChar
		self.Value[CurConenctor[2].Y][CurConenctor[2].X] = EndChar
	end
end

function Matrix:SetStartingConnectors(val)
	if not val then
		return
	end
	
	for i = 1, #self.Connectors do
		local CurConnector = self.Connectors[i]
		
		self.Value[CurConnector[1].Y][CurConnector[1].X] = val
	end
end

function Matrix:SetEndingConnectors(val)
	if not val then
		return
	end
	
	for i = 1, #self.Connectors do
		local CurConnector = self.Connectors[i]
		
		self.Value[CurConnector[2].Y][CurConnector[2].X] = val
	end
end

function Matrix:GetFarthestConnectorIndex()
	local Farthest = 1
	local FarMagnitude = 0
	
	for i, c:{p1:Vector2,p2:Vector2} in ipairs(self.Connectors) do
		local m = (c[2] - c[1]).Magnitude
		if m > FarMagnitude then
			Farthest = i
			FarMagnitude = m
		end
	end
	
	return Farthest
end

function Matrix:ConnectMatrix(otherMatrix, selfConnectorI, otherConnectorI)
	--i haven't thought this through... TODO
end

function Matrix:Border(borderChar)
	if borderChar == nil then
		borderChar = CharSet.AssignCharFromObject("Air")
	end
	
	local Background = Matrix.new(self.Dimensions + Vector2.one * 2)
	Background:SetAll(borderChar)
	Background:RectSet(Rect.new(Vector2.new(2,2), self.Dimensions - Vector2.one), false)
	Background:AddOn(self, Vector2.one)
	
	self.Value = Background.Value
	self.Dimensions = Background.Dimensions
	
	Background = nil
end

function Matrix:Wallify() --Surronds Floors with walls
	local WallChar = CharSet.AssignCharFromObject("Wall")
	
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			local CurChar = self.Value[y][x]
			if CharSet.CharValues[CurChar] ~= "Floor" then
				continue
			end
			
			for _, v in ipairs(Direction) do
				local dy, dx = y + v.Y, x + v.X
				if self.Value[dy] ~= nil 
				and self.Value[dy][dx] ~= nil 
				and (self.Value[dy][dx] == CharSet.CharValues[false]) then
					self.Value[dy][dx] = WallChar
				end
			end
		end
	end
end

--debugging tools
function Matrix:SetRandomChar()
	local Chars = {}
	
	for i, _ in pairs(CharSet.CharValues) do
		table.insert(Chars, i)
	end
	
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			self.Value[y][x] = Chars[math.random(1, #Chars)]
		end
	end
end

function Matrix:Print()
	for i = 1, #self.Value do
		print(table.concat(self.Value[i]))
	end
end

--While this function may appear to be useful, DO NOT USE IN PRODUCTION. It takes a long time to load and causes lag! For that reason, it's only meant to be used as a way to debug stuff.
function Matrix:Generate(BlueprintSelected:ModuleScript)
	if not BlueprintSelected then
		BlueprintSelected = Dag.Blueprint.Default
	end
	
	local Model = nil
	Model = require(BlueprintSelected).GenerateMatrix(self)
	Model.Name = "GeneratedMatrix"
	
	local Scale:Vector2 = self.GridScale --defaults to (5,5)
	
	return Model
end

return Matrix