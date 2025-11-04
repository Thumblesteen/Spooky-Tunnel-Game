extends Node3D
@onready var animation_player: AnimationPlayer = $SubViewportContainer/SubViewport/AnimationPlayer
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport

@export_file_path() var sGNDPath:String
@export_file_path() var sProjectilePath:String
@export var bPrimed:bool = false
@export var bLaunchProjectile:bool = false
@onready var projectile_node: Marker3D = $ProjectileNode

var bShouldDelete:bool = false

#special thanks to Zylann for the grenade code snippet

var GND:CollisionObject3D

var rProjectile:RigidBody3D

func _ready() -> void:
	sub_viewport.set_transparent_background(true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	Unequip()

func _physics_process(delta: float) -> void:
	Prime()
	Throw()
	Launch()
	Drop()
	DeleteProcess()

func Prime():
	if animation_player.is_playing(): return
	if Input.is_action_just_pressed("FUNC_USE_EQUIPPED"):
		animation_player.play("Throw_01")
		bPrimed = true

func Throw():
	if animation_player.is_playing(): return
	#if Input.is_action_pressed("FUNC_USE_EQUIPPED"): return
	if bPrimed == false: return
	animation_player.play("Throw_02")

func Launch():
	if bPrimed == false: return
	print("OH HECK YEP WE'RE PRIMING GRENADE BRO")
	if bLaunchProjectile == false: return
	print("AWWW YESSS! Chucken that grenade!")
	rProjectile = load(sProjectilePath).instantiate()
	World.AddToWorld(rProjectile)
	var spawn_pos = World.GetForward()# .global_transform.origin + -global_transform.basis.z * 1.0 + Vector3.UP * 1.0
	rProjectile.global_transform.origin = spawn_pos
	var direction = -global_transform.basis.z.normalized()
	rProjectile.linear_velocity = direction * 10 + Vector3.UP * 7.0
	print("THE GRENADE IS EXIST! "+str(rProjectile.global_position))
	bLaunchProjectile = false
	bPrimed = false
	bShouldDelete = true

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
	if anim_name == "Throw_02": Launch()

func Unequip():
	return
	if get_parent().get_child_count() > 1:
		GND = load(sGNDPath).instantiate()
		World.AddToWorld(GND)
		GND.global_position = World.GetForward()
		queue_free()
