extends PanelContainer

@onready var tooltip_reference = $"../Tooltip"
@onready var troops_reference = $VBoxContainer/Troops
@onready var vbox_reference = $VBoxContainer
@onready var End_Turn_Button_Reference = $"../EndTurn"
@onready var player_hand_reference = $"../PlayerHand"
@onready var text_reference = $VBoxContainer/RichTextLabel
var center_screen_x
var center_screen_y
var card_UI_scene
const CARD_UI_SCENE_PATH = "res://Scenes/cardUI.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_UI_scene = preload(CARD_UI_SCENE_PATH)
	center_screen_x = get_viewport().size.x / 2
	center_screen_y = get_viewport().size.y / 2
	update_position()
	hide()

func update_position():
	position = Vector2(center_screen_x - size.x/2,center_screen_y - size.y/2)

func start():
	text_reference.text = "Please draw 3 cards from any deck"
	tooltip_reference.other_UI = true
	resize()
	show()
	End_Turn_Button_Reference.disabled = true
	End_Turn_Button_Reference.visible = false
	
func start_discard():
	text_reference.text = "Please choose 2 cards to discard"

func add_choices(card_found):
	var card_scene = preload(CARD_UI_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_title = str(card_found.card_title)
	new_card.card_copied = card_found
	card_found.card_UI_reference = new_card
	new_card.name = card_found.card_id
	if card_found.card_type == "troops":	

		var card_color = str(card_found.card_color)
		var card_value = str(card_found.card_value)
		var card_background_image_path = str("res://Assets/" + card_color + "/" + card_color + ".png")
		new_card.get_node("CardImage").texture = load(card_background_image_path)
		var card_background_design_path = str("res://Assets/card_designs/" + card_title + ".png")
		new_card.get_node("CardDesign").texture = load(card_background_design_path)
		new_card.get_node("NumberCenter").text = card_title
		new_card.get_node("NumberLeftTop").text = str(card_value)
		new_card.get_node("NumberRightBottom").text = str(card_value)
	else:
		var card_background_image_path = str("res://Assets/card_designs/tactics.png")
		new_card.get_node("CardImage").texture = load(card_background_image_path)
		var card_background_design_path = str("res://Assets/card_designs/" + card_title + ".png")
		#new_card.get_node("CardDesign").texture = load(card_background_image_path)
		new_card.get_node("NumberCenter").text = card_title


	#new_card.get_node("Area2D/CollisionShape2D").disabled = true
	new_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	troops_reference.add_child(new_card)
	resize()

func remove_choice(card_found):
	card_found.card_UI_reference.queue_free()
	#print("my kids are " + str(troops_reference.get_children()))
	resize()
	
func resize():
	troops_reference.set_size(Vector2.ZERO)
	vbox_reference.set_size(Vector2.ZERO)
	self.set_size(Vector2.ZERO)
	update_position()

func end():
	tooltip_reference.other_UI = false
	End_Turn_Button_Reference.disabled = false
	End_Turn_Button_Reference.visible = true
	hide()
	player_hand_reference.return_discarded_cards()
	


func _on_confirm_button_pressed() -> void:
	if troops_reference.get_child_count() >= 2:
		end()
	else:
		print("plz pick 2 to discaard nigga")
