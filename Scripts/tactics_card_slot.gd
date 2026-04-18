extends Node2D

var MAX_CARDS_IN_SLOT
var cards_in_slot
var card_slot_type
var same_color
var same_value
var consecutive
var formation_power
var value_array
var flag
var whoami
var sum
#formation power:
#5 wedge: 			same color consecutive
#4 phalanx: 			diff color same value
#3 battalion order:	same color not consecutive
#2 skirmish line: 	consecutive diff color
#1 Host: 			trash, no pattern


func _ready() -> void:
	MAX_CARDS_IN_SLOT = 3
	cards_in_slot = []
	value_array = []
	flag = get_parent()
	sum = 0
	$RichTextLabel.text =  "Tactics"
	card_slot_type = "tactics"

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
