extends Node

var cPlayer:CharacterBody3D
var cCamera:Camera3D
var nWorld:Node3D
var cAttachmentNode:Node3D

var Forward:Vector3

func SetForward(POS:Vector3):
	Forward = POS

func GetForward():
	return Forward

func SetPlayer(Player:CharacterBody3D):
	print("CONNECTING PLAYER TO GLOBAL! Awww yeeeeaaa")
	cPlayer = Player

func DeclareCamera(Camera:Camera3D, CamAttach:Node3D):
	cCamera = Camera
	cAttachmentNode = CamAttach

func SetWorld(WorldRef:Node3D):
	nWorld = WorldRef

func GetPlayer():
	return cPlayer

func GetWorld():
	return nWorld

func AddToWorld(ref:Object):
	get_tree().current_scene.add_child(ref)

func EnablePlayer(bValue:bool = true):
	cCamera.current = bValue
