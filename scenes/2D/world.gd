class_name World
extends Node2D

var WEAPONS = {
	"bunker":load("res://scenes/2D/weapon/bunker.tscn"),
	"fire":load("res://scenes/2D/weapon/primary_fire.tscn"),
	"flare":load("res://scenes/2D/weapon/flare.tscn"),
	"laser":load("res://scenes/2D/weapon/laser.tscn"),
	"thumper":load("res://scenes/2D/weapon/thumper.tscn"),
}


@export var objectives:Array[MissionObjective] = []

@onready var _radar_window: Window = $RadarWindow
@warning_ignore("unused_private_class_variable")
@onready var vessel: Vessel = $Vessel

signal on_weapon_fire(area:Area2D, weapon:Constants.WeaponTypes)

func _ready():
	# TODO: Enable menu and chat interaction after anything else 
	
	# Vessel Must Escape objective is always added to the end of the list
	objectives.append(load("res://resources/objective/survive.gd").new())
	for objective in objectives:
		objective.init(self)
	
	_start_gameplay()
	
	@warning_ignore("integer_division")
	_radar_window.position = get_window().position + (get_window().size / 2) - ($RadarWindow.size / 2)


func _process(_delta: float) -> void:
	_update_objectives()


func _update_objectives() -> void:
	var has_succeeded:bool = true
	var has_failed:bool = false
	var complete_count:int = 0
	var objective_list:String = ""
	for objective in objectives:
		objective.update()
		var objective_text = objective.get_description()
		match objective.state:
			MissionObjective.ObjectiveState.FAILED:
				objective_text = "[color=RED]〔X〕%s[/color]\n" % objective_text
				has_succeeded = false
				has_failed = true
			MissionObjective.ObjectiveState.IN_PROGRESS:
				objective_text = "[color=WHITE]〔 〕%s[/color]\n" % objective_text
				has_succeeded = false
			MissionObjective.ObjectiveState.COMPLETED:
				complete_count += 1
				objective_text = "[color=GREEN]〔O〕%s[/color]\n" % objective_text
		objective_list += objective_text
	
	# If only one objective is left to complete, it must be extraction
	if complete_count == objectives.size()-1:
		if objectives[objectives.size()-1].sequence == []:
			$UI/ExtractionSequenceHeader.visible = true
			$UI/ExtractionSequence.visible = true
			objectives[objectives.size()-1].begin_extraction_sequence()
		else:
			$UI/ExtractionSequence.text = objectives[objectives.size()-1].sequence_message
	
	$UI/MissionObjectivesList.text = objective_list
	if has_succeeded:
		$"/root/Main".show_mission_complete()
	elif has_failed:
		$"/root/Main".show_mission_failed()


func propogate_weapon_fire(affected_area:Area2D, damage_amount:float, damage_type:Constants.WeaponTypes) -> void:
	on_weapon_fire.emit(affected_area, damage_amount, damage_type)


func _start_gameplay() -> void:
	# Enable pause menu
	$"/root/Main".menu_enabled = true
	
	# Activate sensor window
	_radar_window.activate()
	
	# Connect to weapons platform - only listen for commands for weapons we have enabled.
	for weapon in ProgressManager.weapon_progression:
		TwitchService.instance.get_node(weapon.to_pascal_case()).command_received.connect(Callable(self, "_on_received_fire_command"))

	pass


func _on_received_fire_command(_from_username: String, info: TwitchCommandInfo, _args: PackedStringArray) -> void:
	printt(info.command.to_string())
	# Create our weapon node
	var weapon_command = info.command.to_string().replace("!", "")
	var weapon_node
	if (WEAPONS.has(weapon_command)):
		weapon_node = WEAPONS[weapon_command].instantiate()
	
	# Our parameters should be X and Y coordinates
	weapon_node.position = Vector2(info.arguments[0].to_float(), info.arguments[1].to_float())
	add_child(weapon_node)
	
	pass
