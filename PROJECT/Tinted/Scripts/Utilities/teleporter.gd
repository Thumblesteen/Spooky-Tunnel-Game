extends StaticBody3D

@onready var destination: Marker3D = $Destination

func Interact():
	World.cPlayer.global_position = destination.global_position
