local DeepCopy = require(script.Parent.Parent.Utils.DeepCopy) --function that copies everything nested within the table 

local SavedMaps = {}

SavedMaps.SmileyFace = {
	{0,1,0,1,0},
	{0,1,0,1,0},
	{0,0,0,0,0},
	{1,0,0,0,1},
	{0,1,1,1,0},
}

SavedMaps.Dot = {
	{0,0,0,0,0},
	{0,0,0,0,0},
	{0,0,1,0,0},
	{0,0,0,0,0},
	{0,0,0,0,0},
}

SavedMaps.Square = {
	{0,0,0,0,0},
	{0,1,1,1,0},
	{0,1,1,1,0},
	{0,1,1,1,0},
	{0,0,0,0,0},
}

SavedMaps.Triangle = {
	{0,0,0,0,0},
	{0,0,1,0,0},
	{0,1,1,1,0},
	{1,1,1,1,1},
	{0,0,0,0,0},
}

local Presets = {}

function Presets.GetMap(mapName: string)
	if SavedMaps[mapName] == nil then
		error("map doesn't exists!")
		return
	end
	
	return DeepCopy(SavedMaps[mapName])
end

return Presets