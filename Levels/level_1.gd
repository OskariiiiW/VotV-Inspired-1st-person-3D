extends Node3D

#@onready var clouds: Node3D = $Clouds

#var wind_direction : Vector3 = Vector3(50,0,50)

#BUG - cloud container moves, but active particles dont

#func _on_timer_timeout() -> void:
#	for i in clouds.get_children():
#		i.move_clouds(wind_direction)
