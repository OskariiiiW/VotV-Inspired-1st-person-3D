extends Control

signal notification_signal(type, text)

# inventory tab
@onready var inventory: HBoxContainer = $VBox/PanelC/Margin/Inventory
@onready var ext_item_container: VBoxContainer = $VBox/PanelC/Margin/Inventory/ExtInvC
@onready var ext_inv_name: Label = $VBox/PanelC/Margin/Inventory/ExtInvC/ExtItemCName
@onready var ext_inv: VBoxContainer = $VBox/PanelC/Margin/Inventory/ExtInvC/Scroll/ExtInv
@onready var item_container: VBoxContainer = $VBox/PanelC/Margin/Inventory/InvC
@onready var inv: VBoxContainer = $VBox/PanelC/Margin/Inventory/InvC/Scroll/Inv
@onready var current_weight: Label = $VBox/PanelC/Margin/Inventory/InvC/CurrentWeight
@onready var ext_current_weight: Label = $VBox/PanelC/Margin/Inventory/ExtInvC/ExtCurrentWeight
@onready var item_image: TextureRect = $VBox/PanelC/Margin/Inventory/ItemInfo/VBox/ItemImage
@onready var description: Label = $VBox/PanelC/Margin/Inventory/ItemInfo/VBox/Description
@onready var action_container: VBoxContainer = $VBox/PanelC/Margin/Inventory/ItemInfo/VBox/ActionContainer
@onready var stack_selector: PanelContainer = $StackPrompt
# equipment tab
@onready var equipment: Control = $VBox/PanelC/Margin/Equipment
@onready var hands: EquipmentSlot = $VBox/PanelC/Margin/Equipment/Hbox/Hands
@onready var head: EquipmentSlot = $VBox/PanelC/Margin/Equipment/Hbox/VBox/Head
@onready var chest: EquipmentSlot = $VBox/PanelC/Margin/Equipment/Hbox/VBox/Chest
@onready var feet: EquipmentSlot = $VBox/PanelC/Margin/Equipment/Hbox/VBox/Feet
@onready var jewelry: EquipmentSlot = $VBox/PanelC/Margin/Equipment/Hbox/Jewelry
@onready var stat_container: Control = $VBox/PanelC/Margin/Equipment/StatContainer
@onready var equipment_tooltip: PanelContainer = $EquipmentTooltip

@export var player_inventory : InventoryData

var inventory_item_slot = preload("res://UI/inventory_slot.tscn")
var inventory_action = preload("res://UI/inventory_action.tscn")
var ext_inv_data : InventoryData
var drop_pos : Vector3
var current_selector_pos : int
var selector_in_ext_inv : bool

# TODO - find a way to actually link inv action keybind with project keybinds

func _ready():
	for i in player_inventory.slot_datas.size():
		if player_inventory.slot_datas[i]: # if slot has data
			if player_inventory.slot_datas[i].item_data: # if slot has item_data
				var slot := inventory_item_slot.instantiate()
				slot.init(player_inventory.slot_datas[i].item_data, player_inventory.slot_datas[i].quantity)
				slot.slot_clicked.connect(_on_inventory_slot_slot_clicked)
				inv.add_child(slot)
				player_inventory.current_weight += player_inventory.slot_datas[i].item_data.weight \
				* player_inventory.slot_datas[i].quantity # sets current weight in inv
			else: # clears slotdata if item data missing - cannot pop bc then i skips the next one
				player_inventory.slot_datas[i] = null
				#TODO - delete null slots from array
	update_inventory()

