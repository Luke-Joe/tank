class_name DrunkardWalkStrategy
extends GenerationStrategy

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, -1), # North
	Vector2i(0, 1), # South
	Vector2i(-1, 0), # West
	Vector2i(1, 0) # East
]

var rng: RandomNumberGenerator

func generate(config: ArenaConfig) -> Array:
	var grid = _create_grid(config)
	
	_init_rng(config)
		
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
			grid[walker.x][walker.y] = Cell.EMPTY
			carved += 1
	
	spawns = _place_spawns(grid, config)
	
	return grid

func _place_spawns(grid: Array, config: ArenaConfig) -> Array[Vector2i]:
	var empty_cells: Array[Vector2i] = []
	
	for x in grid.size():
		for y in grid[0].size():
			if grid[x][y] == Cell.EMPTY:
				empty_cells.append(Vector2i(x, y))
	
	var spawn_points: Array[Vector2i] = []
	
	var first_spawn = empty_cells[rng.randi() % empty_cells.size()]
	spawn_points.append(first_spawn)
	
	return spawn_points
	

func _init_rng(config: ArenaConfig) -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = config.seed
	
	if config.seed == 0:
		rng.randomize()
	
func get_spawn_points() -> Array[Vector2i]:
	return spawns
	
