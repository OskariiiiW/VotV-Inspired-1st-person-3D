extends Control

signal handle_result(is_correct)

@onready var code_display: Label = $PanelC/Margin/VBox/PanelC/CodeDisplay

@export var keycode : Array[int]
var player_input : Array[int]

func number_pressed(number : int):
	if player_input.size() == 0:
		code_display.text = ""
	player_input.append(number)
	code_display.text += str(number)

func check_keycode():
	if player_input == keycode:
		handle_result.emit(true)
		print("correct")
	else:
		handle_result.emit(false)
		print("incorrect")
	player_input.clear()

func _on_button_7_pressed() -> void:
	number_pressed(7)

func _on_button_8_pressed() -> void:
	number_pressed(8)

func _on_button_9_pressed() -> void:
	number_pressed(9)

func _on_button_4_pressed() -> void:
	number_pressed(4)

func _on_button_5_pressed() -> void:
	number_pressed(5)

func _on_button_6_pressed() -> void:
	number_pressed(6)

func _on_button_1_pressed() -> void:
	number_pressed(1)

func _on_button_2_pressed() -> void:
	number_pressed(2)

func _on_button_3_pressed() -> void:
	number_pressed(3)

func _on_button_0_pressed() -> void:
	number_pressed(0)

func _on_ok_pressed() -> void:
	check_keycode()

func _on_cancel_pressed() -> void:
	player_input.clear()
	code_display.text = ""
