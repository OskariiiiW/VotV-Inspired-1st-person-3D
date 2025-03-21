extends CanvasLayer

@onready var fps: Label = $FPS
@onready var inventory_gui: Control = $InventoryGUI
@onready var notification_gui: Control = $NotificationGUI

@export var player : CharacterBody3D

var select_held : bool
var btn_hold_timer : int

func _physics_process(_delta): #_process(_delta):
	if Input.is_action_just_pressed("inventory"):
		inventory_gui.visible = !inventory_gui.visible
		if inventory_gui.visible:
			inventory_gui.reset_selector()
			player.handle_menu_open()
		else:
			player.handle_menu_close()
			inventory_gui.handle_external_inv_close()

	if inventory_gui.visible:
		if inventory_gui.stack_selector.visible:
			if Input.is_action_just_pressed("ui_right"):
				inventory_gui.stack_selector.move_slider(false)
			if Input.is_action_just_pressed("ui_left"):
				inventory_gui.stack_selector.move_slider(true)
			if Input.is_action_just_pressed("ui_select"):
				inventory_gui.stack_selector._on_confirm_pressed()
		else:
			if Input.is_action_just_pressed("ui_up"):
				inventory_gui.move_selector(0)
			if Input.is_action_just_pressed("ui_right"):
				inventory_gui.move_selector(1)
			if Input.is_action_just_pressed("ui_down"):
				inventory_gui.move_selector(2)
			if Input.is_action_just_pressed("ui_left"): #ui_left"
				inventory_gui.move_selector(3)
			# button hold for item interact if ext_inv open
			if Input.is_action_just_pressed("ui_select"):
				if inventory_gui.ext_item_container.visible:
					select_held = true
				else:
					inventory_gui.item_interact()
			if Input.is_action_pressed("ui_select"):
				if select_held:
					btn_hold_timer += 1
				if btn_hold_timer > 15:
					inventory_gui.item_interact()
					select_held = false
					btn_hold_timer = 0
			if Input.is_action_just_released("ui_select"):
				if select_held:
					inventory_gui.handle_transfer()
				select_held = false
				btn_hold_timer = 0
			if Input.is_action_just_pressed("reload"):
				inventory_gui.handle_drop(player.drop_pos_marker.global_position)

	fps.text = str(Engine.get_frames_per_second())
	if Engine.get_frames_per_second() < 30.0:
		fps.set("theme_override_colors/font_color","Red")
	else:
		fps.set("theme_override_colors/font_color","White")

func close_menu(): # only used to close inv when pressing esc
	if inventory_gui.stack_selector.visible:
		inventory_gui._on_stack_prompt_cancel_pressed()
	else:
		inventory_gui.handle_external_inv_close()
		inventory_gui.visible = false
		player.handle_menu_close()

func open_external_inv(data): # nothing to call atm
	inventory_gui.handle_external_inv_open(data)
	inventory_gui.visible = true
	player.handle_menu_open()

func _on_inventory_gui_notification_signal(type: Variant, text: Variant) -> void:
	notification_gui.add_notification(type, text)
