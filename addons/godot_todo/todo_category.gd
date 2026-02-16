@tool
extends FoldableContainer

var root_node : Control
var _context_menu_open : bool = false

func _ready() -> void:
	$context_menu/vbox/delete.button_down.connect(queue_free)
	$context_menu/vbox/dissolve.button_down.connect(_dissolve)
	$context_menu.mouse_exited.connect(func(): $context_menu.visible = false)
	
func _add_task_to_category() -> void:
	$context_menu.visible = false
	
	if folded:
		folded = false
	
	var _task : Control = root_node.create_new_task("<empty>", $MarginContainer/VBoxContainer)
	_task.get_node("LineEdit").text = ""
	_task.get_node("LineEdit").edit()

func _dissolve() -> void:
	for child in $MarginContainer/VBoxContainer.get_children():
		if child is HBoxContainer:
			child.reparent(get_parent())
	
	queue_free()

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is Control:
		if data.has_meta("is_todo_item"):
			return true
	
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	data.modulate.a = 1.0
	data.reparent($MarginContainer/VBoxContainer)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			return
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			$context_menu.visible = true
			$context_menu.global_position = get_global_mouse_position() - Vector2(20.0, 20.0)
