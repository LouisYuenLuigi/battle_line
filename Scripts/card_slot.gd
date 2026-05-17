extends Control

const PLAYED_CARD_STACK_BUFFER = 30
const CARD_SMALLER_SCALE = 0.8
var MAX_CARDS_IN_SLOT
var card_slot_type
var cards_in_slot = []
var tactics_in_slot = []
var same_color
var same_value
var consecutive
var formation_power
var value_array = []
var flag
var whoami
var sum
var finished
@onready var tooltip_reference = $"../../../../Tooltip"
@onready var card_selector_reference = $"../../../../CardSelector"
@onready var card_manager_reference = $"../../../../CardManager"
@onready var player_hand_reference = $"../../../../PlayerHand"
@onready var guile_tactics_reference = $"../../../../GuileTactics"
@onready var card_slot_highlight = $Highlight
@onready var text_reference = $RichTextLabel
var opponent_card_slot_of_same_flag
#formation power:
#5 wedge: 			same color consecutive
#4 phalanx: 			diff color same value
#3 battalion order:	same color not consecutive
#2 skirmish line: 	consecutive diff color
#1 Host: 			trash, no pattern


func _ready() -> void:
	MAX_CARDS_IN_SLOT = 3
	flag = get_parent()
	sum = 0
	finished = false
	opponent_card_slot_of_same_flag = get_parent().get_node("OpponentCardSlot")
	card_slot_highlight.visible = false
	#text_reference.text = "niggas"
		
	#print($Area2D.collision_mask)

func highlight(state:bool):
	card_slot_highlight.visible = state

func show_cards():
	print("showing cards in " + str(self))
	for i in cards_in_slot:
		print(str(i))

func increase_max_cards_in_slot():
	MAX_CARDS_IN_SLOT += 1

func check_same_color():
	if !cards_in_slot.is_empty():
		same_color = cards_in_slot.all(func(e): return e.card_color == cards_in_slot.front().card_color)
	return same_color
	
func check_same_value():
	if !cards_in_slot.is_empty():
		same_value = cards_in_slot.all(func(e): return e.card_value == cards_in_slot.front().card_value)
	return same_value
	
func check_consecutive():
	if !cards_in_slot.is_empty() && !value_array.is_empty():
		if value_array.max() - value_array.min() != value_array.size()-1:
			consecutive = false
			return consecutive
		var unique_elements = []
		for item in value_array:
			if not item in unique_elements:
				unique_elements.append(item)
			else:
				consecutive = false
				return consecutive
		consecutive = true
		return consecutive

func submit():
	print("formation power: " + str(calculate_formation()))
	flag.receive(self.name,formation_power,sum)

func calculate_formation():
	#add all values to value_array for easier comparison
	for i in cards_in_slot:
		value_array.append(i.card_value)
	for n in value_array:
		sum += n
	#check for same color
	if check_same_value():
		formation_power = 4
		return formation_power
	elif check_same_color() && check_consecutive():
		formation_power = 5
		return formation_power
	elif check_same_color() && !check_consecutive():
		formation_power = 3
		return formation_power
	elif !check_same_color() && check_consecutive():
		formation_power = 2
		return formation_power
	else:
		formation_power = 1
	return formation_power


func execute_tactic(tactic):
	print("doing "+ str(tactic))
	match tactic:
		"alexander": card_selector_reference.start("alexander", self)
		"darius": card_selector_reference.start("darius", self)
		"companioncavalry": card_selector_reference.start("companioncavalry", self)
		"shieldbearers": card_selector_reference.start("shieldbearers", self)
		"fog": flag.make_fog()
		"mud": flag.make_mud()
		"scout": player_hand_reference.scout()
		"redeploy":
			if cards_in_slot.size() <= 0:
				return false
			guile_tactics_reference.redeploy(self)
		"deserter":
			if opponent_card_slot_of_same_flag.cards_in_slot.size() <= 0:
				return false
			guile_tactics_reference.deserter(self)
		"traitor":
			if opponent_card_slot_of_same_flag.cards_in_slot.size() <= 0:
				return false
			guile_tactics_reference.traitor(self)
	return true

func do_mud():
	MAX_CARDS_IN_SLOT +=1

func disable_slot():
	finished = true

func mark_slot(truth):
	if truth:
		card_manager_reference.set_card_slot(self)
	else:
		card_manager_reference.set_card_slot(null)
	#print("Marked ass nigga : " + str(truth) + " "+str(self.get_parent().name))

func trigger_slot_tooltip(on:bool):
	if !cards_in_slot.is_empty() or !tactics_in_slot.is_empty():
		#tooltip_reference.show_cards_in_slot(cards_in_slot,tactics_in_slot)
		tooltip_reference.toggle(on, self)

func trigger_slot_highlight(on:bool):
	if name == "CardSlot":
		if !cards_in_slot.size() >= MAX_CARDS_IN_SLOT:
			card_manager_reference.toggle_highlight(on, self)
		else:
			self.highlight(false)
	#elif name == "OpponentCardSlot" and guile_tactics_reference.get_picking_opponent():
		#if !finished:
			##card_manager_reference.toggle_highlight(on, self)
			#self.highlight(on)
		#else:
			#self.highlight(false)


func rearrange_cards_y_position():
	if cards_in_slot.size() <= 0:
		return
	if name == "CardSlot":
		for i in range(cards_in_slot.size()):
			cards_in_slot[i].position = Vector2(self.global_position.x,self.global_position.y + i * PLAYED_CARD_STACK_BUFFER )
			#adjust for rotated point, + card size in coord
			print(self.name)
			print("niggas in yeah yeah " + str(cards_in_slot[i].position))
	else:
		for i in range(cards_in_slot.size()):
			cards_in_slot[i].position = Vector2(self.global_position.x,self.global_position.y - i * PLAYED_CARD_STACK_BUFFER )
			#adjust for rotated point, + card size in coord
			cards_in_slot[i].position.x += self.size.x * CARD_SMALLER_SCALE
			cards_in_slot[i].position.y += self.size.y * CARD_SMALLER_SCALE
			print(self.name)
			print("niggas in yeah yeah " + str(cards_in_slot[i].position))

func _on_area_2d_mouse_entered() -> void:
	#print("sloton")
	#mark_slot(true)
	trigger_slot_tooltip(true)
	trigger_slot_highlight(true)
		
func _on_area_2d_mouse_exited() -> void:
	#mark_slot(false)
	trigger_slot_tooltip(false)
	trigger_slot_highlight(false)
