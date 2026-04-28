extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

const DEFAULT_CARD_MOVE_SPEED = 0.1
const DEFAULT_CARD_SCALE = 1
const CARD_BIGGER_SCALE = 1.05
const CARD_SMALLER_SCALE = 0.8
const SUPER_HOVER_Z_INDEX = 10
@onready var dragging_or_not = false

@onready var tooltip_reference = $"../Tooltip"
var screen_size
var card_being_dragged
var is_hovering_on_card
@onready var player_hand_reference = $"../PlayerHand"
@onready var deck_reference = $"../Deck"
var played_card_this_turn
var flag_states = []
var card_slot_found

@onready var choosing_scouted_cards = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	played_card_this_turn = false
	screen_size = get_viewport_rect().size
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)
	
	
	for i in $"../CenterContainer/Flags".get_child_count():
		flag_states.append(0)
#


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x,0,screen_size.x), clamp(mouse_pos.y,0,screen_size.y))

			

func start_drag(card):
	dragging_or_not = true
	if choosing_scouted_cards:
		return
	card_being_dragged = card
	card.scale = Vector2(CARD_BIGGER_SCALE,CARD_BIGGER_SCALE)
	card_being_dragged.get_node("CardImage").z_index += SUPER_HOVER_Z_INDEX
	card_being_dragged.get_node("CardDesign").z_index += SUPER_HOVER_Z_INDEX
	card_being_dragged.get_node("NumberRightBottom").z_index += SUPER_HOVER_Z_INDEX
	card_being_dragged.get_node("NumberLeftTop").z_index += SUPER_HOVER_Z_INDEX
	card_being_dragged.get_node("NumberCenter").z_index += SUPER_HOVER_Z_INDEX
	tooltip_reference.dragging(true)

func toggle_highlight(on, card_slot_to_highlight):
	if !on:
		card_slot_to_highlight.highlight(on)
		return
	if !played_card_this_turn and dragging_or_not:
		card_slot_to_highlight.highlight(on)

func set_card_slot(slot):
	card_slot_found = slot

func toggle_choosing_scouted_cards(value:bool):
	choosing_scouted_cards = (value)

func finish_drag():
	dragging_or_not = false
	card_being_dragged.scale = Vector2(DEFAULT_CARD_SCALE,DEFAULT_CARD_SCALE)
	card_being_dragged.get_node("CardImage").z_index -= SUPER_HOVER_Z_INDEX
	card_being_dragged.get_node("CardDesign").z_index -= SUPER_HOVER_Z_INDEX
	card_being_dragged.get_node("NumberRightBottom").z_index -= SUPER_HOVER_Z_INDEX
	card_being_dragged.get_node("NumberLeftTop").z_index -= SUPER_HOVER_Z_INDEX
	card_being_dragged.get_node("NumberCenter").z_index -= SUPER_HOVER_Z_INDEX
	var card_slot_found = raycast_check_for_card_slot()
	tooltip_reference.dragging(false)
	#print(raycast_check_for_card_slot())
	#print("testo test: "+str(card_slot_found))
	if card_slot_found:
		if card_slot_found.name == "CardSlot":
			#print(card_being_dragged.name)
			match card_being_dragged.card_type:
				"troops":
					if card_slot_found and card_slot_found.cards_in_slot.size()<card_slot_found.MAX_CARDS_IN_SLOT and !card_slot_found.finished and !played_card_this_turn:
						card_being_dragged = revise_card(card_slot_found, card_slot_found.cards_in_slot)
						deck_reference.add_to_played_cards(card_being_dragged)
						
						#print("in troop basic new indingga is: "+str(card_being_dragged.get_node("CardImage").z_index))
						card_being_dragged = null
						disable_play()
						if card_slot_found.cards_in_slot.size() >= card_slot_found.MAX_CARDS_IN_SLOT:
							card_slot_found.submit()
						card_slot_found.trigger_slot_tooltip(true)
						return
				"guile", "environment":
					if card_slot_found and !card_slot_found.finished and !played_card_this_turn:
						card_being_dragged = revise_card(card_slot_found, card_slot_found.tactics_in_slot)
						card_being_dragged.position.y += 250
						card_slot_found.execute_tactic(card_being_dragged.card_id)
						card_being_dragged = null
						disable_play()
						card_slot_found.trigger_slot_tooltip(true)
						return
				"morale":
					if card_slot_found and card_slot_found.cards_in_slot.size()<card_slot_found.MAX_CARDS_IN_SLOT and !card_slot_found.finished and !played_card_this_turn:
						card_being_dragged = revise_card(card_slot_found, card_slot_found.tactics_in_slot)
						card_being_dragged.position.y += 250
						card_slot_found.execute_tactic(card_being_dragged.card_id)
						card_being_dragged = null
						disable_play()
						card_slot_found.trigger_slot_tooltip(true)
						return
	player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null
	


func revise_card(card_slot_found, card_or_tactic_in_slot):
	
	#print(card_being_dragged.name)
	card_or_tactic_in_slot.append(card_being_dragged)
	var new_z_index = 2 * card_or_tactic_in_slot.size()
	card_being_dragged.get_node("CardImage").z_index = new_z_index
	card_being_dragged.get_node("CardDesign").z_index = new_z_index
	card_being_dragged.get_node("NumberRightBottom").z_index = new_z_index
	card_being_dragged.get_node("NumberLeftTop").z_index = new_z_index
	card_being_dragged.get_node("NumberCenter").z_index = new_z_index
	is_hovering_on_card = false
	card_being_dragged.card_slot_card_is_in = card_slot_found
	player_hand_reference.remove_card_from_hand(card_being_dragged)
	
	card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE,CARD_SMALLER_SCALE)
	card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
	card_being_dragged.position.x = card_slot_found.global_position.x
	card_being_dragged.position.y = card_slot_found.global_position.y+ 30 * (card_or_tactic_in_slot.size()-1)
	#card_slot_found.get_node("CardContainer").add_child(card_being_dragged)
	#card_being_dragged.reparent(card_slot_found.get_node("CardContainer"))
	#print(card_slot_found.get_node("CardContainer").get_children())
	return card_being_dragged

func on_left_click_released():
	if card_being_dragged:
		finish_drag()


func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card,true)
	
func on_hovered_off_card(card):
	if !card.card_slot_card_is_in && !card_being_dragged:
		highlight_card(card,false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered,true)
		else:
			is_hovering_on_card = false
			
	
func disable_play():
	played_card_this_turn = true

func highlight_card(card,hovered):
	if hovered:
		card.scale = Vector2(CARD_BIGGER_SCALE,CARD_BIGGER_SCALE)
		card.z_index = 2
	else:
		card.scale = Vector2(DEFAULT_CARD_SCALE,DEFAULT_CARD_SCALE)
		card.z_index = 1
		

func update_flag_states(index, win):
	if win:
		flag_states[index] = 1
	else:
		flag_states[index] = -1
	print("player flags: " + str(flag_states))
	check_win()

func check_win():
	if flag_states.count(1) >= 5:
		print("PLAYER HAS WON THE GAME")
		return
	var consecutive_wins = 0
	for i in flag_states:
		if i == 1:
			consecutive_wins += 1
			if consecutive_wins >= 3:
				print("PLAYER HAS WON THE GAME")
				return
		else:
			consecutive_wins = 0
		
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	#print(result)
	if result.size() > 0:
		return result[0].collider.get_parent()
		#return get_card_with_highest_z_index(result)
	return null
	


func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	
	if result.size() > 0:
		#return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null



func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1,cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
