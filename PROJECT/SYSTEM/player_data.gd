extends Node

var rPlayerNoseObject:CollisionObject3D
var ThingCondtion_01:int
var EquipmentCount:int = 0

var rHudNode:Control

var iHealth:int = 100
var iMaxHealth:int = 100

var iMaxStamina:int = 100
var iStamina:int = 100

func DamagePlayer(iValue = 10, sKeyword:StringName = ""):
	iHealth = iHealth - iValue
	if sKeyword == "Laceration": pass
	if sKeyword == "BluntForce": pass
	if sKeyword == "Burn": pass
	if sKeyword == "Bleed": pass

func Demonstration(Thing:CollisionObject3D):
	if Thing.has_meta("Condition"): ThingCondtion_01 = Thing.get_meta("Condition")

func DeclareHUD(cRef:Control):
	rHudNode = cRef

func EquipObject(ObjectToEquip:String):
	if EquipmentCount > 0: return
	if World.cAttachmentNode.get_child_count() > 0: return
	var nObject = load(ObjectToEquip).instantiate()
	World.cAttachmentNode.add_child(nObject)

func CanEquip():
	if World.cAttachmentNode.get_child_count() > 0: return false
	if EquipmentCount > 0: return false
	else: return true

func EvalHealth():
	if iHealth >= iMaxHealth * 0.80: return str("HEALTH STATUS:[color=green] NOMINAL")
	if iHealth >= iMaxHealth * 0.60: return str("HEALTH STATUS:[color=yellow] ACUTE")
	if iHealth >= iMaxHealth * 0.40: return str("HEALTH STATUS:[color=orange] EMERGENCY")
	if iHealth >= iMaxHealth * 0.20: return str("HEALTH STATUS:[color=red] CRITICAL")
	return str("HEALTH STATUS:[color=purple] UNKNOWN")

func ReduceStamina(iValue:int = 1):
	if UTIL.CoinToss(): iValue = iValue / 2
	if iStamina - iValue <= 0: 
		iStamina = 0
		return
	iStamina = iStamina - iValue

func RestoreStamina(iValue:int = 1):
	if iStamina >= iMaxStamina: return
	iStamina = iStamina + iValue
