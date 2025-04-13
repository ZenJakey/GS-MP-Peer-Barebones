extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.lobby_members_updated.connect(_on_player_list_updated)
	Signals.steam_avatar_loaded.connect(_on_avatar_loaded)
	
func _on_player_list_updated():
	print("Refreshing player list.")
	for n in %LobbyMemberList.get_children():
		n.queue_free()
	for member in Network.LOBBY_MEMBERS:
		var card = load("res://scenes/LobbyMemberCard.tscn").instantiate()
		card.username = member["steam_name"]
		if (member["image"] != null) :
			card.picture = ImageTexture.create_from_image(member["image"])
		%LobbyMemberList.add_child(card)
	%LobbyMemberList.show()
	
func _on_avatar_loaded(steam_id, image):
	for member in Network.LOBBY_MEMBERS:
		if member["steam_id"] == steam_id:
			member["image"] = image
	_on_player_list_updated()
