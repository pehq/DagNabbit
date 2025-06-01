local Maker = {}
Maker.__index = Maker

local function FindMidPointOfRect(rect:{{["h"]:number, ["w"]:number, ["x"]:number, ["y"]:number}})
	return {
		x = rect.x + (rect.w / 2),
		y = rect.y + (rect.h / 2)
	}
end

function Maker.NewMatrixMap(dimensions:Vector2, tilesize:Vector2)
	local MatrixMap = {}
	setmetatable(MatrixMap, Maker)
	
	MatrixMap.Value = {}
	
	for y = 1, dimensions.Y do
		MatrixMap.Value[y] = {}
		for x = 1, dimensions.X do
			MatrixMap.Value[y][x] = "_"
		end
	end
	
	MatrixMap.TileSize = tilesize ~= nil and Vector2.new(math.min(tilesize.X, 2048), math.min(tilesize.Y, 2048)) or Vector2.one
	MatrixMap.Dimensions = dimensions
	
	return MatrixMap
end

function Maker:PrintMap()
	for i, v in pairs(self.Value) do
		print(table.concat(v))
	end
	
	return self
end

function Maker.GenerateMapFromDimensions(Dimensions: Vector2)
	if not Dimensions then Dimensions = Vector2.one end

	local BigPartsToGenerate = Vector2.new(math.floor(Dimensions.X / 2048), math.floor(Dimensions.Y / 2048))
	local PartsLeftToGenerate = Vector2.new(Dimensions.X % 2048, Dimensions.Y % 2048)

	local totalWidth = BigPartsToGenerate.X * 2048 + (PartsLeftToGenerate.X > 0 and PartsLeftToGenerate.X or 0)
	local totalHeight = BigPartsToGenerate.Y * 2048 + (PartsLeftToGenerate.Y > 0 and PartsLeftToGenerate.Y or 0)

	local offsetX = totalWidth / 2
	local offsetY = totalHeight / 2

	local totalParts = (BigPartsToGenerate.X * BigPartsToGenerate.Y) + 
		(BigPartsToGenerate.X * (PartsLeftToGenerate.Y > 0 and 1 or 0)) + 
		(BigPartsToGenerate.Y * (PartsLeftToGenerate.X > 0 and 1 or 0)) + 
		((PartsLeftToGenerate.X > 0 and PartsLeftToGenerate.Y > 0) and 1 or 0)

	for i = 1, totalParts do
		if i % 100 == 0 then
			print(i, totalParts)
			task.wait()
		end
		local x, y

		if i <= BigPartsToGenerate.X * BigPartsToGenerate.Y then
			x = (i - 1) % BigPartsToGenerate.X + 1
			y = math.floor((i - 1) / BigPartsToGenerate.X) + 1
		else
			local remainingIndex = i - BigPartsToGenerate.X * BigPartsToGenerate.Y

			if remainingIndex <= BigPartsToGenerate.X then
				x = remainingIndex
				y = BigPartsToGenerate.Y + 1
			else
				x = BigPartsToGenerate.X + 1
				y = remainingIndex - BigPartsToGenerate.X
			end
		end

		local xColorOdd = x % 2 == 1
		local yColorOdd = y % 2 == 1

		local xSize = (x <= BigPartsToGenerate.X) and 2048 or PartsLeftToGenerate.X
		local ySize = (y <= BigPartsToGenerate.Y) and 2048 or PartsLeftToGenerate.Y
		local xPos = (x - 1) * 2048 + xSize / 2 - offsetX
		local yPos = (y - 1) * 2048 + ySize / 2 - offsetY

		local color = Color3.new(1, 1, 1)
		if xColorOdd ~= yColorOdd then
			color = Color3.new(0, 0, 0)
		end

		local Part = Instance.new("Part")
		Part.Anchored = true
		Part.Size = Vector3.new(xSize, 1, ySize)
		Part.Position = Vector3.new(xPos, 0.5, yPos)
		Part.Color = color
		Part.Parent = workspace.Folder
	end

	return
end

