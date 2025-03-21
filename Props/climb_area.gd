extends Node3D

func _on_climb_area_top_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		if body.is_in_group("player"):
			body.set_state(6)
			#{DEFAULT, SPRINT, JUMP, FALL, CROUCH, VAULT, CLIMB}

func _on_climb_area_top_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		if body.is_in_group("player"):
			body.grav_enabled = true
			body.set_state(3)
