## This is the code that runs this template!
##
## Most of this was COPIED DIRECTLY from Twitcher's documentation, please read
## it here: https://twitcher.kani.dev/core-nodes/twitch-service.html

extends Node

# The button that you click to send a message in Twitch.
@export var send_message_button: Button;

# The label that shows someone redeemed a redeem.
@export var redeem_label: Label;

# ---

# Called when scene is ready.
# Please note this node MUST be listed after TwitchService in the scene tree.
func _ready() -> void:
	
	# Connect to Twitch! 
	var success: bool = await TwitchService.instance.setup();

	# If failed, print an error and cancel...
	if !success:
		printerr("Twitch Service setup failed.");
		return;

	# Success!
	print("Twitch Service successfully set up and authenticated!");

	# Now you can do things with Twitch.
	on_twitch_ready();


# Called in _ready if Twitch connects successfully!
func on_twitch_ready() -> void:
	register_commands();
	await subscribe_to_events();
	await connect_to_greenheat();


# Register commands users can run by typing !COMMAND in chat.
func register_commands() -> void:
	TwitchService.instance.add_command("info", on_info_command);

func on_info_command(_from_username: String, _info: TwitchCommandInfo, _args: PackedStringArray) -> void:
	TwitchService.chat("This message is sending because you ran the !info command.");



func connect_to_greenheat()->void:
	# Ensure EventSub is connected first
	await TwitchService.instance.eventsub.wait_setup();
	var current_user: TwitchUser = await TwitchService.instance.get_current_user();
	if current_user == null:
		return
	
	var greenheat = GreenHeat.new()
	greenheat.channel_name = current_user.login
	greenheat.name = "GreenHeat"
	get_parent().add_child(greenheat)


# ---
# There's tons of "events" that can occur to the streamer: follows, subs, redeems, etc.
# For right now, we're only concerned with redeems.
func subscribe_to_events() -> void:
	# Ensure EventSub is connected first
	await TwitchService.instance.eventsub.wait_setup();

	# Required to make Twitcher listen to chat events
	var me = await TwitchService.instance.get_current_user();
	TwitchService.instance.subscribe_event(TwitchEventsubDefinition.CHANNEL_CHAT_MESSAGE, {
		&"broadcaster_user_id": me.id,
		&"user_id": me.id
	})


# Called when [member send_message_button] is pressed!
func send_message_button_pressed() -> void:
	TwitchService.chat("Hello from Godot! This message will send from the streamer playing your game's account to their chat.");


func _on_twitch_command_command_received(_from_username: String, _info: TwitchCommandInfo, _args: PackedStringArray) -> void:
	printt("Wow! Command get!")
	pass # Replace with function body.
