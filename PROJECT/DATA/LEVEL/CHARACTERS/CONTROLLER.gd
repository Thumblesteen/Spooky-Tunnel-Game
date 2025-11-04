extends CharacterBody3D

@export_category("CONTROLS")
## CONTROLS -- A series of animationplayers that govern player motion and function.
# By using animationplayers as controls, you can manipulate a lot of nodes under the
# camera for incidental movement. Such as viewbobbing when sprinting, or even falling
# over or being disoriented. Adds a lot of functionality. 

@export var CONT_WALK:AnimationPlayer
@export var CONT_FALL:AnimationPlayer
@export var CONT_JUMP:AnimationPlayer
@export var CONT_INCIDENTAL:AnimationPlayer
@export var CONT_BUMP:AnimationPlayer
@export var CONT_CROUCH:AnimationPlayer
@export var CONT_IDLE: AnimationPlayer

@export_category("AnimationDictionary")
## This is where you enter the string names of certain animations.
@export var sCROUCH_Normal:StringName = "CROUCH"
@export var sFST_L:StringName = "FST_L"
@export var sFST_R:StringName = "FST_R"
@export var asBump:Array[StringName] = ["BUMP_01"]

@export_category("INPUT VARS")
## Variables for the inputs, can be manipulated by player stats. 
@export var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var speed:float = 5
@export var jump_speed:float = 5
@export var mouse_sensitivity:float = 0.002

@export_category("CAMERA")
@export var cPlayerCamera:Camera3D
@export var InteractionNose:RayCast3D
@export var InteractPrompt:Label3D

@export_category("TIMERS")
@export var StepTimer:Timer

#----CRITICAL VARS----#
var fDelta:float
var refInputEvent:InputEvent
var v3PlayerMovement:Vector3
var fStepTime:float = 0.4
var bSprinting:bool = false
var bCrouching:bool = false

@export var fRunSpeed_Base:float = 5
var fRunSpeed_Real:float = 5

var fRunSpeedModifier_Sprint:float = 1.75
var fRunSpeedModifier_Crouch:float = 0.5
var fRunSpeedModifier_Leap:float = 1.65
var fRunSpeedModifier_Slide:float = 2.5
#-------------------------PROCESS-----------------------------------#

func _ready() -> void:
	DeclarePlayer()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	StepTimer.start(fStepTime)

func _physics_process(delta: float) -> void:
	if CoreKiller(): return
	DeclareDelta(delta)
	InputProcess()
	VisibilityControl()
	BumpProcess()

func _input(event: InputEvent) -> void:
	if CoreKiller(): return
	DeclareInput(event)
	MouseProcess()
	JumpProcess()
	CrouchProcess()
	InteractProcess()
	SprintProcess()

#-------------------------METHODS-----------------------------------#
#---------UTILITY--------------------------------#

func DeclarePlayer():
	World.SetPlayer(self)

func VisibilityControl():
	if InteractionNose.is_colliding(): InteractPrompt.visible = true
	else: InteractPrompt.visible = false

func DeclarePlayerDirection(v3Direction:Vector3):
	v3PlayerMovement = v3Direction

func DeclareDelta(delta:float):
	fDelta = delta

func DeclareInput(event):
	refInputEvent = event

func IsMoving():
	if v3PlayerMovement == Vector3.ZERO: return false
	else: return true

@export var bKillCore:bool = false

func CoreKiller():
	if World.cCamera.current != true: return true
	if CONT_BUMP.is_playing(): return true
	return bKillCore
#---------UTILITY--------------------------------#

var fRunSpeed_StaminaMod:float = 1

func StaminaModifier(fVal:float):
	return fVal * abs(float( 100 / PlayerData.iMaxStamina - PlayerData.iStamina ) / 65)
	
#	if PlayerData.iStamina < PlayerData.iMaxStamina * 0.20: return fVal * 0.1
#	if PlayerData.iStamina >= PlayerData.iMaxStamina: return 1.0
#	if PlayerData.iStamina >= PlayerData.iMaxStamina * 0.80: return fVal * 1.00
#	if PlayerData.iStamina >= PlayerData.iMaxStamina * 0.60: return fVal * 0.80
#	if PlayerData.iStamina >= PlayerData.iMaxStamina * 0.40: return fVal * 0.60
#	if PlayerData.iStamina >= PlayerData.iMaxStamina * 0.20: return fVal * 0.40

