extends RigidBody3D

@export_file_path() var sObjectToLoad:String

func Interact():
	if PlayerData.CanEquip():
		PlayerData.EquipObject(sObjectToLoad)
		queue_free()

func _ready() -> void:
	if World.cPlayer != null:
		self.global_rotation = World.cPlayer.global_rotation
