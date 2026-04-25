extends PanelContainer
const CARD_UI_SCENE_PATH = "res://Scenes/cardUI.tscn"
const BUTTON_PANEL_SCENE_PATH = "res://Scenes/button_panel.tscn"
const CARD_SMALLER_SCALE = 0.8
var opacity_tween: Tween = null
var text_reference
var card_UI_scene
var button_panel_scene
var hbox_reference
var vbox_reference
var card_ui_reference
const card_database_reference = preload("res://Scripts/card_database.gd")
const HAND_Y_POSITION = 150
var center_x
var center_y
var center_screen_x
var center_screen_y
var card_slot_showing
var new_card
var deck_reference
const CARD_WIDTH = 115
const CARD_UI_SCALE = 2
var colors = ["#b83dba","#ff7f27","#b83dba","#0ed145","#3f48cc","#b83dba"]
				# ["red","orange","yellow","green","blue","purple"]
var button_panel_reference = "res://Scenes/button_panel.tscn"

const DEFAULT_CARD = "red1"
const DEFAULT_COMPANIONCAVALRY = "red8"
var card_color
var card_title
var card_value
var card_background_image_path
var card_background_design_path
var played_tactic
var tooltip_reference
var card_slot_played_in

func _ready() -> void:
	text_reference = $VBoxContainer/RichTextLabel
	hbox_reference = $VBoxContainer/HBoxContainer
	vbox_reference = $VBoxContainer
	card_ui_reference = %Card
	tooltip_reference = $"../Tooltip"
	deck_reference = $"../Deck"
	card_UI_scene = preload(CARD_UI_SCENE_PATH)
	button_panel_scene = preload(BUTTON_PANEL_SCENE_PATH)
	#size = Vector2(get_viewport().size.x / 2 ,get_viewport().size.y / 2)
	#center_x = size.x / 2
	#center_y = size.y / 2
	center_screen_x = get_viewport().size.x / 2
	center_screen_y = get_viewport().size.y / 2
	position = Vector2(center_screen_x - size.x/2,center_screen_y - size.y/2)
	#print("position is " + str(position))
	hide()

func start(tactic, card_slot):
	card_slot_played_in = card_slot
	new_card = null
	tooltip_reference.other_UI = true
	tooltip_reference.toggle(false, null)
	played_tactic = tactic
	decide_tactic(tactic)
	show()
	
	
func decide_tactic(tactic):
	
	text_reference.text = "Choose your card:"


	if tactic == "companioncavalry":
		card_color = str(card_database_reference.CARDS["troops"][DEFAULT_COMPANIONCAVALRY][1])
		card_title = str(card_database_reference.CARDS["troops"][DEFAULT_COMPANIONCAVALRY][0])
		card_value = card_database_reference.CARDS["troops"][DEFAULT_COMPANIONCAVALRY][2]

		
	else:
		card_color = str(card_database_reference.CARDS["troops"][DEFAULT_CARD][1])
		card_title = str(card_database_reference.CARDS["troops"][DEFAULT_CARD][0])
		card_value = card_database_reference.CARDS["troops"][DEFAULT_CARD][2]

	update_card_color(card_color)
	update_card_values(card_title, card_value)
	card_ui_reference.get_node("Area2D/CollisionShape2D").disabled = true
	card_ui_reference.scale = Vector2(CARD_UI_SCALE,CARD_UI_SCALE)


func update_card_color(card_color_local):
	card_color = card_color_local
	card_ui_reference.card_color = card_color
	card_background_image_path = str("res://Assets/" + card_color + "/" + card_color + ".png")
	card_ui_reference.get_node("CardImage").texture = load(card_background_image_path)

func update_card_values(card_title_local, card_value_local):
	card_title = card_title_local
	card_value = card_value_local
	card_ui_reference.card_title = card_title
	card_ui_reference.card_value = card_value
	card_background_design_path = str("res://Assets/card_designs/" + card_title + ".png")
	card_ui_reference.get_node("CardDesign").texture = load(card_background_design_path)
	card_ui_reference.get_node("NumberCenter").text = card_title
	card_ui_reference.get_node("NumberLeftTop").text = str(card_value)
	card_ui_reference.get_node("NumberRightBottom").text = str(card_value)
	
func get_card_title():
	card_title = str(card_database_reference.CARDS["troops"][str(card_color)+str(card_value)][0])
	return card_title

func _on_button_pressed() -> void:
	if played_tactic == "companioncavalry":
		return
	if played_tactic == "shieldbearers":
		if card_value >= 3:
			return
	if card_value < 10:
		card_value += 1
		update_card_values(get_card_title(), card_value)


func _on__pressed() -> void:
	if played_tactic == "companioncavalry":
		return
	if played_tactic == "shieldbearers":
		if card_value <= 1:
			return
	if card_value > 1:
		card_value -= 1
		update_card_values(get_card_title(), card_value)

func end(card_id):
	print("i chose " + card_id)
	hide()
	var new_card = deck_reference.create_card(card_id)
	new_card.get_node("AnimationPlayer").play("card_flip")
	play_card(new_card, card_slot_played_in)
	tooltip_reference.other_UI = false


func play_card(new_card, card_slot_played_in):
	#if card_slot_found.name == "CardSlot":
		#if card_being_dragged.card_type == "troops":
			#if card_slot_found and card_slot_found.cards_in_slot.size()<card_slot_found.MAX_CARDS_IN_SLOT and !card_slot_found.finished and !played_card_this_turn:
	card_slot_played_in.cards_in_slot.append(new_card)
	deck_reference.add_to_played_cards(new_card)
	var new_z_index = 2 * card_slot_played_in.cards_in_slot.size()
	new_card.get_node("CardImage").z_index = new_z_index
	new_card.get_node("CardDesign").z_index = new_z_index
	new_card.get_node("NumberRightBottom").z_index = new_z_index
	new_card.get_node("NumberLeftTop").z_index = new_z_index
	new_card.get_node("NumberCenter").z_index = new_z_index

	new_card.card_slot_card_is_in = card_slot_played_in
	new_card.scale = Vector2(CARD_SMALLER_SCALE,CARD_SMALLER_SCALE)
	new_card.get_node("Area2D/CollisionShape2D").disabled = true
	new_card.position.y = card_slot_played_in.global_position.y+ 30 * (card_slot_played_in.cards_in_slot.size()-1)
	new_card.position.x = card_slot_played_in.global_position.x

	if card_slot_played_in.cards_in_slot.size() >= card_slot_played_in.MAX_CARDS_IN_SLOT:
		card_slot_played_in.submit()
	card_slot_played_in.trigger_slot_tooltip(true)
	print(new_card.get_node("NumberLeftTop").z_index)
	return
