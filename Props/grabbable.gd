extends RigidBody3D

class_name Grabbable

@export var item_data : ItemData

var grabber
var is_grabbed
var original_collision_mask

#TODO - change grab from position change to apply_impulse so cant lift heavy items
#TODO - movement speed affected by dragged item weight - gets slower the further player is from obj

func _ready() -> void:
	if get_collision_layer_value(5):
		original_collision_mask = 5
	elif get_collision_layer_value(6):
		original_collision_mask = 6
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC # so I dont have to set it manually to every object

func interact(object : CharacterBody3D):
	print(object.name + " interacting with " + name)
	if item_data:
		if object.GUI.inventory_gui.add_item(item_data) == true:
			queue_free()
		else:
			object.GUI.notification_gui.add_notification(1, "No room in inventory")

func grab(object : CharacterBody3D):
	grabber = object
	is_grabbed = true
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC # bc kinematic stops rotation for some reason
	self.freeze = true
	self.set_collision_layer_value(7, true) # grabbed item layer
	self.set_collision_layer_value(original_collision_mask, false)

func release():
	if grabber: # bc sometimes crashes bc null - gets called multiple times at once??
		is_grabbed = false
		self.freeze = false
		freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		self.set_collision_layer_value(original_collision_mask, true)
		self.set_collision_layer_value(7, false) # grabbed item layer
		#var impulse_strength = 1 #* mass # useless?
		#var angle = -position + grabber.grab_pos_marker.global_position
		#apply_central_impulse(angle * impulse_strength)
		grabber = null

func _physics_process(_delta: float) -> void:
	if is_grabbed:
		position = lerp(position, grabber.grab_pos_marker.global_position, 0.15)
		#var impulse_strength = 14 #7
		#var angle = -position + grabber.grab_pos_marker.global_position
		#apply_impulse(angle * impulse_strength)
		if self.global_position.distance_to(grabber.grab_pos_marker.global_position) > 1.5:
			print("too far")
			grabber.release_grabbed_obj()
