extends Resource

class_name ItemData

enum Type {MISC, EQUIPMENT, CONSUMABLE, BOOK} # dunno what else there should be

@export var name : String
@export var type : Type
@export var description : String
@export var is_stackable : bool
@export var weight : float
@export var value : int
@export var icon : Texture2D
@export var scene : PackedScene
