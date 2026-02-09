extends RefCounted

class_name GenerationStrategy

enum Cell {
	EMPTY,
	HARD,
	SPAWN
}

func generate(config: ArenaConfig) -> Array:
	push_error('generate not implemented')
	return []

# This function will return a list of spawn points, one for each active_player
func get_spawn_points() -> Array[Vector2i]:
	push_error('get_spawn_points not implemented')
	return []
	
func _create_grid(config: ArenaConfig) -> Array:
	var grid: Array = []
	
	for x in config.grid_width:
		var row: Array = []
		for z in config.grid_length:
			row.append(Cell.HARD)
		grid.append(row)
	
	return grid
