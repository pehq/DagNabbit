local RectValMod = require(script.RectVal)

local RectList = {}
RectList.__index = RectList

function RectList.new()
	local self = setmetatable({}, RectList)
	
	self.List = {}
	self.Connectors = {}

	return self
end

function RectList:Insert(RectVal:Rect, val)
	local NewRect = RectValMod.new(RectVal, val)
	
	table.insert(self.List, NewRect)
end

function RectList:GenerateList()
	local Model = Instance.new("Model")

	for i, v in pairs(self.List) do
		local GenPart = v:Generate()
		GenPart.Name = tostring(i)
	end

	return Model
end

return RectList