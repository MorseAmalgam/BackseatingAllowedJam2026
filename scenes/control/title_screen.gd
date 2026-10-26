extends Node

@onready var verification_ui: Control = %VerificationUI
@onready var code_field: LineEdit = %VerificationCodeField
@onready var browser_button: Button = %OpenBrowserButton

@export var token: OAuthToken

var _device_code_request: OAuth.OAuthDeviceCodeResponse

func _ready() -> void:
	# Validate our tokens
	token.load_tokens()
	
	# Connect to the device code request so we can build our input and button
	TwitchService.instance.device_code_requested.connect(open_request)


func _process(_delta: float) -> void:
	# Hide the verification window and enable the Start Game button if we're verified
	if token.is_token_valid() && %VerificationUI.visible:
		%VerificationUI.visible = false
		%StartGameButton.disabled = false


func open_request(device_code_request: OAuth.OAuthDeviceCodeResponse) -> void:
	# Get the request code
	_device_code_request = device_code_request
	# Fill in the input field to allow copy/paste
	code_field.text = device_code_request.verification_uri
	# Enable the "Open in Browser" button for those who want that instead
	browser_button.pressed.connect(open_os_browser)
	browser_button.disabled = false


func open_os_browser() -> void:
	# Should attempt to automatically open the page in the user's default browser
	OS.shell_open(_device_code_request.verification_uri)


func _on_start_game_button_pressed() -> void:
	# TODO: Send to map
	SceneLoader.change_scene("res://scenes/2D/world.tscn")


func _on_exit_button_pressed() -> void:
	# Closing time.
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
	pass
