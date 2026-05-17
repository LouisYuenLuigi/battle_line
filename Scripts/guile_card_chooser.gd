extends PanelContainer

const CARD_UI_SCENE_PATH = "res://Scenes/cardUI.tscn"
const FADEOUT_TIME = 0.1
var opacity_tween: Tween = null
@onready var text_reference = $VBoxContainer/RichTextLabel
@onready var troops_reference = %Troops
@onready var vbox_reference = $VBoxContainer
@onready var tooltip_reference = $"../Tooltip"
@onready var guile_tactics_reference = $"../GuileTactics"
@onready var End_Turn_Button_Reference = $"../EndTurn"
const card_database_reference = preload("res://Scripts/card_database.gd")
const HAND_Y_POSITION = 150
var center_x
var card_slot_showing
const CARD_WIDTH = 115
var cards_in_slot_to_show = []
const COLLISION_MASK_CARD_SLOT = 2
const card_x_offset = 140 * 1.05
var center_screen_x
var center_screen_y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vbox_reference.visible = true
	center_x = size.x / 2
	center_screen_x = get_viewport().size.x / 2
	center_screen_y = get_viewport().size.y / 2
	position = Vector2(center_screen_x - size.x/2,center_screen_y - size.y/2)
	hide()
	
func show_cards_in_slot(card_slot_showing_local):
	var cards_in_slot = card_slot_showing_local.cards_in_slot
	text_reference.text = "Pick a card:"
	for i in cards_in_slot:
		var card_scene = preload(CARD_UI_SCENE_PATH)
		var new_card = card_scene.instantiate()
		
		var card_color = str(i.card_color)
		var card_title = str(i.card_title)
		var card_value = str(i.card_value)
		var card_background_image_path = str("res://Assets/" + card_color + "/" + card_color + ".png")
		new_card.get_node("CardImage").texture = load(card_background_image_path)
		var card_background_design_path = str("res://Assets/card_designs/" + card_title + ".png")
		new_card.get_node("CardDesign").texture = load(card_background_design_path)
		new_card.get_node("NumberCenter").text = card_title
		new_card.get_node("NumberLeftTop").text = str(card_value)
		new_card.get_node("NumberRightBottom").text = str(card_value)
		#new_card.get_node("Area2D/CollisionShape2D").disabled = true
		new_card.card_copied = i
		new_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		troops_reference.add_child(new_card)
		
		cards_in_slot_to_show.append(new_card)
	
	troops_reference.update_minimum_size()
	vbox_reference.update_minimum_size()

func resize():
	troops_reference.set_size(Vector2.ZERO)
	vbox_reference.set_size(Vector2.ZERO)
	self.set_size(Vector2.ZERO)

func reset_panel():

	cards_in_slot_to_show.clear()
	for child in troops_reference.get_children():
		#child.queue_free()
		troops_reference.remove_child(child)

	resize()

func toggle(on:bool, card_slot_showing_local):
	if on:
		reset_panel()
		show_cards_in_slot(card_slot_showing_local)
		tooltip_reference.other_UI = true
		resize()
		show()
		End_Turn_Button_Reference.disabled = true
		End_Turn_Button_Reference.visible = false

	else:

		hide()
		reset_panel()
		tooltip_reference.other_UI = false
		#card_slot_showing_local = null

func restore_end_turn():
	End_Turn_Button_Reference.disabled = false
	End_Turn_Button_Reference.visible = true

func _on_confirm_button_pressed() -> void:
	guile_tactics_reference.confirm()
