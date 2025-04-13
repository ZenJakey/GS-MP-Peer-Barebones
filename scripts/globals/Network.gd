extends Control


#Lobby vars
var DATA
var LOBBY_ID = 0
var LOBBY_MEMBERS = []
var LOBBY_INVITE_ARG = false
var LOBBY_MAX_MEMBERS = 4
var LOBBY_HOST_ID = 0
var is_host = false

var peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()

func _ready():
	multiplayer.peer_connected.connect(_peer_connected_message)
	multiplayer.peer_disconnected.connect(_peer_disconnected_message)
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	#while true:w
	#	await get_tree().create_timer(1.0).timeout
	#	print(LOBBY_MEMBERS)
		
func _peer_connected_message(data):
	print("peer connected!\tid: ", data)
	
func _peer_disconnected_message(data):
	print("peer disconnected!\tid: ", data)
	
func _process(_delta: float) -> void:
	pass

###################
### Our methods ###
###################
func create_lobby():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	is_host = true

func join_lobby(lobby_id):
	peer.connect_lobby(lobby_id)
	Steam.joinLobby(lobby_id)
	LOBBY_ID = lobby_id
	multiplayer.multiplayer_peer = peer
	
func leave_lobby():
	if LOBBY_ID != 0:
		print("Leaving lobby...")
		Steam.leaveLobby(LOBBY_ID)
		multiplayer.multiplayer_peer.close()
		peer = SteamMultiplayerPeer.new()
		LOBBY_ID = 0
		LOBBY_HOST_ID = 0
		is_host = false
		LOBBY_MEMBERS.clear()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func update_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	# filter out lobbies where the current user is the host
	Steam.addRequestLobbyListStringFilter("lobby_host", str(Globals.STEAM_ID), Steam.LOBBY_COMPARISON_NOT_EQUAL)
	Steam.requestLobbyList()
	
func update_lobby_members():
	LOBBY_MEMBERS.clear()
	var member_count = Steam.getNumLobbyMembers(LOBBY_ID)
		
	for member in range(0, member_count):
		var steam_id = Steam.getLobbyMemberByIndex(LOBBY_ID, member)
		var steam_name = Steam.getFriendPersonaName(steam_id)
		get_member_profile_picture(steam_id)
		LOBBY_MEMBERS.append({"steam_id": steam_id, "steam_name":steam_name, "image":null})
	Signals.lobby_members_updated.emit()
	
func get_member_profile_picture(steam_id):
	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, steam_id)

#######################
### Steam Callbacks ###
#######################
func _on_lobby_created(result: int, lobby_id: int):
	if result == Steam.Result.RESULT_OK:
		print("Lobby created")
		LOBBY_ID = lobby_id
		var lobby_name = Globals.STEAM_NAME + "'s Lobby"
		print("Created lobby: " + lobby_name)
		Steam.setLobbyData(lobby_id, "name", lobby_name)
		Steam.setLobbyJoinable(lobby_id, true)
		Steam.setLobbyData(lobby_id, "lobby_host", str(Globals.STEAM_ID))
		print(lobby_id)
		update_lobby_members()
		
func _on_lobby_joined(lobby: int, _permissions: int, _locked: bool, response: int):
	print("lobby_id: ", lobby, " response: ", response)
	LOBBY_ID = lobby
	var lobby_name = Steam.getLobbyData(lobby, "name")
	LOBBY_HOST_ID = int(Steam.getLobbyData(lobby, "lobby_host"))
	print("Joined lobby:" + "\""+ lobby_name + "\"")
	update_lobby_members()
	
func _on_avatar_loaded(steam_id: int, image_size: int, data: Array):
	var image: Image = Image.create_from_data(image_size, image_size, false, Image.FORMAT_RGBA8, data)
	Signals.steam_avatar_loaded.emit(steam_id, image)

func _on_lobby_match_list(lobbies):
	var valid_lobbies = []
	print("Received " + str(lobbies.size()) + " lobbies from Steam")
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var memb_count = Steam.getNumLobbyMembers(lobby)
		valid_lobbies.append({"lobby_id":lobby, "lobby_name":lobby_name, "memb_count":memb_count})
		
	print("\tFiltered to " + str(valid_lobbies.size()) + " valid lobbies")
	Signals.lobby_list_received.emit(valid_lobbies)
	
func _on_lobby_chat_update(_lobby_id: int, changed_id: int, _making_change_id: int, chat_state: int):
	print(str(changed_id), " has make change: ", chat_state)
	if (
		chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_DISCONNECTED 
		|| chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_BANNED 
		|| chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED
		|| chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT
	):
		if LOBBY_HOST_ID == changed_id:
			Signals.lobby_owner_left.emit()
		else:
			Signals.lobby_member_left.emit()
		
	update_lobby_members()
