extends Resource

class_name BuffEffect

enum ElementType {NONE, FIRE, WATER, AIR, EARTH}
enum StatType {HP, SP, MP, RES} #DMG, SPEED
enum EffectType {RESTORE, ENHANCE, REGEN, SKILLCOST}
enum AmountType {FLATVALUE, PERCENT}

@export var element_type : ElementType
@export var stat_type : StatType
@export var effect_type : EffectType
@export var value_type : AmountType
@export var value : float
@export var duration : float # if 0.0, effect will be instant (duh!) - since 0.6 != 1 sec, double check values
@export var can_stack : bool # whether same effect can appear as a buff multiple times
#@export var icon : Texture2D # for buff/debuff UI
