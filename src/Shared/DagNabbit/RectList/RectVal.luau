--This module allows values to be assigned to rects
local Dag = script:FindFirstAncestor("DagNabbit")

local CharSet = require(Dag.Data.CharSet)


local RectVal = {}
RectVal.__index =  RectVal

function RectVal.new(rect:Rect, val:any)
    local self = setmetatable({}, RectVal)

    self.Rect = rect
	self.Value = val

    return self
end

--These two modules are mega useless...
function RectVal:SetRect(rect)
    self.Rect = rect
end

function RectVal:SetValue(val)
    self.Value = val
end

function RectVal:GetMidpoint()
    local Mid = Vector2.new(self.Rect.Min.X + self.Rect.Width/2, self.Rect.Min.Y + self.Rect.Height/2)
    return Mid
end

function RectVal:Generate(BlueprintSelected)
    if not BlueprintSelected then
		BlueprintSelected = Dag.Blueprint.Default
	end
	
	
	print(self)
	
	local Blueprint = require(BlueprintSelected)
	local GeneratedPart:BasePart = Blueprint.GenerateRectVal(self)
	

    return GeneratedPart
end

return RectVal