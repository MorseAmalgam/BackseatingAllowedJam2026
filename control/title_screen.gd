extends Node
# OS.shell_open(_device_code_request.verification_uri)

@onready var verification_ui: Control = %VerificationUI
@onready var code_field: LineEdit = %VerificationCodeField
@onready var browser_button: Button = %OpenBrowserButton

@export var token: OAuthToken

var twitch_connected: bool:
	set = _set_twitch_connected

var _device_code_request: OAuth.OAuthDeviceCodeResponse

func _ready() -> void:
	token.load_tokens()
	twitch_connected = token.is_token_valid()
	
	TwitchService.instance.device_code_requested.connect(open_request)
	TwitchService.instance.auth.authorize()

func _process(_delta: float) -> void:
	if twitch_connected && %VerificationUI.visible:
		%VerificationUI.visible = false
		%StartGameButton.disabled = false

func open_request(device_code_request: OAuth.OAuthDeviceCodeResponse) -> void:
	_device_code_request = device_code_request
	code_field.text = device_code_request.verification_uri
	browser_button.pressed.connect(open_os_browser)
	browser_button.disabled = false


func open_os_browser() -> void:
	OS.shell_open(_device_code_request.verification_uri)


func _set_twitch_connected(val: bool) -> void:
	twitch_connected = val
	if not is_node_ready(): await ready


func _on_exit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
	pass # Replace with function body.
