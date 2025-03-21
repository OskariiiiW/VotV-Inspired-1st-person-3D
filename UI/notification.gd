extends PanelContainer

signal delete_signal

@onready var icon: TextureRect = $Margin/HBox/Icon
@onready var label: Label = $Margin/HBox/Label

var type : int
var text : String

func _ready() -> void:
	label.text = text
	if type == 1: # 0 : neutral, 1 : error, 2 : green something
		label.add_theme_color_override("font_color", "RED")

func init(_type : int, _text : String):
	type = _type
	text = _text

func _on_timer_timeout() -> void:
	delete_signal.emit()
