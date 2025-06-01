local RectValModule = require(script.HyperRectVal)

--RectList --> Reckless lol
local RectList = {}
RectList.__index = RectList

function RectList.new()
	local self = setmetatable({}, RectList)
	
	self.List = {}
	
	return self
end

function RectList:Insert(RectVal:Rect, val)
	
	local NewRect = RectValModule.new(RectVal)
	if val then
		NewRect:SetValue(val)
	end
	
	table.insert(self.List, NewRect)
end

function RectList:SetAll(val)
	for i = 1, #self.List do
		self.List[i]:SetValue(val)
	end
end

function RectList:Generate()
	local Model = Instance.new("Model")
	
	for i = 1, #self.List do
		local Parts = self.List[i]:Generate2D()
		
		for j = 1, #Parts do
			Parts[j].Parent = Model
		end
	end
	
	Model:PivotTo(CFrame.new(0, 100, 0) * Model:GetPivot().Rotation)
	Model.Parent = workspace.tmp
end

return RectList