local Generator = {}
--[[
local Map = {
	{0,0,0,0,0},
	{0,0,0,0,0},
	{0,0,0,0,0},
	{0,0,0,0,0},
	{0,0,0,0,0},
}

Zeroes are it's there, Ones are it's not there

]]

--[[
	CODES:
	0 = air
	1 = Floor
	2 = Block
	
	S = Start
	E = End

]]

function CreateArray(num, DimensionsX, DimensionsY)
	local Array = {}

	if not DimensionsY then --Makes it a square if there isn't a Y value
		DimensionsY = DimensionsX
	end

	for i = 1, DimensionsY, 1 do 
		table.insert(Array, {}) --Y
		for j = 1, DimensionsX, 1 do
			table.insert(Array[i], num) --X
		end
	end

	return Array
end

function Generator.MazeGenerator(Dimensions, maxTunnels, maxLength)
	local Map = CreateArray(0, Dimensions)
	
	print(Dimensions, maxTunnels, maxLength)
	
	--Picks Starting Position
	local CurrentRow = math.floor(math.random() * Dimensions)
	local CurrentColumn = math.floor(math.random() * Dimensions)
	
	local Directions = {
		{-1, 0}, -- Up
		{1, 0}, -- Down
		{0, -1}, -- Right
		{0, 1}, --Left
	}
	
	local RandomDirection = {}
	local lastDirection = nil
	
	--Sets Starting Position
	Map[CurrentRow][CurrentColumn] = 'S'
	
	while maxTunnels ~= 0 and Dimensions and maxLength do
		print(maxTunnels)
		
		--Look at direction
		if lastDirection == nil then --if no direction then make one
			RandomDirection = Directions[math.random(1, #Directions)]
		else --other wise take old direction, and look left or right
			local CoinFlip = math.random(1, 2) -- 1 = positive, 2 = negative
			RandomDirection = {math.abs(lastDirection[2]),math.abs(lastDirection[1])}
			if CoinFlip == 1 then
				--do nothing lol
			elseif CoinFlip == 2 then
				--reverse values
				RandomDirection[1] *= -1
				RandomDirection[2] *= -1					
			end
		end	
		
		--until not lastDirection or RandomDirection[1] == -(lastDirection[1]) and RandomDirection[2] == -(lastDirection[2]) or RandomDirection[1] == lastDirection[1] and RandomDirection[2] == lastDirection[2]
		
		local RandomLength = math.ceil(math.random()*maxLength)
		local tunnelLength = 0
		
		while tunnelLength < RandomLength do
			if CurrentRow == 1 and RandomDirection[1] ==  -1 or CurrentColumn == 1 and RandomDirection[2] == -1 or CurrentRow == Dimensions - 1 and RandomDirection[1] == 1 or CurrentColumn == Dimensions - 1 and RandomDirection[2] == 1 then
				break
			else
				if Map[CurrentRow][CurrentColumn] == 0 then
					Map[CurrentRow][CurrentColumn] = 1
				end
				CurrentRow += RandomDirection[1]
				CurrentColumn += RandomDirection[2]
				tunnelLength += 1
			end
		end
		
		if tunnelLength >= 1 then
			lastDirection = RandomDirection
			maxTunnels += -1
		end
	end
	
	--Sets End Position
	Map[CurrentRow][CurrentColumn] = 'E'
	
	return Map
end

return Generator


--local Module = require(game.ReplicatedStorage.Modules.DungeonGenerator) Module.GenerateMap(Module.MazeGenerator(70, 300, 4))