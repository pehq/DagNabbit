local Dag = script:FindFirstAncestor("DagNabbit")
local CharSet = require(Dag.Data.CharSet)

local Blueprint = {}

local Segments = {}
for i, v in pairs(Dag.Segments:GetChildren()) do
	if v:IsA("ModuleScript") then
		Segments[v.Name] = require(v)
	end
end

local DefaultParts = Dag.Models.Default

function Blueprint.Wall(Pos:Vector2, Scale:Vector2)
	local Part = DefaultParts.Floor:Clone()

	Part.Size = Vector3.new(Scale.X, 2, Scale.Y)
	Part.CFrame = CFrame.new(Pos.X, -Part.Size.Y / 2, Pos.Y)
	Part.Name = `{Pos.X} {Pos.Y}`

	return Part
end

function Blueprint.Floor(Pos, Scale)
	local Part = DefaultParts.Wall:Clone()

	Part.Size = Vector3.new(Scale.X, 16, Scale.Y)
	Part.CFrame = CFrame.new(Pos.X, Part.Size.Y / 2, Pos.Y)
	Part.Name = `{Pos.X} {Pos.Y}`

	return Part
end

local GenFuncs = {
	Wall = Blueprint.Floor,
	Floor = Blueprint.Wall,
}

function Blueprint.GenerateMatrix(self)
	local Model = Instance.new("Model")
	Model.Name = "GeneratedMatrix"
	
	for y = 1, #self.Value do
		for x = 1, #self.Value[y] do
			local Val = self.Value[y][x]
			local CharVal = CharSet.CharValues[Val]
			if not CharVal then
				continue
			end
			
			local pos = Vector2.new(x, y)
			local scale = self.GridScale
			
			local ReturnedObj = nil
			
			if GenFuncs[CharVal] == nil and Segments[CharVal] ~= nil then
				ReturnedObj = Segments[CharVal](pos, scale)
			elseif GenFuncs[CharVal] ~= nil then
				ReturnedObj = GenFuncs[CharVal](pos, scale)
			else
				continue
			end
			
			ReturnedObj.Parent = Model
		end
	end
	
	return Model
end

function Blueprint.GenerateRectVal(self:{Rect:Rect, Value:any?}) --TODO: issue with positioning parts
	local Val = self.Value
	local CharVal = CharSet.CharValues[Val]
	
	if not CharVal then
		return
	end
	
	local pos = self:GetMidpoint()
	local scale = Vector2.new(self.Rect.Width, self.Rect.Height)
	
	local Part = nil
	
	if GenFuncs[CharVal] == nil and Segments[CharVal] ~= nil then
		Part = Segments[CharVal](pos, scale)
	elseif GenFuncs[CharVal] ~= nil then
		Part = GenFuncs[CharVal](pos, scale)
	end
	
	return Part
end

return Blueprint