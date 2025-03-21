extends PanelContainer

@onready var item_name: Label = $MarginContainer/VBox/Name
@onready var description: Label = $MarginContainer/VBox/Description
@onready var effect_container: VBoxContainer = $MarginContainer/VBox/EffectContainer
@onready var action_container: VBoxContainer = $MarginContainer/VBox/ActionContainer
@onready var value: Label = $MarginContainer/VBox/HBox/PanelC/Value
@onready var weight: Label = $MarginContainer/VBox/HBox/PanelC2/Weight

var inventory_action = preload("res://UI/inventory_action.tscn")

var item : EquipmentData

func init(item_data : EquipmentData):
	item = item_data
	item_name.text = item.name
	description.text = item.description
	value.text = str(item.value)
	weight.text = str(item.weight)
	for i in item.item_effects:
		var new_label = Label.new()
		new_label.text = str(i.value)
		effect_container.add_child(new_label)
	var interact_action = inventory_action.instantiate()
	interact_action.init("E", "Unequip")
	action_container.add_child(interact_action)
	var drop_action = inventory_action.instantiate()
	drop_action.init("R", "Drop")
	action_container.add_child(drop_action)

func handle_free():
	queue_free()
