extends Node

# movement
var move := 0.0
var turn := 0.0

# turret
var aim_world_pos : Vector3
var fire := false

var state = TankInputState.new()

func _physics_process(delta: float) -> void:
	state.move = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	state.turn = Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")
	state.aim = get_mouse_world_position()
	state.fire = Input.is_action_pressed("fire")

func get_mouse_world_position() -> Vector3:
	var viewport := get_viewport()
	var camera := viewport.get_camera_3d()
	
	var mouse_pos := viewport.get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir := camera.project_ray_normal(mouse_pos)

	var plane := Plane(Vector3.UP, 0)
	return plane.intersects_ray(ray_origin, ray_dir)
