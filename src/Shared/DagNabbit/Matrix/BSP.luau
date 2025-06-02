--!nonstrict
-- BSP Map Generator (Cleaned Up)

local Data = {}

local HallwayChar = true
local RoomChar = true
local Attempts = 0

local function newRectangleContainer(x, y, w, h)
	return Rect.new(x, y, x + w, y + h)
end

local function HighestIteration(Dims:Vector2)
	local i = 1

	local SplitSize = nil
	repeat
		i += 1
		SplitSize = 2 ^ i
	until SplitSize >= Dims.X or SplitSize >= Dims.Y

	return i - 1
end

local function DrawRectOnMap(map, rect, value)
	if rect.Width == 0 and rect.Height ~= 0 then
		for y = 0, rect.Height do
			map[rect.Min.Y + y][rect.Min.X] = value
		end
	elseif rect.Height == 0 and rect.Width ~= 0 then
		for x = 0, rect.Width do
			map[rect.Min.Y][rect.Min.X + x] = value
		end
	elseif rect.Width == 0 and rect.Height == 0 then
		map[rect.Min.Y][rect.Min.X] = value
	end
end

local function CreateRooms(roomMap, tree, chance)
	chance = chance or 1
	for _, leaf in ipairs(tree) do
		local id, shape = leaf[1], leaf[2]
		if math.random() <= chance then
			local x = shape.Min.X + math.random(0, math.floor(shape.Width / 3))
			local y = shape.Min.Y + math.random(0, math.floor(shape.Height / 3))
			local w = shape.Width - (x - shape.Min.X) - math.random(0, (shape.Width - (x - shape.Min.X)) / 3)
			local h = shape.Height - (y - shape.Min.Y) - math.random(0, (shape.Height - (y - shape.Min.Y)) / 3)
			table.insert(roomMap, {id, newRectangleContainer(x, y, w, h)})
		end
	end
end

local function CreateHallway(hallwayMap, leafA, leafB, Dimensions:Vector2)
	local function clamp(x, y)
		return math.clamp(x, 1, Dimensions.X), math.clamp(y, 1, Dimensions.Y)
	end

	local ax, ay = clamp(
		leafA[2].Min.X + math.floor(leafA[2].Width / 2),
		leafA[2].Min.Y + math.floor(leafA[2].Height / 2)
	)
	local bx, by = clamp(
		leafB[2].Min.X + math.floor(leafB[2].Width / 2),
		leafB[2].Min.Y + math.floor(leafB[2].Height / 2)
	)

	local horizFirst = math.abs(by - ay) <= math.abs(bx - ax)
	local hall1, hall2
	if horizFirst then
		hall1 = Rect.new(ax, ay, bx, ay)
		hall2 = Rect.new(bx, ay, bx, by)
	else
		hall1 = Rect.new(ax, ay, ax, by)
		hall2 = Rect.new(ax, by, bx, by)
	end
	table.insert(hallwayMap, {leafA[1], hall1, hall2})
end

local function RandomSplitRect(container, discardByRatio, ratios)
	Attempts += 1
	if Attempts > 10000 then error("Too many attempts") end

	local r1, r2
	if math.random(0, 1) == 0 then
		local split = math.random(1, container.Width)
		r1 = newRectangleContainer(container.Min.X, container.Min.Y, split, container.Height)
		r2 = newRectangleContainer(container.Min.X + split, container.Min.Y, container.Width - split, container.Height)
	else
		local split = math.random(1, container.Height)
		r1 = newRectangleContainer(container.Min.X, container.Min.Y, container.Width, split)
		r2 = newRectangleContainer(container.Min.X, container.Min.Y + split, container.Width, container.Height - split)
	end

	if discardByRatio then
		local function isInvalid(rect, wr, hr)
			return (rect.Width / rect.Height < wr) or (rect.Height / rect.Width < hr)
		end
		if isInvalid(r1, ratios[1], ratios[2]) or isInvalid(r2, ratios[1], ratios[2]) then
			return RandomSplitRect(container, discardByRatio, ratios)
		end
	end

	return r1, r2
end

function Data.BSPGenerateMap(self, Iterations, RoomChance, DiscardByRatio, Ratios)
	Attempts = 0

	if not Iterations then
		Iterations = HighestIteration(self.Dimensions)
	end

	DiscardByRatio = DiscardByRatio or false
	Ratios = Ratios or {0.35, 0.35}
	Ratios[2] = Ratios[2] or Ratios[1]

	local tree, roomMap, hallwayMap = {}, {}, {}

	local base = newRectangleContainer(1, 1, self.Dimensions.X - 1, self.Dimensions.Y - 1)
	local r1, r2 = RandomSplitRect(base, DiscardByRatio, Ratios)
	tree = {{"A", r1}, {"B", r2}}

	for i = 2, Iterations do
		local nextGen = {}
		for _, node in ipairs(tree) do
			local a, b = RandomSplitRect(node[2], DiscardByRatio, Ratios)
			table.insert(nextGen, {node[1].."1", a})
			table.insert(nextGen, {node[1].."2", b})
		end
		tree = nextGen
	end

	CreateRooms(roomMap, tree, RoomChance)
	for i = 1, #roomMap - 1 do
		CreateHallway(hallwayMap, roomMap[i], roomMap[i + 1], self.Dimensions)
	end

	for _, hall in ipairs(hallwayMap) do
		DrawRectOnMap(self.Value, hall[2], HallwayChar)
		DrawRectOnMap(self.Value, hall[3], HallwayChar)
	end
	for _, room in ipairs(roomMap) do
		local rect = room[2]
		for y = 0, rect.Height - 1 do
			for x = 0, rect.Width - 1 do
				self.Value[rect.Min.Y + y][rect.Min.X + x] = RoomChar
			end
		end
	end
	
	--Connectors
	local StartingRect:Rect = roomMap[1][2]
	local EndingRect:Rect = roomMap[#roomMap][2]
	
	table.insert(self.Connectors, {
		Vector2.new(
			StartingRect.Min.X + math.floor(StartingRect.Width / 2),
			StartingRect.Min.Y + math.floor(StartingRect.Height/ 2)
		),
		Vector2.new(
			EndingRect.Min.X + math.floor(EndingRect.Width / 2),
			EndingRect.Min.Y + math.floor(EndingRect.Height/ 2)
		)
	})
	
	return self
end

return Data