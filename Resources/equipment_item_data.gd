extends ItemData

class_name EquipmentData

enum EquipmentType {HEAD, CHEST, HANDS, JEWELRY, FEET}

@export var equipment_type : EquipmentType
@export var item_effects : Array[BuffEffect]
