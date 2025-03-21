extends PanelContainer

class_name InventorySlot

signal slot_clicked

@onready var select_border: Panel = $SelectBorder
@onready var name_label: Label = $HBox/MarginContainer/NameLabel
@onready var stack_label: Label = $HBox/MarginContainer2/StackLabel
@onready var weigth_label: Label = $HBox/MarginContainer3/WeigthLabel

@export var data: ItemData

var selected : bool
var stack_size : int

func _ready() -> void:
	name_label.text = data.name
	weigth_label.text = str(data.weight)
	update_stack()

func select(is_selected : bool):
	if is_selected:
		selected = true
		select_border.visible = true
	else:
		selected = false
		select_border.visible = false

func init(_data: ItemData, _stack_size: int):
	data = _data
	stack_size = _stack_size

func update_stack():
	stack_label.text = "x" + str(stack_size)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		select(true)
		slot_clicked.emit()
		#selected = true # spaghetti code, but without this slot would get unselected if already selected
		#select_border.visible = true # needed anymore?
