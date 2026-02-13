class_name ConstraintGridStrategy
extends GenerationStrategy

var directions: Array[Vector2i] = [
	Vector2i(0, -1), # North
	Vector2i(0, 1), # South
	Vector2i(-1, 0), # East
	Vector2i(1, 0) # West
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
