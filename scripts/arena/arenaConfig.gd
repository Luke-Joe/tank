extends Resource

class_name ArenaConfig

@export var grid_width: int = 24
@export var grid_length: int = 24
@export var cell_size := 2.0
@export var wall_height := 2.0
@export var seed: int = 0
@export_range(0.1, 0.8) var carve_ratio: float = 0.4
