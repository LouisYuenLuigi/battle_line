extends Node2D

var MAX_HAND_COUNT
const CARD_WIDTH = 150
const HAND_Y_POSITION = 1340
const DEFAULT_CARD_MOVE_SPEED = 0.1
const TEST_SLOW_ASS_SPEED = 1
const CARD_DRAW_SPEED = 0.2
const DEFAULT_CARD_SCALE = 1

var flag_states = []

var player_hand = []
var center_screen_x
var center_screen_y
var mid_position
@onready var deck_reference = $"../Deck"
@onready var tactics_deck_reference = $"../TacticsDeck"
@onready var input_manager_reference = $"../InputManager"
@onready var card_manager_reference = $"../CardManager"
@onready var scout_panel_reference = $"../ScoutPanel"
@onready var scout_draw_limit = 3
@onready var scout_draw_count = 0
@onready var choosing_scouted_cards = false
var scouted_cards_to_discard = []
@onready var discard_limit = 2
#@onready var discard_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MAX_HAND_COUNT = 7
	center_screen_x = get_viewport().size.x / 2
	center_screen_y = get_viewport().size.y / 2
	mid_position = Vector2(center_screen_x,center_screen_y)
	for i in $"../CenterContainer/Flags".get_child_count():
		flag_states.append(0)

#func connect_click_signals(input_manager_reference):
	#input_manager_reference.connect("left_mouse_button_clicked",click)

#func click():
	#pass

func pick_card(card_found):
	if !choosing_scouted_cards:
		return
	
	if scouted_cards_to_discard.has(card_found):
		return
		#print("unpicking " + str(card_found))
	if !scouted_cards_to_discard.size() >= discard_limit:
		card_found.z_index += 100
		#card_found.position.y -= 150
		#
		#idk how to put the tween and await it outside the function
		#will find a workaround when i can/want to
		#this works for now, same with the return disacrded cards function
		#
		#animate_card_to_position(card_found, mid_position, TEST_SLOW_ASS_SPEED)
		var tween = get_tree().create_tween()
		tween.tween_property(card_found, "position", mid_position, DEFAULT_CARD_MOVE_SPEED)
		await tween.finished
		remove_card_from_hand(card_found)
		card_found.visible = false
		scouted_cards_to_discard.append(card_found)
		scout_panel_reference.add_choices(card_found)
	

func scout():
	MAX_HAND_COUNT = 10
	deck_reference.toggle_scouting(true)
	tactics_deck_reference.toggle_scouting(true)
	scout_panel_reference.start()

func increment_scouted_cards():
	scout_draw_count += 1
	if scout_draw_count >= scout_draw_limit:
		deck_reference.toggle_scouting(false)
		tactics_deck_reference.toggle_scouting(false)
		MAX_HAND_COUNT = 7
		choose_scouted_cards()

func choose_scouted_cards():
	choosing_scouted_cards = true
	card_manager_reference.toggle_choosing_scouted_cards(true)
	#scout_panel_reference.start()
	scout_panel_reference.start_discard()
	
func remove_discard_choice(card_UI_to_remove):
	var card_to_remove = card_UI_to_remove.card_copied
	#print("not gon discard "+ str(card_to_remove))
	scout_panel_reference.remove_choice(card_to_remove)
	scouted_cards_to_discard.erase(card_to_remove)
	card_to_remove.visible = true
	card_to_remove.scale = Vector2(DEFAULT_CARD_SCALE,DEFAULT_CARD_SCALE)
	#card_found.disabled = false
	card_to_remove.z_index -= 100
	#card_found.position.y += 150
	add_card_to_hand(card_to_remove, DEFAULT_CARD_MOVE_SPEED)
	#print("unpicking " + str(card_found))

func return_discarded_cards():
	deck_reference.toggle_scouting(false)
	tactics_deck_reference.toggle_scouting(false)
	card_manager_reference.toggle_choosing_scouted_cards(false)
	choosing_scouted_cards = false
	#print("i will return fucking " + str(scouted_cards_to_discard))
	for card in scouted_cards_to_discard:
		card.visible = true
		if card.card_type == "troops":
			deck_reference.insert_card_in_front(card.card_id)
			#card.get_node("AnimationPlayer").play_backwards("card_flip")
			var tween = get_tree().create_tween()
			var new_position = deck_reference.position
			new_position.x -= card.size.x
			new_position.y -= card.size.y
			tween.tween_property(card, "position", new_position, CARD_DRAW_SPEED)
			await tween.finished
		else:
			tactics_deck_reference.insert_card_in_front(card.card_id)
			#card.get_node("AnimationPlayer").play_backwards("card_flip")
			var tween = get_tree().create_tween()
			var new_position = tactics_deck_reference.position
			new_position.x -= card.size.x
			new_position.y -= card.size.y
			tween.tween_property(card, "position", new_position, CARD_DRAW_SPEED)
			await tween.finished
		card.queue_free()
	scouted_cards_to_discard.clear()

func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.position_in_hand, DEFAULT_CARD_MOVE_SPEED)
	

func update_hand_positions(speed):
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.position_in_hand = new_position
		animate_card_to_position(card, new_position, speed)
	

func calculate_card_position(index):
	var total_width = (player_hand.size() -1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset
	
func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
	#tween.connect("finished", on_tween_finished.bind(card))
	
#func on_tween_finished(card_to_remove):
	#if choosing_scouted_cards:
		#print("tween done whatthe fuck " + str(card_to_remove.card_id))
		#card_to_remove.visible = true


func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
