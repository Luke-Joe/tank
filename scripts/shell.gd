extends Node3D

const SURFACE_OFFSET := 0.1

@export_group("Movement")
@export var speed := 150.0
@export var lifetime := 5.0

@export_group("Collision")
@export var max_bounces := 100

@onready var cast := $ShapeCast3D

var bounces := 0
var dir := Vector3.ZERO

signal shell_despawned(shell: Node)

func fire(direction: Vector3) -> void:
	dir = direction.normalized()
	
func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		despawn()
		return
		
	var remaining := speed * delta

	while (remaining > 0.0):
		cast.global_transform = global_transform
		cast.target_position = dir * remaining
		cast.force_shapecast_update()
		
		if (!cast.is_colliding()):
			global_position += dir * remaining
			break
			
		var hit = cast.get_collider(0)
		var impact_normal: Vector3 = cast.get_collision_normal(0).normalized()
		var impact_point: Vector3 = cast.get_collision_point(0)
		var impact_distance: float = impact_point.distance_to(global_position)
		
		print('collision detected with: ', hit.name)	
		global_position += dir * impact_distance
		remaining -= impact_distance

		bounces += 1
		if bounces >= max_bounces:
			despawn()
			return

		# Ricochet
		global_position += impact_normal * SURFACE_OFFSET
		break 
		

func _ready() -> void:
	print("shell ready")

func despawn():
	shell_despawned.emit(self)
	queue_free()
