extends PanelContainer
@onready var hbox_container = $HBoxContainer 

const CARD_UI_SCENE_PATH = "res://Scenes/cardUI.tscn"
var opacity_tween: Tween = null
var text_reference
const card_database_reference = preload("res://Scripts/card_database.gd")
const HAND_Y_POSITION = 150
var center_x
var card_slot_showing
const CARD_WIDTH = 115
var cards_in_slot_to_show = []
func _ready() -> void:
	text_reference = $RichTextLabel
	center_x = size.x / 2
	hide()



func _input(event: InputEvent) -> void:
	if visible and event is InputEventMouseMotion:
		global_position = get_global_mouse_position()

func show_cards_in_slot(card_slot_showing):
	var cards_in_slot = card_slot_showing.cards_in_slot
	reset_panel()
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
		#hbox_container.add_child(new_card)
		self.add_child(new_card)
		cards_in_slot_to_show.append(new_card)
	update_positions()
	#print("2: "+str(cards_in_slot))

func update_positions():
	size.x = CARD_WIDTH * cards_in_slot_to_show.size() + 2 * 30
	center_x = size.x / 2
	for i in range(cards_in_slot_to_show.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = cards_in_slot_to_show[i]
		card.position = new_position
	

	

func calculate_card_position(index):
	var total_width = (cards_in_slot_to_show.size() -1) * CARD_WIDTH
	var x_offset = center_x + index * CARD_WIDTH - total_width / 2
	return x_offset

func reset_panel():
	for i in self.get_children():
		if i.name != "RichTextLabel":
			remove_child(i)
	cards_in_slot_to_show.clear()

func toggle(on:bool, card_slot_showing):
	show_cards_in_slot(card_slot_showing)
	if on:
		show()
		modulate.a = 0.0
		tween_opacity(1.0)
	else:
		modulate.a = 1.0
		await tween_opacity(0.0).finished
		hide()
		card_slot_showing = null
		
		
func tween_opacity(to: float):
	if opacity_tween: opacity_tween.kill()
	opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(self, 'modulate:a', to, 0.1)
	return opacity_tween
