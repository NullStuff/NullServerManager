extends VBoxContainer
class_name ServerSettingsGUI


signal pop_server(server)


@onready var _settings_group: SettingsGroup = get_node("./SettingsGroup")
var _server_gui: Control


var _server_manager
var _custom_commands_watcher


var _name: String
var _jar_path: String
var _ram_amount: int
var _ram_unit: String
var _use_custom_args: bool
var _custom_args: String
var _java_path: String
var _save_path: String
var _use_custom_commands: bool


func _ready():
	# for setting in _settings_group._settings:
	# 	if not setting is SettingsGroup:
	# 		print("Subbing to %s" % setting._key)
	# 		# _setting_saved(setting)
	# 		setting.save.connect(_setting_saved)
	# 		setting.value_loaded.connect(_setting_loaded)

	if _server_gui != null:
		# print ("SERVER MANAGER: %s" % _server_manager)
		_server_manager = _server_gui.get_node("./Server Manager")
		_custom_commands_watcher = _server_gui.get_node("./Custom Commands Watcher")
		if  _custom_commands_watcher == null:
			printerr("Spell better")

	var main = get_node("/root/Main")

	# for setting in main._settings:
	# 	if not setting is SettingsGroup:
	# 		print("Subbing to %s" % setting._key)
	# 		# _setting_saved(setting)
	# 		setting.save.connect(_setting_saved)
	# 		setting.value_loaded.connect(_setting_loaded)

	main.ready.connect(_on_main_ready)

	tree_exiting.connect(_on_exiting)


func _on_main_ready():
	for setting in _settings_group._settings:
		if not setting is SettingsGroup:
			# print("Subbing to %s" % setting._key)
			_setting_saved(setting)
			setting.save.connect(_setting_saved)
			setting.value_loaded.connect(_setting_loaded)

	var main = get_node("/root/Main")
	# print("Big stinky %s" % main)
	for setting in main._settings:
		if not setting is SettingsGroup:
			# print("Subbing to %s" % setting._key)
			_setting_saved(setting)
			setting.save.connect(_setting_saved)
			setting.value_loaded.connect(_setting_loaded)


func get_setting():
	return _settings_group


func get_server_gui():
	return _server_gui


func set_server_gui(new_server_gui: Control):
	# TODO: listen to events and such from server.

	_server_gui = new_server_gui
	# print ("SERVER GUI: %s" % _server_gui)
	_server_manager = _server_gui.get_node("./Server Manager")
	_custom_commands_watcher = _server_gui.get_node("./Custom Commands Watcher")


func _on_close_button_pressed():
	pop_server.emit(self)
	_server_manager.KillServer()


func _setting_saved(setting):
	print("Passed in setting %s" % setting._key)
	if setting.get_value() != null:
		_setting_loaded(setting.serialize())


func _setting_loaded(setting_data: Dictionary):
	print ("Loaded %s" % setting_data)
	for key in setting_data.keys():
		# print("Deploying key %s" % key)
		match key:
			"name":
				_name = setting_data[key]
			"jar_path":
				_jar_path = setting_data[key].replace("/", "\\")
			"ram_amount":
				_ram_amount = setting_data[key]
			"ram_unit":
				var i = setting_data[key]
				if i == 0:
					_ram_unit = "M"
				elif i == 1:
					_ram_unit = "G"
			"use_custom_args":
				_use_custom_args = setting_data[key]
			"custom_args":
				_custom_args = setting_data[key]
			"java_path":
				# print("Java reeee %s" % setting_data)
				_java_path = setting_data[key].replace("/", "\\")
			"save_path":
				_save_path = setting_data[key].replace("/", "\\")
			"use_custom_commands":
				print("Pogpoles")
				_use_custom_commands = setting_data[key]
				_custom_commands_watcher.set_watch(_use_custom_commands)

	if _server_manager != null:
		# print("Deploy the good good. Which now %s" % _assemble_args())
		_server_manager.SetServerName(_name)
		_server_manager.SetArgs(_assemble_args())

		var patharr = _jar_path.split("\\").slice(0, -1)
		var path = ""

		for element in patharr:
			path += element + "\\"

		_server_manager.SetWorkingDir(path)
		_server_manager.SetJavaPath(_java_path)
		_server_manager.SetSavePath(_save_path)


func _assemble_args():
	# var ram = str(_ram_amount) + _ram_unit

	if _use_custom_args:
		return _custom_args.format({"Java": _java_path, "Ram": str(_ram_amount) + _ram_unit, "Jar": _jar_path})
	else:
		return "-Xmx{Ram}{RamUnit} -Xms{Ram}{RamUnit} -jar \"{Jar}\" nogui".format({"Java": _java_path, "Ram": _ram_amount, "RamUnit": _ram_unit, "Jar": _jar_path})


func _on_exiting():
	if _server_manager != null:
		_server_manager.KillServer()
