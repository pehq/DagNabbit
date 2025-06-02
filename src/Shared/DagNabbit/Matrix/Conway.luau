local deepcopy = require(script.Parent.Parent.Utils.DeepCopy)

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
		local newMatrix = deepcopy(matrix)

		for y = 1, height do
			for x = 1, width do
				local neighbors = 0

				for _, dir in ipairs(Directions) do
					local nx, ny = x + dir.X, y + dir.Y
					if matrix[ny] and matrix[ny][nx] == true then
						neighbors += 1
					end
				end

				local currentChar = matrix[y][x]
				local nextChar = (neighbors > 5 or neighbors == 0) and true or false
				newMatrix[y][x] = nextChar
			end
		end

		matrix = newMatrix
	end

	self.Value = matrix
	return self
end

return Conway
