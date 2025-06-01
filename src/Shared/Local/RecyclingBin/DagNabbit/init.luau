--[[

WELCOME TO MY PAIN, D.A.G - N.A.B.I.T

IF YOU DON'T KNOW WHAT THAT MEANS THEN IT'S SIMPLE REALLY...

IT MEANS Dungeon with Algorithmic Generator with a Nonsensical Agonizing that Backstabs you with Bewildered Imaginary Tunnels

BackStab???

TF2 REFERENCE!!11!1

So yeah, here it is
	
Instructions are to tell a mouse what to do and where to go and it'll do it, after all, it could tunnel if it tried hard enough
]]

local Data = {}

Data.Algorithms = {
	["Random Walk"] = require(script.RandomWalkAlgorithm),
	["BSPDungeon"] = require(script.BSPDungeonGeneration),
	["Conway's Game of Life"] = require(script.ConwayLifeSimulation),
	["DrunardWalk"] = require(script.DrunkardWalk)
}

Data.SavedMap = require(script.SavedBlueprintMaps)

function Data.CreateArray(num, Dimensions:{DimensionsX:number, DimensionsY:number})
	local Array = {}
	
	if type(Dimensions) == "number" then
		Dimensions = {Dimensions}
	end
	
	if not Dimensions[2] then --Makes it a square if there isn't a Y value
		Dimensions[2] = Dimensions[1]
	end

	for i = 1, Dimensions[2], 1 do 
		table.insert(Array, {}) --Y
		for j = 1, Dimensions[1], 1 do
			table.insert(Array[i], num) --X
		end
	end

	return Array
end

function Data.StringifyMatrix(Map:{{number:number}}) --turns all values to strings
	--Turns all values to strings
	for i = 1, #Map, 1 do
		for j = 1, #Map[i], 1 do
			Map[i][j] = tostring(Map[i][j])
		end
	end
	
	return Map
end

function Data.StringifyRect(RectMap)
	for i, v in pairs(RectMap) do
		v[1] = tostring(v[1])
	end
	
	return RectMap
end

function Data.MergeMatrixValues(Matrices:{MatrixMap1:any, MatrixMap2:any, MatrixMap3:any}) --Put an order of MatrixMaps or Matrices Map (That Nurses joy and Nurse Joys paradox again guh) in a table, it'll merge it with the first MatrixMap in array as the base. Make sure the dimensions are the same
	
	--Find Matrix with highest dimensions
	local MaxX = 0
	local MaxY = 0
	
	for i = 1, #Matrices do
		if MaxY < #Matrices[i] then
			MaxY = #Matrices[i]
		end
		for y = 1, #Matrices[i] do
			if MaxX < #Matrices[i][y] then
				MaxX = #Matrices[i][y]
			end
		end
	end
	
	local BaseMatrixMap = Data.CreateArray(0, {MaxX, MaxY})
	
	--Start Merging
	for i = 1, #Matrices do
		for y = 1, #Matrices[i] do
			for x = 1, #Matrices[i][y] do
				BaseMatrixMap[y][x] = Matrices[i][y][x]
			end
		end
	end
	
	--Merge done
	
	return BaseMatrixMap 
end

function Data.InvertTwoMatrixValues(MatrixMap, Value1, Value2) --Changes two values with each other in a matrix map
	for y = 1, #MatrixMap do
		for x = 1, #MatrixMap[y] do
			if MatrixMap[y][x] == Value1 then
				MatrixMap[y][x] = Value2
			elseif MatrixMap[y][x] == Value2 then
				MatrixMap[y][x] = Value1
			end
		end
	end 
end

