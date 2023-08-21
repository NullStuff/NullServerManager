@tool
extends HBoxContainer


@export var label: String = "":
	set(value):
		label = value
		if _label_node != null:
			_label_node.text = value


@onready var _label_node: Label = $Label

func _ready():
	_label_node.text = label
