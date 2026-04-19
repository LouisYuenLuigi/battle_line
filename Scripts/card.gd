extends Node2D

signal hovered
signal hovered_off

var position_in_hand
var card_slot_card_is_in
var card_type
var card_color
var card_value
var card_title

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#All cards must be child of Cardmanager or else error
	get_parent().connect_card_signals(self)
	

func retrieve_card_value():
	return card_value

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
