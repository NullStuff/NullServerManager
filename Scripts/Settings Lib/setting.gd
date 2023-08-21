extends Node
class_name Setting


signal value_loaded(new_value)
signal save(setting)


@export var _key: String = "";


var _value


func _ready():
	# print("Setting is ready! %s" % get_path())
	if _key == "":
		printerr("Setting '%s' has blank key. This may lead to undesireable behaviour, please specify a key." % get_path())


func get_value():
	return _value


func get_key():
	return _key


func load_value(new_value):
	_value = new_value
	value_loaded.emit(new_value)


func save_value(new_value):
	_value = new_value
	save.emit(self)


func serialize():
	return {_key: _value}
