@tool
extends EditorPlugin

var  todo_list_scene : Control

var config : Dictionary = {
	"discard_tasks" : 2,
	"new_task_field_location": 0,
	"auto_delete_empty_tasks": true
}

func _enter_tree() -> void:
	todo_list_scene = preload("res://addons/godot_todo/todo_list.tscn").instantiate()
	todo_list_scene.plugin = self
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, todo_list_scene)
	
	todo_list_scene.get_node("settings_container/Control/MarginContainer/VBoxContainer/discard_tasks/OptionButton").item_selected.connect(func(x): config.discard_tasks = x)
	todo_list_scene.get_node("settings_container/Control/MarginContainer/VBoxContainer/new_task_field/OptionButton").item_selected.connect(func(x): config.new_task_field_location = x)
	todo_list_scene.get_node("settings_container/Control/MarginContainer/VBoxContainer/auto_delete_empty_tasks/CheckBox").toggled.connect(func(x): config.auto_delete_empty_tasks = x)
	
	var _dir := DirAccess.open("res://addons/godot_todo")
	if !_dir.file_exists("configuration.json"):
		save_configuration()
	if !_dir.file_exists("todo_list.json"):
		save_todo_list()
	
	load_todo_list()
	load_configuration()
	
func _exit_tree() -> void:
	save_todo_list()
	save_configuration()
	remove_control_from_docks(todo_list_scene)

func get_children_recursive(node : Node) -> Array[Node]:
	var _result : Array[Node] = []
	var _children_to_be_checked : Array[Node] = []
	
	for _child in node.get_children():
		_children_to_be_checked.append(_child)
	
	while _children_to_be_checked.size() > 0:
		var _child_to_check : Node = _children_to_be_checked[0]
		for _subchild in _child_to_check.get_children():
			_children_to_be_checked.append(_subchild)
		
		_result.append(_child_to_check)
		_children_to_be_checked.erase(_child_to_check)
	
	return _result

func save_configuration() -> void:
	var _config_file := FileAccess.open("res://addons/godot_todo/configuration.json", FileAccess.WRITE)
	#print(JSON.stringify(config))
	_config_file.store_string(JSON.stringify(config))

func load_configuration() -> void:
	var _config_file := FileAccess.open("res://addons/godot_todo/configuration.json", FileAccess.READ)
	var _parsed : Dictionary = JSON.parse_string(_config_file.get_as_text())
	config = _parsed
	#print(_parsed)
	todo_list_scene.get_node("settings_container").load_settings(_parsed)

func save_todo_list() -> void:
	var _todo_list : Dictionary = {
		"categorised": {}, #dictionary of string : list
		"loose":[]
	}
	
	for child in todo_list_scene.get_node("todo_container/ScrollContainer/MarginContainer/todo_item_list").get_children():
		if !child.visible:
			continue
		if todo_list_scene.completed_tasks.has(child):
			continue
		
		if child is FoldableContainer:
			_todo_list.categorised[child.title] = []
			for subchild in child.get_node("MarginContainer/VBoxContainer").get_children():
				if subchild is HBoxContainer and subchild.visible:
					_todo_list.categorised[child.title].append(subchild.get_node("LineEdit").text)
					
		if child is HBoxContainer:
			_todo_list.loose.append(child.get_node("LineEdit").text)
	
	var _todo_list_file := FileAccess.open("res://addons/godot_todo/todo_list.json", FileAccess.WRITE)
	_todo_list_file.store_string(JSON.stringify(_todo_list))

func load_todo_list() -> void:
	var _todo_list_file := FileAccess.open("res://addons/godot_todo/todo_list.json", FileAccess.READ)
	
	todo_list_scene.load_todo_list(JSON.parse_string(_todo_list_file.get_as_text()))
