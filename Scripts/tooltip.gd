extends PanelContainer


const CARD_UI_SCENE_PATH = "res://Scenes/cardUI.tscn"
const FADEOUT_TIME = 0.1
var opacity_tween: Tween = null
var text_reference
var hbox_reference
var vbox_reference
const card_database_reference = preload("res://Scripts/card_database.gd")
const HAND_Y_POSITION = 150
var center_x
var card_slot_showing
const CARD_WIDTH = 115
var cards_in_slot_to_show = []
var other_UI
const COLLISION_MASK_CARD_SLOT = 2
const card_x_offset = 140 * 1.05
var dragging_card

func _ready() -> void:
	text_reference = $VBoxContainer/RichTextLabel
	hbox_reference = %HBoxContainer
	vbox_reference = $VBoxContainer
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
		hbox_reference.add_child(new_card)
		
		cards_in_slot_to_show.append(new_card)
	#update_positions()
	hbox_reference.update_minimum_size()
	vbox_reference.update_minimum_size()
	#print("2: "+str(cards_in_slot))

#func update_positions():
	#size.x = CARD_WIDTH * cards_in_slot_to_show.size() + 2 * 30
	#center_x = size.x / 2
	#for i in range(cards_in_slot_to_show.size()):
		#var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		#var card = cards_in_slot_to_show[i]
		#card.position = new_position
	
func resize():
	hbox_reference.set_size(Vector2.ZERO)
	vbox_reference.set_size(Vector2.ZERO)
	self.set_size(Vector2.ZERO)

func calculate_card_position(index):
	var total_width = (cards_in_slot_to_show.size() -1) * CARD_WIDTH
	var x_offset = center_x + index * CARD_WIDTH - total_width / 2
	return x_offset

func reset_panel():
	#for i in self.get_children():
		#if i.name != "RichTextLabel":
			#remove_child(i)
	cards_in_slot_to_show.clear()
	for child in hbox_reference.get_children():
		#child.queue_free()
		hbox_reference.remove_child(child)
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