func item_interact():
	if inventory.visible: 								# INVENTORY VIEW
		var item_data = inv.get_child(current_selector_pos).data
		if item_data.type == 1: # equipment
			print("equipment")
			if item_data.equipment_type == 0: # head
				if head.data:
					add_equipped_item(head.data)
				head.init(item_data)
			elif item_data.equipment_type == 1: # chest
				if chest.data:
					add_equipped_item(chest.data)
				chest.init(item_data)
			elif item_data.equipment_type == 2: # hands
				if hands.data:
					add_equipped_item(hands.data)
				hands.init(item_data)
			elif item_data.equipment_type == 3: # jewelry
				if jewelry.data:
					add_equipped_item(jewelry.data)
				jewelry.init(item_data)
			elif item_data.equipment_type == 4: # feet
				if feet.data:
					add_equipped_item(feet.data)
				feet.init(item_data)
			destroy_item(1)
			#{HEAD, CHEST, HANDS, JEWELRY, FEET}
		elif item_data.type == 2: # consumable
			print("consumable")
			#TODO - buff handling
		#elif item_data.type == 3: # book
	elif equipment.visible:								# EQUIPMENT VIEW
		if current_selector_pos == 0:
			if head.data:
				print("head")
				if equipment_tooltip.visible:
					add_equipped_item(head.data)
					head.clear()
					equipment_tooltip.visible = false
				else:
					equipment_tooltip.visible = true
					equipment_tooltip.init(head.data)
		elif current_selector_pos == 1:
			if chest.data:
				print("chest")
				if equipment_tooltip.visible:
					add_equipped_item(chest.data)
					chest.clear()
					equipment_tooltip.visible = false
				else:
					equipment_tooltip.visible = true
					equipment_tooltip.init(chest.data)
		elif current_selector_pos == 2:
			if jewelry.data:
				print("jewelry")
				if equipment_tooltip.visible:
					add_equipped_item(jewelry.data)
					jewelry.clear()
					equipment_tooltip.visible = false
				else:
					equipment_tooltip.visible = true
					equipment_tooltip.init(jewelry.data)
		elif current_selector_pos == 3:
			if feet.data:
				print("feet")
				if equipment_tooltip.visible:
					add_equipped_item(feet.data)
					feet.clear()
					equipment_tooltip.visible = false
				else:
					equipment_tooltip.visible = true
					equipment_tooltip.init(feet.data)
		elif current_selector_pos == 4:
			if hands.data:
				print("hands")
				if equipment_tooltip.visible:
					add_equipped_item(hands.data)
					hands.clear()
					equipment_tooltip.visible = false
				else:
					equipment_tooltip.visible = true
					equipment_tooltip.init(hands.data)

func add_equipped_item(item : ItemData): # adds equipped item to inv, ignoring weight
	var new_slot_data = SlotData.new()
	new_slot_data.init(item, 1)
	player_inventory.slot_datas.append(new_slot_data)
	var slot := inventory_item_slot.instantiate()
	slot.init(item, 1)
	slot.slot_clicked.connect(_on_inventory_slot_slot_clicked)
	inv.add_child(slot)
	update_inventory()

func add_item(item : ItemData): # returns bool to check if possible to add to inv
	if player_inventory.current_weight + item.weight <= player_inventory.max_weight:
		for i in player_inventory.slot_datas.size():
			if player_inventory.slot_datas[i]:
				if player_inventory.slot_datas[i].item_data:
					if player_inventory.slot_datas[i].item_data == item and item.is_stackable:
						player_inventory.slot_datas[i].quantity += 1
						inv.get_child(i).stack_size += 1
						inv.get_child(i).update_stack()
						player_inventory.current_weight += item.weight
						update_inventory()
						return true
		var new_slot_data = SlotData.new()
		new_slot_data.init(item, 1)
		player_inventory.slot_datas.append(new_slot_data)
		var slot := inventory_item_slot.instantiate()
		slot.init(item, 1)
		slot.slot_clicked.connect(_on_inventory_slot_slot_clicked)
		inv.add_child(slot)
		player_inventory.current_weight += item.weight
		update_inventory()
		return true
	return false

