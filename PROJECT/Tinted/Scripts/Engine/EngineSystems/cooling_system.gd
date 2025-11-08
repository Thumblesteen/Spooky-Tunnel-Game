extends Node3D
class_name CoolingSystem

var max_coolant_amount: float = 500.0
var coolant_amount: float = 0.0
var coolant_quality: float = 0.0

var adding_coolant: bool = false
var consuming_coolant: bool = false



func add_coolant():
	if coolant_amount == max_coolant_amount:
		adding_coolant = false
		print("Coolant tank is full.")
		return

	else:
		adding_coolant = true
		if adding_coolant:
			coolant_amount += 15.0
			print("Adding coolant to resevoir.")

			if coolant_amount >= max_coolant_amount:
				coolant_amount = max_coolant_amount
				return


func consume_coolant():
	if coolant_amount <= 0.0:
		print("Coolant tank is empty.")
		return

	if coolant_amount > 0.0:
		consuming_coolant = true
		print("Coolant is draining.")
		if consuming_coolant:
			coolant_amount -= 25.0
			if coolant_amount <= 0.0:
				coolant_amount = 0.0
			return


func determine_coolant_quality():
	if adding_coolant:
		## Check coolant quality that is being added.
		return
