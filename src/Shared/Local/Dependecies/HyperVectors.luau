local HyperVector = {}
HyperVector.__index = HyperVector
-- Metatable to dynamically update Dims when Value changes

local VectorToTableFuncs = {
	--0D
	["nil"] = function(args:nil)
		return {}
	end,
	--1D
	["string"] = function(args:string)
		if tonumber(args) then
			return tonumber(args)
		else
			return {}
		end
	end,
	["number"] = function(args:number)
		return args
	end,
	--2D
	["Vector2"] = function(args:Vector2)
		return {args.X, args.Y}
	end,
	["Vector2int16"] = function(args:Vector2int16)
		return {args.X, args.Y}
	end,
	--3D
	["Vector3"] = function(args:Vector3)
		return {args.X, args.Y, args.Z}
	end,
	["Vector3int16"] = function(args:Vector3int16)
		return {args.X, args.Y, args.Z}
	end,
	--∞D
	["table"] = function(args:{})
		return args
	end,
}

function HyperVector.CordToIndex(Cord:string)
	local index = 0
	local str = Cord:gsub("%A+",""):upper()
	for i = 1, #str do
		local c = str:sub(i,i)
		--string.byte(c) - string.byte("X") + 1 + (26 * (i - 1)) - (i - 1)
		local x = string.byte(c) + 25*i - 112 --This is a simplified version of the line above
		x = x <= 0 and 4 + -(x) or x --x is always a negative number
		index += x
	end
	
	return index
end

