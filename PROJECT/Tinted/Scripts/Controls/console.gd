extends Node3D

class_name EngineConsole

@export var start_delay_range: Vector2 = Vector2(3.0, 5.0) # Range for random start time.

@onready var player_camera: Camera3D = %Camera3D
@onready var console_camera: Camera3D = $ConsoleCamera

@onready var engine_start_sound: AudioStreamPlayer3D = $engine_start
@onready var engine_running_sound: AudioStreamPlayer3D = $engine_running
@onready var starter_scrub_sound: AudioStreamPlayer3D = $starter_scrub
@onready var fuel_pump_sound: AudioStreamPlayer3D = $fuel_pump
@onready var electric_sound: AudioStreamPlayer3D = $electric

# Engine Metrics
@onready var max_temp: float = 0.0
@onready var temperature: float = 60.0
@onready var rpm: float = 0.0
@onready var quality: float = 0.0


# Guages
@onready var temp_bar: ProgressBar = $Guages/SubViewport/temp_guage/temp_bar
@onready var fuel_bar: ProgressBar = $Guages/SubViewport/fuel_bar


# Engine Systems

@export var exhaust_system = ExhaustSystem.new()
@export var electrical_system = ElectricalSystem.new()

# Oiling System
@export var oiling_system = OilingSystem.new()
@export var oil_quality: int = 1
@export var max_oil: float = 200.0
@export var Oil_level: float = 0.0

# Cooling System
@export var cooling_system = CoolingSystem.new()
@export var coolant_quality: int = 1
@export var max_coolant: float = 500.0
@export var coolant_consumption: float = 0.0
@export var coolant_level: float = 50.0

# Fuel System
@export var fuel_system = FuelSystem.new()
@export var max_fuel: float = 500.0
@export var fuel_level: float = 0.0
@export var fuel_consumption: float = 0.05
@export var fuel_quality: int = 1

var current_state: State = State.OFF

var player_in_console: bool = false
var previous_mouse_mode: Input.MouseMode


enum State {OFF, RUNNING}


var master_on: bool = false
var fuel_on: bool = false
var electrical_on: bool = false
var engine_starting: bool = false
var engine_running: bool = false
var transmission_forward: bool = false


@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var fuel_switch: Area3D = $"BYOC-1_2/Safety_Switch_fuel/Area3D"
@onready var electrical_switch: StaticBody3D = $"BYOC-1_2/Safety_Switch_electrical/Area3D"
@onready var starter_key: Area3D = %Starter_Key/Area3D
@onready var red_switch: Area3D = $"BYOC-1_2/Red_Switch/Area3D"
@onready var transmotion_lever: Area3D = $"BYOC-1_2/Transmotion_Lever/Area3D"


func _physics_process(delta: float) -> void:
	handle_state(delta)

func Interact():
	print("Interacting with console?")
	_enter_console()


func _ready() -> void:
	red_switch.input_event.connect(_on_master_input)
	fuel_switch.input_event.connect(_on_fuel_input)
	electrical_switch.input_event.connect(_on_electrical_input)
	starter_key.input_event.connect(_on_starter_input)
	transmotion_lever.input_event.connect(_on_lever_push)
	console_camera.current = false
	print("Console ready")


#region STATE MACHINE
func handle_state(_delta: float) -> void:
	match current_state:
		State.RUNNING: handle_running()
		State.OFF: handle_off()

func change_state(new_state: State) -> void:
	current_state = new_state

func handle_off():
	change_state(State.OFF)
	PlayerHome.fTravel_Speed = 0
	engine_running_sound.stop()
	engine_running = false

func handle_running():
	change_state(State.RUNNING)
	engine_running = true
#endregion

#region MAIN INTERACT / EXIT LOGIC
func _input(event):
	# allow pressing Escape or right-click to exit console
	if player_in_console and event.is_action_pressed("ui_cancel"):
		_exit_console()

func _enter_console():
	print("Entering console view...")
	player_in_console = true

	# store mouse mode so we can restore it
	previous_mouse_mode = Input.get_mouse_mode()

	# switch cameras
	
	console_camera.current = true

	# enable mouse for interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _exit_console():
	print("Exiting console view...")
	player_in_console = false

	# restore previous camera
	console_camera.current = false
	if player_camera:
		player_camera.current = true

	# restore mouse mode
	Input.set_mouse_mode(previous_mouse_mode)
#endregion

