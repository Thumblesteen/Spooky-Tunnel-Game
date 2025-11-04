extends Node3D

class_name EngineController

## Core Engine State
@export var engine_on: bool = false
@export var rpm: float = 0.0
@export var throttle: float = 0.0
@export var ignition: bool = false

## Physical/Thermal/Fuel Systems
@export var max_rpm: float = 9000.00
@export var idle_rpm: float = 850.0
@export var rpm_accel_rate: float = 2000.0 # RPM per second
@export var rpm_decel_rate: float = 1500.0 # RPM per second

@export var coolant_temp: float = 25.0
@export var oil_pressure: float = 0.0
@export var fuel_level: float = 100.0
@export var fuel_consumption_rate: float = 0.05 # per second at full throttle

@export var cooling_system_path: NodePath
@export var fuel_system_path: NodePath
@export var oiling_system_path: NodePath
@export var exhaust_system_path: NodePath

@export var cooling_system = CoolingSystem
@export var fuel_system = FuelSystem
@export var oiling_system = OilingSystem
@export var exhaust_system = ExhaustSystem


## Engine Metrics
@export var temperature: float = 0.0
@export var quality: float = 0.0



func _ready() -> void:
	if cooling_system_path != NodePath():
		cooling_system = get_node(cooling_system_path) 
	if fuel_system_path != NodePath():
		fuel_system = get_node(fuel_system_path)
	if oiling_system_path != NodePath():
		oiling_system = get_node(oiling_system_path)
	if exhaust_system_path != NodePath():
		exhaust_system = get_node(exhaust_system_path)


func _process(delta: float) -> void:
	if not engine_on:
		rpm = lerp(rpm, 0.0, delta * 2.0)
		return
	
	# Throttle directly controls target RPM
	var target_rpm = lerp(idle_rpm, max_rpm, throttle)
	
	# Smooth ramping
	if rpm < target_rpm:
		rpm = move_toward(rpm, target_rpm, rpm_accel_rate * delta)
	else:
		rpm = move_toward(rpm, target_rpm, rpm_decel_rate * delta)
	
	# Update subsystems if present
	_update_systems(delta)


func _update_systems(delta: float) -> void:
	if cooling_system and cooling_system.has_method("update_from_engine"):
		cooling_system.update_from_engine(rpm, delta)
	if oiling_system and oiling_system.has_method("update_from_engine"):
		oiling_system.update_from_engine(rpm, delta)
	if exhaust_system and exhaust_system.has_method("update_from_engine"):
		exhaust_system.update_from_engine(rpm, delta)
	if fuel_system and fuel_system.has_method("update_from_engine"):
		fuel_system.update_from_engine(rpm, delta)


## Engine Control Methods

func start_engine() -> void:
	if ignition:
		engine_on = true
		rpm = idle_rpm
		print("Engine has started! Woohoo!")
	
	## When the engine is started play any animations regarding the train starting to move, the engine
	## parts turning on and moving, and sounds or console updates that should be handled whenever the engine
	## is started.

func stop_engine() -> void:
	engine_on = false
	throttle = 0.0
	print("The engine has stopped. Hope it was intentional.")


func set_ignition(state: bool) -> void:
	ignition = state
	print("Ignition: ", state)


func set_throttle(value: float) -> void:
	throttle = clamp(value, 0.0, 1.0)


func get_engine_rpm() -> float:
	return rpm


func get_engine_status() -> String:
	if engine_on:
		return "Running"
	else: 
		return "Stopped"


func _on_coolant_level_changed(new_level: float) -> void:
	print("UH HUH the coolant is moving!! Coolant is at:", new_level, "%")
	
	if new_level < 25.0:
		print("WARNING: Coolant critically low!! Add more coolant dumb dumb!")
		
		## Spot for adding some functions regarding the cooling system
		## Example: Turn the Engine off or lower the throttle automatically as a fail safe.
