extends Control
const FLAG_MOVE_SPEED = 1

var first
var player_formation_power
var opponent_formation_power
var player_sum
var opponent_sum
var winner
var playerhere
var opponenthere
var player
var opponent
var new_flag_position
var flag_sprite
var flag_id
var battle_manager_reference
var card_manager_reference
var mud
var fog
var conquered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_manager_reference = $"../../../BattleManager"
	card_manager_reference = $"../../../CardManager"
	playerhere = false
	opponenthere = false
	flag_sprite = self.get_node("Flag")
	flag_id = int(name.right(1))
	player = get_node("CardSlot")
	opponent = get_node("OpponentCardSlot")
	conquered = false

func receive(someone,formation_power, sum):
	if !first:
		first =  someone
	match someone:
		"CardSlot":
			player_formation_power = formation_power
			player_sum = sum
			playerhere = true
		"OpponentCardSlot":
			opponent_formation_power = formation_power
			opponent_sum = sum
			opponenthere = true
	if playerhere && opponenthere:
		disable_slots()
		print(compare()+" is the winner!!")
		move_flag()
		update_flag_states()
		

func disable_slots():
	player.disable_slot()
	opponent.disable_slot()

func make_mud():
	playerhere = false
	opponenthere = false
	player.do_mud()
	opponent.do_mud()
	print(" all mudded up nigga")

func make_fog():
	fog = true
	print(" all fogged up nigga")
		
func compare():
	if fog:
		player_formation_power = 1
		opponent_formation_power = 1
	if player_formation_power > opponent_formation_power:
		winner = "player"
		return winner
	elif player_formation_power < opponent_formation_power:
		winner = "opponent"
		return winner
	elif player_formation_power == opponent_formation_power:
		if player_sum > opponent_sum:
			winner = "player"
			return winner
		elif player_sum < opponent_sum:
			winner = "opponent"
			return winner
		elif player_sum == opponent_sum:
			match first:
				"CardSlot": winner = "player"
				"OpponentCardSlot": winner = "opponent"
	return winner

func move_flag():
	match winner:
		"player": new_flag_position.y += 250
		"opponent": new_flag_position.y -= 250
	flag_sprite.z_index += 10
	var tween = get_tree().create_tween()
	tween.tween_property(flag_sprite, "position", new_flag_position, FLAG_MOVE_SPEED)
	flag_sprite.modulate.a = 0

func update_flag_states():
	match winner:
		"player":
			card_manager_reference.update_flag_states(flag_id-1,true)
			battle_manager_reference.update_flag_states(flag_id-1,false)
		"opponent":
			card_manager_reference.update_flag_states(flag_id-1,false)
			battle_manager_reference.update_flag_states(flag_id-1,true)
