extends Resource

class_name SlotData

@export var item_data : ItemData
@export var quantity : int = 1#: set = set_quantity

func init(_item_data : ItemData, _quantity : int):
	item_data = _item_data
	quantity = _quantity
