--Taken from DataBrain's woodgrain plugin
--some modifications done by PehqDev
--This module is useful for correcting woodgrain on parts that will be generated.
local WoodGrain = {}

local function SearchWoodenParts(search, tab)
	tab = tab or {}
	for _,v in pairs(search) do
		if (v:IsA("Part") or v:IsA("SpawnLocation")) and (v.Material == Enum.Material.Wood or v.Material == Enum.Material.WoodPlanks) and v.Shape == Enum.PartType.Block then
			local doadd = true
			for _,v2 in pairs(v:GetChildren()) do
				if v2:IsA("CylinderMesh") or v2:IsA("FileMesh") then
					doadd = false
					break
				end
			end
			if doadd then
				table.insert(tab, v)
			end
		else
			tab = SearchWoodenParts(v:GetChildren(), tab)
		end
	end
	return tab
end

local function RotateMeshes(part, RotCF)
	for _,v in pairs(part:GetChildren()) do
		if v:IsA("BlockMesh") then
			v.Offset = RotCF:vectorToObjectSpace(v.Offset)
			v.Scale = RotCF:vectorToWorldSpace(v.Scale)
		end
	end
end

local function fixGrainDirection(part, threshold)
	local affected = false
	local sizeLow = math.min(part.Size.X, part.Size.Y, part.Size.Z)
	local sizeHigh = math.max(part.Size.X, part.Size.Y, part.Size.Z)
	if sizeHigh == part.Size.X then
		local sizeLow = math.min(part.Size.Y, part.Size.Z)
		local sizeHigh = math.max(part.Size.Y, part.Size.Z)
		if sizeHigh == part.Size.Y then return affected end
		if threshold > sizeLow / sizeHigh then
			local newCF = part.CFrame * CFrame.Angles(math.rad(90), 0, 0)
			RotateMeshes(part, CFrame.Angles(math.rad(90), 0, 0))
			part.Size = Vector3.new(part.Size.X, part.Size.Z, part.Size.Y)
			part.CFrame = newCF
			affected = true
		end
		return affected
	end
	if threshold > sizeLow / sizeHigh then
		if sizeHigh == part.Size.Z then
			local newCF = part.CFrame * CFrame.Angles(0, math.rad(90), 0)
			RotateMeshes(part, CFrame.Angles(0, math.rad(90), 0))
			part.Size = Vector3.new(part.Size.Z, part.Size.Y, part.Size.X)
			part.CFrame = newCF
			affected = true
		elseif sizeHigh == part.Size.Y then
			local newCF = part.CFrame * CFrame.Angles(0, 0, math.rad(90))
			RotateMeshes(part, CFrame.Angles(0, 0, math.rad(90)))
			part.Size = Vector3.new(part.Size.Y, part.Size.X, part.Size.Z)
			part.CFrame = newCF
			affected = true
		end
	end
	local sizeLow = math.min(part.Size.Y, part.Size.Z)
	local sizeHigh = math.max(part.Size.Y, part.Size.Z)
	if sizeHigh == part.Size.Y then return affected end
	if threshold > sizeLow / sizeHigh then
		local newCF = part.CFrame * CFrame.Angles(math.rad(90), 0, 0)
		RotateMeshes(part, CFrame.Angles(math.rad(90), 0, 0))
		part.Size = Vector3.new(part.Size.X, part.Size.Z, part.Size.Y)
		part.CFrame = newCF
		affected = true
	end
	return affected
end

function WoodGrain.FixPart(part:BasePart, threshold)
	if not threshold then threshold = 0.75 end
	fixGrainDirection(part, threshold)
end

function WoodGrain.FixInInstance(obj:Instance, threshold)
	if not threshold then threshold = 0.75 end
	
	for _, v in pairs(SearchWoodenParts(obj:GetDescendants())) do
		WoodGrain.FixPart(v, threshold)
	end
end

function WoodGrain.FixAllInWorkspace(threshold)
	if not threshold then threshold = 0.75 end
	WoodGrain.FixInInstance(workspace, threshold)
end

return WoodGrain