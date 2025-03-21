extends PanelContainer

@onready var keybind: Label = $HBox/Keybind
@onready var action: Label = $HBox/Action

var key : String
var act : String

func _ready() -> void:
	keybind.text = "[" + key + "]"
	action.text = act

func init(_keybind : String, _action : String):
	key = _keybind
	act = _action
