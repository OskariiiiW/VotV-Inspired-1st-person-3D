extends PanelContainer

class_name EquipmentSlot

@onready var select_border: Panel = $SelectBorder
@onready var texture_rect: TextureRect = $Margin/PanelC/TextureRect

@export var data: EquipmentData

var selected : bool

func init(_data: EquipmentData):
	data = _data
	texture_rect.texture = data.icon

func select(is_selected : bool):
	if is_selected:
		selected = true
		select_border.visible = true
	else:
		selected = false
		select_border.visible = false

func clear():
	data = null
	texture_rect.texture = null
