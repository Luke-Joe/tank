extends CharacterBody3D

signal died(player_id: int, killer_id: int)

@export_group("Movement")
@export var move_speed := 750.0
@export var turn_speed := 2.5
@export var acceleration := 50000.0
@export var deceleration := 150.0

@export_group("Firing")
@export var shell_scene: PackedScene
@export var fire_cooldown := 0.4
@export var max_active_shells := 5

var active_shells := 0
var input_state: TankInputState
var player_id := 0
var can_fire := true
var is_dead := false

@onready var input_node := $TankInput
@onready var turret := $TurretPivot
@onready var muzzle := $TurretPivot/Muzzle
@onready var health := $Health


func _ready() -> void:
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if not is_inside_tree() or is_dead:
		return

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
	if input_state.fire:
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
	if not _can_shoot():
		return

	can_fire = false
	_fire_shell.rpc(muzzle.global_position, -muzzle.global_basis.z)
	await get_tree().create_timer(fire_cooldown).timeout
	can_fire = true


func _can_shoot() -> bool:
	return can_fire and active_shells < max_active_shells and is_inside_tree()


@rpc("any_peer", "reliable", "call_local")
func receive_damage(damage: int, source_id: int) -> void:
	health._apply_damage(HitInfo.new(damage, source_id))


@rpc("any_peer", "reliable", "call_local")
func _fire_shell(spawn_position: Vector3, direction: Vector3) -> void:
	if !shell_scene:
		push_error("shell_scene not set on tank")
		return

	var shell = shell_scene.instantiate()
	get_tree().current_scene.add_child(shell)
	shell.set_multiplayer_authority(player_id)
	shell.global_position = spawn_position
	shell.add_to_group(Groups.SHELL)
	shell.fire(direction, player_id)
	shell.shell_despawned.connect(_on_shell_despawned)
	active_shells += 1


func _on_shell_despawned(_shell: Node) -> void:
	active_shells -= 1
	print("active shells:", active_shells)


func _on_died(source_id: int) -> void:
	if is_dead:
		return

	is_dead = true
	died.emit(player_id, source_id)
	hide()
	disable_tank()


func disable_tank() -> void:
	set_physics_process(false)
	set_collision_layer(0)
	set_collision_mask(0)
