extends SettingsGroup


@export var _save_file_path: String = "user://options.save"


func _ready():
	super()

	if FileAccess.file_exists(_save_file_path):
		var save_file = FileAccess.open(_save_file_path, FileAccess.READ)

		var save_data

		var json_string = save_file.get_as_text()

		# Creates the helper class to interact with JSON
		var json: JSON = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return

		# Get the data from the JSON object
		save_data = json.get_data()
		load_value(save_data)

		_on_save(self)


func _save():
	var data = serialize()
	var save_file: FileAccess = FileAccess.open(_save_file_path, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(data))
	save_file.close()


func _on_save(_setting):
	_save()
