class_name GameManager
extends Node

signal state_changed(state: MatchState)

enum MatchState { LOBBY, IN_ROUND, ROUND_END }

@export var tank_scene: PackedScene
@export var intermission_seconds := 1.5
@export var debug_mode := true

var state: MatchState = MatchState.LOBBY
var tanks: Dictionary = {}  # id => tank
var scores: Dictionary = {}  # id => scores
var active_players: Array[int] = []
var pending_players: Array[int] = []
var remaining_players: int

@onready var arena_generator = $"../Arena/ArenaGenerator"
@onready var lobby = $"../Lobby"
@onready var debug_label = $"../CanvasLayer/DebugLabel"
@onready var score_label = $"../CanvasLayer/ScoreLabel"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	lobby.all_players_ready.connect(_on_all_players_ready)
	arena_generator.arena_ready.connect(_on_arena_ready)

	_set_state(MatchState.LOBBY)


func _physics_process(_delta: float) -> void:
	if state != MatchState.IN_ROUND:
		return


func end_round() -> void:
	if not multiplayer.is_server():
		return

	if state != MatchState.IN_ROUND:
		return

	_on_round_ended.rpc()

	await get_tree().create_timer(intermission_seconds, true).timeout

	if multiplayer.is_server():
		var arena_seed = randi()
		_start_game.rpc(arena_seed, active_players)


@rpc("authority", "reliable", "call_local")
func _on_round_ended() -> void:
	_set_state(MatchState.ROUND_END)
	get_tree().paused = true


func _set_state(s: MatchState) -> void:
	state = s
	print("Match State: ", state)
	state_changed.emit(state)
	_update_debug()


func _on_arena_ready(spawn_points: Array[Vector2i], config: ArenaConfig) -> void:
	for index in spawn_points.size():
		var spawn = spawn_points[index]
		var player_id = active_players[index]

		var tank = tank_scene.instantiate()
		tank.position = Vector3(spawn.x * config.cell_size, 0.2, spawn.y * config.cell_size)
		tank.set_multiplayer_authority(player_id)
		tank.player_id = player_id
		tank.died.connect(_on_tank_died)
		tanks[player_id] = tank
		tank.name = "Tank_" + str(player_id)

		get_parent().add_child(tank)

	_set_state(MatchState.IN_ROUND)
	_update_debug()
	_update_scores()


func _on_all_players_ready(player_ids: Array[int]) -> void:
	var arena_seed = randi()
	_start_game.rpc(arena_seed, player_ids)


@rpc("authority", "reliable", "call_local")
func _start_game(arena_seed: int, player_ids: Array[int]) -> void:
	get_tree().paused = false
	await _cleanup_round()

	print("_start_game - seed: ", arena_seed, " peer: ", multiplayer.get_unique_id())

	var config = ArenaConfig.new()
	config.seed = arena_seed
	config.spawn_count = player_ids.size()

	active_players = player_ids
	remaining_players = active_players.size()

	arena_generator.generate_arena(config)


func _on_tank_died(_player_id, killer_id) -> void:
	scores[killer_id] = scores.get(killer_id, 0) + 1
	print("player_id: ", killer_id, " score: ", scores.get(killer_id))

	remaining_players -= 1

	if remaining_players == 1:
		end_round()

	_update_debug()
	_update_scores()


func _cleanup_round() -> void:
	arena_generator.cleanup_arena()
	_cleanup_tanks()
	_cleanup_shells()

	await get_tree().process_frame


func _cleanup_tanks() -> void:
	for tank in tanks.values():
		tank.get_parent().remove_child(tank)
		tank.queue_free()

	tanks.clear()


func _cleanup_shells() -> void:
	for shell in get_tree().get_nodes_in_group(Groups.SHELL):
		shell.queue_free()


func _update_debug() -> void:
	debug_label.visible = debug_mode
	debug_label.text = (
		"peer: %s\n, state: %s"
		% [
			multiplayer.get_unique_id(),
			state,
		]
	)


func _update_scores() -> void:
	var lines := []

	for i in active_players.size():
		var id = active_players[i]
		lines.append("P%d: %d" % [i + 1, scores.get(id, 0)])

	score_label.text = "\n".join(lines)
