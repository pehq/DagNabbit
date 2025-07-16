local Dag = script:FindFirstAncestor("DagNabbit")

local Connectors = {}
Connectors.__index = Connectors

function Connectors.new()
    local self = setmetatable({}, Connectors)
    return self
end

function Connectors:Insert(p1, p2)
   table.insert(self, {p1, p2}) 
end

function Connectors:Extract(p1, p2)
    local ExtCons = {}
    
    for i, c in ipairs(self) do
		
		local function inBounds(p)
			return p.X >= p1.X and p.X <= p2.X and p.Y >= p1.Y and p.Y <= p2.Y
		end
		
		if inBounds(c[1] and c[2]) then
			local offsetA = Vector2.new(c[1].X - p1.X + 1, c[1].Y - p1.Y + 1)
			local offsetB = Vector2.new(c[2].X - p1.X + 1, c[2].Y - p1.Y + 1)
			
			table.insert(ExtCons, {
				offsetA,
				offsetB
			})
		end	
	end
	
	local newCon = Connectors.new()
	for i = 1, #ExtCons do
		newCon:Insert(ExtCons[i][1], ExtCons[i][2])
	end
	
    return newCon
end

function Connectors:FlipHorizontally()
	for i = 1, #self do
		local CurConnector = self[i]
		self[i] = {
			Vector2.new(CurConnector[2].X, CurConnector[1].Y),
			Vector2.new(CurConnector[1].X, CurConnector[2].Y)
		}
	end
end

function Connectors:FlipVertically()
	for i = 1, #self do
		local CurConnector = self[i]
		self[i] = {
			Vector2.new(CurConnector[1].X, CurConnector[2].Y),
			Vector2.new(CurConnector[2].X, CurConnector[1].Y)
		}
	end
end

function Connectors:RotateClockwise(h)
	for i = 1, #self do
		local CurRect = self[i]
		self[i] = {
			Vector2.new(h - CurRect[1].Y + 1, CurRect[1].X),
			Vector2.new(h - CurRect[2].Y + 1, CurRect[2].X)
		}
	end
end

function Connectors:GetHighMagIndex()
	local Farthest = 1
	local FarMagnitude = 0
	
	for i, c:{p1:Vector2,p2:Vector2} in pairs(self) do
		local m = (c[2] - c[1]).Magnitude
		if m > FarMagnitude then
			Farthest = i
			FarMagnitude = m
		end
	end
	
	return Farthest
end

function Connectors:ShiftConnections(offset:Vector2)
	for i = 1, #self do
		self[i] = {
			self[i][1] + offset,
			self[i][2] + offset,
		}
	end
end

return Connectors