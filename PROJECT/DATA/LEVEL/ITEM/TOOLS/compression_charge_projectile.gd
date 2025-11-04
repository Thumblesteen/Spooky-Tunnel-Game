extends RigidBody3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var rRoomParent:Area3D
@onready var omni_light_3d: OmniLight3D = $"CollisionShape3D/Grenade_Body Grenade_0/OmniLight3D"

func _on_timer_detonator_timeout() -> void:
	animation_player.speed_scale = randf_range(1, 2)
	animation_player.play("Detonate")
	omni_light_3d.visible = false

func ConnectRoom(rRoom:Area3D):
	rRoomParent = rRoom


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Detonate" && rRoomParent != null:  
		rRoomParent.DisplaceSmoke(rRoomParent.fSmokeDensity)
