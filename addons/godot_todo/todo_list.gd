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

func _saved() -> void:
	if plugin.config.discard_tasks == 1:
		clear_completed_tasks()

func clear_completed_tasks() -> void:
	for task in completed_tasks.duplicate(): #Erasing from the array while iterating over it for some reason screws this up. So we duplicate.
		completed_tasks.erase(task)
		task.queue_free()

func load_todo_list(list : Dictionary) -> void:
	for task : String in list.loose:
		create_new_task(task)
	var categories : Array = list.categorised.keys()
	for category_name : String in categories:
		var _category_container : FoldableContainer = _create_new_category(category_name)
		for task : String in list.categorised[category_name]:
			create_new_task(task, _category_container.get_node("MarginContainer/VBoxContainer"))


func create_new_task(new_task_text : String, target_parent : Control = _todo_vbox_container) -> Control:
	if new_task_text == "":
		return
	
	var _new_task : HBoxContainer = _template_todo_item.duplicate()
	_new_task.get_node("LineEdit").text = new_task_text
	_new_task.name = new_task_text
	_new_task.visible = true
	target_parent.add_child(_new_task)
	target_parent.get_node("new_task").text = ""
	
	_new_task.get_node("LineEdit").text_changed.connect(_task_changed.bind(_new_task))
	
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
