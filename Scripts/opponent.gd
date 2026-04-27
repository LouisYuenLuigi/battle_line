extends Node2D


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

	var new_card = deck_reference.create_card(card_drawn_name, CARD_SCENE_PATH)
	new_card.position = deck_reference.position
	$"../OpponentHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	#keep card face down, dont flip 
	#new_card.get_node("AnimationPlayer").play("card_flip")
