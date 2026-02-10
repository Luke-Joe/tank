extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var strategy = DrunkardWalkStrategy.new()
	var config = ArenaConfig.new()
	var grid = strategy.generate(config)
	_print_grid(grid)
	_build_walls(grid, config)
	_set_camera_position(config)


func _print_grid(grid: Array) -> void:
	for x in grid.size():
		var row_str = ""
		for y in grid[0].size():
			match grid[x][y]:
				GenerationStrategy.Cell.HARD: row_str += "# "
				GenerationStrategy.Cell.EMPTY: row_str += ". "
				GenerationStrategy.Cell.SPAWN: row_str += "S "
		print(row_str)

func _build_walls(grid: Array, config: ArenaConfig) -> void:
	var wall_material := StandardMaterial3D.new()
	wall_material.albedo_color = Color.WHITE
				
	for x in grid.size():
		for y in grid[0].size():
			if grid[x][y] == GenerationStrategy.Cell.HARD:
				var wall := StaticBody3D.new()
				
				var mesh_instance := MeshInstance3D.new()
				var box_mesh := BoxMesh.new()
				box_mesh.size = Vector3(config.cell_size, config.wall_height, config.cell_size)
				mesh_instance.mesh = box_mesh
				mesh_instance.material_override = wall_material
				
				var collision := CollisionShape3D.new()
				var box_shape := BoxShape3D.new()
				box_shape.size = Vector3(config.cell_size, config.wall_height, config.cell_size)
				collision.shape = box_shape
				
				wall.add_child(mesh_instance)
				wall.add_child(collision)
				wall.position = Vector3(
					x * config.cell_size,
					config.wall_height / 2.0,
					y * config.cell_size
				)
				add_child(wall)

func _set_camera_position(config: ArenaConfig) -> void:
	var center_x = (config.grid_width * config.cell_size) / 2.0
	var center_y = (config.grid_length * config.cell_size) / 2.0 - config.camera_offset
	
	var cam = get_viewport().get_camera_3d()
	cam.position = Vector3(center_x, 12.5, center_y)
