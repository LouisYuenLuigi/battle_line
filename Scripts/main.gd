extends Node2D

var flag_reference
var flags = []
const CARD_SMALLER_SCALE = 0.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#flag_reference = $Flags
	var container = $CenterContainer
	container.scale = Vector2(CARD_SMALLER_SCALE,CARD_SMALLER_SCALE)
	container.pivot_offset = container.size / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
