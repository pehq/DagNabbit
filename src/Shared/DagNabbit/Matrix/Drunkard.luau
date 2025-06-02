local Drunkard = {}

local Directions = {
	--North, East, South, West
	Vector2.new(0, -1),
	Vector2.new(1, 0),
	Vector2.new(0, 1),
	Vector2.new(-1, 0),
}

function Drunkard.Walk(self, lifetime:number, iterations:number, StartPos:Vector2)
	if StartPos == nil then
		--Center Position if there is no provided position
		StartPos = Vector2.new(math.ceil(self.Dimensions.X / 2), math.ceil(self.Dimensions.Y / 2))
	end
	
	local x, y = StartPos.X, StartPos.Y
	
	self.Value[StartPos.Y][StartPos.X] = true
	
	for i = 1, iterations do
		x, y = StartPos.X, StartPos.Y
		
		for age = 1, lifetime do
			local Dir = Directions[math.random(1,4)]
			
			if self.Value[y + Dir.Y] == nil or self.Value[y + Dir.Y][x + Dir.X] == nil then
				continue
			end
			
			x += Dir.X
			y += Dir.Y
			
			self.Value[y][x] = true
		end 

		--TODO: There is a weird bug in which some of the connectors are not being added
		table.insert(self.Connectors, {StartPos, Vector2.new(x + 1,y + 1)})
	end
end

return Drunkard