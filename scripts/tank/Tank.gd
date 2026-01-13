extends CharacterBody3D

@onready var input_node := $TankInput
@onready var turret := $TurretPivot

@export var move_speed := 750.0
@export var turn_speed := 2.5
@export var acceleration := 50000.0
@export var deceleration := 150.0

var input_state : TankInputState
	
func _physics_process(delta: float) -> void:
	handle_input()
	handle_rotation(delta)
	handle_movement(delta)
	move_and_slide()

func handle_input() -> void:
	if input_node:
		input_state = input_node.state
		
	if input_state == null:
		return
	
	turret.apply_input(input_state)
	
func handle_movement(delta):
	var forward := -transform.basis.z
	var target_speed := input_state.move * move_speed
	var current_speed := velocity.dot(forward)
	
	var accel := acceleration if abs(input_state.move) > 0 else deceleration
	var new_speed := move_toward(current_speed, target_speed, accel * delta)
	
	velocity = forward * new_speed
	velocity.y = 0.0
		
func handle_rotation(delta):
	var is_reversing := input_state.move < 0
	
	var turn = input_state.turn
	turn *= -1.0 if is_reversing else 1.0
	
	rotation.y += turn * turn_speed * delta
	