func GetSpeed():
	fRunSpeed_Real = fRunSpeed_Base
	if bSprinting: fRunSpeed_Real = fRunSpeed_Real * fRunSpeedModifier_Sprint
	if bCrouching && is_on_floor(): fRunSpeed_Real = fRunSpeed_Real * fRunSpeedModifier_Crouch
	if !self.is_on_floor() && bSprinting: fRunSpeed_Real = fRunSpeed_Real * fRunSpeedModifier_Leap
	if self.is_on_floor() && self.bSprinting && CONT_CROUCH.is_playing() && bCrouching: fRunSpeed_Real = fRunSpeed_Real * fRunSpeedModifier_Slide
	return StaminaModifier(fRunSpeed_Real)



func SprintProcess():
	if Input.is_action_just_pressed("NAV_ACCELERATE"): bSprinting = true
	if Input.is_action_just_released("NAV_ACCELERATE"): bSprinting = false

func InputProcess():
	velocity.y += -gravity * fDelta
	var input = Input.get_vector("NAV_LEFT", "NAV_RIGHT", "NAV_FORWARD", "NAV_BACKWARD")
	var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
	DeclarePlayerDirection(movement_dir)
	velocity.x = movement_dir.x * GetSpeed()
	velocity.z = movement_dir.z * GetSpeed()
	move_and_slide()

func MouseProcess():
	if refInputEvent is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-refInputEvent.relative.x * mouse_sensitivity)
		cPlayerCamera.rotate_x(-refInputEvent.relative.y * mouse_sensitivity)
		cPlayerCamera.rotation.x = clampf(cPlayerCamera.rotation.x, -deg_to_rad(70), deg_to_rad(70))

@export var iStaminaJumpCost:int = 15

func JumpProcess():
	if PlayerData.iStamina < iStaminaJumpCost: return
	if is_on_floor() and Input.is_action_just_pressed("NAV_UP"):
		velocity.y = jump_speed
		PlayerData.ReduceStamina(iStaminaJumpCost)
		PlayerData.rHudNode.StaminaBlip()

@onready var crouch_checker: RayCast3D = $CrouchChecker

var bUnCrouch:bool = false

func CrouchProcess():
	if crouch_checker.is_colliding() && bCrouching: 
		bUnCrouch = true
		return
	if bUnCrouch && !crouch_checker.is_colliding() && bCrouching && !Input.is_action_pressed("NAV_DOWN"): 
		bCrouching = false
		bUnCrouch = false
		CONT_CROUCH.play_backwards(sCROUCH_Normal)
	if Input.is_action_just_pressed("NAV_DOWN"):
		bCrouching = true
		CONT_CROUCH.play(sCROUCH_Normal)
	if Input.is_action_just_released("NAV_DOWN"):
		bCrouching = false
		CONT_CROUCH.play_backwards(sCROUCH_Normal)

var bStep:bool = false

func StepProcess():
	if !IsMoving(): 
		CONT_WALK.stop()
		return
	if CONT_WALK.is_playing(): return
	if bStep: 
		bStep = false
		CONT_WALK.play(sFST_R)
		return
	else:
		bStep = true
		CONT_WALK.play(sFST_L)
		return


func _on_step_timer_timeout() -> void:
	StepTimer.start(fStepTime)
	StepProcess()

var rInteractionNoseObject:CollisionObject3D
@onready var instruction: Label3D = $NODE_CAMERA/NODE_DAMAGE/NODE_FALL/NODE_RECOIL/NODE_INTERACT/NODE_PIVOT/NODE_LIMP/NODE_INJURY/NODE_FST/NODE_IDLE/NODE_KNOCK/NODE_FX/NODE_REACH/NODE_BUMP/Camera3D/INTERACTION/InteractPrompt/INSTRUCTION
@onready var cont_interaction: AnimationPlayer = $NODE_CAMERA/NODE_DAMAGE/NODE_FALL/NODE_RECOIL/NODE_INTERACT/NODE_PIVOT/NODE_LIMP/NODE_INJURY/NODE_FST/NODE_IDLE/NODE_KNOCK/NODE_FX/NODE_REACH/NODE_BUMP/Camera3D/INTERACTION/InteractPrompt/CONT_Interaction

func ClearInstructions():
	if cont_interaction.is_playing(): return
	if instruction.modulate != Color(0, 0, 0, 0): cont_interaction.play_backwards("UI.Show")
	else: instruction.text = ""

