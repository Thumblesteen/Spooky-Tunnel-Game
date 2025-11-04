extends Node

var iVal:int = 0
var iVal2:int = 0
var sPreviousPrint:StringName

func CutDecimals(fValue:float):
	fValue = float(str("%0.4f" % fValue," s"))
	return fValue

func CoinToss():
	iVal = randi_range(0,1)
	if iVal == 0: return true
	if iVal == 1: return false

func DiceRoll():
	iVal = randi_range(1, 6)
	iVal2 = randi_range(1, 6)
	if iVal > iVal2: return true
	else: return false

func D20(DC:int = 10, Mod:int = 0):
	iVal = randi_range(1, 20) + Mod
	if iVal >= DC: return true
	else: return false

func FinePrint(Str:StringName):
	if sPreviousPrint != Str: 
		sPreviousPrint = Str
		print(Str)
