--By Pehq
local RectModule = {}
RectModule.__index = RectModule

local function FindRects(Matrix, TargetValue:Vector2)
	local MinX, MinY = TargetValue.X, TargetValue.Y
	local MaxX, MaxY = TargetValue.X, TargetValue.Y
	
	--TODO: Make it work
	
	return
end

function RectModule.GetRectFromMatrix(Matrix)
	local MV = table.clone(Matrix)
	
	
	
end

function RectModule.NewRectMap(rectValues, Value:any)
	local RectMaps = {}
	setmetatable(RectMaps, RectModule)
	
	RectMaps.Rects = {}
	
	if rectValues ~= nil then
		for i, v in pairs(rectValues) do
			local rect = Rect.new(v.x, v.y, v.x + v.w, v.y + v.h)		
			table.insert(RectMaps.Rects, rect)
		end
	end
	
	RectMaps.Value = Value --Value associated with RectMaps
	
	return RectMaps
end

function RectModule:GetRectMidPoints()
	local MidPoints = table.clone(self.Rects)
	for i, v:Rect in pairs(MidPoints) do
		MidPoints[i] = (v.Min + v.Max) / 2
	end

	return MidPoints
end

function RectModule:Split(SizeLimit:Vector2)
	if SizeLimit == nil then SizeLimit = Vector2.new(2048, 2048) end
	local newRects = {}
	
	for i = 1, #self.Rects do
		local rect:Rect = self.Rects[i]
		local x, y, w, h = rect.Min.X, rect.Min.Y, rect.Width, rect.Height
		
		for j = x, x + w - 1, SizeLimit.X do
			for k = y, y + h - 1, SizeLimit.Y do
				local SubW = math.min(SizeLimit.X, (x + w) - j)
				local SubH = math.min(SizeLimit.Y, (y + h) - k)
				
				table.insert(newRects, Rect.new(Vector2.new(j, k), Vector2.new(j + SubW, k + SubH)))
			end
		end
	end
	
	self.Rects = newRects
	
	return self
end

function RectModule:GetRectsDimensions()
	local RectDims = Rect.new()
	
	--Have a big rectangle expand to keep every rect values within
	for i, v:Rect in pairs(self.Rects) do
		if RectDims.Min.X > v.Min.X then
			RectDims = Rect.new(Vector2.new(v.Min.X, RectDims.Min.Y), RectDims.Max)
		end
		if RectDims.Min.Y > v.Min.Y then
			RectDims = Rect.new(Vector2.new(RectDims.Min.X, v.Min.Y), RectDims.Max)
		end
		if RectDims.Max.X + RectDims.Width < v.Max.X + v.Width then
			RectDims = Rect.new(RectDims.Min, Vector2.new(v.Max.X + v.Width, RectDims.Max.Y))
		end
		if RectDims.Max.Y + RectDims.Height < v.Max.Y + v.Height then
			RectDims = Rect.new(RectDims.Min, Vector2.new(RectDims.Max.X, v.Max.Y + v.Height))
		end
	end
	
	local Dimensions = Vector2.new(RectDims.Width, RectDims.Height)
	
	return Dimensions
end

function RectModule:Scale(scale:Vector2)
	-- Scale the rects
	if scale.X ~= 1 or scale.Y ~= 1 then
		for i = 1, #self.Rects do
			local rect:Rect = self.Rects[i]
			self.Rects[i] = Rect.new(rect.Min * scale, rect.Max * scale)
		end
	end
	
	return self
end

function RectModule:CutIn(cuttingArea:Rect)
	local Midpoints = self:GetRectMidPoints()
	
	for i, v:Vector2 in pairs(Midpoints) do
		if v.X < cuttingArea.Min.X or v.Y < cuttingArea.Min.Y or
			v.X > cuttingArea.Max.X or v.Y > cuttingArea.Max.Y then
			self.Rects[i] = nil
		end
	end
	
	local NewRects = {}
	for i, v in pairs(self.Rects) do
		if v ~= nil then
			table.insert(NewRects, v)
		end
	end
	
	self.Rects = NewRects
	
	return self
end

function RectModule:CutOut(cuttingArea:Rect)
	local Midpoints = self:GetRectMidPoints()

	for i, v:Vector2 in pairs(Midpoints) do
		if v.X > cuttingArea.Min.X and v.Y > cuttingArea.Min.Y or
			v.X < cuttingArea.Max.X and v.Y < cuttingArea.Max.Y then
			self.Rects[i] = nil
		end
	end

	local NewRects = {}
	for i, v in pairs(self.Rects) do
		if v ~= nil then
			table.insert(NewRects, v)
		end
	end

	self.Rects = NewRects

	return self
