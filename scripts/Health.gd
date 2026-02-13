extends Node

@export var max_health := 1

var health: int

signal damaged(amount: int, health: int)
signal died(source_id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health

func _apply_damage(hit: HitInfo) -> void:
	var amount := hit.damage
	
	if (amount < 0):
		return
	
	health = max(health - amount, 0)
	damaged.emit(amount, health)
	
	print('health: ', health)
	
	if (health <= 0):
		died.emit(hit.source_id)
		

func _die() -> void:
	died.emit(-1)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
