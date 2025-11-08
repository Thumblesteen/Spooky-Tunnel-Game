extends Node3D
@onready var button_01: MeshInstance3D = $BUTTONPARENT_01/BUTTON_01
@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@onready var camera_3d: Camera3D = $Camera3D

#Took us 3 hours to figure out how to get this to work since I forgot to
#filter the input through the hud - V

func _ready():
	pass

func Interact():
	World.cPlayer.bKillCore = true
	camera_3d.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED



func _on_buttonparent_01_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		print("Wow, a left mouse click")


func _on_buttonparent_01_mouse_entered() -> void:
	print("Mouse_entered")
