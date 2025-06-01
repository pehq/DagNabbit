local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HyperVector = require(ReplicatedStorage.Dependecies.HyperVectors)

local Pseudo = {}
Pseudo.__index = Pseudo

local VectorToTableFuncs = {
	["number"] = function(args:number)
		return args
	end,
	["Vector2"] = function(args:Vector2)
		return {args.X, args.Y}
	end,
	["Vector2int16"] = function(args:Vector2int16)
		return {args.X, args.Y}
	end,
	["Vector3"] = function(args:Vector3)
		return {args.X, args.Y, args.Z}
	end,
	["Vector3int16"] = function(args:Vector3int16)
		return {args.X, args.Y, args.Z}
	end,
	["table"] = function(args:{})
		return args
	end,
	["nil"] = function(args:nil)
		return {}
	end,
}


function Pseudo.new(...:number|Vector2|Vector3|Vector2int16|Vector3int16|{number})
	local args = typeof(...) == "table" and ... or {...}
	args = VectorToTableFuncs[typeof(args[1])](args)

	local self = setmetatable({}, Pseudo)
	self.Dimensions = args
	self.Value = nil
	self:SetAll(false)

	return self
end

function Pseudo:GetIndexFromCoord(...)
	local Args = {...}
	local converter = VectorToTableFuncs[typeof(Args[1])]
	assert(converter, "Invalid type for Args[1]")
	Args = converter(Args)

	-- Validate Args length
	if #Args > #self.Dimensions then
		error("Too many coordinates provided")
	end

	-- Recursive helper function
	local function Recurse(axis)
		if axis > #self.Dimensions or axis > #Args then
			return 0
		end

		-- Calculate product of previous dimensions
		local LastDimsLength = 1
		if axis > 1 then
			for i = 1, axis - 1 do
				LastDimsLength *= self.Dimensions[i]
			end
		end

		-- Calculate current index and recurse
		local currentIndex = (Args[axis] - 1) * LastDimsLength
		return currentIndex + Recurse(axis + 1)
	end

	return Recurse(1) + 1
end

function Pseudo:GetValueFromCoordinate(...)
	local index = self:GetIndexFromCoord(...)
	return self.Value[index]
end

function Pseudo:GetCoordFromIndex(index:number)
	assert(index >= 1 and index <= #self.Value, "Index out of bounds")

	local coords = {}
	index -= 1 -- Make it 0-based for calculation
	for i = #self.Dimensions, 1, -1 do
		local dimSize = self.Dimensions[i]
		local coord = (index % dimSize) + 1
		table.insert(coords, 1, coord)
		index = math.floor(index / dimSize)
	end
	
	return coords
end

function Pseudo:SetAll(val)
	local Factor = 1
	for i = 1, #self.Dimensions do
		Factor *= self.Dimensions[i]
	end

	self.Value = table.create(Factor, val)

	return self
end

function Pseudo:SetByCoordinate(Value, ...)
	local Args = {...}
	Args = VectorToTableFuncs[typeof(Args[1])](Args)

	self.Value[self:GetIndexFromCoord(...)] = Value

	return self
end

--Provides functionaliyu to loops through all elements
--Tbh, I forgot what this did and will need to look into this... <-- TODO
function Pseudo:Iterate()
	local index = 0
	local size = #self.Value
	return function()
		index += 1
		if index <= size then
			local coords = self:GetCoordFromIndex(index) -- fixed name here
			return coords, self.Value[index]
		end
	end
end

function Pseudo.__add(self, other)
	assert(self == other, "Dimensions do not match for addition")
	local result = Pseudo.new(unpack(self.Dimensions))
	for i = 1, #self.Value do
		result.Value[i] = self.Value[i] + other.Value[i]
	end
	
	return result
end

function Pseudo.__eq(self, other)
	if getmetatable(other) ~= Pseudo then --not using this module
		return false
	end
	if #self.Dimensions ~= #other.Dimensions then --not the same dimensions
		return false
	end
	for i = 1, #self.Dimensions do --dimensions aren't equal
		if self.Dimensions[i] ~= other.Dimensions[i] then
			return false
		end
	end
	
	return true
end

function Pseudo:PrettyPrint() --DEBUG ONLY
	local output = {}
	for coords, value in self:Iterate() do
		table.insert(output, string.format("(%s): %s", table.concat(coords, ", "), tostring(value)))
	end
	print(table.concat(output, "\n"))
end

--TODO: Test this
return Pseudo