func add_ext_item(item : ItemData):
	if ext_inv_data.current_weight + item.weight <= ext_inv_data.max_weight:
		for i in ext_inv_data.slot_datas.size():
			if ext_inv_data.slot_datas[i]:
				if ext_inv_data.slot_datas[i].item_data:
					if ext_inv_data.slot_datas[i].item_data == item and item.is_stackable:
						ext_inv_data.slot_datas[i].quantity += 1
						ext_inv.get_child(i).stack_size += 1
						ext_inv.get_child(i).update_stack()
						ext_inv_data.current_weight += item.weight
						update_ext_inventory()
						return true
		var new_slot_data = SlotData.new()
		new_slot_data.init(item, 1)
		ext_inv_data.slot_datas.append(new_slot_data)
		var slot := inventory_item_slot.instantiate()
		slot.init(item, 1)
		slot.slot_clicked.connect(_on_inventory_slot_slot_clicked)
		ext_inv.add_child(slot)
		ext_inv_data.current_weight += item.weight
		update_ext_inventory()
		return true
	return false

func transfer_item(amount : int):
	for i in range (amount):
		if selector_in_ext_inv:
			var selected_slot = ext_inv.get_child(current_selector_pos)
			if add_item(selected_slot.data):
				selected_slot.stack_size -= 1
				ext_inv_data.slot_datas[current_selector_pos].quantity -= 1
				ext_inv_data.current_weight -= ext_inv_data.slot_datas[current_selector_pos].item_data.weight
				selected_slot.update_stack()
				update_ext_inventory()
			else:
				notification_signal.emit(1, "No room in inventory")
				break
			if selected_slot.stack_size == 0:
				selected_slot.free()
				ext_inv_data.slot_datas.pop_at(current_selector_pos)
				move_selector(4)
		else:
			var selected_slot = inv.get_child(current_selector_pos)
			if add_ext_item(selected_slot.data):
				selected_slot.stack_size -= 1
				player_inventory.slot_datas[current_selector_pos].quantity -= 1
				player_inventory.current_weight -= player_inventory.slot_datas[current_selector_pos].item_data.weight
				selected_slot.update_stack()
				update_inventory()
			else:
				notification_signal.emit(1, "No room in " + ext_inv_data.name)
				break
			if selected_slot.stack_size == 0:
				selected_slot.free()
				player_inventory.slot_datas.pop_at(current_selector_pos)
				move_selector(4)

func handle_transfer():
	if inventory.visible: # stop while not in inv tab
		if selector_in_ext_inv:
			var selected_slot = ext_inv.get_child(current_selector_pos)
			if selected_slot.stack_size > 3:
				stack_selector.init(selected_slot.stack_size)
			else:
				transfer_item(1)
		else:
			if ext_item_container.visible: # disables transfer if no ext inv
				var selected_slot = inv.get_child(current_selector_pos)
				if selected_slot.stack_size > 3:
					stack_selector.init(selected_slot.stack_size)
				else:
					transfer_item(1)

func drop_item(to_drop : int):
	for i in range(to_drop):
		var dropped_item = inv.get_child(current_selector_pos).data.scene.instantiate()
		get_tree().root.get_child(1).add_child(dropped_item) # TEST problems if new global scenes added
		dropped_item.position = drop_pos
		player_inventory.current_weight -= inv.get_child(current_selector_pos).data.weight
		player_inventory.slot_datas[current_selector_pos].quantity -= 1
		inv.get_child(current_selector_pos).stack_size -= 1
		inv.get_child(current_selector_pos).update_stack()
		if inv.get_child(current_selector_pos).stack_size == 0:
			player_inventory.slot_datas.pop_at(current_selector_pos)
			inv.get_child(current_selector_pos).free()
			move_selector(4)

func destroy_item(to_destroy : int):
	for i in range(to_destroy):
		player_inventory.slot_datas[current_selector_pos].quantity -= 1
		inv.get_child(current_selector_pos).stack_size -= 1
		inv.get_child(current_selector_pos).update_stack()
		if inv.get_child(current_selector_pos).stack_size == 0:
			player_inventory.slot_datas.pop_at(current_selector_pos)
			inv.get_child(current_selector_pos).free()
			move_selector(4)

