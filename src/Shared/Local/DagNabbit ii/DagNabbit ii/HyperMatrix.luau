--This module shouldn't be used as it requires a lot of RAM to run, please view Pehq's other modules relating to this module.
local Dependecies = script.Parent
local HyperVectors = require(Dependecies.HyperVectors)

--Air = 0
--Wall = #
--Floor = _

local Matrix = {}
Matrix.__index = Matrix

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

-- Recursive function to build nested tables
local function build_matrix(value, dims, depth)
	local size = dims[depth]
	local t = {}
	if depth == #dims then
		for i = 1, size do
			t[i] = value
		end
	else
		for i = 1, size do
			t[i] = build_matrix(value, dims, depth + 1)
		end
	end
	return t
end

-- Recursively sets all leaf values in a matrix
local function set_all(t, val)
	for i = 1, #t do
		if type(t[i]) == "table" then
			set_all(t[i], val)
		else
			t[i] = val
		end
	end
end

function Matrix.new(...)
	local args = typeof(...) == "table" and ... or {...}
	args = VectorToTableFuncs[typeof(args[1])](args)
	
	if #args >= 4 then
		warn("Caution with Matrices with at least 4 dimensions, they take up a lot of memory! Instead use Pseudo-Dimensional Tables by PehqDev.")
	end
	
	local self = setmetatable({}, Matrix)
	self.Value = build_matrix(0, args, 1)
	self.Dimensions = HyperVectors.new(args)
	
	return self
end

function Matrix:SetAll(val)
	set_all(self.Value, val)
end

-- Helper: Get nested value
local function get_at(t, pos)
	local ref = t
	for i = 1, #pos do
		ref = ref[pos[i]]
	end
	return ref
end

-- Helper: Set nested value
local function set_at(t, pos, value)
	local ref = t
	for i = 1, #pos - 1 do
		ref = ref[pos[i]]
	end
	ref[pos[#pos]] = value
end

-- Add to Matrix methods
function Matrix:Swap(pos1, pos2)
	local val1 = get_at(self.Value, pos1)
	local val2 = get_at(self.Value, pos2)
	set_at(self.Value, pos1, val2)
	set_at(self.Value, pos2, val1)
end

-- Randomly assigns a true or false value
function Matrix:TrueFalse(seed)
	local rng = seed and Random.new(seed) or Random.new()

	local function assign_random(t)
		for i = 1, #t do
			if type(t[i]) == "table" then
				assign_random(t[i])
			else
				local x = rng:NextInteger(0, 1)
				t[i] = x == 1 and "#" or " "
			end
		end
	end

	assign_random(self.Value)
	
	return self
end

function Matrix:Raw()
	return self.Value
end

function Matrix:Clone()
	local Clone = setmetatable(table.clone(self), getmetatable(self))
	return Clone
end

--Cover with offset from top left
function Matrix:Cover(otherMatrix, offset:{})
end

function Matrix:Wallify(Wall, Air)
	if not Air then
		Air = 0
	end
	
	
	
end

return Matrix