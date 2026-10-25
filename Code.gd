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

	# Connect the button!
	send_message_button.pressed.connect(send_message_button_pressed);

	# TODO: Set up the texture copying proper
	$"../WindowRadar/Field/Ground".texture = $"../TextureRect".texture
	
# ---

# Called in _ready if Twitch connects successfully!
func on_twitch_ready() -> void:
	print_your_name();
	register_command();
	await subscribe_to_events();
	await connect_to_greenheat();

# Shows how to view information about the broadcaster!
func print_your_name() -> void:
	var current_user: TwitchUser = await TwitchService.instance.get_current_user();
	if current_user:
		print("Your Twitch name is: " + current_user.display_name);
	else:
		printerr("Could not get current user info.");

# Register commands users can run by typing !COMMAND in chat.
func register_command() -> void:
	TwitchService.instance._log.set_enabled(true)
	TwitchService.instance.add_command("info", on_info_command);

func on_info_command(_from_username: String, _info: TwitchCommandInfo, _args: PackedStringArray) -> void:
	TwitchService.chat("This message is sending because you ran the !info command.");



func connect_to_greenheat()->void:
	# Ensure EventSub is connected first
	await TwitchService.instance.eventsub.wait_setup();
	var current_user: TwitchUser = await TwitchService.instance.get_current_user();
	if current_user == null:
		return
		
	print("Greenheat address is wss://heat.prod.kr/%s " % current_user.login);


# ---
# There's tons of "events" that can occur to the streamer: follows, subs, redeems, etc.
# For right now, we're only concerned with redeems.
func subscribe_to_events() -> void:
	# Ensure EventSub is connected first
	await TwitchService.instance.eventsub.wait_setup();

	var me = await TwitchService.instance.get_current_user();
	TwitchService.instance.subscribe_event(TwitchEventsubDefinition.CHANNEL_CHAT_MESSAGE, {
		&"broadcaster_user_id": me.id,
		&"user_id": me.id
	})

	# Now, connect to the signal on the TwitchEventsub node itself
	# to receive the actual event notifications.
	# TwitchService.instance.eventsub.event.connect(on_eventsub_event);

# This runs for ANY type of event that occurs as long as it was subscribed to.
func on_eventsub_event(type: StringName, data: Dictionary):
	if type == "channel.channel_points_custom_reward_redemption.add":
		# You can view the contents of "data" in the Twitch API:
		# https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelchannel_points_custom_reward_redemptionadd
		var redeemer_name = data.user_name;
		var redeem_name = data.reward.title;
		print(redeemer_name + " redeemed " + redeem_name);
		
		redeem_label.text = "Godot Game Redeem redeemed by " + redeemer_name;
		
		# If the redeem has a prompt, it can be found with:
		# var redeem_prompt = data.reward.prompt;

# ---

# Called when [member send_message_button] is pressed!
func send_message_button_pressed() -> void:
	TwitchService.chat("Hello from Godot! This message will send from the streamer playing your game's account to their chat.");


func _on_twitch_command_command_received(_from_username: String, _info: TwitchCommandInfo, _args: PackedStringArray) -> void:
	printt("Wow! Command get!")
	pass # Replace with function body.
