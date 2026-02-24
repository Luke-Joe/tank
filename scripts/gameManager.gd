class_name GameManager
extends Node

signal state_changed(state: MatchState)
signal score_changed(id: int, score: int)
signal round_time_changed(time_left: float)
signal round_ended(winner_id: int, scores: Dictionary)

enum MatchState { LOBBY, IN_ROUND, ROUND_END }

@export var tank_scene: PackedScene
@export var round_seconds := 60.0
@export var respawn_delay := 2.0
@export var intermission_seconds := 3.0
@export var auto_start_when_players := 2

var state: MatchState = MatchState.LOBBY
var tanks: Dictionary = {}  # id => tank
var scores: Dictionary = {}  # id => scores
var active_players: Array[int] = []
var pending_players: Array[int] = []
var remaining_players: int
var time_left := 0.0

@onready var arena_generator = $"../Arena/ArenaGenerator"
@onready var lobby = $"../Lobby"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	lobby.all_players_ready.connect(_on_all_players_ready)
	arena_generator.arena_ready.connect(_on_arena_ready)

	_set_state(MatchState.LOBBY)


func _physics_process(_delta: float) -> void:
	if state != MatchState.IN_ROUND:
		return


func end_round() -> void:
	if state != MatchState.IN_ROUND:
		return

	_set_state(MatchState.ROUND_END)

	get_tree().paused = true

	var winner_id := _get_winner_id()


func _get_winner_id() -> int:
	var winner_id := -1
	var max_score := -1

	for id in active_players:
		var score = scores.get(id)
		if score > max_score:
			max_score = score
			winner_id = id

	return winner_id


func _set_state(s: MatchState) -> void:
	state = s
	print("Match State: ", state)
	state_changed.emit(state)


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

		get_parent().add_child(tank)

	_set_state(MatchState.IN_ROUND)


func _on_all_players_ready(player_ids: Array[int]) -> void:
	var arena_seed = randi()
	_start_game.rpc(arena_seed, player_ids)


@rpc("authority", "reliable", "call_local")
func _start_game(arena_seed: int, player_ids: Array[int]) -> void:
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
