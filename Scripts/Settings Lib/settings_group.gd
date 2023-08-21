extends Setting
class_name SettingsGroup


@export var _settings_and_groups: Array[NodePath]


var _settings: Array[Setting]


func _ready():
	# print("Hello, I am %s" % get_path())
	for node_path in _settings_and_groups:
		var node = get_node(node_path)

		if node == null:
			printerr("null node passed!")
		elif node is Setting:
			# print("is setting")
			_settings.append(node)
		elif node.has_method("get_setting"):
			# print("node %s has setting, and is ready? %s" % [node.get_path(), node.is_node_ready()])
			_settings.append(node.get_setting())

	for setting in _settings:
		# print("Connecting to setting %s" % setting)
		setting.save.connect(_on_save)

	# print("%s has child settings %s" % [get_path(), _settings])


func add_setting(setting: Setting):
	_settings.append(setting)

	setting.save.connect(_on_save)


func remove_setting(setting: Setting):
	var i = _settings.find(setting)

	if i > -1:
		_settings.pop_at(i)
		setting.save.disconnect(_on_save)


func load_value(values: Dictionary):
	for setting in _settings:
		var key = setting.get_key()

		# empty keys get passed the whole set of values since their keys
		# got collapsed into this set of values anyway.
		# this may cause weird behaviour at the setting level.
		if key == "":
			setting.load_value(values)
		elif values.has(key):
			setting.load_value(values.get(key))


func _on_save(_setting):
	save.emit(self)


func serialize():
	if len(_settings) > 0:
		var dict = {}

		for setting in _settings:
			dict.merge(setting.serialize())

		# this can lead to alot of confusion, consider removing it.
		# this is likely fixed by passing values down to any children
		# with empty keys on load.
		if _key == "":
			return dict

		return {_key: dict}

	return {}
