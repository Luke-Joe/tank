class_name RelayMessageType

enum Client { CREATE, JOIN, RELAY, LEAVE }

enum Server { ID_ASSIGNED, ROOM_JOINED, PEER_CONNECTED, PEER_DISCONNECTED, RELAY, ERROR }


static func client_to_string(client: Client) -> String:
	return Client.keys()[client]


static func string_to_server(s: String) -> Server:
	if s in Server:
		return Server[s]
	return Server.ERROR