func MetaDataHandling_InteractLabel():
	if !InteractionNose.is_colliding(): 
		return
	if InteractionNose.get_collider() == null: return
	if InteractionNose.get_collider().has_meta("Instructions") && rInteractionNoseObject != null: 
		instruction.text = InteractionNose.get_collider().get_meta(&"Instructions")
	else: ClearInstructions()

func InteractProcess():
	rInteractionNoseObject = InteractionNose.get_collider()
	if rInteractionNoseObject == null: ClearInstructions()
	PlayerData.rPlayerNoseObject = rInteractionNoseObject
	MetaDataHandling_InteractLabel()
	if instruction.modulate != Color(0, 0, 0) && InteractionNose.get_collider() != null: cont_interaction.play("UI.Show")
	if !Input.is_action_just_pressed("FUNC_USE"): 
		return
	print("OOoooooo! Someone's pressing the E button! HECK YEP BROTHER!")
	if !InteractionNose.is_colliding(): 
		ClearInstructions()
		return
	print("HOLEY MOLEY WE HAVE A COLLIDING OBJECT!")
	if InteractionNose.get_collider() == null: return
	print("WOOPIEEEDOOO! We're Interacting!")
	#InteractionNose.get_collider().Interact()
	PerformInteraction(InteractionNose.get_collider(), "Interact")

func PerformInteraction(rObject:CollisionObject3D, sMethod:StringName):
	if rObject.has_method(sMethod): 
		print("WOOOOH! LOOKS LIKE WE'RE DOING SOME KINDA WEIRD "+str(sMethod))
		rObject.call(sMethod)

@onready var bumper: RayCast3D = $NODE_CAMERA/NODE_DAMAGE/NODE_FALL/NODE_RECOIL/NODE_INTERACT/NODE_PIVOT/NODE_LIMP/NODE_INJURY/NODE_FST/NODE_IDLE/NODE_KNOCK/NODE_FX/NODE_REACH/NODE_BUMP/Camera3D/INTERACTION/Bumper
var rBumpObject

func BumpProcess():
	if !bumper.is_colliding(): return
	if GetSpeed() < fRunSpeed_Base * fRunSpeedModifier_Sprint: return
	if CONT_BUMP.is_playing(): return
	rBumpObject = bumper.get_collider()
#		fJumpSpeed = movement_dir.length()
#		if !is_on_floor: fDamageAddon = fJumpSpeed * 2
#		else: fDamageAddon = 0
#		DamagePlayer_BluntFX(fJumpSpeed * 5 + fDamageAddon)
	#velocity.y = 0
	velocity.x = 0
	velocity.z = 0
	Input.action_release("NAV_DOWN")
	Input.action_release("NAV_BACKWARD")
	Input.action_release("NAV_LEFT")
	Input.action_release("NAV_RIGHT")
	Input.action_release("NAV_FORWARD")
	Input.action_release("NAV_ACCELERATE")
	bSprinting = false
	if PlayerData.rPlayerNoseObject != null && PlayerData.rPlayerNoseObject.has_method("Bump") && UTIL.D20(8, int(GetSpeed())): PlayerData.rPlayerNoseObject.Bump()
	CONT_WALK.stop()
	CONT_IDLE.stop()
	PlayerData.DamagePlayer(int(GetSpeed()))
	CONT_BUMP.play(asBump.pick_random())

@onready var stamina_timer: Timer = $CONTROL/StaminaTimer


func IdleProcess():
	if CONT_IDLE.is_playing(): return
	if PlayerData.iStamina >= PlayerData.iMaxStamina * 0.55: CONT_IDLE.speed_scale = 1
	else: CONT_IDLE.speed_scale = 3
	if PlayerData.iStamina >= PlayerData.iMaxStamina * 0.75: CONT_IDLE.play("IDLE_NORMAL")
	if !PlayerData.iStamina >= PlayerData.iMaxStamina * 0.75 && !IsMoving(): CONT_IDLE.play("IDLE_FATIGUED")


func _on_stamina_timer_timeout() -> void:
	if bSprinting && IsMoving(): PlayerData.ReduceStamina(1)
	if IsMoving() && PlayerData.iStamina > PlayerData.iMaxStamina * 0.75: 
		if UTIL.CoinToss(): PlayerData.ReduceStamina(1)
	if UTIL.CoinToss() && !IsMoving(): PlayerData.RestoreStamina(1)
	if UTIL.CoinToss() && !IsMoving() && bCrouching: PlayerData.RestoreStamina(1)
	stamina_timer.start(0.30)
	IdleProcess()
