class_name RelayMultiplayerPeer
extends MultiplayerPeerExtension

signal room_joined(join_code: String)

const MAX_PACKET_BYTES := 65536

var _socket := WebSocketPeer.new()
var _unique_id := 0
var _host_id := 0
var _target_peer := 0
var _status := MultiplayerPeer.CONNECTION_DISCONNECTED
var _incoming := []
var _join_code := ""
var _is_host := false


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

	if _socket.get_available_packet_count() > 0:
		print("packets available: ", _socket.get_available_packet_count())

	var socket_state = _socket.get_ready_state()

	if (
		socket_state == WebSocketPeer.STATE_CLOSED
		and _status != MultiplayerPeer.CONNECTION_DISCONNECTED
	):
		_status = MultiplayerPeer.CONNECTION_DISCONNECTED
		return

	while _socket.get_available_packet_count() > 0:
		var raw = _socket.get_packet()
		var msg = JSON.parse_string(raw.get_string_from_utf8())
		_handle_message(msg)


func _handle_message(msg: Dictionary) -> void:
	print("_handle_message: ", msg.get("type", ""))
	var msg_type = RelayMessageType.string_to_server(msg.get("type", ""))

	match msg_type:
		RelayMessageType.Server.ID_ASSIGNED:
			_unique_id = msg.get("id")
			if _is_host:
				_send({"type": RelayMessageType.client_to_string(RelayMessageType.Client.CREATE)})
			else:
				_send(
					{
						"type": RelayMessageType.client_to_string(RelayMessageType.Client.JOIN),
						"joinCode": _join_code
					}
				)
		RelayMessageType.Server.ROOM_JOINED:
			_host_id = msg.get("hostId")
			_status = MultiplayerPeer.CONNECTION_CONNECTED
			var peers: Array = msg.get("peers", [])
			for relay_id in peers:
				if relay_id != _unique_id:
					var godot_id = (
						MultiplayerPeer.TARGET_PEER_SERVER if relay_id == _host_id else relay_id
					)
					emit_signal("peer_connected", godot_id)
			room_joined.emit(msg.get("joinCode"))

		RelayMessageType.Server.PEER_CONNECTED:
			var peer_id: int = msg.get("peerId")
			emit_signal("peer_connected", peer_id)

		RelayMessageType.Server.PEER_DISCONNECTED:
			var peer_id: int = msg.get("peerId")
			emit_signal("peer_disconnected", peer_id)

		RelayMessageType.Server.RELAY:
			var from: int = msg.get("from")
			if from == _host_id:
				from = MultiplayerPeer.TARGET_PEER_SERVER

			var data: PackedByteArray = Marshalls.base64_to_raw(msg.get("data", ""))
			_incoming.append({"peer": from, "data": data})

		RelayMessageType.Server.ERROR:
			push_error("Relay error: " + str(msg.get("message", "")))

		_:
			push_error("Unhandled message type: " + str(msg.get("type", "")))


func _get_unique_id() -> int:
	if _is_host:
		return MultiplayerPeer.TARGET_PEER_SERVER

	return _unique_id


func _get_connection_status() -> ConnectionStatus:
	return _status


func _is_server() -> bool:
	return _is_host


func _get_max_packet_size() -> int:
	return MAX_PACKET_BYTES


func _set_target_peer(peer: int) -> void:
	_target_peer = peer


func _get_packet_peer() -> int:
	return _incoming[0]["peer"]


func _get_available_packet_count() -> int:
	return _incoming.size()


func _get_packet_script() -> PackedByteArray:
	return _incoming.pop_front()["data"]


func _put_packet_script(p_buffer: PackedByteArray) -> Error:
	var target := _host_id if _target_peer == MultiplayerPeer.TARGET_PEER_SERVER else _target_peer

	_send(
		{
			"type": RelayMessageType.client_to_string(RelayMessageType.Client.RELAY),
			"targetPeerId": target,
			"data": Marshalls.raw_to_base64(p_buffer)
		}
	)

	return OK


func _get_packed_mode() -> MultiplayerPeer.TransferMode:
	return MultiplayerPeer.TRANSFER_MODE_RELIABLE


func _disconnect_peer(_peer: int, _force: bool) -> void:
	pass


func _send(data: Dictionary) -> void:
	_socket.send_text(JSON.stringify(data))
