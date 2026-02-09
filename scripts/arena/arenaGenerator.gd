extends Node


@export var wall_scene: PackedScene


var grid: Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var strategy = DrunkardWalkStrategy.new()
	var config = ArenaConfig.new()
	var grid = strategy.generate(config)
	_print_grid(grid)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _print_grid(grid: Array) -> void:
	for x in grid.size():
		var row_str = ""
		for y in grid[0].size():
			match grid[x][y]:
				GenerationStrategy.Cell.HARD: row_str += "# "
				GenerationStrategy.Cell.EMPTY: row_str += ". "
				GenerationStrategy.Cell.SPAWN: row_str += "S "
		print(row_str)
				
