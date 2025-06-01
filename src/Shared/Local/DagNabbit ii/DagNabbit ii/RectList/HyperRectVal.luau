local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HyperRect = require(ReplicatedStorage.Dependecies.HyperRect)
local CharSet = require(ReplicatedStorage["DagNabbit ii"]["DagNabbit ii"].CharSet)

local RectValue = {}
RectValue.__index = RectValue

function RectValue.new(...)
	local Args = {...}
	if typeof(Args[1]) == "Rect" then
		local RectVal:Rect = Args[1]
		
		Args = {RectVal.Min.X, RectVal.Min.Y, RectVal.Max.X, RectVal.Max.Y}
	end
	
	local self = setmetatable({}, RectValue)
	self.RectValue = HyperRect.new(Args)
	self.Dimensions = #Args / 2
	self.Value = nil
	return self
end

function RectValue:SetRect(...)
	local Args = {...}
	if typeof(Args[1]) == "Rect" then
		local RectVal:Rect = Args[1]

		Args = {RectVal.Min.X, RectVal.Min.Y, RectVal.Max.X, RectVal.Max.Y}
	end
	
	self.RectValue = HyperRect.new(Args)
end

function RectValue:SetValue(Val)
	self.Value = Val
end

function RectValue:GetMidpoint()
	local CurRect:Rect = self.RectValue
	local MidVector = (CurRect.Min + CurRect.Max) / 2
	
	return MidVector
end

--Only works in 2 Dimensions
function RectValue:Generate2D()
	assert(self.Dimensions == 2, "RectValue must be 2D")

	local blueprintFolder = ReplicatedStorage:FindFirstChild("Blueprint")
	assert(blueprintFolder, "Missing 'Blueprint' folder")

	local charKey = CharSet[self.Value]
	assert(charKey, "Invalid CharSet entry for value: " .. tostring(self.Value))

	local template = blueprintFolder:FindFirstChild(charKey)
	if not template then
		warn("No template for char: " .. tostring(charKey))
		return false
	end

	local sizeX, sizeZ = table.unpack(self.RectValue.Size.Value)
	local min = self.RectValue.Min:ToVector()
	local max = self.RectValue.Max:ToVector()
	local MAX_SIZE = 2048

	local partsCreated = {}

	for x = min.X, max.X - 1, MAX_SIZE do
		for y = min.Y, max.Y - 1, MAX_SIZE do
			local chunkWidth = math.min(MAX_SIZE, max.X - x)
			local chunkHeight = math.min(MAX_SIZE, max.Y - y)

			local part = template:Clone()
			part.Size = Vector3.new(chunkWidth, template.Size.Y, chunkHeight)

			local centerX = x + chunkWidth / 2
			local centerY = y + chunkHeight / 2
			part.Position = Vector3.new(centerX, template.Position.Y, centerY)

			table.insert(partsCreated, part)
		end
	end

	return partsCreated
end

return RectValue