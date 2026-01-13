extends Node3D

@export var rotation_speed = 3

var input_state : TankInputState

func apply_input(input: TankInputState) -> void:
	input_state = input

func _physics_process(delta: float) -> void:
	handle_rotation(delta)

func handle_rotation(delta: float) -> void:
	var world_dir := input_state.aim - global_position
	world_dir.y = 0
	
	if world_dir.length_squared() < 0.001:
		return
			
	var local_dir := ((get_parent() as Node3D).global_basis.inverse() * world_dir).normalized()

	var desired_yaw := atan2(-local_dir.x, -local_dir.z)
	
	rotation.y = lerp_angle(rotation.y, desired_yaw, rotation_speed * delta)
	
