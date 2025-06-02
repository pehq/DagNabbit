--This module allows values to be assigned to rects
local CharSet = require(script.Parent.Parent.Data.CharSet)

local RectVal = {}

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
    local Mid = Vector2.new(self.Rect.Min + self.Rect.Max) / 2
    return Mid
end

function RectVal:Generate(BlueprintSelected:Folder)
    if not BlueprintSelected then
		BlueprintSelected = script.Parent.Blueprint.Default
	end

    local MidPoint = self:GetMidpoint()
    local GeneratedPart:BasePart = nil
    if self.Value == "Wall" then
        GeneratedPart = BlueprintSelected.Wall:Clone()
        GeneratedPart.Size = Vector3.new(self.Rect.Width, 16, self.Rect.Height)
        GeneratedPart.CFrame = CFrame.new(MidPoint.X, GeneratedPart.Size.Y/2, MidPoint.Y)
    elseif self.Value == "Floor" then
        GeneratedPart = BlueprintSelected.Floor:Clone()
        GeneratedPart.Size = Vector3.new(self.Rect.Width, 2, self.Rect.Height)
        GeneratedPart.CFrame = CFrame.new(MidPoint.X, -GeneratedPart.Size.Y/2, MidPoint.Y)
    end

    return GeneratedPart
end

return RectVal