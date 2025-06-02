--This module allows values to be assigned to rects
local CharSet = require(script.Parent.Parent.Data.CharSet)

local RectVal = {}
RectVal.__index =  RectVal

function RectVal.new(rect:Rect, val:any)
    local self = setmetatable({}, RectVal)

    self.Rect = rect
	self.Value = val
	self.Scale = Vector2.one * 5

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

function RectVal:Generate(BlueprintSelected:Folder)
    if not BlueprintSelected then
		BlueprintSelected = script.Parent.Parent.Blueprint.Default
	end
	
	local MidPoint = self:GetMidpoint()
	
    local GeneratedPart:BasePart = nil
	if CharSet.CharValues[self.Value] == "Wall" then
        GeneratedPart = BlueprintSelected.Wall:Clone()
		GeneratedPart.Size = Vector3.new((self.Rect.Width + 1) * self.Scale.X, 16, (self.Rect.Height + 1) * self.Scale.Y)
		GeneratedPart.CFrame = CFrame.new(MidPoint.X * self.Scale.X, GeneratedPart.Size.Y/2, MidPoint.Y * self.Scale.Y)
	elseif CharSet.CharValues[self.Value] == "Floor" then
        GeneratedPart = BlueprintSelected.Floor:Clone()
        GeneratedPart.Size = Vector3.new((self.Rect.Width + 1) * self.Scale.X, 2, (self.Rect.Height + 1) * self.Scale.Y)
        GeneratedPart.CFrame = CFrame.new(MidPoint.X * self.Scale.X, -GeneratedPart.Size.Y/2, MidPoint.Y * self.Scale.Y)
    end

    return GeneratedPart
end

return RectVal