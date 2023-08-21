@tool
extends SpinBox


@export var setting_key: String = "" :
	set(new_value):
		setting_key = new_value
		if _setting != null:
			_setting._key = new_value


@onready var _setting: Setting = $Setting


# Called when the node enters the scene tree for the first time.
func _ready():
	_setting._key = setting_key

	if _setting._value == null:
		_setting.load_value(value)


func get_setting():
	return _setting


func _on_setting_value_loaded(new_value):
	if new_value is int or new_value is float:
		value = new_value
	else:
		printerr("Value %s invalid for spin box %s" % [new_value, get_path()])


func _on_value_changed(new_value:float):
	_setting.save_value(new_value)
