extends Camera3D
@onready var camera_attach: Node3D = $CAMERA_ATTACH

func _ready() -> void:
	World.DeclareCamera(self, camera_attach)
#	PlayerData.EquipmentCount = camera_attach.get_child_count()
