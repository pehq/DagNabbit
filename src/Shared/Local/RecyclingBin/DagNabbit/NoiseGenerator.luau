local Noise = {}

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


function Noise.newPerlinMatrix(Dimensions:Vector2, Seed, BlackValue, WhiteValue, Frequency, Power)
	if not Seed then
		Seed = math.randomseed(1, 10e6)
	end
	if not BlackValue then
		BlackValue = 1
	end
	if not WhiteValue then
		WhiteValue = 0
	end
	if not Frequency then
		Frequency = 1
	end
	if not Power then
		
	end
	
	local MatrixMap = CreateArray(WhiteValue, Dimensions)
	
	for y = 1, MatrixMap do
		for x = 1, MatrixMap[y] do
			if math.round(math.noise(x, y, Seed)) > 0.5 then
			end
			
			
			--MatrixMap[y][x] = 
		end
	end
	
	return 
end

return Noise
