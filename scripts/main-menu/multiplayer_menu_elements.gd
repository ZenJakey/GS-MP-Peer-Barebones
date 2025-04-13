extends Node

@onready var main: Node2D = $".."
@onready var ms: MultiplayerSpawner = $"../MultiplayerSpawner"

func _ready() -> void:
	ms.spawn_function = get_level
	pass

func _on_back_pressed() -> void:
	main.hide_children(%Multiplayer_Menu_Elements)
	main.show_children(%Main_Menu_Elements)

func _on_play_online_pressed() -> void:
	if !Network.is_host:
		return
	if Network.LOBBY_ID == 0:
		Network.create_lobby()
	spawn_level("level")
	pass # Replace with function body.
	
func spawn_level(level_name):
	ms.spawn(Globals.get_level_from_name(level_name))


func get_level(data):
	main.hide_children(%Main_Menu_Elements)
	main.hide_children(%Multiplayer_Menu_Elements)
	main.hide_children(%Lobby_Browser)
	$"../Label".hide()
	var a = (load(data) as PackedScene).instantiate()
	return a

func _on_create_lobby_pressed() -> void:
	Network.create_lobby()
	pass # Replace with function body.


func _on_view_lobby_list_pressed() -> void:
	main.hide_children(%Multiplayer_Menu_Elements)
	main.show_children(%Lobby_Browser)
	Network.update_lobby_list()
pass # Replace with function body.


func _on_leave_lobby_pressed() -> void:
	Network.leave_lobby()


func _on_invite_pressed() -> void:
	if (Network.LOBBY_ID == 0):
		Network.create_lobby()
	Network.open_invite_window()
