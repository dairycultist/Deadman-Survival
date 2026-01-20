extends CharacterBody3D
class_name Creature

@export var _health: int = 100

func change_health(amt: int):
	_health += amt
