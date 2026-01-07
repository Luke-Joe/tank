extends CharacterBody3D

@export var move_speed := 750.0
@export var turn_speed := 2.5
@export var acceleration := 50000.0
@export var deceleration := 150.0

func _physics_process(delta: float) -> void:
	handle_rotation(delta)
	handle_movement(delta)
	move_and_slide()

func handle_movement(delta):
	var input := 0.0
	if Input.is_action_pressed("move_forward"):
		input += 1.0
	if Input.is_action_pressed("move_backward"):
		input -= 1.0
		
	var forward := -transform.basis.z
	var target_speed := input * move_speed
	var current_speed := velocity.dot(forward)
	
	var accel := acceleration if abs(input) > 0 else deceleration
	var new_speed := move_toward(current_speed, target_speed, accel * delta)
	
	velocity = forward * new_speed
	velocity.y = 0.0
		
func handle_rotation(delta):
	var reversing := Input.is_action_pressed("move_backward")
	
	var turn := 0.0
	if Input.is_action_pressed("turn_left"):
		turn += 1.0
	if Input.is_action_pressed("turn_right"):
		turn -= 1.0
		
	turn *= -1.0 if reversing else 1.0
		
	rotation.y += turn * turn_speed * delta
