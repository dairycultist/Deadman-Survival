extends Item

@export var ammo_type: String = "pistol"
@export var ammo_amount: int = 15

# TODO when you click on an ammo_item in the backpack, if you're holding
# a weapon that accepts the corresponding ammo type, it reloads it,
# otherwise it does nothing (does not equip)
