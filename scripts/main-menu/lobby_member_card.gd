extends Control

@onready var profile_picture: Sprite2D = $ProfilePicture
@onready var usernameLabel: Label = $Username

@export var username = "username"
@export var picture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	usernameLabel.text = username
	profile_picture.texture = picture
	pass # Replace with function body.
