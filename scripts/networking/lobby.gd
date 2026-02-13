class_name Lobby
extends Node

@export var port: int = 7000
var players: Dictionary = {}
 
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed) 
	
	if "--server" in OS.get_cmdline_user_args():
		host_game()
	else:
		join_game("127.0.0.1")


func host_game() -> void:
	var peer = ENetMultiplayerPeer.new()
	
	var response = peer.create_server(port)
	if (response != OK):
		print("Failed to host: ", response)
		return
	
	multiplayer.multiplayer_peer = peer
	print("Hosting on port: ", port)
	players[multiplayer.get_unique_id()] = {}
	
func join_game(address: String) -> void:
	var peer = ENetMultiplayerPeer.new()
	var response = peer.create_client(address, port)
	if (response != OK):
		print("Failed to join: ", response)
		return
	
	multiplayer.multiplayer_peer = peer
	print("Joining ", address, ":", port)
	
func _on_peer_connected(id: int) -> void:
	print("Peer connected: ", id)
	players[id] = {}
	
func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: ", id)
	players.erase(id)
	
func _on_connected() -> void:
	print("Connected to server!	")
	
	
func _on_connection_failed() -> void:
	print("Connection failed!")
