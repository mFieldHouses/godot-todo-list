@tool
extends VBoxContainer

func load_settings(settings : Dictionary) -> void:
	$Control/MarginContainer/VBoxContainer/discard_tasks/OptionButton.selected = int(settings.discard_tasks)
	$Control/MarginContainer/VBoxContainer/new_task_field/OptionButton.selected = int(settings.new_task_field_location)
	$Control/MarginContainer/VBoxContainer/auto_delete_empty_tasks/CheckBox.button_pressed = int(settings.auto_delete_empty_tasks)
