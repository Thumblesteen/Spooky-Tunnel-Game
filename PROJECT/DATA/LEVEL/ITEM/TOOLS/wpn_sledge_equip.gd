extends Node3D
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var everybody_loves_raycast: RayCast3D = $EverybodyLovesRaycast
@onready var animation_player: AnimationPlayer = $SubViewportContainer/SubViewport/AnimationPlayer

@export_file_path() var sGNDPath:String
@export_file_path() var sProjectilePath:String

var bShouldDelete:bool = false

#special thanks to Zylann for the grenade code snippet

var GND:CollisionObject3D

var rProjectile:RigidBody3D
var bColliderLog:CollisionObject3D

func _ready() -> void:
	sub_viewport.set_transparent_background(true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	Unequip()

func KillCore(bVal:bool):
	World.GetPlayer().bKillCore = bVal

func _physics_process(delta: float) -> void:
	IdleProcess()
	BumpPrompt()
	PryPrompt()
	Use_Primary()
	Use_Secondary()
	Drop()
	DeleteProcess()

@export var sSwingAnimations:Array[StringName] = ["Swing_01", "Swing_01"]

#How to code like Thumblesteen: 
#1. Use return blocks to optimise your code. 
#2. Never make custom signals for some reason. 
#3. Give everything emergent methods.
#4. Write your code in even more methods to make the code more tidy.
#5. Test your code
#6. Fail at coding
#7. Get anxious
#8. Realise you forgot to add the method to the process block.
#9. Realise that even smart people are morons. 
@onready var idler: AnimationPlayer = $SubViewportContainer/SubViewport/IDLER

func IdleProcess():
	if animation_player.is_playing(): 
		if idler.is_playing(): idler.stop(true)
		return
	if idler.is_playing(): return
	idler.play("IDLE_NORMAL")

func Use_Primary():
	if animation_player.is_playing(): return
	if !everybody_loves_raycast.is_colliding(): 
		if Input.is_action_just_pressed("FUNC_USE_EQUIPPED"):
			animation_player.play("NoTarget")
			return
		return
	if !Input.is_action_just_pressed("FUNC_USE_EQUIPPED"): return
	bColliderLog = everybody_loves_raycast.get_collider()
	KillCore(true)
	animation_player.play(sSwingAnimations.pick_random())

@export var sPryAnimations:Array[StringName] = ["Pry_01", "Pry_02"] 

func Use_Secondary():
	if animation_player.is_playing(): return
	if !everybody_loves_raycast.is_colliding(): 
		if Input.is_action_just_pressed("FUNC_AUX"):
			return
		return
	if !Input.is_action_just_pressed("FUNC_AUX"): return
	bColliderLog = everybody_loves_raycast.get_collider()
	KillCore(true)
	animation_player.play(sPryAnimations.pick_random())

func DeleteProcess():
	if animation_player.is_playing(): return
	if !bShouldDelete: return
	queue_free()

func Drop():
	if animation_player.is_playing(): return
	if !Input.is_action_just_pressed("FUNC_DROP_EQUIPPED"): return
	GND = load(sGNDPath).instantiate()
	World.AddToWorld(GND)
	GND.global_position = World.GetForward()
	queue_free()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	KillCore(false)

@export var bBumpPrompt:bool = false

func BumpPrompt():
	if !bBumpPrompt: return
	if bColliderLog.has_method("Bump"): bColliderLog.Bump()
	bBumpPrompt = false

@export var bPryPrompt:bool = false

func PryPrompt():
	if !bPryPrompt: return
	if bColliderLog.has_method("Pry"): bColliderLog.Pry()
	bPryPrompt = false

func Unequip():
	return
	if get_parent().get_child_count() > 1:
		GND = load(sGNDPath).instantiate()
		World.AddToWorld(GND)
		GND.global_position = World.GetForward()
		queue_free()
