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

var tactics_deck = []
var colors = ["red","orange","yellow","green","blue","purple"]
var card_database_reference
var deck_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get cards from db
	card_database_reference = preload("res://Scripts/card_database.gd")
	deck_reference = $"../Deck"
	for i in card_database_reference.CARDS["tactics"]:
		tactics_deck.append(str(i))
	$RichTextLabel.text = str(tactics_deck.size())
	tactics_deck.shuffle()



func draw_card():
	
	if !deck_reference.decide_can_draw_card() || tactics_deck.size() == 0:
		return
	deck_reference.drawn_card_this_turn = true
	var card_drawn_name = tactics_deck[0]
	tactics_deck.erase(card_drawn_name)
	
	#if last card drawn, disable deck
	if tactics_deck.size() ==0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(tactics_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_title = str(card_database_reference.CARDS["tactics"][card_drawn_name][0])
	var card_background_image_path = str("res://Assets/card_designs/tactics.png")
	new_card.get_node("CardImage").texture = load(card_background_image_path)
	var card_background_design_path = str("res://Assets/card_designs/" + card_title + ".png")
	#new_card.get_node("CardDesign").texture = load(card_background_image_path)
	new_card.get_node("NumberCenter").text = card_title

	$"../CardManager".add_child(new_card)
	new_card.name = card_drawn_name
	new_card.card_id = card_drawn_name
	new_card.position = position
	new_card.card_type = str(card_database_reference.CARDS["tactics"][card_drawn_name][1])
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	#keep card face down, dont flip 
	new_card.get_node("AnimationPlayer").play("card_flip")


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)
	self.scale = Vector2(DECK_BIGGER_SCALE,DECK_BIGGER_SCALE)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
	self.scale = Vector2(DEFAULT_DECK_SCALE,DEFAULT_DECK_SCALE)