function Data.Wallify(Map:{{number:number}})

	local FortifiedMap = Data.CreateArray(0, {#Map + 2})
	
	for i = 1, #Map, 1 do
		for j = 1, #Map[i], 1 do
			FortifiedMap[i+1][j+1] = Map[i][j]
		end
	end
	
	wait()
	
	Data.StringifyMatrix(FortifiedMap)
	
	wait()
	
	for i = 1, #FortifiedMap, 1 do
		for j = 1, #FortifiedMap[i] do
			if FortifiedMap[i][j] ~= '0' and FortifiedMap[i][j] ~= '2' then
				if i ~= 1 and FortifiedMap[i-1][j] == '0' then
					FortifiedMap[i-1][j] = '2'
				end
				if i ~= #FortifiedMap and FortifiedMap[i+1][j] == '0' then
					FortifiedMap[i+1][j] = '2'
				end
				if j ~= 1 and FortifiedMap[i][j-1] == '0' then
					FortifiedMap[i][j-1] = '2'
				end
				if j ~= #FortifiedMap[i] and FortifiedMap[i][j+1] == '0' then
					FortifiedMap[i][j+1] = '2'
				end
			end
		end
	end
	
	wait()
	
	return FortifiedMap
end

function Data.MatrixToRect(MatrixMap) --Converts Matrix to Rect by using greedy meshing
	local RectMap = {}
	local VisitedCells = {}
	local CellSizes = {} --Keep track of cell sizes
	
	MatrixMap = Data.StringifyMatrix(MatrixMap)
	
	for y = 1, #MatrixMap do -- Initialize visited cells
		VisitedCells[y] = {}
		for x = 1, #MatrixMap[y] do
			VisitedCells[y][x] = false
		end
	end
	
	for y = 1, #MatrixMap do --Inputs width and height for every cell
		table.insert(CellSizes, {})
		for x = 1, #MatrixMap[y] do
			table.insert(CellSizes[y], {["X"] = 1, ["Y"] = 1})
		end
	end
	
	--Calulate width in 1d
	for y = 1, #MatrixMap do
		for x = 2, #MatrixMap[y] do
			local CellId = MatrixMap[y][x]
			if CellId == MatrixMap[y][x - 1] then
				CellSizes[y][x].X += CellSizes[y][x - 1].X
				CellSizes[y][x - 1].X = nil
			end
		end
	end 
	
	for y = 2, #MatrixMap do
		for x, Size in pairs(CellSizes[y]) do
			if MatrixMap[y - 1][x] ~= nil and Size.X == CellSizes[y - 1][x].X and MatrixMap[y][x] == MatrixMap[y - 1][x] then
				Size.Y += CellSizes[y - 1][x].Y
				CellSizes[y - 1][x] = nil
			end
		end
	end
	
	for y = 1, #MatrixMap do
		for x = 1, #MatrixMap[y] do
			local CellId = MatrixMap[y][x]
			if CellId == '0' then continue end --Removes air block
			if CellSizes[y][x] == nil then continue end
			if CellSizes[y][x].X == nil or CellSizes[y][x].Y == nil then continue end
			table.insert(RectMap, {CellId, Rect.new( x - CellSizes[y][x].X + 1, y - CellSizes[y][x].Y + 1 , x, y)})
		end
	end
	
	return RectMap
end

function Data.RectToMatrix(Map:{{RectValue:Rect}})
	local W, H = 0, 0
	-- Get the dimensions of the Map
	for i = 1, #Map do
		local RectValue:Rect = Map[i][2]
		if RectValue.Max.X > W then
			W = RectValue.Max.X
		end
		if RectValue.Max.Y > H then
			H = RectValue.Max.Y
		end
	end
	
	local MatrixMap = Data.CreateArray('0', {W, H})
	
	for i = 1, #Map do
		local RectValue:Rect = Map[i][2]
		local V = Map[i][1]
		
		wait()
		
		if RectValue.Width == 0 and RectValue.Height ~= 0 then --Checks to see if rect is a line
			for dy = 0, RectValue.Height do
				MatrixMap[RectValue.Min.Y + dy][RectValue.Min.X] = V
			end
		elseif RectValue.Height == 0 and RectValue.Width ~= 0 then --Checks to see if rect is a line
			for dx = 0, RectValue.Width do
				MatrixMap[RectValue.Min.Y][RectValue.Min.X + dx] = V
			end
		elseif RectValue.Width == 0 and RectValue.Height == 0 then --Checks to see if rect is a point
			MatrixMap[RectValue.Min.Y][RectValue.Min.X] = V
		elseif RectValue.Width > 0 and RectValue.Height > 0 then --Checks to see if rect is a square
			for dx = 0, RectValue.Width do
				for dy = 0, RectValue.Height do
					MatrixMap[RectValue.Min.Y + dy][RectValue.Min.X + dx] = V
				end
			end
		end
	end
	
	return MatrixMap
end

function Data.GenerateMapFromMatrix(Map:{{number:number}})
	local ServerStorage = game.ServerStorage
	local Area = ServerStorage.Area
	local Base = Area.Base
	local Block = Area.BasicBlock
	local Start = Area.SpawnBase
	--local Wall = Area.Basic4WallRoom
	--local FourWay = Area.Basic4WayRoom
	
	wait()

	for i = 1, #Map, 1 do
		print(table.concat(Map[i]))
	end

	local Model = Instance.new("Model")
	Model.Name = "TmpMap"
	Model.Parent = workspace.tmp

	local SquareSizeX = Base.Base.Size.X
	local SquareSizeZ = Base.Base.Size.Z
	
	Data.StringifyMatrix(Map)
	
	for i = 1, #Map do
		wait()
		for j = 1, #Map[i] do
			if tostring(Map[i][j]) == "1" then
				local Obj = Base:Clone()
				Obj:PivotTo(CFrame.new(Vector3.new(i * SquareSizeX, 500, j*SquareSizeZ)))
				Obj.Parent = Model
			elseif tostring(Map[i][j]) == "2" then
				local Obj = Block:Clone()
				Obj:PivotTo(CFrame.new(Vector3.new(i*SquareSizeX, 500, j*SquareSizeZ)))
				Obj.Parent = Model
			elseif Map[i][j] == 'S' then
				local Obj = Start:Clone()
				Obj.Base.BrickColor = BrickColor.new("Lime green")
				Obj:PivotTo(CFrame.new(Vector3.new(i*SquareSizeX, 500, j*SquareSizeZ)))
				Obj.Parent = Model
			elseif Map[i][j] == 'E' then
				local Obj = Base:Clone()
				Obj.Base.BrickColor = BrickColor.new("Really red")
				Obj:PivotTo(CFrame.new(Vector3.new(i*SquareSizeX, 500, j*SquareSizeZ)))
				Obj.Parent = Model
			elseif tostring(Map[i][j]) == '3' then
				local Obj = Base:Clone()
				Obj:PivotTo(CFrame.new(Vector3.new(i*SquareSizeX, 500, j*SquareSizeZ)))
				Obj.Parent = Model
			end
		end
	end
	
	Model:MoveTo(Vector3.new(0, 500, 0))
	
	return Model
end

function Data.GenerateMapFromRect(RectMap:{{id:string, RectValue:Rect}})
	local ServerStorage = game.ServerStorage
	local Area = ServerStorage.Area
	local Base = Area.Base
	local Block = Area.BasicBlock
	local Start = Area.SpawnBase
	local Model = Instance.new("Model", workspace.tmp)
	
	local function GenerateArea(Value, Size:Vector2, Pos:Vector2)
		local SizeX = Size.X * Base.Base.Size.X
		local SizeY = Size.Y * Base.Base.Size.Z
		local XPos = Pos.X * Base.Base.Size.X
		local YPos = Pos.Y * Base.Base.Size.Z
		
		local Obj
		if tostring(Value) == '1' then
			Obj = Base:Clone()
			Obj.Base.Size = Vector3.new(SizeX, 1, SizeY)
		elseif tostring(Value) == '2' then
			Obj = Block:Clone()
			Obj.Base.Size = Vector3.new(SizeX, 16, SizeY)
		elseif tostring(Value) == 'S' then
			Obj = Start:Clone()
			Obj.Base.Size = Vector3.new(SizeX, 1, SizeY)
		elseif tostring(Value) == 'E' then
			Obj = Base:Clone()
			Obj.Base.BrickColor = BrickColor.new("Really red")
			Obj.Base.Size = Vector3.new(SizeX, Base.Base.Size.Y, SizeY)
		end
		
		print(XPos, YPos)
		Obj:PivotTo(CFrame.new(Vector3.new(XPos, 500, YPos)))
		Obj.Parent = Model
	end
	
	for i, rectData in ipairs(RectMap) do
		local TileValue = rectData[1]
		local RectValue:Rect = rectData[2]
		
		local CenterX = (RectValue.Min.X + RectValue.Max.X) / 2
		local CenterY = (RectValue.Min.Y + RectValue.Max.Y) / 2
		
		local SizeX = RectValue.Width + 1
		local SizeY = RectValue.Height + 1
		
		GenerateArea(TileValue, Vector2.new(SizeX, SizeY), Vector2.new(CenterX, CenterY))
	end
	
	Model:PivotTo(CFrame.new(Vector3.new(0, 500, 0)))
	
	return Model
end

return Data