local function CorrectAndMatchVectors(self, ...)
	--Check if input is good
	local args = {...}
	local arrs = {}
	for i, v in pairs(args) do
		local x = VectorToTableFuncs[typeof(v)](v)
		if #x ~= #self.Value then --not same dimensions?
			if #x > #self.Value then
				x = table.move(x, 1, #self.Value, 1, {})
			elseif #x < #self.Value then
				x = table.move(table.create(#self.Value - #x, 0), 1, #self.Value - #x, #x + 1, x)
			end
		end
		if getmetatable(x) == nil then --regular table
			x = HyperVector.new(x)
		end

		table.insert(arrs, x)
	end

	--Correct input if there is few/more other vectors
	if #self.Value ~= #arrs + 1 then
		if #self.Value > #arrs + 1 then
			local x = table.create(#self.Value - #arrs - 1, HyperVector.zero(#self.Value)) 
			arrs = table.move(x, 1, #x, #arrs + 1, arrs)
		elseif #self.Value < #arrs + 1 then
			arrs = table.move(arrs, 1, #self.Value - 1, 1, {})
		end
	end
	
	return self, arrs
end

local function RecalculateSelf(self)
	self.Magnitude = HyperVector.calculateMagnitude(self.Value)
	self.HyperVector.calculateUnit(self.Value, self.Magnitude)
end

function HyperVector.calculateMagnitude(value)
	local sum = 0
	for _, v in ipairs(value) do
		sum = sum + v^2
	end
	return math.sqrt(sum)
end

-- Calculate unit vector
function HyperVector.calculateUnit(value, magnitude)
	if magnitude == 0 then return value end
	local unit = {}
	for _, v in ipairs(value) do
		table.insert(unit, v / magnitude)
	end
	return unit
end

--Vector Creation
--Create a new Hyper Vector
function HyperVector.new(...)
	local args = typeof(...) == "table" and ... or {...}
	args = VectorToTableFuncs[typeof(args[1])](args)

	local self = setmetatable({}, HyperVector)
	self.Value = args
	self.Magnitude = HyperVector.calculateMagnitude(self.Value)
	self.Unit = HyperVector.calculateUnit(self.Value, self.Magnitude)

	return self
end

function HyperVector.num(dims:number, num:number)
	return HyperVector.new(table.create(dims, num))
end

function HyperVector.zero(dims)
	return HyperVector.num(dims, 0)
end

function HyperVector.one(dims:number)
	return HyperVector.num(dims, 1)
end

--Provides a Hyper Vector with only one axis being set to 1. Axis' are listed by index (1 = x, 2 = y, 3 = z, 4 = w, etc...)
function HyperVector.nAxis(dims:number, i:number)
	local IdentityVector = table.create(dims, 0)
	IdentityVector[i] = 1
	
	return HyperVector.new(IdentityVector)
end

--Vector functions
--Returns new vector with all values Abs. i: starting range, j: ending range
function HyperVector:Abs(i, j)
	if i == nil then i = 1 end
	if j == nil then j = #self.Value end
	
	--Using strings for optimization purposes, it's easier to delete all negative numbers than to do a for loop through all numbers...
	local StringFormat = table.concat(self.Value, " ", i, j):gsub("%-", "") --delete all negatives
	local ResVector = {}
	
	for n in StringFormat:gmatch("([^,]+)") do
		table.insert(ResVector, tonumber(n))
	end
	
	return HyperVector.new(ResVector)
end

function HyperVector:Ceil(i, j)
	if i == nil then i = 1 end
	if j == nil then j = #self.Value end
	
	local ResVector = table.move(self.Value, i, j, 1, {})
	for i = 1, #ResVector do
		local v = ResVector[i]
		ResVector[i] = math.ceil(v)
	end
	
	return HyperVector.new(ResVector)
end

function HyperVector:Floor(i, j)
	if i == nil then i = 1 end
	if j == nil then j = #self.Value end

	local ResVector = table.move(self.Value, i, j, 1, {})
	for i = 1, #ResVector do
		local v = ResVector[i]
		ResVector[i] = math.floor(v)
	end
	
	return HyperVector.new(ResVector)
end

function HyperVector:Sign(i, j)
	local StringFormat = table.concat(self.Value, " ", i, j):gsub("[-0-9]+", function(val)
		return val == "0" and "0" or tonumber(val) > 0 and "+" or "-" end)
	
	local ResVector = {}
	StringFormat:gmatch(".")(
		function(c)
			if c == "+" then 
				table.insert(ResVector, 1)
			elseif c == "-" then
				table.insert(ResVector, -1)
			else
				table.insert(ResVector, 0)
			end
		end)
	
	return HyperVector.new(ResVector)
end

-- Angle: Returns the angle between two vectors in radians
function HyperVector:Angle(other)
	local dotProduct = self:Dot(other)
	local magnitudeProduct = self.Magnitude * other.Magnitude
	if magnitudeProduct == 0 then
		error("One of the vectors has zero magnitude, angle is undefined.")
	end
	local cosineTheta = dotProduct / magnitudeProduct
	-- Clamp the cosine value to avoid errors from floating point precision issues
	cosineTheta = math.clamp(cosineTheta, -1, 1)
	return math.acos(cosineTheta)  -- Angle in radians
end

function HyperVector:Dot(other)
	local result = 0
	for i = 1, math.min(#self.Value, #other.Value) do
		result = result + (self.Value[i] * other.Value[i])
	end
	return result
end

-- Fuzzy Equality: Checks if two vectors are approximately equal within a small tolerance
function HyperVector:FuzzyEq(other, tolerance)
	tolerance = tolerance or 1e-6  -- default tolerance
	if #self.Value ~= #other.Value then return false end
	for i = 1, #self.Value do
		if math.abs(self.Value[i] - other.Value[i]) > tolerance then
			return false
		end
	end
	return true
end

-- Lerp: Linear interpolation between two vectors (alpha from 0 to 1)
function HyperVector:Lerp(other, alpha)
	alpha = alpha or 0.5
	local result = {}
	for i = 1, math.min(#self.Value, #other.Value) do
		result[i] = self.Value[i] + (other.Value[i] - self.Value[i]) * alpha
	end
	return HyperVector.new(result)
end

-- Max: Returns a vector with the maximum values element-wise
function HyperVector:Max(other)
	local result = {}
	for i = 1, math.min(#self.Value, #other.Value) do
		result[i] = math.max(self.Value[i], other.Value[i])
	end
	return HyperVector.new(result)
end

-- Min: Returns a vector with the minimum values element-wise
function HyperVector:Min(other)
	local result = {}
	for i = 1, math.min(#self.Value, #other.Value) do
		result[i] = math.min(self.Value[i], other.Value[i])
	end
	return HyperVector.new(result)
end

local function HyperCross()
	
end

--Cross --too power consuming???? :< --REACH OUT TO ME IF YOU FOUND A WAY FOR THIS!!!! 😭😭😭
function HyperVector:Cross(...)
	local self, args = CorrectAndMatchVectors(self, ...)
	
	return error("Cross product with 4 dimensions is considered to be tough and takes linear algegbra, and that only scales in difficulty the more dimensions you go up by. Would appreciate it if you manage to provide a solution to this problem. <3 -Pehq")
end

--Extra Functions
--Project one vector onto another
function HyperVector:Project(other)
	local dot = self:Dot(other)
	local magSq = other:Dot(other)
	if magSq == 0 then return HyperVector.zero(#self.Value) end
	return other * (dot / magSq)
end

--Sometimes you might want to multiply vectors component-wise instead of using a dot product.
function HyperVector:Hadamard(other)
	local result = {}
	for i = 1, math.min(#self.Value, #other.Value) do
		result[i] = self.Value[i] * other.Value[i]
	end
	return HyperVector.new(result)
end

--These are useful for different applications, like grid-based movement in pathfinding.
function HyperVector:ManhattanDistance(other)
	local sum = 0
	for i = 1, math.min(#self.Value, #other.Value) do
		sum = sum + math.abs(self.Value[i] - other.Value[i])
	end
	return sum
end

function HyperVector:ChebyshevDistance(other)
	local maxDiff = 0
	for i = 1, math.min(#self.Value, #other.Value) do
		maxDiff = math.max(maxDiff, math.abs(self.Value[i] - other.Value[i]))
	end
	return maxDiff
end

--Reflect a vector off a normal (useful for physics and raytracing)
function HyperVector:Reflect(normal)
	return self - normal * (2 * self:Dot(normal))
end

--Clamping a vector between a minimum and maximum
function HyperVector:Clamp(minVec, maxVec)
	local result = {}
	for i = 1, #self.Value do
		result[i] = math.clamp(self.Value[i], minVec.Value[i] or -math.huge, maxVec.Value[i] or math.huge)
	end
	return HyperVector.new(result)
end

--
function HyperVector:Mean()
	local sum = 0
	for _, v in ipairs(self.Value) do
		sum = sum + v
	end
	return sum / #self.Value
end

function HyperVector:Variance()
	local mean = self:Mean()
	local sum = 0
	for _, v in ipairs(self.Value) do
		sum = sum + (v - mean)^2
	end
	return sum / #self.Value
end

--Turn HyperVector back to a normal vector,
function HyperVector:ToVector()
	local Dimensions = #self.Value
	
	assert(Dimensions ~= 1 or Dimensions ~= 2 or Dimensions ~= 3, "Dimensions not in range of reality!!!")
	
	if Dimensions == 1 then
		return self.Value[1]
	elseif Dimensions == 2 then
		return Vector2.new(self.Value[1], self.Value[2])
	else
		return Vector3.new(self.Value[1], self.Value[2], self.Value[3])
	end
end

--Turn HyperVector back to a normal vectorInt,
function HyperVector:ToVectorInt()
	local Dimensions = #self.Value

	assert(Dimensions == 1 or Dimensions == 2 or Dimensions == 3, "Dimensions not in range of our current reality!!!")

	if Dimensions == 1 then
		return self.Value[1]
	elseif Dimensions == 2 then
		return Vector2int16.new(self.Value[1], self.Value[2])
	else
		return Vector3int16.new(self.Value[1], self.Value[2], self.Value[3])
	end
end

--Metamethods
function HyperVector.__add(self, other)
    local result = {}
    for i = 1, math.min(#self.Value, #other.Value) do
        result[i] = self.Value[i] + other.Value[i]
    end
    return HyperVector.new(result)
end

function HyperVector.__sub(self, other)
    local result = {}
    for i = 1, math.min(#self.Value, #other.Value) do
        result[i] = self.Value[i] - other.Value[i]
    end
    return HyperVector.new(result)
end

function HyperVector.__mul(self, other)
    local result = {}
    if type(other) == "table" then  -- array-array multiplication
        for i = 1, math.min(#self.Value, #other.Value) do
            result[i] = self.Value[i] * other.Value[i]
        end
    else  -- array-number multiplication
        for i = 1, #self.Value do
            result[i] = self.Value[i] * other
        end
    end
    return HyperVector.new(result)
end

function HyperVector.__div(self, other)
    local result = {}
    if type(other) == "table" then  -- array-array division
        for i = 1, math.min(#self.Value, #other.Value) do
            result[i] = self.Value[i] / other.Value[i]
        end
    else  -- array-number division
        for i = 1, #self.Value do
            result[i] = self.Value[i] / other
        end
    end
    return HyperVector.new(result)
end

function HyperVector.__idiv(self, other)
    local result = {}
    if type(other) == "table" then  -- array-array floor division
        for i = 1, math.min(#self.Value, #other.Value) do
            result[i] = math.floor(self.Value[i] / other.Value[i])
        end
    else  -- array-number floor division
        for i = 1, #self.Value do
            result[i] = math.floor(self.Value[i] / other)
        end
    end
    return HyperVector.new(result)
end

function HyperVector.__eq(self, other)
    if #self.Value ~= #other.Value then
        return false
    end
    for i = 1, #self.Value do
        if self.Value[i] ~= other.Value[i] then
            return false
        end
    end
    return true
end

return HyperVector