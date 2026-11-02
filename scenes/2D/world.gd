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

# Settings for map randomization. Tweak this if maps look or feel dumb
@export_group("Map Randomization")
@export var randomize_layout:bool = true
@export var spawn_margin:float = 80
@export var rift_min_distance_from_vessel:float = 300
@export var rift_min_distance_between:float = 200
@export var min_distance_from_boulders:float = 100
@export var randomize_boulders:bool = true
@export var boulder_min_distance_between:float = 120

const MAX_PLACEMENT_ATTEMPTS := 50
# Keep spawns out from under the UI text (objectives list, command hint)
const NO_SPAWN_RECTS:Array[Rect2] = [Rect2(0, 0, 620, 170), Rect2(0, 590, 640, 130)]

@onready var _radar_window: Window = $RadarWindow
@warning_ignore("unused_private_class_variable")
@onready var vessel: Vessel = $Vessel

signal on_weapon_fire(area:Area2D, weapon:Constants.WeaponTypes)

func _ready():
	
	_radar_window.world_2d = get_window().world_2d
	# TODO: Enable menu and chat interaction after anything else 
	
	# Work on a copy so the survive objective added below doesn't pile up in the
	# scene's exported array when the level is reloaded (retry/replay).
	var level_objectives:Array[MissionObjective] = []
	level_objectives.assign(objectives)
	objectives = level_objectives

	# Vessel Must Escape objective is always added to the end of the list
	objectives.append(load("res://resources/objective/survive.gd").new())
	for objective in objectives:
		objective.init(self)

	$UI/MissionObjectivesHeader.text = "MISSION %d OBJECTIVES:" % ProgressManager.current_level
	_apply_level_settings()
	if randomize_layout:
		_randomize_layout()
	
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
		_radar_window.deactivate()
	elif has_failed:
		$"/root/Main".show_mission_failed()
		_radar_window.deactivate()


func propogate_weapon_fire(affected_area:Area2D, damage_amount:float, damage_type:Constants.WeaponTypes) -> void:
	on_weapon_fire.emit(affected_area, damage_amount, damage_type)


func _start_gameplay() -> void:
	# Connect to weapons platform - only listen for commands for weapons we have enabled.
	for weapon in ProgressManager.weapon_progression:
		TwitchService.instance.get_node(weapon.to_pascal_case()).command_received.connect(Callable(self, "_on_received_fire_command"))

	var main:Main = $"/root/Main"
	if ProgressManager.show_tutorial:
		# Wait for the player to dismiss the how-to-play card
		main.how_to_play.dismissed.connect(_begin_play, CONNECT_ONE_SHOT)
		main.show_how_to_play()
	else:
		_begin_play()


func _begin_play() -> void:
	ProgressManager.show_tutorial = false  # only once per session, so Retry doesn't re-show it
	# Enable pause menu
	$"/root/Main".menu_enabled = true
	# Activate sensor window
	_radar_window.activate()


func _on_received_fire_command(_from_username: String, info: TwitchCommandInfo, _args: PackedStringArray) -> void:
	printt(info.command.to_string())
	# Create our weapon node
	var weapon_command = info.command.to_string().replace("!", "")
	var weapon_node
	if (WEAPONS.has(weapon_command)):
		weapon_node = WEAPONS[weapon_command].instantiate()
	
	$LockOnSound.play()
	# Our parameters should be X and Y coordinates
	weapon_node.position = Vector2(info.arguments[0].to_float(), info.arguments[1].to_float())
	add_child(weapon_node)
	
	pass


func _randomize_layout() -> void:
	# Own RNG so the layout is repeatable on Retry without affecting other randomness
	if ProgressManager.map_seed == 0:
		ProgressManager.map_seed = randi()
	var rng := RandomNumberGenerator.new()
	rng.seed = ProgressManager.map_seed

	var bounds := Rect2(Vector2.ONE * spawn_margin, get_viewport_rect().size - Vector2.ONE * spawn_margin * 2)

	var boulders:Array[Vector2] = []
	var boulder_nodes:Array[Node2D] = []
	var rifts:Array[Rift] = []
	for child in get_children():
		if child is Rift:
			rifts.append(child)
		elif child.has_node("NavigationObstacle2D"):
			boulder_nodes.append(child)

	# Boulders first; the ship and rifts are placed around them.
	# If no spot fits, a boulder keeps its hand-placed position.
	for boulder in boulder_nodes:
		if randomize_boulders:
			for _attempt in MAX_PLACEMENT_ATTEMPTS:
				var point := _random_point(rng, bounds)
				if _is_spawnable(point) && _is_clear(point, boulders, boulder_min_distance_between):
					boulder.position = point
					break
		boulders.append(boulder.position)

	# Ship next, anywhere not inside a boulder. Try MAX_PLACEMENT_ATTEMPTS times then give up
	for _attempt in MAX_PLACEMENT_ATTEMPTS:
		var point := _random_point(rng, bounds)
		if _is_spawnable(point) && _is_clear(point, boulders, min_distance_from_boulders):
			vessel.position = point
			break

	# Rifts away from the ship, each other, and boulders
	# If no spot fits, the rift keeps its hand-placed position
	var placed:Array[Vector2] = []
	for rift in rifts:
		for _attempt in MAX_PLACEMENT_ATTEMPTS:
			var point := _random_point(rng, bounds)
			if !_is_spawnable(point):
				continue
			if point.distance_to(vessel.position) < rift_min_distance_from_vessel:
				continue
			if !_is_clear(point, placed, rift_min_distance_between):
				continue
			if !_is_clear(point, boulders, min_distance_from_boulders):
				continue
			rift.position = point
			break
		placed.append(rift.position)

	if randomize_boulders:
		# Re-carve the navigation mesh around the boulders' new positions
		$NavigationRegion2D.bake_navigation_polygon()


func _random_point(rng:RandomNumberGenerator, bounds:Rect2) -> Vector2:
	return Vector2(rng.randf_range(bounds.position.x, bounds.end.x), rng.randf_range(bounds.position.y, bounds.end.y))


func _is_spawnable(point:Vector2) -> bool:
	for rect in NO_SPAWN_RECTS:
		if rect.has_point(point):
			return false
	return true


func _is_clear(point:Vector2, others:Array[Vector2], min_distance:float) -> bool:
	for other in others:
		if point.distance_to(other) < min_distance:
			return false
	return true


func _apply_level_settings() -> void:
	var settings := ProgressManager.get_level_settings()
	var rift_count := 0
	for child in get_children():
		if child is Rift:
			rift_count += 1
			if rift_count > settings.max_rifts:
				# Remove now so _randomize_layout doesn't see it
				remove_child(child)
				child.queue_free()
			else:
				child.set_spawn_interval(settings.rift_spawn_interval)
