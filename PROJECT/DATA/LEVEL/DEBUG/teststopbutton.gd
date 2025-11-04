extends StaticBody3D

func Interact():
	if PlayerHome.fTravel_Speed == 0: 
		PlayerHome.fTravel_Speed = 1
		return
	if PlayerHome.fTravel_Speed > 0: 
		PlayerHome.fTravel_Speed = 0
		return
