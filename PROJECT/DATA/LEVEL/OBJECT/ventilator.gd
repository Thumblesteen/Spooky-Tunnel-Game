extends StaticBody3D

var rRoomParent:Area3D
@onready var fog_volume: FogVolume = $FogVolume

var bActive:bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func Interact():
	if !bActive:
		animation_player.play("ACTIVE")
		rRoomParent.fVentilationValue += 0.015
		fog_volume.visible = true
		bActive = true
		return
	if bActive:
		animation_player.play("STOP")
		rRoomParent.fVentilationValue -= 0.015
		fog_volume.visible = false
		bActive = false
		return

func _ready() -> void:
	ConnectParent()

func ConnectParent():
	if self.get_parent().has_method("ConnectRoom"): 
		print("Connecting "+str(self.get_parent())+" to "+str(self))
		rRoomParent = self.get_parent()
