local HyperVectors = require(script.HyperVectors)

local PseudoDim = {}
PseudoDim.__index = {}

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

function PseudoDim.new(...)
	local args = typeof(...) == "table" and ... or {...}
	args = VectorToTableFuncs[typeof(args[1])](args)
	
	local self = setmetatable({}, PseudoDim)
	self.Value = {}
	self.Dimensions = args
	
	return self
end

function PseudoDim:SetAll(val)
	local Factor = 1
	for i = 1, #self.Dimensions do
		Factor *= self.Dimensions[i]
	end

	self.Value = table.create(Factor, val)

	return self
end

function PseudoDim:GetIndexByCoord(...)
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

function PseudoDim.__add()
	
end

return PseudoDim