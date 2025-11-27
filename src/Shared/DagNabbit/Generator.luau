local Dag = script:FindFirstAncestor("DagNabbit")
local Blueprints = {}

for i, v in pairs(Dag.Blueprint:GetChildren()) do
	if not v:IsA("ModuleScript") then
		continue
	end
	Blueprints[v.Name] = require(v)
end

local Generator = {}

function Generator.Generate_Matrix(blueprint:string)
	if not blueprint or Blueprints[blueprint] == nil then
		blueprint = "Default"
	end
	
	local ReqBlue = Blueprints[blueprint]
end

function Generator.Generate_RectVal(blueprint:string)
	if not blueprint or Blueprints[blueprint] == nil then
		blueprint = "Default"
	end
	
	local ReqBlue = Blueprints[blueprint]
end

return Generator