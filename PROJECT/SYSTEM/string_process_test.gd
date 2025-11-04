extends Control
@onready var hp: RichTextLabel = $HP
@onready var hp_display: AnimationPlayer = $HPDisplay
@onready var stamina_display: AnimationPlayer = $StaminaDisplay

var iHealthPrevious:int = 0
@onready var stamina: ProgressBar = $Stamina

func _ready() -> void:
	PlayerData.DeclareHUD(self)

func _physics_process(delta: float) -> void:
	HPProcess()
	HPDisplay()
	StaminaDisplay()

func HPProcess():
	hp.text = PlayerData.EvalHealth()

func HPDisplay():
	if iHealthPrevious == PlayerData.iHealth: return
	if hp_display.is_playing(): return
	hp_display.play("Display")
	iHealthPrevious = PlayerData.iHealth

func StaminaDisplay():
	if stamina_display.is_playing(): return
	if World.cPlayer.bSprinting && stamina.modulate != Color(1.0, 1.0, 1.0, 1.0): stamina_display.play("Display")
	if !World.cPlayer.bSprinting && stamina.modulate != Color(1.0, 1.0, 1.0, 0.0) : stamina_display.play_backwards("Display")
	stamina.value = PlayerData.iStamina
	stamina.min_value = 0
	stamina.max_value = PlayerData.iMaxStamina

func StaminaBlip():
	if stamina_display.is_playing(): return
	stamina_display.play("Display")
