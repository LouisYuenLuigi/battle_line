extends Node2D

@onready var picking_opponent = false
@onready var picking_player = false
@onready var input_manager_reference = $"../InputManager"
@onready var card_manager_reference = $"../CardManager"
@onready var guile_card_chooser_reference = $"../GuileCardChooser"
@onready var discard_pile_reference = $"../DiscardPile"
var screen_size
var temp_cards_position
const DEFAULT_CARD_MOVE_SPEED = 0.1
const CARD_SMALLER_SCALE = 0.8
var card_slot_selected
var new_card_slot
var current_tactic
var picked_card
var card_to_move
var opponent_card_slot_of_same_flag

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_slot_selected = null
	picked_card = null
	current_tactic = null
	screen_size = get_viewport_rect().size
	temp_cards_position = Vector2(get_viewport_rect().size.x - 400,get_viewport_rect().size.y - 300)
	

func click():
	#print("nigas is "+str(card_manager_reference.raycast_check_for_card_slot()))
	if !picking_opponent and !picking_player:
		return
	
	new_card_slot = card_manager_reference.raycast_check_for_card_slot()
	if new_card_slot == null:
		return
	#if picking_opponent and new_card_slot.name == "OpponentCardSlot" and new_card_slot.cards_in_slot.size > 0:
		#guile_card_chooser_reference.toggle(true,new_card_slot)
	print(new_card_slot)
	if picking_player and new_card_slot.name == "CardSlot" and new_card_slot != card_slot_selected:
		if new_card_slot.cards_in_slot.size()<new_card_slot.MAX_CARDS_IN_SLOT and !new_card_slot.finished:

			new_card_slot.cards_in_slot.append(card_to_move)
			relocate_card(card_to_move, new_card_slot.global_position)
			new_card_slot.rearrange_cards_y_position()
			if new_card_slot.cards_in_slot.size() >= new_card_slot.MAX_CARDS_IN_SLOT:
				new_card_slot.submit()
			new_card_slot.trigger_slot_tooltip(true)
			picking_player = false
			guile_card_chooser_reference.restore_end_turn()
	if picking_player and new_card_slot.name == "discard" and current_tactic == "redeploy":
		discard_card(card_to_move,"player")
		new_card_slot.trigger_slot_tooltip(true)
		picking_player = false
		guile_card_chooser_reference.restore_end_turn()


func get_picking_opponent():
	return picking_opponent
	
func get_picking_player():
	return picking_player

func deserter(local_card_slot_selected):
	card_slot_selected = local_card_slot_selected
	print("doin nigers")

	current_tactic = "deserter"
	opponent_card_slot_of_same_flag = local_card_slot_selected.get_parent().get_node("OpponentCardSlot")
	guile_card_chooser_reference.toggle(true,opponent_card_slot_of_same_flag)

func traitor(local_card_slot_selected):
	card_slot_selected = local_card_slot_selected
	print("doin trairni")

	current_tactic = "traitor"
	opponent_card_slot_of_same_flag = local_card_slot_selected.get_parent().get_node("OpponentCardSlot")
	guile_card_chooser_reference.toggle(true,opponent_card_slot_of_same_flag)

func redeploy(local_card_slot_selected):
	card_slot_selected = local_card_slot_selected
	print("doin resdeploy")

	current_tactic = "redeploy"
	guile_card_chooser_reference.toggle(true,local_card_slot_selected)

	
func select_card(card_UI):
	if !current_tactic:
		return
	print("yeah i picked "+str(card_UI))
	if picked_card != card_UI:
		if picked_card != null:
			picked_card.highlight_reference.visible = false
		picked_card = card_UI
		picked_card.highlight_reference.visible = true


func isolate_card(card_slot_to_isolate):
	
	card_slot_to_isolate.cards_in_slot.erase(card_to_move)
	card_slot_to_isolate.rearrange_cards_y_position()
	
func relocate_card(card_to_move, position_to_move):
	var tween = get_tree().create_tween()
	tween.tween_property(card_to_move, "position", position_to_move, DEFAULT_CARD_MOVE_SPEED)
	await tween.finished
	

func discard_card(card, player_or_opponent):
	
	discard_pile_reference.cards_in_slot.append(card)
	var tween = get_tree().create_tween()
	var discard_position = Vector2(discard_pile_reference.position.x, discard_pile_reference.position.y)
	if player_or_opponent == "opponent":
		discard_position.x +=  card.size.x * CARD_SMALLER_SCALE
		discard_position.y +=  card.size.y * CARD_SMALLER_SCALE
	
	tween.tween_property(card, "position", discard_position, DEFAULT_CARD_MOVE_SPEED)
	await tween.finished
	discard_pile_reference.rearrange_cards_y_position()

func confirm():
	if !picked_card:
		print("admin give him a negev")
		return
	card_to_move = picked_card.card_copied
	match current_tactic:
		"deserter":
			print("desrting "+ str(picked_card))
			isolate_card(opponent_card_slot_of_same_flag)
			discard_card(card_to_move,"opponent")
			card_to_move.rotation = 0	
			guile_card_chooser_reference.restore_end_turn()
		"traitor":
			print("traiting "+ str(picked_card))
			isolate_card(opponent_card_slot_of_same_flag)
			relocate_card(card_to_move, temp_cards_position)
			picking_player = true
			card_to_move.rotation = 0
			
		"redeploy":
			print("redpeloying "+ str(picked_card))
			isolate_card(card_slot_selected)
			relocate_card(card_to_move, temp_cards_position)
			picking_player = true
			
	
	guile_card_chooser_reference.toggle(false,null)
	guile_card_chooser_reference.reset_panel()
	print("niggabigpenis "+ str(card_slot_selected))
