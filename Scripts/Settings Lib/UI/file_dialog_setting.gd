@tool
extends HBoxContainer


@export_category("Setting")
@export var setting_key: String = "" :
	set(value):
		setting_key = value
		if _setting != null:
			_setting._key = value


@export_category("File Dialog")
@export var mode_overrides_title: bool = true :
	set(value):
		mode_overrides_title = value
		if _file_dialog != null:
			_file_dialog.mode_overrides_title = value

@export var file_mode: FileDialog.FileMode = FileDialog.FileMode.FILE_MODE_OPEN_FILE :
	set(value):
		file_mode = value
		if _file_dialog != null:
			_file_dialog.file_mode = value

@export var access: FileDialog.Access = FileDialog.Access.ACCESS_FILESYSTEM :
	set(value):
		access = value
		if _file_dialog != null:
			_file_dialog.access = value

@export var root_subfolder: String = "" :
	set(value):
		root_subfolder = value
		if _file_dialog != null:
			_file_dialog.root_subfolder = value

@export var filters: PackedStringArray :
	set(value):
		filters = value
		if _file_dialog != null:
			_file_dialog.filters = value

@export var show_hidden_files: bool = false :
	set(value):
		show_hidden_files = value
		if _file_dialog != null:
			_file_dialog.show_hidden_files = value

@export var cancel_button_text: String = "Cancel" :
	set(value):
		cancel_button_text = value
		if _file_dialog != null:
			_file_dialog.cancel_button_text = value

@export var ok_button_text: String = "Open" :
	set(value):
		ok_button_text = value
		if _file_dialog != null:
			_file_dialog.ok_button_text = value

@export var title: String = "Open a File" :
	set(value):
		title = value
		if _file_dialog != null:
			_file_dialog.title = value

@export var initial_size: Vector2 = Vector2(854, 480) :
	set(value):
		initial_size = value
		if _file_dialog != null:
			_file_dialog.set_size(value)
			print("HOLY SMOKES the thing is now %s" % _file_dialog.size)


@onready var _setting: Setting = $Setting
@onready var _line_edit: LineEdit = $LineEdit
@onready var _file_dialog: FileDialog = $FileDialog


func _ready():
	_setting._key = setting_key
	_file_dialog.mode_overrides_title = mode_overrides_title
	_file_dialog.file_mode = file_mode
	_file_dialog.access = access
	_file_dialog.root_subfolder = root_subfolder
	_file_dialog.filters = filters
	_file_dialog.show_hidden_files = show_hidden_files
	_file_dialog.cancel_button_text = cancel_button_text
	_file_dialog.ok_button_text = ok_button_text
	_file_dialog.title = title
	_file_dialog.size = initial_size

	if _setting._value != null:
		_setting.load_value("")


func get_setting():
	return _setting


func _on_setting_value_loaded(new_value):
	if new_value is String:
		_line_edit.text = new_value
	else:
		printerr("Value %s invalid for file dialog %s" % [new_value, get_path()])


func _change_path(new_path):
	_setting.save_value(new_path)


func _on_file_dialog_dir_selected(dir:String):
	_line_edit.text = dir
	_change_path(dir)


func _on_file_dialog_file_selected(path:String):
	_line_edit.text = path
	_change_path(path)


func _on_file_dialog_files_selected(paths:PackedStringArray):
	var temp = ", "
	for path in paths:
		temp += "\"%s\"" % path
	temp = temp.split(", ", true, 1)[1]
	_line_edit.text = temp
	_change_path(paths)


func _on_line_edit_text_changed(new_text:String):
	_change_path(new_text)


func _on_line_edit_text_submitted(new_text:String):
	_change_path(new_text)


func _on_button_pressed():
	_file_dialog.show()
