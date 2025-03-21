extends PanelContainer

signal amount_selected(_amount)
signal cancel_pressed

@onready var value_label: Label = $MarginContainer/VBoxContainer/ValueLabel
@onready var h_slider: HSlider = $MarginContainer/VBoxContainer/HSlider

var amount : int

func init(max_value : int):
	h_slider.max_value = max_value
	h_slider.value = 1
	change_value(1)
	visible = true

func change_value(value : int):
	amount = value
	value_label.text = str(amount)

func move_slider(is_left : bool):
	if is_left:
		if amount > 1:
			amount -= 1
			h_slider.value = amount
			change_value(amount)
	else:
		if amount < h_slider.max_value:
			amount += 1
			h_slider.value = amount
			change_value(amount)

func _on_h_slider_value_changed(value: float) -> void:
	change_value(int(value))

func _on_confirm_pressed() -> void:
	amount_selected.emit(amount)

func _on_cancel_pressed() -> void:
	cancel_pressed.emit()
