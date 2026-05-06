class_name Lobby
extends Node

signal all_players_ready(player_ids: Array[int])
signal room_joined(join_code: String)

const LOCAL_WS_SERVER = "ws://localhost:8080"
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
		join_game("JOINCODE123")


func host_game() -> void:
	var peer = RelayMultiplayerPeer.new()
	peer.host(LOCAL_WS_SERVER)
	peer.room_joined.connect(func(code): room_joined.emit(code))
	multiplayer.multiplayer_peer = peer


func join_game(join_code: String) -> void:
	var peer = RelayMultiplayerPeer.new()
	peer.join(LOCAL_WS_SERVER, join_code)
	multiplayer.multiplayer_peer = peer
	print("Joining ", join_code)


func _on_peer_connected(id: int) -> void:
	print("Peer connected: ", id)
	players[id] = {}

	if multiplayer.is_server() and players.size() >= 2:
		var player_ids: Array[int] = []
		player_ids.assign(players.keys())
		all_players_ready.emit(player_ids)


func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: ", id)
	players.erase(id)


func _on_connected() -> void:
	print("Connected to server!	")
	players[multiplayer.get_unique_id()] = {}


func _on_connection_failed() -> void:
	print("Connection failed!")


func _on_room_joined(join_code: String) -> void:
	print("Join code: ", join_code)
	players[multiplayer.get_unique_id()] = {}
