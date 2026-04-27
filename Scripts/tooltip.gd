extends PanelContainer


const CARD_UI_SCENE_PATH = "res://Scenes/cardUI.tscn"
const FADEOUT_TIME = 0.1
var opacity_tween: Tween = null
@onready var text_reference = $VBoxContainer/RichTextLabel
@onready var troops_reference = %Troops
@onready var tactics_reference = $VBoxContainer/Tactics
@onready var vbox_reference = $VBoxContainer
const card_database_reference = preload("res://Scripts/card_database.gd")
const HAND_Y_POSITION = 150
var center_x
var card_slot_showing
const CARD_WIDTH = 115
var cards_in_slot_to_show = []
var tactics_in_slot_to_show = []
var other_UI
const COLLISION_MASK_CARD_SLOT = 2
const card_x_offset = 140 * 1.05
var dragging_card

func _ready() -> void:
	vbox_reference.visible = true
	center_x = size.x / 2
	hide()
	other_UI = false
	dragging_card = false



func _input(event: InputEvent) -> void:
	if visible and event is InputEventMouseMotion:
		global_position = get_global_mouse_position()
		if dragging_card:
			global_position.x += card_x_offset

func show_cards_in_slot(card_slot_showing_local):
	var cards_in_slot = card_slot_showing_local.cards_in_slot
	var tactics_in_slot = card_slot_showing_local.tactics_in_slot
	#print("1: "+str(cards_in_slot))

	text_reference.text = "Cards in Slot:"
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
		new_card.get_node("Area2D/CollisionShape2D").disabled = true

		new_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		troops_reference.add_child(new_card)
		
		cards_in_slot_to_show.append(new_card)
	
	for j in tactics_in_slot:
		var card_scene = preload(CARD_UI_SCENE_PATH)
		var new_card = card_scene.instantiate()
		var card_title = str(j.card_title)
		var card_background_image_path = str("res://Assets/card_designs/tactics.png")
		new_card.get_node("CardImage").texture = load(card_background_image_path)
		var card_background_design_path = str("res://Assets/card_designs/" + card_title + ".png")
		#new_card.get_node("CardDesign").texture = load(card_background_image_path)
		new_card.get_node("NumberCenter").text = card_title
		new_card.get_node("Area2D/CollisionShape2D").disabled = true
		new_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tactics_reference.add_child(new_card)
		tactics_in_slot_to_show.append(new_card)

	#update_positions()
	troops_reference.update_minimum_size()
	tactics_reference.update_minimum_size()
	vbox_reference.update_minimum_size()
	#print("2: "+str(cards_in_slot))


	
func resize():
	troops_reference.set_size(Vector2.ZERO)
	tactics_reference.set_size(Vector2.ZERO)
	vbox_reference.set_size(Vector2.ZERO)
	self.set_size(Vector2.ZERO)

#func calculate_card_position(index):
	#var total_width = (cards_in_slot_to_show.size() -1) * CARD_WIDTH
	#var x_offset = center_x + index * CARD_WIDTH - total_width / 2
	#return x_offset

func reset_panel():

	cards_in_slot_to_show.clear()
	tactics_in_slot_to_show.clear()
	for child in troops_reference.get_children():
		#child.queue_free()
		troops_reference.remove_child(child)
	for child in tactics_reference.get_children():
		child.queue_free()
		#tactics_reference.remove_child(child)
	resize()

func toggle(on:bool, card_slot_showing_local):
	if on and !other_UI:
		reset_panel()
		show_cards_in_slot(card_slot_showing_local)
		resize()
		show()
		modulate.a = 0.0
		tween_opacity(1.0)

	else:
		modulate.a = 1.0
		await tween_opacity(0.0).finished
		hide()
		card_slot_showing_local = null
		reset_panel()

func dragging(on):
	dragging_card = on
	
		
func tween_opacity(to: float):
	if opacity_tween: opacity_tween.kill()
	opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(self, 'modulate:a', to, FADEOUT_TIME)
	return opacity_tween
