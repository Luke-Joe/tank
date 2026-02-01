extends RigidBody3D

@export var speed := 175.0
@export var lifetime := 7.5

var owner_id: int = -1

signal shell_despawned(shell: Node)

func fire(direction: Vector3, owner: int) -> void:
	owner_id = owner
	linear_velocity = direction.normalized() * speed
	
func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		shell_despawned.emit(self)
		queue_free()
		
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("shell ready")

func _on_body_entered(body: Node) -> void:
	print("shell hit: ", body.name)
	queue_free()
