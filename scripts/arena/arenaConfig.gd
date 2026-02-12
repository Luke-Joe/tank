extends Resource

class_name ArenaConfig

@export var grid_width: int = 20
@export var grid_length: int = 10
@export var cell_size := 0.4
@export var wall_height := 0.4
@export var seed: int = 0
@export_range(0.1, 0.8) var carve_ratio: float = 0.4
@export var spawn_count: int = 2


@export var camera_offset := 0.5
