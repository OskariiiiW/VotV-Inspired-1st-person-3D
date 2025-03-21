extends Grabbable

@export var inventory : InventoryData

func interact(object : CharacterBody3D):
	print( object.name + " interacting with " + name)
	object.GUI.open_external_inv(inventory)
