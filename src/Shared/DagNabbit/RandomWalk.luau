local Walk = {}

local Directions = {
	Vector2.new(1,0),
	Vector2.new(0,1),
	Vector2.new(-1,0),
	Vector2.new(0,-1),
}

function Walk.Run(self, MaxTunnels, MaxLength, StartPos:Vector2)
	if StartPos == nil then
		StartPos = Vector2.new(math.random(1, self.Dimensions.X), math.random(1, self.Dimensions.Y))
	end
	
	--Random number that adds 1 or 3 to index
	local CoinFlip = math.random(2)
	
	
	local LastDir:Vector2 = nil
	local CurDir:Vector2 = nil
	local x, y = StartPos.X, StartPos.Y

	self.Value[y][x] = true

	for _ = 1, MaxTunnels do
		--Decide turning direction
		if CurDir ~= nil then
			CoinFlip = math.random(1, 2)
			--Swap direction and negate if tails.
			CurDir = Vector2.new(LastDir.Y, LastDir.X)
			if CoinFlip == 2 then
				CurDir *= -1
			end
		else
			CurDir = Directions[math.random(1,4)]
		end
		
		--Correct direction for corners
		if x == 1 and y ==1 then
			CurDir = LastDir == Vector2.new(-1,0) and Vector2.new(0,1) or Vector2.new(1,0)
		elseif x == self.Dimensions.X and y == 1 then
			CurDir = LastDir == Vector2.new(1,0) and Vector2.new(0,1) or Vector2.new(-1,0)
		elseif x == 1 and y == self.Dimensions.Y then
			CurDir = LastDir == Vector2.new(-1,0) and Vector2.new(0,-1) or Vector2.new(1,0)
		elseif x == self.Dimensions.X and y == self.Dimensions.Y then
			CurDir = LastDir == Vector2.new(1,0) and Vector2.new(0,-1) or Vector2.new(-1,0)
		end
		
		--Walk
		for j = 1, math.random(1, MaxLength) do
			if self.Value[y + CurDir.Y] == nil or self.Value[y + CurDir.Y][x + CurDir.X] == nil then
				break
			end
			
			x += CurDir.X
			y += CurDir.Y
			
			self.Value[y][x] = true
		end
		
		LastDir = CurDir
	end
	
	table.insert(self.Connectors, {StartPos, Vector2.new(x,y)})
	
	return self
end

function Walk.RunUntilPercent(self, Percent:number, TunnelsPerCheck:number, MaxLength:number, StartPos:Vector2)
	if StartPos == nil then
		StartPos = Vector2.new(math.random(1, self.Dimensions.X), math.random(1, self.Dimensions.Y))
	end
	
	Percent = math.clamp(Percent, 0, 1)
	local MatrixSize = self.Dimensions.X * self.Dimensions.Y
	
	
	repeat
		local Res, NewPos = Walk.Run(self, TunnelsPerCheck, MaxLength, StartPos)
		StartPos = NewPos
	until Percent < self:GetNumOfChars(true) / MatrixSize
end

return Walk