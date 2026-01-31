extends CharacterBody3D

@onready var input_node := $TankInput
@onready var turret := $TurretPivot
@onready var muzzle := $TurretPivot/Muzzle

# MOVEMENT
@export var move_speed := 750.0
@export var turn_speed := 2.5
@export var acceleration := 50000.0
@export var deceleration := 150.0

# FIRING
@export var shell_scene: PackedScene
@export var fire_cooldown := 0.4


var can_fire := true
var input_state : TankInputState
var player_id := 0
	
func _physics_process(delta: float) -> void:
	handle_input()
	if input_state == null:
		return
	handle_rotation(delta)
	handle_movement(delta)
	move_and_slide()

func handle_input() -> void:
	if input_node:
		input_state = input_node.state
		
	if input_state == null:
		return
	
	turret.apply_input(input_state)
	if (input_state.fire):
		request_fire()
	
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
	
func request_fire():
	if not can_fire:
		return
		
	can_fire = false
	fire_shell()
	await get_tree().create_timer(fire_cooldown).timeout
	can_fire = true
	
func fire_shell():
	if (!shell_scene):
		push_error("shell_scene not set on tank")
		return
		
	var shell = shell_scene.instantiate()
	shell.global_transform = muzzle.global_transform
	shell.fire(-muzzle.global_basis.z, player_id)

	get_tree().current_scene.add_child(shell)
	
	
