extends RigidBody3D

@export var speed := 25.0
@export var lifetime := 7.5

var owner_id: int = -1

func fire(direction: Vector3, owner: int) -> void:
	owner_id = owner
	linear_velocity = direction.normalized() * speed
	
func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	queue_free()
