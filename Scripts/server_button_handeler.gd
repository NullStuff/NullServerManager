extends Node


@onready var _server_manager = get_node("../Server Manager")


func _ready():
	print("WHO AM I %s" % _server_manager)


func _on_start_button_pressed():
	print("UwU")
	_server_manager.StartServer()


func _on_stop_button_pressed():
	_server_manager.StopServer()


func _on_force_stop_button_pressed():
	_server_manager.KillServer()


func _on_reset_button_pressed():
	_server_manager.StopServer()
	if _server_manager.ServerIsRunning():
		print("Awaiting stop.")
		await _server_manager.ServerStopped
	print("Server Stopped, deleting world and restarting!")
	_server_manager.DeleteWorld()
	_server_manager.StartServer()


func _on_delete_world_button_pressed():
	_server_manager.DeleteWorld()


func _on_save_run_button_pressed():
	_server_manager.StopServer()
	if _server_manager.ServerIsRunning():
		print("Awaiting stop.")
		await _server_manager.ServerStopped
	print("Server Stopped, Zipping world!")
	_server_manager.ZipRun()
