extends StaticBody3D

func Interact():
	print("WOOOP! FOUND AN ACTIVATOR FOR A "+str(get_parent()))
	if get_parent().has_method("Interact"): get_parent().Interact()

func Bump():
	print("WOOOP! FOUND A BUMP FOR A "+str(get_parent()))
	if get_parent().has_method("Bump"): get_parent().Bump()

func Pry():
	print("WOOOP! FOUND A PRY FOR A "+str(get_parent()))
	if get_parent().has_method("Pry"): get_parent().Pry()
