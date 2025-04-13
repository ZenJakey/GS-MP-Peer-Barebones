extends Node

const PACKET_READ_LIMIT: int = 32

#Vars til own steam app id
const MATCH_KEY = "PXmme*87hjwl&ZwB"

#Steam vars
var OWNED = false
var ONLINE = false
var STEAM_ID = 0
var STEAM_NAME = ""
var APP_ID = 3649010

func _ready() -> void:
	var INIT = Steam.steamInitEx(APP_ID)
	if INIT['status'] != 0:
		print("failed to init Steam. " + str(INIT['verbal']) + " Shutting down...")
		get_tree().quit()
		
	ONLINE = Steam.loggedOn()
	STEAM_ID = Steam.getSteamID()
	STEAM_NAME = Steam.getPersonaName()
	OWNED = Steam.isSubscribed()
	
	if OS.get_environment("BOTTLED_UP_DEV") == "1":
		print("Bypassing ownership check.")
		# If in development environment, don't check game ownership
		return
	
	if !OWNED:
		print("User does not own this game")
		get_tree().quit()
		
func _process(_delta: float) -> void:
	Steam.run_callbacks()
	
func get_level_from_name(level_name) -> String:
	if level_name == "level": 
		return "res://scenes/level.tscn"
	
	return ""
	
	
	
	
	
	
