local HyperVectors = require(game.ReplicatedStorage.Dependecies.HyperVectors)

local HyperRect = {}
HyperRect.__index = HyperRect

function HyperRect.new(...) --Only numbers
	local Args = {...}
	
	if #Args % 2 ~= 0 then
		Args = table.remove(Args, #Args)
	end
	
	local MinNums = {}
	local MaxNums = {}
	
	for i = 1, #Args do
		local CurNum = Args[i]
		
		if #Args / 2 >= i then
			table.insert(MinNums, CurNum)
		else
			table.insert(MaxNums, CurNum)
		end
	end
	
	
	local self = setmetatable({}, HyperRect)
	
	self.Min = HyperVectors.new(MinNums)
	self.Max = HyperVectors.new(MaxNums)
	
	self.Size = self.Max - self.Min
	
	return self
end

return HyperRect