local Data = {}

local HallwayChar = 1
local RoomChar = 1

local Attempts = 0

local Map
local SplitMap = {{'A'},{'B'}}

local function CreateArray(num, Dimensions:{Width:number, Height:number})
	local Array = {}
	
	if not Dimensions[2] then --Makes it a square if there isn't a Y value
		Dimensions[2] = Dimensions[1]
	end
	
	for i = 1, Dimensions[2], 1 do 
		table.insert(Array, {}) --Y
		for j = 1, Dimensions[1], 1 do
			table.insert(Array[i], num) --X
		end
	end

	wait()

	return Array
end

local function RandomNumber(min:number, max:number)
	return math.floor(math.random() * (max - min + 1) + min)
end

local function newRectangleContainer(x:number, y:number, w:number, h:number)
	return Rect.new(x, y, x + w, y + h)
end

local function CreateRooms(RoomMap:{}, Tree, chance)
	if not chance then
		chance = 1
	end
	wait()
	for i = 1, #Tree, 1 do
		local Leaf = Tree[i]
		local LeafID:string = Leaf[1]
		local LeafShape:Rect = Leaf[2]
		if math.abs(1 - (chance)) <= math.random() then --if chance is 1.00 then 0 is always < to math.random()
			local x = LeafShape.Min.X + RandomNumber(0, math.floor(LeafShape.Width / 3))
			local y = LeafShape.Min.Y + RandomNumber(0, math.floor(LeafShape.Height / 3))
			local width = LeafShape.Width - (x - LeafShape.Min.X)
			local height = LeafShape.Height - (y - LeafShape.Min.Y)
			width -= RandomNumber(0, width/3)
			height -= RandomNumber(0, height/3)
			
			table.insert(RoomMap, {Leaf[1], newRectangleContainer(x, y, width, height)})
		end
	end
end

local function CreateHallway(HallwayMap:{}, Leaf1:{Id:string, LeafShape:Rect}, Leaf2:{Id:string, LeafShape:Rect}, Dimensions:{Width:number, Height:number})
	wait()
	local Room1OriginX = Leaf1[2].Min.X + math.floor(Leaf1[2].Width/2)
	local Room1OriginY = Leaf1[2].Min.Y + math.floor(Leaf1[2].Height/2)
	local Room2OriginX = Leaf2[2].Min.X + math.floor(Leaf2[2].Width/2)
	local Room2OriginY = Leaf2[2].Min.Y + math.floor(Leaf2[2].Height/2)
	local Slope = math.abs((Room2OriginY - Room1OriginY) / (Room2OriginX - Room1OriginX))
	
	math.clamp(Room1OriginX, 1, Dimensions[1])
	math.clamp(Room1OriginY, 1, Dimensions[2])
	math.clamp(Room2OriginX, 1, Dimensions[1])
	math.clamp(Room2OriginY, 1, Dimensions[2])
	
	--[[there will be 2 rect values for hallways]]
	if Slope <= 1 then --Horizontal
		table.insert(HallwayMap,
			{Leaf1[1],
				Rect.new(
					Room1OriginX,
					Room1OriginY,
					Room2OriginX,
					Room1OriginY
				),
				Rect.new(
					Room2OriginX,
					Room1OriginY,
					Room2OriginX,
					Room2OriginY
				)
			}
		)
	elseif Slope > 1 then --Verticle
		table.insert(HallwayMap,
			{Leaf1[1],
				Rect.new(
					Room1OriginX,
					Room1OriginY,
					Room1OriginX,
					Room2OriginY
				), Rect.new(
					Room1OriginX,
					Room2OriginY,
					Room2OriginX,
					Room2OriginY
				)
			}
		)
	end
end

local function RandomSplitRect(RectangleContainer:Rect, DiscardByRatio:boolean, Ratios:{WidthRatio:number, HeightRatio:number})
	wait()
	if Attempts > 500 then
		return error("Too many attempts, try lowering the iterations or decrease the RatioAspect or increase map size")
	end
	
	local r1, r2
	if RandomNumber(0,1) == 0 then
		--Vertical split
		local Split = RandomNumber(1, RectangleContainer.Width)
		r1 = newRectangleContainer(
			RectangleContainer.Min.X,
			RectangleContainer.Min.Y,
			Split,
			RectangleContainer.Height
		)
		r2 = newRectangleContainer(
			RectangleContainer.Min.X + r1.Width,
			RectangleContainer.Min.Y,
			RectangleContainer.Width - r1.Width,
			RectangleContainer.Height
		)

		if DiscardByRatio == true then
			local r1WidthRatio = r1.Width / r1.Height
			local r2WidthRatio = r2.Width / r2.Height
			
			if r1WidthRatio < Ratios[1] or r2WidthRatio < Ratios[1] then
				print(Attempts)
				Attempts += 1
				wait()
				return RandomSplitRect(RectangleContainer)
			end
		end
	else
		--Horizontal split
		local Split = RandomNumber(1, RectangleContainer.Height)
		r1 = newRectangleContainer(
			RectangleContainer.Min.X,
			RectangleContainer.Min.Y,
			RectangleContainer.Width,
			RandomNumber(
				1,
				RectangleContainer.Height
			)
		)
		r2 = newRectangleContainer(
			RectangleContainer.Min.X,
			RectangleContainer.Min.Y + r1.Height,
			RectangleContainer.Width,
			RectangleContainer.Height - r1.Height
		)
		
		if DiscardByRatio == true then
			local r1HeightRatio = r1.Height / r1.Width
			local r2HeightRatio = r2.Height / r2.Width

			if r1HeightRatio < Ratios[2] or r2HeightRatio < Ratios[2] then
				Attempts += 1
				wait()
				return RandomSplitRect(RectangleContainer)
			end
		end
	end
	
	return r1, r2
