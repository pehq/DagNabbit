local ConwaySim = {}

local function CreateArray(num, Dimensions:Vector2, Percentage:boolean)
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

local function SimulateConwayGame(MatrixMap, Iterations)
	for i = 1, Iterations do
		wait()
		local ValuesToChange = {} --Container for values to change, What value to change to and where
		for y = 1, #MatrixMap do
			for x = 1, #MatrixMap[y] do
				local Neighbors = 0

				if x ~= 1 and y ~= 1 and MatrixMap[y-1][x-1] == 1 then --Check Up Left
					Neighbors += 1
				end
				if y ~= 1 and MatrixMap[y-1][x] == 1 then --Check Up
					Neighbors += 1
				end
				if x ~= #MatrixMap[y] and y ~= 1 and MatrixMap[y-1][x+1] == 1 then --Check Up Right
					Neighbors += 1
				end
				if x ~= 1 and MatrixMap[y][x-1] == 1 then --Check Left
					Neighbors += 1
				end
				if x ~= #MatrixMap[y] and y ~= 1 and MatrixMap[y][x+1] == 1 then --Check Right
					Neighbors += 1
				end
				if x ~= 1 and y ~= #MatrixMap and MatrixMap[y+1][x-1] == 1 then --Check Down left
					Neighbors += 1
				end
				if y ~= #MatrixMap and MatrixMap[y+1][x] == 1 then --Check Down
					Neighbors += 1
				end
				if x ~= #MatrixMap[y] and y ~= #MatrixMap and MatrixMap[y+1][x+1] == 1 then --Check DOWNRIGHT
					Neighbors += 1
				end
				
				--Neighbors have been checked, now time to determine survival
				if Neighbors > 4 or Neighbors == 0 then
					table.insert(ValuesToChange, {0, Vector2.new(x, y)})
				else
					table.insert(ValuesToChange, {1, Vector2.new(x, y)})
				end
			end
		end
		for i = 1, #ValuesToChange do
			local V = ValuesToChange[i][1]
			local Pos:Vector2 = ValuesToChange[i][2]
			
			MatrixMap[Pos.Y][Pos.X] = V
		end 
		
		for i = 1, #MatrixMap do
			print(table.concat(MatrixMap[i]))
		end
	end
	
	return MatrixMap
end

function ConwaySim.RunSimulationWithRandom(Dimensions:Vector2, Iterations, Percentage)
	local MatrixMap = CreateArray(0, Dimensions)
	
	for i = 1, #MatrixMap do
		for j = 1, #MatrixMap[i] do
			if math.random() <= Percentage then
				MatrixMap[i][j] = 1
			end
		end
	end
	
	SimulateConwayGame(MatrixMap, Iterations)
	
	print("Done")
	
	return MatrixMap
end

function ConwaySim.RunSimulationWithMatrixMap(MatrixMap, Iterations)
	SimulateConwayGame(MatrixMap, Iterations)
	return MatrixMap
end
return ConwaySim