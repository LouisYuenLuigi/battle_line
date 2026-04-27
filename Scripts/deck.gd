extends Control

signal hovered
signal hovered_off
const DECK_BIGGER_SCALE = 1.05
const DEFAULT_DECK_SCALE = 1

@onready var player_hand_reference = $"../PlayerHand"

const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.2
const CARD_MAX_NUMBER = 10
const STARTING_HAND_SIZE = 7
const COLLISION_MASK_DECK = 4
var is_hovering_on_deck
var scouting
var player_deck = []
var played_cards = []
var colors = ["red","orange","yellow","green","blue","purple"]
const card_database_reference = preload("res://Scripts/card_database.gd")
var drawn_card_this_turn = false
var can_draw_card = true
@onready var card_count_text_reference = $RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get cards from db
	#initialize deck
	#currently hardcoded, should get from deck json
	for i in colors:
		for j in range(CARD_MAX_NUMBER):
			var add_card_to_deck = i+str(j+1)
			player_deck.append(add_card_to_deck)
	player_deck.shuffle()
	card_count_text_reference.text = str(player_deck.size())
	#initialize hand
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false
	#drawn_card_this_turn = true
	can_draw_card = false
	scouting = false


func insert_card_in_front(card_to_insert):
	player_deck.push_front(card_to_insert)
	card_count_text_reference.text = str(player_deck.size())

func draw_card():
	
	if scouting and !player_deck.size() == 0:
		scout_draw()
		return
		
	if !decide_can_draw_card() || player_deck.size() == 0:
		return
	drawn_card_this_turn = true
	draw_card_pt_2()
	
func draw_card_pt_2():
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	if player_deck.size() ==0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		card_count_text_reference.visible = false
	
	card_count_text_reference.text = str(player_deck.size())
	var new_card = create_card(card_drawn_name, CARD_SCENE_PATH)
	new_card.position = self.position
	player_hand_reference.add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")

func scout_draw():
	draw_card_pt_2()
	player_hand_reference.increment_scouted_cards()

func create_card(card_drawn_name, path_str):
	var card_scene = load(path_str)
	var new_card = card_scene.instantiate()
	var card_color = str(card_database_reference.CARDS["troops"][card_drawn_name][1])
	var card_title = str(card_database_reference.CARDS["troops"][card_drawn_name][0])
	var card_value = card_database_reference.CARDS["troops"][card_drawn_name][2]
	var card_background_image_path = str("res://Assets/" + card_color + "/" + card_color + ".png")
	new_card.get_node("CardImage").texture = load(card_background_image_path)
	var card_background_design_path = str("res://Assets/card_designs/" + card_title + ".png")
	new_card.get_node("CardDesign").texture = load(card_background_design_path)
	new_card.get_node("NumberCenter").text = card_title
	new_card.get_node("NumberLeftTop").text = str(card_value)
	new_card.get_node("NumberRightBottom").text = str(card_value)
	new_card.card_title = card_title
	new_card.card_value = card_value
	new_card.card_color = card_color
	new_card.card_type = "troops"
	new_card.name = card_drawn_name
	new_card.card_id = card_drawn_name
	$"../CardManager".add_child(new_card)
	return new_card

func disable_draw():
	drawn_card_this_turn = true
	can_draw_card = false

func reset_draw():
	drawn_card_this_turn = false
	can_draw_card = true
	
func add_to_played_cards(cardname):
	played_cards.append(cardname)

func show_played_cards():
	print("showing played cards!!!")
	for i in played_cards:
		print(i)
	print("finished showing played cards!!!")
	
func decide_can_draw_card():
	if !drawn_card_this_turn && player_hand_reference.player_hand.size() < player_hand_reference.MAX_HAND_COUNT:
		can_draw_card = true
		return can_draw_card
	else:
		can_draw_card = false
		return can_draw_card

func toggle_scouting(state: bool):
	scouting = state

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)
	self.scale = Vector2(DECK_BIGGER_SCALE,DECK_BIGGER_SCALE)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
	self.scale = Vector2(DEFAULT_DECK_SCALE,DEFAULT_DECK_SCALE)
