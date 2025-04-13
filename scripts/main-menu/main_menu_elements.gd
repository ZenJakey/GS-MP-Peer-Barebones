extends Node
@onready var main: Node2D = $".."

func _on_play_pressed() -> void:
	# have save game selection and stuff here
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_multiplayer_pressed() -> void:
	main.hide_children(%Main_Menu_Elements)
	main.show_children(%Multiplayer_Menu_Elements)


func _on_quit_pressed() -> void:
	get_tree().quit()
