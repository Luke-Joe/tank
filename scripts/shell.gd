extends Node3D

@export_group("Movement")
@export var speed := 1.5
@export var lifetime := 5.0

@export_group("Collision")
@export var max_bounces := 8
@export var min_margin := 0.05
@export var max_margin := 0.07
@export var damage := 1

@onready var cast := $ShapeCast3D

var bounces := 0
var direction := Vector3.ZERO
var shooter_id: int

signal shell_despawned(shell: Node)
signal shell_bounced()

class CollisionResult:
	var point: Vector3
	var normal: Vector3
	var distance: float
	var collider: Node3D
	
	func _init(p: Vector3, n: Vector3, d: float, c: Node3D) -> void:
		point = p
		normal = n
		distance = d
		collider = c

func fire(dir: Vector3, shooter_id: int) -> void:
	direction = dir.normalized()
	shooter_id = shooter_id
	
func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		_despawn()
		return
		
	_process_movement(delta)
		

func _process_movement(delta: float) -> void:	
	var distance_to_travel := speed * delta
	var motion := direction * distance_to_travel
	
	cast.target_position = motion
	cast.force_shapecast_update()
	
	if !cast.is_colliding():
		global_position += motion
		return
	
	var collision_data = _get_collision_data()
	
	if (!collision_data):
		return
		
	global_position += direction * collision_data.distance
	
	if _try_deal_damage(collision_data):
		_despawn()
		return
		
	_apply_bounce(collision_data)
		

func _check_collision(motion: Vector3) -> bool:
	cast.target_position = motion
	cast.force_shapecast_update()
	return cast.is_colliding()

func _get_collision_data() -> CollisionResult:
	if !cast.is_colliding():
		return null
		
	return CollisionResult.new(
		cast.get_collision_point(0),
		cast.get_collision_normal(0).normalized(),
		global_position.distance_to(cast.get_collision_point(0)),
		cast.get_collider(0)
	)

func _try_deal_damage(collision_data: CollisionResult) -> bool:
	var hit := collision_data.collider
	
	if hit == null:
		return false
		
	if (hit.is_in_group('damageable') and hit.has_method('receive_damage')):
		print('receiving damage: ', hit.name)
		hit.receive_damage(HitInfo.new(damage, shooter_id))
		return true
		
	return false
	

func _apply_bounce(collision_data: CollisionResult) -> bool:
	bounces += 1
		
	if bounces >= max_bounces:
		_despawn()
		return false
		
	var normal := collision_data.normal
	
	var impact_angle = abs(direction.dot(normal))
	
	direction = direction.bounce(normal).normalized()
	
	global_position += normal * _calculate_adaptive_margin(impact_angle)
	
	shell_bounced.emit(collision_data.point, normal, bounces)
	
	return true

func _calculate_adaptive_margin(impact_angle: float) -> float:	
	return lerp(min_margin, max_margin, impact_angle)

func _ready() -> void:
	print("shell ready")

func _despawn():
	shell_despawned.emit(self)
	queue_free()
