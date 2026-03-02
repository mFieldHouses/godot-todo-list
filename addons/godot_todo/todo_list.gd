@tool
extends VBoxContainer

@onready var _todo_vbox_container = $todo_container/ScrollContainer/MarginContainer/todo_item_list
@onready var _template_todo_item = $todo_container/ScrollContainer/MarginContainer/template_todo
@onready var _template_category = $todo_container/ScrollContainer/MarginContainer/template_category

var plugin : EditorPlugin

signal dragging_separator_made_visible(separator : HSeparator)

var completed_tasks : Array[Control]

func someone_made_separator_visible(separator : HSeparator): #sorry for the jankiness here
	dragging_separator_made_visible.emit(separator)

func _ready() -> void:
	$toolbar.visible = true
	$todo_container.visible = true
	$settings_container.visible = false
	_template_category.visible = false
	_template_todo_item.visible = false
	
	plugin.scene_saved.connect(_saved.unbind(1))
	
	$todo_container/ScrollContainer/MarginContainer/template_todo/open_script.icon = EditorInterface.get_base_control().get_theme_icon("Script", "EditorIcons")

func _saved() -> void:
	if plugin.config.discard_tasks == 1:
		clear_completed_tasks()

func clear_completed_tasks() -> void:
	for task in completed_tasks.duplicate(): #Erasing from the array while iterating over it for some reason screws this up. So we duplicate.
		completed_tasks.erase(task)
		task.queue_free()

func load_todo_list(list : Dictionary) -> void:
	for task : Dictionary in list.loose:
		create_new_task(task.task_text, _todo_vbox_container, task.script_link_path, task.script_link_line)
	var categories : Array = list.categorised.keys()
	for category_name : String in categories:
		var _category_container : FoldableContainer = _create_new_category(category_name)
		for task : Dictionary in list.categorised[category_name]:
			create_new_task(task.task_text, _category_container.get_node("MarginContainer/VBoxContainer"), task.script_link_path, task.script_link_line)


func create_new_task(new_task_text : String, target_parent : Control = _todo_vbox_container, script_link_path : String = "", script_link_line : int = 0) -> Control:
	if new_task_text == "":
		return
	
	var _new_task : HBoxContainer = _template_todo_item.duplicate()
	_new_task.get_node("LineEdit").text = new_task_text
	_new_task.name = new_task_text
	_new_task.visible = true
	_new_task.script_link_path = script_link_path
	_new_task.script_link_line = script_link_line
	target_parent.add_child(_new_task)
	target_parent.get_node("new_task").text = ""
	
	_new_task.get_node("LineEdit").text_changed.connect(_task_changed.bind(_new_task))
	
	var regex : RegEx = RegEx.new()
	regex.compile("<[a-zA-Z]*:[0-9]*>")
	var _match : RegExMatch = regex.search(new_task_text)
	if _match != null:
		print("found a match")
		var _components : PackedStringArray = new_task_text.split("<script:")
		var _line_number : int = int(_components[1].split(">")[0])
		
		_new_task.script_link_path = EditorInterface.get_script_editor().get_current_script().resource_path
		_new_task.script_link_line = _line_number
		
		_new_task.get_node("LineEdit").text = new_task_text.erase(_match.get_start(), _match.get_end() - _match.get_start())
	
	return _new_task
	
func _task_changed(new_text : String, task_item : HBoxContainer) -> void:
	if new_text == "" and plugin.config.auto_delete_empty_tasks:
		task_item.queue_free()


func _create_new_category(new_text: String) -> FoldableContainer:
	if new_text == "":
		return
	
	var _new_category : FoldableContainer = _template_category.duplicate()
	_new_category.name = "category_" + new_text
	_todo_vbox_container.add_child(_new_category)
	_new_category.visible = true
	_new_category.title = new_text
	_todo_vbox_container.move_child(_new_category, 1)
	_new_category.root_node = self	
	$toolbar/new_category.text = ""
	
	return _new_category


func _toggle_settings(state : bool) -> void:
	if state:
		$toolbar.visible = false
		$todo_container.visible = false
		$settings_container.visible = true
	else:
		$toolbar.visible = true
		$todo_container.visible = true
		$settings_container.visible = false


func clear_todo_list() -> void:
	for child in _todo_vbox_container.get_children():
		if child is HBoxContainer or child is FoldableContainer:
			if completed_tasks.has(child):
				completed_tasks.erase(child)
			child.queue_free()

func set_task_completed(task : Control, completed : bool) -> void:
	if completed:
		if plugin.config.discard_tasks == 0:
			task.queue_free()
		elif !completed_tasks.has(task):
			completed_tasks.append(task)
	else:
		if completed_tasks.has(task):
			completed_tasks.erase(task)
