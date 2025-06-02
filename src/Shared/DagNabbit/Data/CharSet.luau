local CharSet = {}

CharSet.CharValues = { --TODO: maybe have a reversed version?
	[0] = "Air",
	["_"] = "Floor",
	["#"] = "Wall",
	[false] = false
} --This is used for quick translation of letters to numbers.

table.freeze(CharSet.CharValues)

function CharSet.AssignCharFromObject(str:string)
	local Char = nil
	for i, v in pairs(CharSet.CharValues) do
		if v == str then
			Char = i
			break
		end
	end

	return Char
end

return CharSet