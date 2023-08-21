extends SettingsGroup


@export var _servers_parent: Control
@export var _servers_settings_parent: Control
@export var _servers: Array[ServerSettingsGUI]


var _server_settings_gui: PackedScene = preload("res://Scenes/server_settings_gui.tscn")
var _server_gui: PackedScene = preload("res://Scenes/server_gui.tscn")


func add_server():
	_add_server()
	save.emit(self)


func _add_server():
	var server_settings_gui: ServerSettingsGUI = _server_settings_gui.instantiate()
	_servers_settings_parent.add_child(server_settings_gui)
	_servers_settings_parent.move_child(server_settings_gui, len(_servers_settings_parent.get_children()) - 2)

	var server_gui = _server_gui.instantiate()
	_servers_parent.add_child(server_gui)

	server_settings_gui.set_server_gui(server_gui)

	server_settings_gui.pop_server.connect(pop_server)

	_servers.append(server_settings_gui)

	add_setting(server_settings_gui.get_setting())


func pop_server(server: ServerSettingsGUI):
	var i = _servers.find(server)

	if i > -1:
		_pop_server(i)


func _pop_server(index: int):
	if index < len(_servers):
		remove_setting(_servers[index].get_setting())
		_servers[index].get_server_gui().queue_free()
		_servers[index].queue_free()
		_servers.pop_at(index)
		save.emit(self)


func serialize():
	var list = []

	for server in _servers:
		list.append(server.get_setting().serialize())

	return {_key: list}


func load_value(new_value):
	for i in len(new_value):
		_add_server()

		_servers[i].get_setting().load_value(new_value[i])
