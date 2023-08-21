@tool
extends CheckButton


@export var setting_key: String = "" :
	set(value):
		setting_key = value
		if _setting:
			_setting._key = value


@onready var _setting: Setting = $Setting


# Called when the node enters the scene tree for the first time.
func _ready():
	_setting._key = setting_key
	if _setting._value == null:
		_setting.load_value(toggle_mode)


func get_setting():
	return _setting


func _on_setting_value_loaded(new_value):
	if new_value is bool:
		button_pressed = new_value
	else:
		printerr("Value %s invalid for check button %s" % [new_value, get_path()])


func _on_toggled(button_state:bool):
	_setting.save_value(button_state)
