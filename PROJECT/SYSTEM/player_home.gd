extends Node

var fTravel_Speed:float = 0

func IncreaseSpeed(fValue:float = 0.001):
	fTravel_Speed += fValue

func StopSpeed():
	fTravel_Speed = 0

func DecreaseSpeed(fValue:float = 0.001):
	fTravel_Speed -= fValue

func SpeedRate(fVal):
	return fVal * fTravel_Speed

func SetAnimationSpeed(ref:AnimationPlayer):
	ref.speed_scale = fTravel_Speed
