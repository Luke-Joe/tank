extends Control

@onready var network_manager = $NetworkManager
@onready var join_code_label = $CenterContainer/VBoxContainer/HBoxContainer/CodeLabel
@onready var player_list = $CenterContainer/VBoxContainer/PlayerList
@onready var copy_button = $CenterContainer/VBoxContainer/HBoxContainer/Copy
@onready var start_button = $CenterContainer/VBoxContainer/Start


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.visible = ConnectionState.is_host

	network_manager.room_joined.connect(_on_room_joined)
	multiplayer.peer_connected.connect(_on_player_joined)


func _on_room_joined(join_code: String) -> void:
	join_code_label.text = join_code


func _on_player_joined(id: int) -> void:
	var label = Label.new()
	label.text = "Player " + str(id)
	player_list.add_child(label)


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(join_code_label.text)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