end

function RectModule:Puncture(puncturingArea:Rect)
	--TODO: Instead of cutting out parts by the mid points, it'll modify the rect points
	
end

function RectModule:Shift(shift:Vector2)
	for i = 1, #self.Rects do
		local rect:Rect = self.Rects[i]
		self.Rects[i] = Rect.new(rect.Min.X - shift.X, rect.Min.Y - shift.Y, rect.Max.X - shift.X, rect.Max.Y - shift.Y)
	end
	
	return self
end

function RectModule:ToMatrix()
	if self.Value == nil then self.Value = true end
	
	local MatrixValue = {}
	
	--Draw every rect values onto the Matrix
	for i, v:Rect in pairs(self.Rects) do
		local x = v.Min.X
		local y = v.Min.Y
		local width = v.Width
		local height = v.Height
		
		for iy = y, y + height do
			if MatrixValue[iy] == nil then
				MatrixValue[iy] = {}
			end
			for ix = x, x + width do	
				MatrixValue[iy][ix] = self.Value
			end
		end
	end
	
	--Set missing table values to false for convenience for table functions
	for y = math.min(table.unpack(MatrixValue)), table.maxn(MatrixValue) do --Matrices could be infinitely samll to infinitely big
		for x = math.min(table.unpack(MatrixValue)), table.maxn(MatrixValue) do
			local v = MatrixValue[y][x]
			if v == nil then
				MatrixValue[y][x] = false
			end
		end
	end
	
	return MatrixValue
end

function RectModule:__add(other:Instance)
	local function CombineTables(table1, table2)
		for i, v in pairs(table2) do
			table.insert(table1, v)
		end
	end
	
	if typeof(other) == "Rect" then
		table.insert(self.Rects)
		return self
	end
	if typeof(other) == "table" and other.Rects ~= nil then
		CombineTables(self.Rects, other.Rects)
		return self
	end
	if typeof(other) == "table" and typeof(other[1]) == "Rect" then
		CombineTables(self.Rects, other)
		return self
	end
	if typeof(other) == "table" and #other == 0 then
		return self
	end
	
	error("Not recognized value")
end

function RectModule:__len()
	return #self.Rects
end

function RectModule:Generate(pos:Vector3)
	if not pos then pos = Vector3.zero end --The offset
	
	-- Calculate the bounds of the map
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge

	for i = 1, #self.Rects do
		local rect:Rect = self.Rects[i]
		minX = math.min(minX, rect.Min.X)
		minY = math.min(minY, rect.Min.Y)
		maxX = math.max(maxX, rect.Min.X + rect.Width)
		maxY = math.max(maxY, rect.Min.Y + rect.Height)
	end

	-- Calculate the center of the map 
	local centerX = (minX + maxX) / 2 + pos.X
	local centerY = (minY + maxY) / 2 + pos.Z

	-- Define the size limit
	local SIZE_LIMIT = 2048

	-- Function to create and place a part
	local function CreatePart(x, y, w, h)
		local Part = Instance.new("Part")
		Part.Size = Vector3.new(w, 1, h)
		Part.Position = Vector3.new(x + w / 2 - centerX, pos.Y, y + h / 2 - centerY)
		Part.Anchored = true
		Part.Parent = workspace.Folder
	end

	for i = 1, #self.Rects do
		local rect:Rect = self.Rects[i]
		local x = rect.Min.X
		local y = rect.Min.Y
		local w = rect.Width
		local h = rect.Height

		-- Check if the part exceeds the size limit
		if w > SIZE_LIMIT or h > SIZE_LIMIT then
			-- Split the rect into smaller parts
			local splitWidth = math.min(w, SIZE_LIMIT)
			local splitHeight = math.min(h, SIZE_LIMIT)
			local numX = math.ceil(w / SIZE_LIMIT)
			local numY = math.ceil(h / SIZE_LIMIT)

			for xi = 0, numX - 1 do
				for yi = 0, numY - 1 do
					local partWidth = (xi == numX - 1) and (w - xi * SIZE_LIMIT) or splitWidth
					local partHeight = (yi == numY - 1) and (h - yi * SIZE_LIMIT) or splitHeight
					local partX = x + xi * SIZE_LIMIT
					local partY = y + yi * SIZE_LIMIT

					CreatePart(partX, partY, partWidth, partHeight)
				end
			end
		else
			-- Create the part normally
			CreatePart(x, y, w, h)
		end
	end
end

return RectModule
