extends Node3D

@onready var animation_player: AnimationPlayer = $CSGCombiner3D/AnimationPlayer

var is_open: bool = false

func Interact():
	if animation_player.is_playing():
		return
	
	if !is_open:
		animation_player.play("waterPumpLid_function")
		is_open = true
		return
	
	if is_open:
		animation_player.play_backwards("waterPumpLid_function")
		is_open = false
		return
