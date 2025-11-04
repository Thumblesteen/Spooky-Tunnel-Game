extends Node3D
@onready var tunnel_2: AnimationPlayer = $TUNNEL2
@onready var hull: AnimationPlayer = $HULL
@onready var front_light: AnimationPlayer = $HULL_PIVOT/HullMotion/ELECTRICITY/TUNNEL/LightPivot/FrontLight

func _ready() -> void:
	World.SetWorld(self)

func _process(delta: float) -> void:
	MovementProcess()

func MovementProcess():
	if PlayerHome.fTravel_Speed == 0: 
		tunnel_2.stop(true)
		hull.stop(true)
		front_light.stop(true)
		return
	
	if PlayerHome.fTravel_Speed != tunnel_2.speed_scale: 
		print("SYNCING THAR SPEED SCALE!")
		tunnel_2.speed_scale = PlayerHome.fTravel_Speed
		hull.speed_scale = PlayerHome.fTravel_Speed
		front_light.speed_scale = PlayerHome.fTravel_Speed
	
	if PlayerHome.fTravel_Speed > 0:
		if !tunnel_2.is_playing(): 
			print("WOOP! WOOOOP! TRAIAAAAINYE!")
			tunnel_2.play("Travel")
		if !hull.is_playing(): hull.play("IDLE")
		if !front_light.is_playing(): front_light.play("new_animation")
	
	if PlayerHome.fTravel_Speed == 0 && tunnel_2.is_playing():
		print("Turning off the train!")
		tunnel_2.stop(true)
		hull.stop(true)
