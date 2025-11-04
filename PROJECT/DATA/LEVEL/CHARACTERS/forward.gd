extends Marker3D

func _physics_process(delta: float) -> void:
	World.SetForward(self.global_position)
