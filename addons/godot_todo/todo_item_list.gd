@tool
extends VBoxContainer

@onready var _dragging_separator : HSeparator = HSeparator.new()

signal made_separator_visible(separator : HSeparator)

func _ready() -> void:
	if get_parent().get_parent().name == "template_category":
		return

	made_separator_visible.connect(get_root().someone_made_separator_visible)
	get_root().dragging_separator_made_visible.connect(separator_was_made_visible)
	
	add_child(_dragging_separator)
	_dragging_separator.visible = false
	_dragging_separator.add_theme_constant_override("separation", 0)
	_dragging_separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dragging_separator.add_theme_stylebox_override("separator", preload("res://addons/godot_todo/hseparator_style.tres"))
	_dragging_separator.top_level = true
	
	$new_task.text_submitted.connect(create_task)
	
func create_task(task_text : String) -> void:
	get_root().create_new_task(task_text, self)
	$new_task.text = ""

func separator_was_made_visible(separator : HSeparator) -> void:
	if separator != _dragging_separator:
		_dragging_separator.visible = false

func _process(delta: float) -> void:
	if !get_root().get_parent() is EditorDock:
		return
		
	if get_root().plugin.config.new_task_field_location == 0:
		move_child($new_task, get_child_count())
	elif get_root().plugin.config.new_task_field_location == 1:
		move_child($new_task, 0)
	
	if !get_tree().root.gui_is_dragging():
		modulate.a = 1.0
		_dragging_separator.visible = false
		$new_task.mouse_filter = MOUSE_FILTER_STOP
	else:
		$new_task.mouse_filter = MOUSE_FILTER_IGNORE
		$new_task.release_focus()

func move_separator(index : int) -> void:
	
	if index == get_child_count():
		var _child = get_child(index - 1)
		_dragging_separator.position = _child.global_position + Vector2(0.0, _child.size.y)
		_dragging_separator.size.x = _child.size.x
	else:
		var _child = get_child(index)
		_dragging_separator.position = _child.global_position
		_dragging_separator.size.x = _child.size.x
	
	_dragging_separator.visible = true
	made_separator_visible.emit(_dragging_separator)

func move_task(index : int, task : Control) -> void:
	task.reparent(self)
	move_child(task, index)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is Control:
		if data.has_meta("is_todo_item"):
			return true
	
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void: #when a task is dropped into this container, aka the background, it has to end up at the bottom
	data.modulate.a = 1.0
	move_task(get_child_count(), data)

func get_root() -> Control:
	if has_meta("is_in_category"):
		#sorry...
		return get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	else:
		return get_parent().get_parent().get_parent().get_parent()
	