func handle_drop(pos : Vector3):
	if inventory.visible: # stop while not in inv tab
		if !selector_in_ext_inv: # cannot drop items directly from ext inv
			if inv.get_child_count() > 0: # if inv not empty
				drop_pos = pos
				if inv.get_child(current_selector_pos).stack_size > 3:
					stack_selector.init(inv.get_child(current_selector_pos).stack_size)
				else:
					drop_item(1)
	elif equipment.visible:
		if equipment_tooltip.visible:
			var item_to_drop
			if current_selector_pos == 0:
				player_inventory.current_weight -= head.data.weight
				item_to_drop = head.data.scene.instantiate()
				head.clear()
			elif current_selector_pos == 1:
				player_inventory.current_weight -= chest.data.weight
				item_to_drop = chest.data.scene.instantiate()
				chest.clear()
			elif current_selector_pos == 2:
				player_inventory.current_weight -= jewelry.data.weight
				item_to_drop = jewelry.data.scene.instantiate()
				jewelry.clear()
			elif current_selector_pos == 3:
				player_inventory.current_weight -= feet.data.weight
				item_to_drop = feet.data.scene.instantiate()
				feet.clear()
			elif current_selector_pos == 4:
				player_inventory.current_weight -= hands.data.weight
				item_to_drop = hands.data.scene.instantiate()
				hands.clear()
			if item_to_drop:
				get_tree().root.get_child(1).add_child(item_to_drop) # TEST problems if new global scenes added
				item_to_drop.position = pos
				equipment_tooltip.visible = false

func move_selector(direction : int): # 0 = up, 1 = right, 2 = down, 3 = left
	if inventory.visible: # stop while not in inv tab
		if direction == 0: # up - position -- 
			if current_selector_pos > 0: # cannot be first (smallest)
				if !selector_in_ext_inv:
					inv.get_child(current_selector_pos).select(false)
					current_selector_pos -= 1
					inv.get_child(current_selector_pos).select(true)
				else:
					ext_inv.get_child(current_selector_pos).select(false)
					current_selector_pos -= 1
					ext_inv.get_child(current_selector_pos).select(true)
		elif direction == 1: # right - to player inv
			if inv.get_child_count() > 0:
				if ext_inv.get_child(current_selector_pos):
					ext_inv.get_child(current_selector_pos).select(false)
				if current_selector_pos > inv.get_child_count() - 1:
					current_selector_pos = inv.get_child_count() - 1 # selects last
				inv.get_child(current_selector_pos).select(true)
				selector_in_ext_inv = false
		elif direction == 2: # down - position ++
			if !selector_in_ext_inv:
				if current_selector_pos < inv.get_child_count() - 1: # cannot be last in array (biggest)
					inv.get_child(current_selector_pos).select(false)
					current_selector_pos += 1
					inv.get_child(current_selector_pos).select(true)
			elif current_selector_pos < ext_inv.get_child_count() - 1:
				ext_inv.get_child(current_selector_pos).select(false)
				current_selector_pos += 1
				ext_inv.get_child(current_selector_pos).select(true)
		elif direction == 3: # left - to ext inv
			if ext_inv.get_child_count() > 0:
				if inv.get_child(current_selector_pos): # stops crash if inv empty
					inv.get_child(current_selector_pos).select(false)
				if current_selector_pos > ext_inv.get_child_count() - 1:
					current_selector_pos = ext_inv.get_child_count() - 1 # selects last
				ext_inv.get_child(current_selector_pos).select(true)
				selector_in_ext_inv = true
		else: # dont move - used when slots freed
			if selector_in_ext_inv:
				if ext_inv.get_child_count() > 0:
					if ext_inv.get_child_count() <= current_selector_pos:
						current_selector_pos += -1
					if ext_inv.get_child(current_selector_pos):
						ext_inv.get_child(current_selector_pos).select(true)
				else:
					reset_selector()
			else:
				if inv.get_child_count() > 0:
					if inv.get_child_count() <= current_selector_pos:
						current_selector_pos += -1
					if inv.get_child(current_selector_pos):
						inv.get_child(current_selector_pos).select(true)
				else:
					reset_selector()
		if current_selector_pos < 0:
			current_selector_pos = 0
		set_item_info()
	else: # 0 = up, 1 = right, 2 = down, 3 = left
		if direction == 0:
			if hands.selected or chest.selected or jewelry.selected:
				hands.select(false)
				chest.select(false)
				jewelry.select(false)
				head.select(true)
				current_selector_pos = 0
			elif feet.selected:
				feet.select(false)
				chest.select(true)
				current_selector_pos = 1
		elif direction == 1:
			if head.selected or chest.selected or feet.selected:
				head.select(false)
				chest.select(false)
				feet.select(false)
				jewelry.select(true)
				current_selector_pos = 2
			elif hands.selected:
				hands.select(false)
				chest.select(true)
				current_selector_pos = 1
		elif direction == 2:
			if hands.selected or chest.selected or jewelry.selected:
				hands.select(false)
				chest.select(false)
				jewelry.select(false)
				feet.select(true)
				current_selector_pos = 3
			elif head.selected:
				head.select(false)
				chest.select(true)
				current_selector_pos = 1
		elif direction == 3:
			if head.selected or chest.selected or feet.selected:
				head.select(false)
				chest.select(false)
				feet.select(false)
				hands.select(true)
				current_selector_pos = 4
			elif jewelry.selected:
				jewelry.select(false)
				chest.select(true)
				current_selector_pos = 1
		equipment_tooltip.visible = false

