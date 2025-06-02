return function(matrix)
	local copy = {}
	for y, row in ipairs(matrix) do
		copy[y] = {}
		for x, value in ipairs(row) do
			copy[y][x] = value
		end
	end
	return copy
end