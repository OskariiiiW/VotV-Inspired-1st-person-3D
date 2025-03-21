extends StaticBody3D

var slot1 : Array[Node3D]
var slot2 : Array[Node3D]
var slot3 : Array[Node3D]
var slot4 : Array[Node3D]
var slot5 : Array[Node3D]

func interact(object : CharacterBody3D):
	for i in slot1.size():
		print(slot1[i].name)
		if i > 0:
			object.GUI.notification_gui.add_notification(1, "Too many items in slot 1")
	for i in slot2.size():
		print(slot2[i].name)
		if i > 0:
			object.GUI.notification_gui.add_notification(1, "Too many items in slot 2")
	for i in slot3.size():
		print(slot3[i].name)
		if i > 0:
			object.GUI.notification_gui.add_notification(1, "Too many items in slot 3")
	for i in slot4.size():
		print(slot4[i].name)
		if i > 0:
			object.GUI.notification_gui.add_notification(1, "Too many items in slot 4")
	for i in slot5.size():
		print(slot5[i].name)
		if i > 0:
			object.GUI.notification_gui.add_notification(1, "Too many items in slot 5")

func _on_slot_1_body_entered(body: Node3D) -> void:
	print("brr")
	if body.is_in_group("grabbable"):
		slot1.append(body)

func _on_slot_1_body_exited(body: Node3D) -> void:
	print("rrb")
	if body.is_in_group("grabbable"):
		slot1.erase(body)


func _on_slot_2_body_entered(body: Node3D) -> void:
	print("brr")
	if body.is_in_group("grabbable"):
		slot2.append(body)

func _on_slot_2_body_exited(body: Node3D) -> void:
	print("rrb")
	if body.is_in_group("grabbable"):
		slot2.erase(body)
