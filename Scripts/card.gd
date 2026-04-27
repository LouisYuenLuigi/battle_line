extends Control

signal hovered
signal hovered_off

var position_in_hand
var card_slot_card_is_in
var card_type
var card_color
var card_value
var card_title
var card_id
var card_UI_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#All cards must be child of Cardmanager or else error
	get_parent().connect_card_signals(self)
	

#func revise_card(card_slot_found, card_or_tactic_in_slot):
	#
	#print(card_being_dragged.name)
	#card_or_tactic_in_slot.append(card_being_dragged)
	#var new_z_index = 2 * card_or_tactic_in_slot.size()
	#deck_reference.add_to_played_cards(card_being_dragged)
	#card_being_dragged.get_node("CardImage").z_index = new_z_index
	#card_being_dragged.get_node("CardDesign").z_index = new_z_index
	#card_being_dragged.get_node("NumberRightBottom").z_index = new_z_index
	#card_being_dragged.get_node("NumberLeftTop").z_index = new_z_index
	#card_being_dragged.get_node("NumberCenter").z_index = new_z_index
	#is_hovering_on_card = false
	#card_being_dragged.card_slot_card_is_in = card_slot_found
	#player_hand_reference.remove_card_from_hand(card_being_dragged)
	#card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE,CARD_SMALLER_SCALE)
	#card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
	#card_being_dragged.position.x = card_slot_found.global_position.x
	#card_being_dragged.position.y = card_slot_found.global_position.y+ 30 * (card_slot_found.cards_in_slot.size()-1)
	#card_being_dragged = null
	#disable_play()
	#return card_being_dragged

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
