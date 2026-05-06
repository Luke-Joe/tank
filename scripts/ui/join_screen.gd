extends Control

@onready var join_code_input = $CenterContainer/VBoxContainer/JoinCodeInput


func _on_confirm_pressed() -> void:
	ConnectionState.is_host = false
	ConnectionState.join_code = join_code_input.text
	get_tree().change_scene_to_file("res://scenes/lobby_screen.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
