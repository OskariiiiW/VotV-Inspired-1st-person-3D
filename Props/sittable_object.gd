extends Grabbable

@onready var sit_marker: Marker3D = $SitMarker

func interact(object : CharacterBody3D):
	print(object.name + " interacting with " + name)
	object.sit(sit_marker.global_position, self.rotation)
	object.reparent(self)