#region SWITCH / BUTTON HANDLERS
func _on_lever_push(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if not player_in_console: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_motion()

func _on_fuel_input(camera, event, click_position, normal, shape_idx):
	if not player_in_console: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_fuel()

func _on_electrical_input(camera, event, click_position, normal, shape_idx):
	if not player_in_console: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_electrical()

func _on_starter_input(camera, event, click_position, normal, shape_idx):
	if not player_in_console: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_starter()

func _on_master_input(camera, event, click_position, normal, shape_idx):
	if not player_in_console: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_master()
#endregion

#region ENGINE CONTROL LOGIC 
func toggle_master():
	if master_on:
		animation_player.play("red_switch_off")
		handle_off()
		master_on = false
		print("Master switch on! Let's get ready to rumble!!")
		return
	else:
		animation_player.play("red_switch_on")
		master_on = true
		print("Master off, rumble go bye bye.")
		return


func toggle_fuel():
	if animation_player.is_playing():
		return
	if !fuel_on: 
		print("Fuel pump is on.")
		fuel_on = true
		animation_player.play("fuel_switch_on")
		# Set a random delay...
		fuel_pump_sound.play()
		print("Fuel is primed and ready.")
		return
	else:
		print("Fuel pump turned off.")
		fuel_on = false
		animation_player.play("fuel_switch_off")
		handle_off()
		return
		# Set a random delay... 
		# Turn off the fuel pump sound.


func toggle_electrical():
	if animation_player.is_playing():
		return
	if electrical_on:
		print("Electrical system deactivated.")
		# Set a random delay...
		print("Engine Powering down...")
		animation_player.play("safety_switch_off")
		electric_sound.stop()
		electrical_on = false
		handle_off()
		return
	else:
		print("Electrical System activated.")
		# Set a random delay...
		electric_sound.play()
		print("Electrical system ready for use...")
		electrical_on = true
		animation_player.play("safety_switch_on")
		return


func toggle_starter():
	if animation_player.is_playing():
		return
	
	if engine_running:
		print("Engine is already running.")
		animation_player.play("dial_on")
		animation_player.play_backwards("dial_on")
		starter_scrub_sound.play()
		return
	
	if engine_starting:
		animation_player.play("dial_on")
		animation_player.play_backwards("dial_on")
		print("Engine is already starting.")
		return
	
	if not fuel_on or not electrical_on or not master_on:
		animation_player.play("dial_on")
		animation_player.play_backwards("dial_on")
		starter_scrub_sound.play()
		print("Cannot start engine - Fuel or Electrical system is off.")
		return
		
		
	animation_player.play("dial_on")
	engine_start_sound.play()
	engine_starting = true
	var delay = randf_range(start_delay_range.x, start_delay_range.y)
	print("Starting engine in %.2f seconds..." %delay)
	await get_tree().create_timer(delay).timeout
	engine_starting = false
	animation_player.play_backwards("dial_on")
	change_state(State.RUNNING)
	engine_running_sound.play()
	print("Engine started successfully")
	toggle_motion()
	# Set a chance that the engine doesn't start.


func shutdown_engine():
	handle_off()
	print("Engine shut down.")
#endregion

#region TRANSMOTION CONTROL


func toggle_motion():
	if !transmission_forward:
		animation_player.play("prime_lever_forward")
		transmission_forward = true
		if State.RUNNING and transmission_forward:
			if PlayerHome.fTravel_Speed == 0: 
				PlayerHome.fTravel_Speed = 1
				return
	if transmission_forward:
		animation_player.play_backwards("prime_lever_forward")
 

#endregion

#region GUAGE CONTROL LOGIC
# -----------------------------------------------------------------------------#
# Cooling System #

func handle_temp():
	if temperature > max_temp:
		temperature = max_temp
	if State.RUNNING:
		temperature += 10
		if quality >= 50: # Cooling Quality
			max_temp = 120.0

func temp_guage():
	temp_bar.value = temperature
	return

# -----------------------------------------------------------------------------#
# Fuel System #

func handle_fuel():
	if fuel_level > max_fuel:
		fuel_level = max_fuel
		# Overfill Animation
	if State.RUNNING:
		if quality == 3:
			fuel_level -= fuel_consumption
			return
		if quality == 2:
			fuel_level -= fuel_consumption * 1.2
			return
		if quality == 1:
			fuel_level -= fuel_consumption * 2.5
			return


func fuel_gauge():
	print("Current Fuel Level = ", fuel_level)
	fuel_bar.value = fuel_level
	return

#endregion

#region QUALITY CONTROL

# -----------------------------------------------------------------------------#
# Cooling System #

func determine_coolant_quality():
	cooling_system.relay_coolant_quality()
	return

func determine_fuel_quality():
	return

func determine_oil_quality():
	return

func determine_overall_engine_quality():
	if quality:	
		quality = (coolant_quality + fuel_quality + oil_quality) / 3
		return

#endregion