function Maker:GenerateMapFromMatrix()
	
	return self
end

function Maker.CreateMatrixFromRectMap(RectMap:{{["h"]:number, ["w"]:number, ["x"]:number, ["y"]:number}})
	--get dimensions
	local highestX = 0
	local highestY = 0
	
	for i = 1, #RectMap do
		local rect = RectMap[i]
		highestX = math.max(highestX, rect.x + rect.w)
		highestY = math.max(highestY, rect.y + rect.h)
	end
	
	local Matrix = Maker.NewMatrixMap(Vector2.new(highestX, highestY))
	for i = 1, #RectMap do
		local rect = RectMap[i]
		for y = rect.y, rect.y + rect.h - 1 do
			for x = rect.x, rect.x + rect.w - 1 do
				Matrix.Value[y][x] = "#"
			end
		end
	end
	
	return Matrix
end

function Maker:FlipMatrixHorizontally()
	--Flips the matrix 
	for i = 1, #self.Value do
		local row = self.Value[i]
		local numCols = #row
		for j = 1, numCols / 2 do
			row[j], row[numCols - j + 1] = row[numCols - j + 1], row[j]
		end
	end
	
	return self
end

function Maker:FlipMatrixVertically()
	local numRows = #self.Value
    for i = 1, numRows / 2 do
        self.Value[i], self.Value[numRows - i + 1] = self.Value[numRows - i + 1], self.Value[i]
	end
	return self
end

function Maker:RotateMatrix90Clockwise()
	local numRows = #self.Value
	local numCols = #self.Value[1]
	local result = {}

	for i = 1, numCols do
		result[i] = {}
		for j = 1, numRows do
			result[i][j] = self.Value[numRows - j + 1][i]
		end
	end
	
	self.Value = result
	
	return self
end

function Maker:Rotate180Clockwise()
	local rotated90 = Maker.RotateMatrix90Clockwise(self)
	self.Value = Maker.RotateMatrix90Clockwise(rotated90)
	return self
end

function Maker:Rotate270Clockwise()
	local rotated90 = Maker.RotateMatrix90Clockwise(self)
	local rotated180 = Maker.RotateMatrix90Clockwise(rotated90)
	self.Value = Maker.RotateMatrix90Clockwise(rotated180)
	return self
end

--rects
function Maker.GenerateFromRect(RectMap:{{["h"]:number, ["w"]:number, ["x"]:number, ["y"]:number}}, TilesizeMultiplier:Vector2)
	if not TilesizeMultiplier then
		TilesizeMultiplier = Vector2.one
	end

	-- Scale the rects
	if TilesizeMultiplier.X ~= 1 or TilesizeMultiplier.Y ~= 1 then
		for i = 1, #RectMap do
			local rect = RectMap[i]
			rect.x = rect.x * TilesizeMultiplier.X
			rect.y = rect.y * TilesizeMultiplier.Y
			rect.w = rect.w * TilesizeMultiplier.X
			rect.h = rect.h * TilesizeMultiplier.Y
		end
	end

	-- Calculate the bounds of the map
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge

	for i = 1, #RectMap do
		local rect = RectMap[i]
		minX = math.min(minX, rect.x)
		minY = math.min(minY, rect.y)
		maxX = math.max(maxX, rect.x + rect.w)
		maxY = math.max(maxY, rect.y + rect.h)
	end

	-- Calculate the center of the map
	local centerX = (minX + maxX) / 2
	local centerY = (minY + maxY) / 2

	-- Define the size limit
	local SIZE_LIMIT = 2048

	-- Function to create and place a part
	local function CreatePart(x, y, w, h)
		local Part = Instance.new("Part")
		Part.Size = Vector3.new(w, 1, h)
		Part.Position = Vector3.new(x + w / 2 - centerX, 0, y + h / 2 - centerY)
		Part.Anchored = true
		Part.Parent = workspace.Folder
	end

	for i = 1, #RectMap do
		local rect = RectMap[i]
		local x = rect.x
		local y = rect.y
		local w = rect.w
		local h = rect.h

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

return Maker