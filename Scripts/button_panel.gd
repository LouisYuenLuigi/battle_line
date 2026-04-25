extends Control
@export var group: ButtonGroup
var color_picked
var card_UI_reference
const colors = ["#ec1c24","#ff7f27","#fff200","#0ed145","#3f48cc","#b83dba"]
const color_names = ["red","orange","yellow","green","blue","purple"]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print(group.get_buttons())
	card_UI_reference = $"../../.."
	color_picked = "red"
	for i in group.get_buttons():
		i.connect("pressed", button_pressed)
		var color_index = int(i.name) - 1
		i.modulate = Color(colors[color_index])
		i.text = str(color_names[color_index])

		
		

func button_pressed():
	color_picked = str(group.get_pressed_button().text)
	card_UI_reference.update_card_color(color_picked)

func _on_confirm_button_pressed() -> void:
	var final_choice = color_picked+str(card_UI_reference.card_value)
	card_UI_reference.end(final_choice)
