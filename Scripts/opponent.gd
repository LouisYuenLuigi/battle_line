extends Node2D

signal hovered
signal hovered_off
const DECK_BIGGER_SCALE = 1.05
const DEFAULT_DECK_SCALE = 1


const CARD_SCENE_PATH = "res://Scenes/opponent_card.tscn"
const CARD_DRAW_SPEED = 0.2
const CARD_MAX_NUMBER = 10
const STARTING_HAND_SIZE = 7
const COLLISION_MASK_DECK = 4
var is_hovering_on_deck

var deck_reference
var opponent_deck = []
#var colors = ["red","orange","yellow","green","blue","purple"]
var card_database_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get cards from db
	card_database_reference = preload("res://Scripts/card_database.gd")
	
	
	deck_reference = $"../Deck"
	opponent_deck = deck_reference.player_deck
	for i in range(STARTING_HAND_SIZE):
		draw_card()




func draw_card():
	
	var card_drawn_name = opponent_deck[0]
	opponent_deck.erase(card_drawn_name)
	
	#if last card drawn, disable deck
	$"../Deck/RichTextLabel".text = str(opponent_deck.size())

	var card_scene = preload(CARD_SCENE_PATH)
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
	
	new_card.card_value = card_value
	new_card.card_color = card_color
	new_card.card_title = card_title

	$"../CardManager".add_child(new_card)
	new_card.name = card_drawn_name
	$"../OpponentHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	#keep card face down, dont flip 
	#new_card.get_node("AnimationPlayer").play("card_flip")
