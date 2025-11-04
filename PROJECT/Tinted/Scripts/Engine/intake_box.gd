extends Node3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer


var is_open: bool = false

func Interact():
	if animation_player.is_playing():
		return
	
	if !is_open:
		animation_player.play("open_box")
		is_open = true
		return
	
	if is_open:
		animation_player.play_backwards("open_box")
		is_open = false
		return
