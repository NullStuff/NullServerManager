extends Label


func _on_server_manager_server_name_changed(_oldName:String, newName:String):
	text = newName
