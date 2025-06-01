--[[Take a mouse, make it drunk and make it dig]]
local DrunkardWalk = {}

local function CreateArray(num, Dimensions:Vector2)
	local Array = {}

	if Dimensions.Y == 0 then --Makes it a square if there isn't a Y value
		Dimensions.Y = Dimensions.X
	end

	for i = 1, Dimensions.Y, 1 do 
		table.insert(Array, {}) --Y
		for j = 1, Dimensions.X, 1 do
			table.insert(Array[i], num) --X
		end
	end

	wait()

	return Array
end

function DrunkardWalk.SimulateDrunkenWalk(MatrixMap, LifeTime:number, Position:Vector2)
	if not Position then
		Position = Vector2.new(math.round(#MatrixMap[1] / 2), math.round(#MatrixMap / 2))
	end
	
	local function WalkDig()
		local RandomDir = math.random(1, 4)
		
		if Position.Y ~= 1 and RandomDir == 1 then --go up
			Position += Vector2.new(0, -1)
		elseif Position.Y ~= #MatrixMap and RandomDir == 2 then --go down
			Position += Vector2.new(0, 1)
		elseif Position.X ~= 1 and RandomDir == 3 then -- go left
			Position += Vector2.new(-1, 0)
		elseif Position.X ~= #MatrixMap[Position.Y] and RandomDir == 4 then --go right
			Position += Vector2.new(1, 0)
		end
		if MatrixMap[Position.Y][Position.X] == 0 then
			MatrixMap[Position.Y][Position.X] = 1
		end
	end
	for i = 1, LifeTime do
		WalkDig()
	end
	
	wait()
	
	return MatrixMap
end

function DrunkardWalk.NewMatrixDrunkardWalk(Dimensions:Vector2, Iterations, Lifetime, StartingPosition:Vector2)
	local MatrixMap = CreateArray(0, Dimensions)
	local Rats = 0
	
	if not StartingPosition then
		StartingPosition = Vector2.new(math.round(#MatrixMap[1] / 2), math.round(#MatrixMap / 2))
	end
	
	local Width = #MatrixMap[1]
	local Height = #MatrixMap
	local TotalCells = Width * Height
	local ActiveCells = {} --table with list of cells' position that drunkard could be placed on
	
	for i = 1, Iterations do
		print(StartingPosition)
		DrunkardWalk.SimulateDrunkenWalk(MatrixMap, Lifetime, StartingPosition)
		
		--pick next starting position
		for y = 1, #MatrixMap do
			for x = 1, #MatrixMap[y] do
				if MatrixMap[y][x] == 1 then
					table.insert(ActiveCells, Vector2.new(x, y))
				end
			end
		end
		
		StartingPosition = ActiveCells[math.random(1, #ActiveCells)]
		ActiveCells = {}
	end
	return MatrixMap
end

return DrunkardWalk
