extends Node2D

func _ready() -> void:
	Signals.lobby_member_left.connect(_on_member_left)
	Signals.lobby_owner_left.connect(_on_owner_left)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func hide_children(parent: Node):
	for n in parent.get_children():
		n.hide()
		
func show_children(parent: Node):
	for n in parent.get_children():
		n.show()
		
func _on_member_left():
	Network.update_lobby_members()
	
func _on_owner_left():
	Network.leave_lobby()
