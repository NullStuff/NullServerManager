extends Node


var _use_custom_commands: bool

@onready var _server_manager = get_node("../Server Manager")


func _ready():
	if _server_manager == null:
		printerr("FOR THE LOVE OF GOD LEARN TO SPELL")


func set_watch(do_watch: bool):
	print("CATJAM")
	_use_custom_commands = do_watch
	if _use_custom_commands:
		_server_manager.ServerOutput.connect(_on_server_manager_server_output)
	else:
		_server_manager.ServerOutput.disconnect(_on_server_manager_server_output)



func _on_server_manager_server_output(server_output:String):
	var proccessed = server_output.split("> .")
	print("Proce %s" % proccessed)

	if len(proccessed) >= 2:
		var command = proccessed[1].to_lower()
		print("Command %s" % command)

		match command:
			"reset":
				reset_server()
			"rs":
				reset_server()
			"res":
				reset_server()
			"r":
				reset_server()
			"re":
				reset_server()
			"stop":
				stop_server()
			"s":
				stop_server()
			"delete":
				delete_world()
			"del":
				delete_world()
			"zip":
				save_run()
			"save":
				save_run()
			"fin":
				save_run()
			"finish":
				save_run()

func reset_server():
	_server_manager.StopServer()
	if _server_manager.ServerIsRunning():
		print("Awaiting stop.")
		await _server_manager.ServerStopped
	print("Server Stopped, deleting world and restarting!")
	_server_manager.DeleteWorld()
	_server_manager.StartServer()


func stop_server():
	_server_manager.StopServer()


func delete_world():
	_server_manager.StopServer()
	if _server_manager.ServerIsRunning():
		print("Awaiting stop.")
		await _server_manager.ServerStopped
	print("Server Stopped, deleting world")
	_server_manager.DeleteWorld()


func save_run():
	_server_manager.StopServer()
	if _server_manager.ServerIsRunning():
		print("Awaiting stop.")
		await _server_manager.ServerStopped
	print("Server Stopped, Zipping world!")
	_server_manager.ZipRun()