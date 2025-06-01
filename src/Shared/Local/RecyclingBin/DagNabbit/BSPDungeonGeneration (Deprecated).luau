local Data = {}

local function CreateArray(num, DimensionsX, DimensionsY)
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

function Data.GenerateDungeonOld(Dimensions:{DimensionX:number, DimensionsY:number}, Iterations:number)
	local Map = CreateArray(0, Dimensions[1], Dimensions[2])
	local SplitsMap = {}
	local LastSplitsMap
	
	--
	if Dimensions[1] < 5 or Dimensions[2] < 5 then
		warn("You pain me")
	end
	
	
	--Determines splitting Direction
	local Direction
	local function RandomDir()
		if math.random(1,2) == 1 then
			Direction = "Horizontal"
		else
			Direction = "Vertical"
		end
		return Direction
	end
	
	local function SplitSquares()	
		local Split
		for i = 1, Iterations, 1 do	--for every tree branch 
			if i == 1 then
				RandomDir()
				if Direction == "Horizontal" then
					Split = math.clamp(math.random(1, #Map) - 0.5, math.ceil(Iterations - i + 1) + 0.5, math.floor(#Map - (Iterations - i + 1)) + 0.5) --Err
					table.insert(SplitsMap, {'A', 1, 1, #Map[1], math.floor(Split)})
					table.insert(SplitsMap, {'B', 1, math.ceil(Split), #Map[1], #Map})
				elseif Direction == "Vertical" then
					Split = math.clamp(math.random(1, #Map[1]) - 0.5, math.ceil(Iterations - i + 1) + 0.5, math.floor(#Map[1] - (Iterations - i + 1)) + 0.5) --Err
					table.insert(SplitsMap, {'A', 1, 1, math.floor(Split), #Map})
					table.insert(SplitsMap, {'B', math.ceil(Split), 1, #Map[1], #Map})
				end
				LastSplitsMap = SplitsMap
			elseif i > 1 then
				SplitsMap = {}
				print(LastSplitsMap)
				for j = 1, #LastSplitsMap, 1 do --for every sections per branch
					RandomDir()
					print(LastSplitsMap[j][3], LastSplitsMap[j][5], LastSplitsMap[j])
					if Direction == "Horizontal" then
						Split = math.clamp(math.random(LastSplitsMap[j][3], LastSplitsMap[j][5]) - 0.5, math.ceil(Iterations - i + 1) + 0.5, math.floor(LastSplitsMap[j][5] - (Iterations - i + 1)) + 0.5)
						table.insert(SplitsMap, {LastSplitsMap[j][1].. tostring(j).. 'A', LastSplitsMap[j][2], LastSplitsMap[j][3], LastSplitsMap[j][4], math.floor(Split)})
						table.insert(SplitsMap, {LastSplitsMap[j][1].. tostring(j).. 'B', LastSplitsMap[j][2], math.ceil(Split), LastSplitsMap[j][4], LastSplitsMap[j][5]})
					elseif Direction == "Vertical" then
						Split = math.clamp(math.random(LastSplitsMap[j][2], LastSplitsMap[j][4]) - 0.5, math.ceil((Iterations - i + 1)) + 0.5, math.floor(LastSplitsMap[j][4] - (Iterations - i + 1)) + 0.5)
						table.insert(SplitsMap, {LastSplitsMap[j][1].. tostring(j).. 'A', LastSplitsMap[j][2], LastSplitsMap[j][3], math.floor(Split), LastSplitsMap[j][5]})
						table.insert(SplitsMap, {LastSplitsMap[j][1].. tostring(j).. 'B', math.ceil(Split), LastSplitsMap[j][3], LastSplitsMap[j][4], LastSplitsMap[j][5]})
					end
					print(Split)
				end
				LastSplitsMap = SplitsMap
			end
		end
	end
	--print(LastSplitsMap)
	--print(SplitsMap)
	--First Split
	local Split
	local Success, Response = pcall(SplitSquares)
	if not Success then
		SplitSquares()
	end 
	
	SplitSquares()
	print(SplitsMap)
	
	
	--for i = 1, #Map do
	--	print(table.concat(Map[i]))
	--end
end

return Data
