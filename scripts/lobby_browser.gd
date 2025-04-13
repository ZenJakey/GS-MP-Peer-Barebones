extends Node

@onready var main: Node2D = $".."

func _ready():
	Signals.lobby_list_received.connect(_on_lobby_list_received)
	#Network.update_lobby_list()
	

func _on_lobby_browser_back_pressed() -> void:
	main.hide_children(%Lobby_Browser)
	main.show_children(%Multiplayer_Menu_Elements)
	pass # Replace with function body.


func _on_lobby_browser_refresh_pressed() -> void:
	Network.update_lobby_list()
	
func _on_lobby_list_received(lobbies):
	for n in $Control/ScrollContainer/VBoxContainer.get_children():
		n.queue_free()
	for lobby in lobbies:
		var but = Button.new()
		but.text = str(lobby["lobby_name"]) + " | " + str(lobby["memb_count"]) + " / " + str(Network.LOBBY_MAX_MEMBERS)
		but.size.x = $Control/ScrollContainer/VBoxContainer.size.x
		but.connect("pressed", Callable(Network, "join_lobby").bind(lobby["lobby_id"]))
		$Control/ScrollContainer/VBoxContainer.add_child(but)
	
	
