extends Control

const PLAYED_CARD_STACK_BUFFER = 30
var MAX_CARDS_IN_SLOT
var cards_in_slot = []
@onready var tooltip_reference = $"../Tooltip"
@onready var card_manager_reference = $"../CardManager"
@onready var card_slot_highlight = $Highlight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2(0.8,0.8)
	name = "discard"
	card_slot_highlight.visible = false

func highlight(state:bool):
	card_slot_highlight.visible = state

func trigger_slot_tooltip(on:bool):
	if !cards_in_slot.is_empty():
		#tooltip_reference.show_cards_in_slot(cards_in_slot,tactics_in_slot)
		tooltip_reference.toggle(on, self)

func trigger_slot_highlight(on:bool):
	if name == "CardSlot":
		if !cards_in_slot.size() >= MAX_CARDS_IN_SLOT:
			card_manager_reference.toggle_highlight(on, self)
		else:
			self.highlight(false)

func rearrange_cards_y_position():
	if cards_in_slot.size() <= 0:
		return
	for i in range(cards_in_slot.size()):
		cards_in_slot[i].position = Vector2(self.global_position.x,self.global_position.y + i * PLAYED_CARD_STACK_BUFFER )

func _on_area_2d_mouse_entered() -> void:
	trigger_slot_tooltip(true)
	print("penis")


func _on_area_2d_mouse_exited() -> void:
	trigger_slot_tooltip(false)
