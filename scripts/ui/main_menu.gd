extends Control


func _on_host_pressed() -> void:
	ConnectionState.is_host = true
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")


func _on_join_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/join_screen.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
