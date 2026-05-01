class_name RelayMultiplayerPeer
extends MultiplayerPeerExtension

var _socket := WebSocketPeer.new()
var _unique_id := 0
var _host_id := 0
var _target_peer := 0
var _status := MultiplayerPeer.CONNECTION_DISCONNECTED
var _incoming := []
var _join_code := ""


func host(relay_url: String) -> void:
	_is_host = true
	_socket.connect_to_url(relay_url)
	_status = MultiplayerPeer.CONNECTION_CONNECTING


func join(relay_url: String, join_code: String) -> void:
	_is_host = false
	_join_code = join_code
	_socket.connect_to_url(relay_url)
	_status = MultiplayerPeer.CONNECTION_CONNECTING


func _poll() -> void:
	_socket.poll()

	while _socket.get_available_packet_count() > 0:
		var raw = _socket.get_packet()
		var msg = JSON.parse_string(raw.get_string_from_utf8())
		_handle_message(msg)


func _handle_message(msg: Dictionary) -> void:
	var msg_type = RelayMessageType.string_to_server(msg.get("type", ""))

	match msg_type:
		RelayMessage.Server.ID_ASSIGNED:
			_unique_id = msg.get("id")
			if _is_host:
