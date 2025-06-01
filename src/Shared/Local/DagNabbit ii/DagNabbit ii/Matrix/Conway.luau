local Conway = {}

local Directions = {
	Vector2.new(-1, -1), -- Top Left
	Vector2.new( 0, -1), -- Top
	Vector2.new( 1, -1), -- Top Right
	Vector2.new(-1,  0), -- Left
	Vector2.new( 1,  0), -- Right
	Vector2.new(-1,  1), -- Bottom Left
	Vector2.new( 0,  1), -- Bottom
	Vector2.new( 1,  1), -- Bottom Right
}

function Conway.RunWithMatrix(self, steps)
	local matrix = self.Value
	local height = #matrix
	local width = #matrix[1]

	for step = 1, steps do
		task.wait(0.2)
		local changes = {}

		for y = 1, height do
			for x = 1, width do
				local neighbors = 0

				for _, dir in ipairs(Directions) do
					local nx, ny = x + dir.X, y + dir.Y
					if matrix[ny] and matrix[ny][nx] == "#" then
						neighbors += 1
					end
				end

				local currentChar = matrix[y][x]
				local nextChar = (neighbors > 5 or neighbors == 0) and "#" or " "
				table.insert(changes, {value = nextChar, pos = Vector2.new(x, y)})
			end
		end

		for _, change in ipairs(changes) do
			matrix[change.pos.Y][change.pos.X] = change.value
		end
	end

	return self
end

return Conway