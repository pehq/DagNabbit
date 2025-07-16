local Directions = {}

Directions.King = {
    Vector2.new(-1,-1), --North-West
	Vector2.new(-1, 0), --North
	Vector2.new(-1, 1), --NorthEast
	Vector2.new( 0, 1), --East
	Vector2.new( 1,-1), --SouthWest
	Vector2.new( 1, 0), --South
	Vector2.new( 1, 1), --SouthEast
	Vector2.new( 0,-1), --West
}

Directions.Rook = {
	Vector2.new(-1, 0), --North
	Vector2.new( 0, 1), --East
	Vector2.new( 1, 0), --South
	Vector2.new( 0,-1), --West
}

Directions.Bishop = {
    Vector2.new(-1,-1), --North-West
    Vector2.new(-1, 1), --NorthEast
    Vector2.new( 1,-1), --SouthWest
    Vector2.new( 1, 1), --SouthEast
}

return Directions