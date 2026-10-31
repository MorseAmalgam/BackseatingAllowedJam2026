class_name SurviveObjective
extends MissionObjective


var target:Node2D
var sequence:Array[String]
var input_sequence_progress:int = 0
var sequence_message:String

func get_description() -> String:
	return "Vessel must be extracted"

func init(world:World) -> void:
	# Set the survival target
	target = world.vessel

func update() -> void:
	# If the player has died, objective failed
	if target == null:
		state = ObjectiveState.FAILED

func begin_extraction_sequence() -> void:
	# Generate a extraction key
	var hexidecimal = "1234567890abcdef"
	for i in range(6):
		sequence.append(hexidecimal.substr(randi_range(0, 15), 1))
	
	_update_message()
	# Connect to the Twitcher EventSub
	TwitchService.instance.eventsub.event_received.connect(_on_event)


func _on_event(event: TwitchEventsub.Event) -> void:
	# Only looking for chat messages
	if event.type != TwitchEventsubDefinition.CHANNEL_CHAT_MESSAGE:
		return
	
	# And even then, only chat messages that are a single character
	var data: TwitchESChannelChatMessage.Event = event.typed_data
	var message:String = data.message.text.to_lower()
	if message.length() > 1:
		return
	
	# Check if this matches the extraction sequence
	if message == sequence[input_sequence_progress]:
		input_sequence_progress += 1
		# Sequence complete
		if input_sequence_progress == 6:
			# Disconnect from EventSub
			TwitchService.instance.eventsub.event_received.disconnect(_on_event)
			state = ObjectiveState.COMPLETED
	else:
		input_sequence_progress = 0
	_update_message()
	pass


func _update_message() -> void:
	sequence_message = ""
	for i in range(6):
		if (i < input_sequence_progress):
			sequence_message += "[color=#3efda6]%s[/color]" % sequence[i]
		else:
			sequence_message += sequence[i]
