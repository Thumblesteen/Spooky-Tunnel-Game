extends Node3D

@export var Room_01:Area3D
@export var Room_02:Area3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var bOpen:bool = false
var bJammed:bool = false

var sBumpFails:Array[StringName] = ["BUMP_FAIL", "BUMP_FAIL_02", "BUMP_FAIL_03"]

func _ready() -> void:
	bJammed = UTIL.CoinToss()
	if bJammed: 
		animation_player.play("BUMP_FAIL_03")

func Interact():
	print("Activator is activating! It's....")
	if animation_player.is_playing(): return
	if bJammed: return
	if bOpen: 
		animation_player.play_backwards("ACTIVATE")
		bOpen = false
		print("Closing...")
		return
	if !bOpen: 
		animation_player.play("ACTIVATE")
		bOpen = true
		print("Opening...")
		return

func _process(delta: float) -> void:
	RoomProcess()

func RoomProcess():
	gpu_particles_3d_2.amount_ratio = gpu_particles_3d.amount_ratio
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var gpu_particles_3d_2: GPUParticles3D = $GPUParticles3D2

func DisplaceSmoke():
	if gpu_particles_3d.amount_ratio > 0:
		Room_02.fSmokeDensity = Room_02.fSmokeDensity + (gpu_particles_3d.amount_ratio / 2500)
		Room_01.fSmokeDensity = Room_01.fSmokeDensity + (gpu_particles_3d.amount_ratio / 2500)
	if Room_01.fSmokeToDisplace > 0: 
		Room_02.fSmokeDensity = Room_02.fSmokeDensity + Room_01.fSmokeToDisplace
		Room_01.fSmokeToDisplace = 0
		print("YIKIES! WE'RE DISPLACING THE SMOKE! "+str(Room_02.fSmokeDensity)+" / "+str(Room_01.fSmokeDensity))
		return
	if Room_02.fSmokeToDisplace > 0: 
		Room_01.fSmokeDensity = Room_01.fSmokeDensity + Room_02.fSmokeToDisplace
		Room_02.fSmokeToDisplace = 0
		print("YIKIES! WE'RE DISPLACING THE SMOKE! "+str(Room_02.fSmokeDensity)+" / "+str(Room_01.fSmokeDensity))
		return

func SmokeBalance():
	if Room_01 == null: return
	if Room_02 == null: return
	DisplaceSmoke()
	if bOpen == false: return
	if Room_01.fSmokeDensity > Room_02.fSmokeDensity:
		Room_02.fSmokeDensity = Room_02.fSmokeDensity + 0.01
		Room_01.fSmokeDensity = Room_02.fSmokeDensity - 0.01
		print("Balancing smoke: "+str(Room_01)+" / "+str(Room_01.fSmokeDensity))
		print("Balancing smoke: "+str(Room_02)+" / "+str(Room_02.fSmokeDensity))
		return
	if Room_02.fSmokeDensity > Room_01.fSmokeDensity:
		Room_02.fSmokeDensity = Room_02.fSmokeDensity - 0.01
		Room_01.fSmokeDensity = Room_02.fSmokeDensity + 0.01
		print("Balancing smoke: "+str(Room_01)+" / "+str(Room_01.fSmokeDensity))
		print("Balancing smoke: "+str(Room_02)+" / "+str(Room_02.fSmokeDensity))
		return
	


func _on_smoke_balancer_timeout() -> void:
	SmokeBalance()

func Bump():
	if bOpen: return
	if bJammed && UTIL.D20(18): 
		animation_player.play("BUMP_FAIL_JAM")
		bJammed = true
		return 
	if animation_player.is_playing(): return
	if UTIL.D20(15,-2):
		animation_player.play("BUMP")
		bOpen = true
	else: 
		bJammed = true
		animation_player.play(sBumpFails.pick_random())

func Pry():
	if bJammed: 
		animation_player.play("BUMP_FAIL_02")
		bJammed = false
