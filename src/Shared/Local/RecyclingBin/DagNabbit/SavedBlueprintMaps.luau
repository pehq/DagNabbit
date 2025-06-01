local SavedMaps = {}

SavedMaps.SmilyFace = {
	{0,1,0,1,0},
	{0,1,0,1,0},
	{0,0,0,0,0},
	{1,0,0,0,1},
	{0,1,1,1,0},
}

SavedMaps.Dot = {
	{0,0,0,0,0},
	{0,0,0,0,0},
	{0,0,1,0,0},
	{0,0,0,0,0},
	{0,0,0,0,0},
}

SavedMaps.Box = {
	{2,2,2,2,0},
	{2,1,1,2,0},
	{2,1,1,2,0},
	{2,2,2,2,0},
	{0,0,0,0,0},
}

SavedMaps.SmilyFaceRect = {
	
}

--local Generator = require(game.ReplicatedStorage.Modules.DungeonAlgorithmicGenerator) Generator.GenerateMapFromRect(Generator.MatrixToRect(Generator.Wallify(Generator.Algorithms["Random Walk"].MazeGenerator(10000, 1000, 7))))

--local Generator = require(game.ReplicatedStorage.Modules.DungeonAlgorithmicGenerator) local map = Generator.Algorithms["Conway's Game of Life"].RunSimulation(Vector2.new(1000, 1000), 5, 0.05) Generator.GenerateMapFromRect(Generator.MatrixToRect(Generator.Algorithms["Conway's Game of Life"].RunSimulation(Vector2.new(1000,1000), 20, 0.2)))

return SavedMaps
