extends Node2D
var battle_timer
var available_card_slots = []
var flag_states = []
var card_database_reference
const CARD_MOVE_SPEED = 0.2
const CARD_SMALLER_SCALE = 0.8
var opponent_hand
var deck_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_database_reference = preload("res://Scripts/card_database.gd")
	battle_timer = $"../BattleTimer"
	deck_reference = $"../Deck"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
	available_card_slots.append($"../Flags/Flag1/OpponentCardSlot")
	available_card_slots.append($"../Flags/Flag2/OpponentCardSlot")
	available_card_slots.append($"../Flags/Flag3/OpponentCardSlot")
	available_card_slots.append($"../Flags/Flag4/OpponentCardSlot")
	available_card_slots.append($"../Flags/Flag5/OpponentCardSlot")
	available_card_slots.append($"../Flags/Flag6/OpponentCardSlot")
	available_card_slots.append($"../Flags/Flag7/OpponentCardSlot")
	available_card_slots.append($"../Flags/Flag8/OpponentCardSlot")
	available_card_slots.append($"../Flags/Flag9/OpponentCardSlot")
	opponent_hand = $"../OpponentHand".opponent_hand
	
	for i in $"../Flags".get_child_count():
		flag_states.append(0)



func _on_end_turn_pressed() -> void:
	deck_reference.disable_draw()
	opponent_turn()
	
func opponent_turn():
	$"../EndTurn".disabled = true
	$"../EndTurn".visible = false
	
	battle_timer.start()
	await battle_timer.timeout
	#check for free slots, if no end turn
	if available_card_slots.size()!=0:
		try_play_card_with_highest_value()
	
	#play card in hand with highest value
	
	#wait 1sec
	battle_timer.start()
	await battle_timer.timeout
	
	if $"../Deck".player_deck.size() != 0 && opponent_hand.size() < 7:
		$"../Opponent".draw_card()

	#end turn
	#reset player deck draw
	
	end_opponent_turn()
	

func try_play_card_with_highest_value():
	
	if opponent_hand.size() == 0:
		end_opponent_turn()
		return
	
	var random_available_card_slot = available_card_slots.pick_random()
	#var random_available_card_slot = available_card_slots[3] #test line for stack cards
	
	var highest_value_card = opponent_hand[0]
	for card in opponent_hand:
		#if card_database_reference.CARDS["troops"][card][1] > card_database_reference.CARDS["troops"][highest_value_card][1]:
			#highest_value_card = card
		if card.card_value > highest_value_card.card_value:
			highest_value_card = card
	
	highest_value_card.scale = Vector2(CARD_SMALLER_SCALE,CARD_SMALLER_SCALE)		
	#animate card to position
	var new_placed_card_position = random_available_card_slot.global_position
	new_placed_card_position.x = random_available_card_slot.global_position.x
	new_placed_card_position.y = random_available_card_slot.global_position.y - 30 * random_available_card_slot.cards_in_slot.size()
	
	
	var tween = get_tree().create_tween()
	tween.tween_property(highest_value_card, "position", new_placed_card_position, CARD_MOVE_SPEED)
	highest_value_card.get_node("AnimationPlayer").play("card_flip")
	$"../OpponentHand".remove_card_from_hand(highest_value_card)
	battle_timer.start()
	await battle_timer.timeout
	
	highest_value_card.get_node("CardImage").z_index = 2 * random_available_card_slot.cards_in_slot.size()
	highest_value_card.get_node("CardDesign").z_index = 2 * random_available_card_slot.cards_in_slot.size()
	highest_value_card.get_node("NumberRightBottom").z_index = 2 * random_available_card_slot.cards_in_slot.size()
	highest_value_card.get_node("NumberLeftTop").z_index = 2 * random_available_card_slot.cards_in_slot.size()
	highest_value_card.get_node("NumberCenter").z_index = 2 * random_available_card_slot.cards_in_slot.size()
	
	
	battle_timer.start()
	await battle_timer.timeout
	
	random_available_card_slot.cards_in_slot.append(highest_value_card)
	deck_reference.add_to_played_cards(highest_value_card)
	#deck_reference.show_played_cards()
	if random_available_card_slot.cards_in_slot.size() >= random_available_card_slot.MAX_CARDS_IN_SLOT:
		available_card_slots.erase(random_available_card_slot)
		random_available_card_slot.submit()
	random_available_card_slot.show_cards()
	
	battle_timer.start()
	await battle_timer.timeout
	
func end_opponent_turn():
	#reset player deck draw
	deck_reference.reset_draw()
	$"../EndTurn".disabled = false
	$"../EndTurn".visible = true
	$"../CardManager".played_card_this_turn = false

func update_flag_states(index, win):
	if win:
		flag_states[index] = 1
	else:
		flag_states[index] = -1
	print("opponent flags: " + str(flag_states))
	check_win()

func check_win():
	if flag_states.count(1) >= 5:
		print("OPPONENT HAS WON THE GAME")
		return
	var consecutive_wins = 0
	for i in flag_states:
		if i == 1:
			consecutive_wins += 1
			if consecutive_wins >= 3:
				print("OPPONENT HAS WON THE GAME")
				return
		else:
			consecutive_wins = 0
		