func reset_selector(): # selects [0] inv slot
	if inv.get_child_count() > 0: # if player inv not empty
		for i in inv.get_children():
			i.select(false)
		inv.get_child(0).select(true)
		current_selector_pos = 0
		selector_in_ext_inv = false
		set_item_info()
	elif ext_inv.get_child_count() > 0: # if player inv empty, but ext not
		ext_inv.get_child(0).select(true)
		current_selector_pos = 0
		selector_in_ext_inv = true
		set_item_info()
	equipment_tooltip.visible = false # closes tooltip if left open before closing inv

func set_item_info():
	if inventory.visible: # stop while not in inv tab
		for i in action_container.get_children():
			i.queue_free()
		if selector_in_ext_inv:
			if ext_inv.get_child_count() > 0: # removes red error (i out of bounds)
				if ext_inv.get_child(current_selector_pos):
					item_image.texture = ext_inv.get_child(current_selector_pos).data.icon
					description.text = ext_inv.get_child(current_selector_pos).data.description
					var new_action = inventory_action.instantiate()
					new_action.init("E", "Transfer") # TODO - change to buy if shop implemented
					action_container.add_child(new_action)
			else:
				item_image.texture = null
				description.text = ""
		else:
			if inv.get_child_count() > 0: # removes red error (i out of bounds)
				if inv.get_child(current_selector_pos):
					item_image.texture = inv.get_child(current_selector_pos).data.icon
					description.text = inv.get_child(current_selector_pos).data.description
					if ext_item_container.visible:
						var transfer_action = inventory_action.instantiate()
						transfer_action.init("E", "Transfer")
						action_container.add_child(transfer_action)
						if inv.get_child(current_selector_pos).data.type != 0:
							var interact_action = inventory_action.instantiate()
							if inv.get_child(current_selector_pos).data.type == 1:
								interact_action.init("Hold E", "Equip") # TODO - better hold indicator
							elif inv.get_child(current_selector_pos).data.type == 2:
								interact_action.init("Hold E", "Eat")
							elif inv.get_child(current_selector_pos).data.type == 3:
								interact_action.init("Hold E", "Drink")
							elif inv.get_child(current_selector_pos).data.type == 4:
								interact_action.init("Hold E", "Read")
							action_container.add_child(interact_action)
						# {MISC, EQUIPMENT, FOOD, DRINK, BOOK}
					else: # main interact with "E"
						if inv.get_child(current_selector_pos).data.type != 0:
							var interact_action = inventory_action.instantiate()
							if inv.get_child(current_selector_pos).data.type == 1:
								interact_action.init("E", "Equip")
							elif inv.get_child(current_selector_pos).data.type == 2:
								interact_action.init("E", "Eat")
							elif inv.get_child(current_selector_pos).data.type == 3:
								interact_action.init("E", "Drink")
							elif inv.get_child(current_selector_pos).data.type == 4:
								interact_action.init("E", "Read")
							action_container.add_child(interact_action)
					var drop_action = inventory_action.instantiate()
					drop_action.init("R", "Drop")
					action_container.add_child(drop_action)
			else:
				item_image.texture = null
				description.text = ""

