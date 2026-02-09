extends Node

class_name GameManager

enum MatchState { 
	LOBBY, 
	IN_ROUND, 
	ROUND_END
}

@export var tank_scene: PackedScene
@export var round_seconds := 60.0
@export var respawn_delay := 2.0
@export var intermission_seconds := 3.0
@export var auto_start_when_players := 2

var state: MatchState = MatchState.LOBBY
var tanks: Dictionary = {} # id => tank
var scores: Dictionary = {} # id => scores
var active_players: Array[int] = []
var pending_players: Array[int] = []

var time_left := 0.0

signal state_changed(state: MatchState)
signal score_changed(id: int, score: int)
signal round_time_changed(time_left: float)
signal round_ended(winner_id: int, scores: Dictionary)

func _ready() -> void:
	_set_state(MatchState.LOBBY)


func _physics_process(delta: float) -> void:
	if (state != MatchState.IN_ROUND):
		return
		
	time_left -= delta
	round_time_changed.emit(time_left)
	
	if (time_left <= 0.0):
		end_round()
		
func end_round() -> void:
	if (state != MatchState.IN_ROUND):
		return
		
	_set_state(MatchState.ROUND_END)
	
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