end

function Data.BSPGenerateMap(Dimensions:{X:number, Y:number}, Iterations:number, RoomChance, DiscardByRatio:boolean, Ratios:{WidthRatio:number, HeightRatio:number})
	
	Attempts = 0
	
	--Filling missing values
	if not Dimensions then
		Dimensions = {50, 50}
	elseif not Dimensions[2] then --Make Dimensions a square if there isn't a Height
		Dimensions[2] = Dimensions[1]
	end
	
	if not Iterations then
		if Dimensions[1] <= Dimensions[2] then
			for i = 1, Dimensions[1] do
				if 2^i > Dimensions[1] then
					Iterations = (i - 1)
					break
				end
			end
		else
			for i = 1, Dimensions[2] do
				if 2^i > Dimensions[2] then
					Iterations = i - 1
					break
				end
			end
		end
	end
		
	if not DiscardByRatio then
		DiscardByRatio = false
	elseif DiscardByRatio == true and not Ratios then
		Ratios = {}
		Ratios[1] = 0.35
		Ratios[2] = 0.35
	elseif DiscardByRatio == true and Ratios[1] ~= nil and not Ratios[2] then
		Ratios[2] = Ratios[1]
	end
	
	if 2^Iterations > Dimensions[1] or 2^Iterations > Dimensions[2] then
		for i = 1, Iterations do
			if 2^i > Dimensions[1] or 2^i > Dimensions[2] then
				return error("Too many iterations, try ".. i - 1 ..".")
			end
		end
	end
	
	
	print("Splitting map ".. 2^Iterations.. " times." )
	wait()
	
	local Map = CreateArray('0', Dimensions)
	local RectMapTable = {}
	local LastRectMap = nil
	local RoomMap = {}
	local LastRoomMap = nil
	local HallwayMap = {}
	
	local RectMap = newRectangleContainer(1, 1, Dimensions[1] - 1, Dimensions[2] - 1)
	
	local r1, r2 = RandomSplitRect(RectMap, DiscardByRatio, Ratios)
	
	table.insert(RectMapTable, {"A", r1})
	table.insert(RectMapTable, {"B", r2})
	
	LastRectMap = RectMapTable

	for i = 1, Iterations - 1, 1 do --minus 1 because it has already been done once
		RectMapTable = {}
		for j = 1, #LastRectMap, 1 do			
			local r1, r2 = RandomSplitRect(LastRectMap[j][2], DiscardByRatio, Ratios)
			table.insert(
				RectMapTable,{
					LastRectMap[j][1].. '1',
					r1
				}
			)
			table.insert(
				RectMapTable,{
					LastRectMap[j][1].. '2',
					r2
				}
			)
		end
		LastRectMap = RectMapTable
	end
	print(RectMapTable)	

	print("Splitting done!")

	CreateRooms(RoomMap, RectMapTable, RoomChance)
	
	print("Room Creation Done!")
	print(RoomMap)
	
	LastRoomMap = table.clone(RoomMap)
	
	for i = 1, #LastRoomMap - 1 do
		local leaf1 = LastRoomMap[i]
		local leaf2 = LastRoomMap[i + 1]
		CreateHallway(HallwayMap, leaf1, leaf2, Dimensions)
	end
	
	print("Hallways created")

	wait()
	
	--Ready to convert to array
	--Start by placing Hallways
	for i = 1, #HallwayMap do
		wait()
		local Rect1:Rect = HallwayMap[i][2]
		local Rect2:Rect = HallwayMap[i][3]
		
		print(Rect1, Rect1.Width, Rect1.Height)
		print(Rect2, Rect2.Width, Rect2.Height)
		
		
		if Rect1.Width == 0 and Rect1.Height ~= 0 then --first hallway is vertical
			for dy = 0, Rect1.Height do
				Map[Rect1.Min.Y + dy][Rect1.Min.X] = HallwayChar
			end
		elseif Rect1.Height == 0 and Rect1.Width ~= 0 then --first hallway is horizontal
			for dx = 0, Rect1.Width do
				Map[Rect1.Min.Y][Rect1.Min.X + dx] = HallwayChar
			end
		elseif Rect1.Width == 0 and Rect1.Height == 0 then
			Map[Rect1.Min.Y][Rect1.Min.X] = HallwayChar
		end
		if Rect2.Width == 0 and Rect2.Height ~= 0 then --second hallway is vertical
			for dy = 0, Rect2.Height do
				Map[Rect2.Min.Y + dy][Rect2.Min.X] = HallwayChar
			end
		elseif Rect2.Height == 0 and Rect2.Width ~= 0 then --second hallway is horizontal
			for dx = 0, Rect2.Width do
				Map[Rect2.Min.Y][Rect2.Min.X + dx] = HallwayChar
			end	
		elseif Rect1.Width == 0 and Rect1.Height == 0 then
			Map[Rect1.Min.Y][Rect1.Min.X] = HallwayChar
		end
	end
	
	print("Hallways mapped")
	
	wait()
	
	for i = 1, #RoomMap do
		local Rect1:Rect = RoomMap[i][2]
		for dy = 0, Rect1.Height - 1 do
			for dx = 0, Rect1.Width - 1 do
				Map[Rect1.Min.Y + dy][Rect1.Min.X + dx] = RoomChar
			end
		end
	end
	
	print("BSP Generation Done!")
	
	return Map
end

return Data
