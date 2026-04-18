extends Node2D

signal hovered
signal hovered_off
const DECK_BIGGER_SCALE = 1.05
const DEFAULT_DECK_SCALE = 1


const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.2
const CARD_MAX_NUMBER = 10
const STARTING_HAND_SIZE = 7
const COLLISION_MASK_DECK = 4
var is_hovering_on_deck

var player_deck = []
var played_cards = []
var colors = ["red","orange","yellow","green","blue","purple"]
var card_database_reference
var drawn_card_this_turn = false
var can_draw_card = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get cards from db
	card_database_reference = preload("res://Scripts/card_database.gd")
	#initialize deck
	#currently hardcoded, should get from deck json
	for i in colors:
		for j in range(CARD_MAX_NUMBER):
			var add_card_to_deck = i+str(j+1)
			player_deck.append(add_card_to_deck)
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	#initialize hand
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false
	#drawn_card_this_turn = true
	can_draw_card = false



func draw_card():
	
	if !decide_can_draw_card() || player_deck.size() == 0:
		return
	drawn_card_this_turn = true
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	#if last card drawn, disable deck
	if player_deck.size() ==0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_color = str(card_database_reference.CARDS["troops"][card_drawn_name][1])
	var card_title = str(card_database_reference.CARDS["troops"][card_drawn_name][0])
	var card_value = card_database_reference.CARDS["troops"][card_drawn_name][2]
	var card_background_image_path = str("res://Assets/" + card_color + "/" + card_color + ".png")
	new_card.get_node("CardImage").texture = load(card_background_image_path)
	var card_background_design_path = str("res://Assets/card_designs/" + card_title + ".png")
	#new_card.get_node("CardDesign").texture = load(card_background_image_path)
	new_card.get_node("NumberCenter").text = card_title
	new_card.get_node("NumberLeftTop").text = str(card_value)
	new_card.get_node("NumberRightBottom").text = str(card_value)
	
	new_card.card_value = card_value
	new_card.card_color = card_color
	new_card.card_type = "troops"
	
	$"../CardManager".add_child(new_card)
	new_card.name = card_drawn_name
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")

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
	if !drawn_card_this_turn && $"../PlayerHand".player_hand.size() < $"../PlayerHand".MAX_HAND_COUNT:
		can_draw_card = true
		return can_draw_card
	else:
		can_draw_card = false
		return can_draw_card

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)
	self.scale = Vector2(DECK_BIGGER_SCALE,DECK_BIGGER_SCALE)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
	self.scale = Vector2(DEFAULT_DECK_SCALE,DEFAULT_DECK_SCALE)
