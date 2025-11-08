extends Node3D

@onready var animation_player: AnimationPlayer = $OilFilter_function/AnimationPlayer


var is_on: bool = true

func Interact():
	if is_on:
		animation_player.play("oilFilter_off")
		is_on = false
		return
	
	if !is_on:
		animation_player.play("oilFilter_on")
		is_on = true
		return
