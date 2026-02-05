extends CharacterBody3D

@onready var health := $Health

func receive_damage(hit: HitInfo) -> void:
	health._apply_damage(hit)
	
