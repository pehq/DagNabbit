
---	@class Matrix
---	A grid of values

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

local SoftDir = {
	Vector2.new(-1, 0), --North
	Vector2.new( 0, 1), --East
	Vector2.new( 1, 0), --South
	Vector2.new( 0,-1), --West
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

--[=[
	Creates the Matrix value with the size in x, and y

	@param ... number|Vector2|Vector2int16|Vector3|Vector3int16|table|boolean -- you get the idea

	@return Matrix -- Returns the Matrix class
]=]
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
	self.Origin = Vector2.one
	self.Connectors = {}
	
	return self
end

--[=[
	Creates the Matrix value with a raw matrix value.

	@param matrixVal {{any}} -- the matrix Value

	@return Matrix -- Returns the Matrix class
]=]
function Matrix.fromMatrix(matrixVal)
	local self = setmetatable({}, Matrix)
	self.Value = DeepCopy(matrixVal)
	self.Dimensions = Vector2.new(#matrixVal[1], #matrixVal)
	self.GridScale = Vector2.new(5,5) 
	self.Connectors = {}
	
	return self
end


--[=[
	Set all the values in the Matrix to one value. Useful for setting up a Matrix.

	@param val any
]=]
function Matrix:SetAll(val)
	for i = 1, self.Dimensions.Y do
		for j = 1, self.Dimensions.X do
			self.Value[i][j] = val
		end
	end
end

--[=[
	Sets a certain area based on a Rect to a value

	@param val any
]=]
function Matrix:RectSet(rectVal:Rect, val)
	for y = math.clamp(rectVal.Min.Y, 1, self.Dimensions.Y), math.clamp(rectVal.Max.Y, 1, self.Dimensions.Y) do
		for x = math.clamp(rectVal.Min.X, 1, self.Dimensions.X), math.clamp(rectVal.Max.X, 1, self.Dimensions.X) do
			self.Value[y][x] = val
		end
	end
end

--[=[
	Sets all of a certain value contained in the Matrix to another Value, useful for setting booleans into characters.
]=]
function Matrix:SetByChar(Char:any, val:any)
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			local CurSelection = self.Value[y][x]
			if CurSelection == Char then
				self.Value[y][x] = val
			end
		end
	end
end

--[=[
	Sets all of a certain value contained in the Matrix to another Value **based on the charset**, useful for converting certain characters into another character.
]=]
function Matrix:SetByObject(str:string, val:any)
	local Char = CharSet.AssignCharFromObject(str)
	
	if Char == nil then
		warn("Obj not found or char not found.")
		return
	end
	
	self:SetByChar(Char, val)
end

--[=[
	Sets all of the Matrix's values to either true or false.
]=]
function Matrix:SetRandomBool()
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			self.Value[y][x] = Random.new():NextInteger(0,1) == 1
		end
	end
end

--[=[
	Sets all of a certain value contained in the Matrix to another Value, useful for setting booleans into characters.
]=]
function Matrix:SetMultipleChars(chars:any, val:any)
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

--[=[
	returns the number of times a value is used within the Matrix.

	@return number
]=]
function Matrix:GetNumOfChars(val:any)
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

--[=[
	Adds a matrix over another matrix. __Anything that's a false value won't be overlaid over the base matrix.__ If the other matrix being added onto the base matrix goes out of bounds then the out of bounds won't be counted. Can be offsetted from the top-left with offset.

	@param otherMatrix Matrix
	@param offset Vector2 -- Offsetted from the top left of the Matrix
]=]
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

--[=[
	Adds a matrix over another matrix. If the other matrix being added onto the base matrix goes out of bounds then the out of bounds won't be counted. Can be offsetted from the top-left with offset.

	@param otherMatrix Matrix
	@param offset Vector2 -- Offsetted from the top left of the Matrix
]=]
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

--[=[
	Adds a matrix over another matrix. Will overlay nil values but at the cost of performance. If the other matrix being added onto the base matrix goes out of bounds then the out of bounds won't be counted. Can be offsetted from the top-left with offset.

	@param otherMatrix Matrix
	@param offset Vector2 -- Offsetted from the top left of the Matrix
]=]function Matrix:Mask(otherMatrix, offset:Vector2)
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

--[=[
	Extracts a Matrix from one point to another, creating another Matrix.

	@return Matrix
]=]
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

---Flips the values in the Matrix on the x-axis.
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

---Flips the values in the Matrix on the y-axis.
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

---Flips the values in the Matrix 90 degrees clockwise.
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
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			local curVal = self.Value[y][x]
			if typeof(curVal) == "boolean" then
				self.Value[y][x] = not curVal
			end
		end
	end
end

---Will change all false values that are next to a true value into true.
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

--[=[
	Zooms in on areas that use a true value, useful for optimization.
	@return Matrix
]=]
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
--[=[
	Inserts a Connector
	@param p1 Vector2
	@param p2 Vector2
]=]
function Matrix:InsertConnector(p1, p2)
	table.insert(self.Connectors, {p1, p2})
end

--[=[
	Change the values in the Matrix to that of the starting and ending connectors, will default to "S" and "E" respectively if no values for them are provided
	@param StartChar any
	@param EndChar any
]=]
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

---Sets all starting connectors to one Vector2
function Matrix:SetStartingConnectors(val:Vector2)
	if not val then
		return
	end
	
	for i = 1, #self.Connectors do
		local CurConnector = self.Connectors[i]
		
		self.Value[CurConnector[1].Y][CurConnector[1].X] = val
	end
end

---Sets all ending connectors to one Vector2
function Matrix:SetEndingConnectors(val:Vector2)
	if not val then
		return
	end
	
	for i = 1, #self.Connectors do
		local CurConnector = self.Connectors[i]
		
		self.Value[CurConnector[2].Y][CurConnector[2].X] = val
	end
end

--[=[
	Gets the Connector that has the highest magnitude.
	@return number
]=]
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

---Will surround the Matrix with a value
function Matrix:Border(borderChar:any)
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

---Very niche but surrounds all Floor characters with a Wall character.
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
---Sets all values to a random character from the Charset
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

---Neatly prints the Matrix in the terminal, will only work if all values are strings or numbers
function Matrix:QuickPrint(seperate)
	local sep = seperate == true and " " or ""
	
	for i = 1, #self.Value do
		print(table.concat(self.Value[i], sep))
	end
end

--Neatly prints the Matrix in the terminal, will work on all values.
function Matrix:Print(seperate)
	self:SetByChar(false, "false")
	self:SetByChar(true, "true")
	self:SetByChar(nil, "") --I have not tested this
	
	self:QuickPrint(seperate)
end

---While this function may appear to be useful, DO NOT USE IN PRODUCTION. It takes a long time to load and causes lag! For that reason, it's only meant to be used as a way to debug stuff.
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