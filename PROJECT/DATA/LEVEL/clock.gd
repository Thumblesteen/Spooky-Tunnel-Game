extends StaticBody3D

@onready var animation_player: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("Take 001")
	animation_player.speed_scale = randf_range(0.05, 1.2)
