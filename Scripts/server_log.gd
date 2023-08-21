extends TextEdit


func _on_server_manager_server_error(serverError:String):
	text += serverError + "\n"


func _on_server_manager_server_output(serverOutput:String):
	text += serverOutput + "\n"


func _on_server_manager_server_started():
	text = "Server Started...\n"


func _on_text_changed():
	pass


func _on_text_set():
	scroll_vertical = get_line_count()


func _on_server_manager_server_killed():
	text += "Server Killed.\n"


func _on_server_manager_server_stopped():
	text += "Server Stopped\n"


func _on_server_manager_server_stopping():
	text += "Server stop command sent...\n"
