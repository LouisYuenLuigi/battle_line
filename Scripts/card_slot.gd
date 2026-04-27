extends Control

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
		
	#print($Area2D.collision_mask)

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
		"redeploy": print("not  implemented yet boss")
		"deserter": print("not  implemented yet boss")
		"traitor": print("not  implemented yet boss")

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


func _on_area_2d_mouse_entered() -> void:
	#print("sloton")
	#mark_slot(true)
	trigger_slot_tooltip(true)
		


func _on_area_2d_mouse_exited() -> void:
	#mark_slot(false)
	trigger_slot_tooltip(false)
