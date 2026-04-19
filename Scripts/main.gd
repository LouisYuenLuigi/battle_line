extends Node2D

var flag_reference
var flags = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flag_reference = $Flags
	#for i in $"../Flags":
		#flags.append(i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
