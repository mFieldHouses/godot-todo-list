@tool
extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CheckBox.mouse_entered.connect(func():
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			$CheckBox.button_pressed = !$CheckBox.button_pressed
		)
	
	$context_menu/vbox/delete.button_down.connect(queue_free)
	$context_menu.mouse_exited.connect(func(): $context_menu.visible = false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().root.gui_is_dragging():
		toggle_children_mouse_filters(false)
	else:
		toggle_children_mouse_filters(true)

func _get_drag_data(at_position: Vector2) -> Variant:
	modulate.a = 0.3
	return self

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is Control:
		if data.has_meta("is_todo_item"):
			var _idx : int
			
			if at_position.y < size.y / 2.0:
				_idx = get_index()
			else:
				_idx = get_index() + 1
			
			get_parent().move_separator(_idx)
			return true
	
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	data.modulate.a = 1.0
	
	var _current_idx = data.get_index()
	
	var _idx = get_index()
	if _idx > _current_idx:
		_idx -= 1
	
	if at_position.y < size.y / 2.0:
		get_parent().move_task(_idx, data)
	else:
		get_parent().move_task(_idx + 1, data)

func toggle_children_mouse_filters(state : bool) -> void:
	for child in get_children():
		if state:
			if child is TextureRect:
				child.mouse_filter = Control.MOUSE_FILTER_PASS
			else:
				child.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _task_toggled(toggled_on: bool) -> void:
	get_parent().get_root().set_task_completed(self, toggled_on)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			return
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			$context_menu.visible = true
			$context_menu.global_position = get_global_mouse_position() - Vector2(20.0, 20.0)
