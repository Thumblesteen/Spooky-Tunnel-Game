extends StaticBody3D

@export var cPlayer:CharacterBody3D
@onready var destination: Marker3D = $Destination

func Interact():
	cPlayer.global_position = destination.global_position
