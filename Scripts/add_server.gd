extends MarginContainer


signal add_server


func _on_button_pressed():
	add_server.emit()
