extends CharacterBody3D

@onready var input_node := $TankInput
@onready var turret := $TurretPivot
@onready var muzzle := $TurretPivot/Muzzle
@onready var health := $Health

@export_group("Movement")
@export var move_speed := 750.0
@export var turn_speed := 2.5
@export var acceleration := 50000.0
@export var deceleration := 150.0

@export_group("Firing")
@export var shell_scene: PackedScene
@export var fire_cooldown := 0.4
@export var max_active_shells := 100

var active_shells := 0
var input_state : TankInputState
var player_id := 0
var can_fire := true
var is_dead := false

func _ready() -> void:
	health.died.connect(_on_died)
	

func _physics_process(delta: float) -> void:
	_handle_input()
	if input_state == null:
		return
	_handle_rotation(delta)
	_handle_movement(delta)
	move_and_slide()

func _handle_input() -> void:
	if input_node:
		input_state = input_node.state
		
	if input_state == null:
		return
	
	turret.apply_input(input_state)
	if (input_state.fire):
		_request_fire()
	
func _handle_movement(delta):
	var forward := -transform.basis.z
	var target_speed := input_state.move * move_speed
	var current_speed := velocity.dot(forward)
	
	var accel := acceleration if abs(input_state.move) > 0 else deceleration
	var new_speed := move_toward(current_speed, target_speed, accel * delta)
	
	velocity = forward * new_speed
	velocity.y = 0.0
		
func _handle_rotation(delta) -> void:
	var is_reversing := input_state.move < 0
	
	var turn = input_state.turn
	turn *= -1.0 if is_reversing else 1.0
	
	rotation.y += turn * turn_speed * delta

func _request_fire() -> void:
	if not can_fire or active_shells >= max_active_shells:
		return
		
	can_fire = false
	_fire_shell()
	await get_tree().create_timer(fire_cooldown).timeout
	can_fire = true

func receive_damage(hit: HitInfo) -> void:
	health._apply_damage(hit)

func _fire_shell() -> void:
	if (!shell_scene):
		push_error("shell_scene not set on tank")
		return
		
	var shell = shell_scene.instantiate()
	shell.global_position = muzzle.global_position
	get_tree().current_scene.add_child(shell)
	shell.fire(-muzzle.global_basis.z, player_id)
	shell.shell_despawned.connect(_on_shell_despawned)
	
	active_shells += 1
	print("firing shell")
	
func _on_shell_despawned(shell: Node) -> void:
	active_shells -= 1
	print('active shells:', active_shells)
	
func _on_died(source_id: int) -> void:
	if is_dead: 
		return
	
	is_dead = true
	
	
