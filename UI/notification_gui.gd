extends Control

enum NotificationType {MISC, ERROR}

var notification_node = preload("res://UI/notification.tscn")

@onready var notification_container: VBoxContainer = $Margin/NotificationContainer

func add_notification(type : NotificationType, text : String):
	var new_notification = notification_node.instantiate()
	new_notification.init(type, text)
	new_notification.delete_signal.connect(free_notification)
	notification_container.add_child(new_notification)

func free_notification():
	notification_container.get_child(0).queue_free()
