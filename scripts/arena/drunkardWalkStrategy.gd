class_name DrunkardWalkStrategy
extends GenerationStrategy

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, -1), # North
	Vector2i(0, 1), # South
	Vector2i(-1, 0), # West
	Vector2i(1, 0) # East
]

func generate(config: ArenaConfig) -> Array:
	var grid = _create_grid(config)
	
	var rng := RandomNumberGenerator.new()
	rng.seed = config.seed
	
	if config.seed == 0:
		rng.randomize()
		
	var walker := Vector2i(config.grid_width / 2, config.grid_length / 2)
	var total_cells = config.grid_width * config.grid_length
	var carve_count = int(total_cells * config.carve_ratio)
	var carved = 0
	
	while carved < carve_count:
		var dir = DIRECTIONS[rng.randi() % DIRECTIONS.size()]
		walker += dir
		walker.x = clampi(walker.x, 1, config.grid_width - 2)
		walker.y = clampi(walker.y, 1, config.grid_length - 2)
		
		if (grid[walker.x][walker.y] == Cell.HARD):
			carved += 1
			
		grid[walker.x][walker.y] = Cell.EMPTY
		
	return grid

func get_spawn_points() -> Array[Vector2i]:
	push_error("drunkardStrategy get_spawn_points not implemented")
	return []
	