func update_inventory():
	current_weight.text = str(player_inventory.current_weight) + "/" + str(player_inventory.max_weight)

func update_ext_inventory():
	ext_current_weight.text = str(ext_inv_data.current_weight) + "/" + str(ext_inv_data.max_weight)

func handle_external_inv_open(data : InventoryData):
	ext_inv_data = data
	ext_inv_name.text = data.name
	ext_inv_data.current_weight = 0
	for i in data.slot_datas.size():
		if data.slot_datas[i]: # if slot has data
			if data.slot_datas[i].item_data: # if slot has item data
				var slot := inventory_item_slot.instantiate()
				slot.init(data.slot_datas[i].item_data, data.slot_datas[i].quantity)
				slot.slot_clicked.connect(_on_inventory_slot_slot_clicked)
				ext_inv.add_child(slot)
				ext_inv_data.current_weight += data.slot_datas[i].item_data.weight * data.slot_datas[i].quantity
			else: # clears slotdata if item data missing
				data.slot_datas[i] = null
				#TODO - delete null slots from array
	item_container.custom_minimum_size.x = 250
	ext_item_container.visible = true
	update_ext_inventory()
	reset_selector()

func handle_external_inv_close():
	ext_inv_name.text = ""
	for i in ext_inv.get_children():
		i.free()
	item_container.custom_minimum_size.x = 300
	ext_item_container.visible = false
	#TODO - save inv before freeing

func _on_stack_prompt_amount_selected(_amount: Variant) -> void:
	if ext_item_container.visible:
		transfer_item(_amount)
	else:
		drop_item(_amount)
	stack_selector.visible = false

func _on_stack_prompt_cancel_pressed() -> void:
	stack_selector.visible = false

func _on_inventory_slot_slot_clicked():
	print(str(selector_in_ext_inv) + str(current_selector_pos))
	if selector_in_ext_inv:
		ext_inv.get_child(current_selector_pos).select(false)
	else:
		inv.get_child(current_selector_pos).select(false)
	var slot_found = false
	for i in inv.get_child_count():
		if inv.get_child(i).selected:
			current_selector_pos = i
			selector_in_ext_inv = false
			slot_found = true
			set_item_info()
			break
	if !slot_found: # if clicked slot wasnt in inv, also scans ext_inv
		for i in ext_inv.get_child_count():
			if ext_inv.get_child(i).selected:
				current_selector_pos = i
				selector_in_ext_inv = true
				set_item_info()
				break

func _on_tab_bar_tab_selected(tab: int) -> void:
	if tab == 0: # inventory
		equipment.visible = false
		reset_selector()
		equipment_tooltip.visible = false
		inventory.visible = true
	elif tab == 1: # equipment
		inventory.visible = false
		current_selector_pos = 1
		head.select(false)
		chest.select(true)
		hands.select(false)
		jewelry.select(false)
		equipment.visible = true
	elif tab == 2: # stats
		print("coming soon!")
