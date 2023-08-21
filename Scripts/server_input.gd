extends LineEdit


@onready var _server_manager = get_node("../Server Manager")


func _on_text_submitted(new_text:String):
	_server_manager.SendServerInput(new_text)
	text = ""
