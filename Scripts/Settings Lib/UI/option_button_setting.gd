@tool
extends OptionButton


@export var setting_key: String = "" :
	set(value):
		setting_key = value
		if _setting != null:
			_setting._key = value


@onready var _setting: Setting = $Setting


# Called when the node enters the scene tree for the first time.
func _ready():
	_setting._key = setting_key

	if _setting._value == null:
		_setting.load_value(selected)


func get_setting():
	return _setting


func _on_setting_value_loaded(new_value):
	if new_value is int or new_value is float:
		selected = new_value
	else:
		printerr("Value %s invalid for option button %s" % [new_value, get_path()])


func _on_item_selected(index:int):
	_setting.save_value(index)
