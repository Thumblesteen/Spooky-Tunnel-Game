extends Node3D
class_name ValveControl

#@onready var animation_player: AnimationPlayer = $AnimationPlayer
#@onready var flowing_coolant = %FlowingCoolant
#@onready var cooling_system = CoolingSystem

var is_open: bool = false
var draining: bool = false
var is_empty: bool = false

signal valve_opened
signal valve_closed

#func _ready() -> void:
#	animation_player.play("valve_close")

#func Interact():
#	if animation_player.is_playing():
#		return
	
#	if is_open:
#		animation_player.play("valve_close")
#		is_open = false
#		valve_closed.emit()
#		flowing_coolant.hide()
#	else:
#		animation_player.play("valve_open")
#		flowing_coolant.show()
#		is_open = true
#		valve_opened.emit()


func drain_tank():
	if is_open:
		draining = true

#func stop_drain():
	#if cooling_system.tank_drained():
		#is_empty = true
		#return
