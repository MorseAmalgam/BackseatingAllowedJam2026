extends Node

var weapon_progression:Array[String] = ["fire", "laser"]
var sensor_progression:Array[String] = ["motion", "infrared", "spatial", "thermal"]

var show_tutorial:bool = true # Show tutorial once
var map_seed:int = 0  # 0 - roll a new layout on next level load

var current_level:int = 1

# Per-level difficulty. Levels past the end of the list reuse the last entry.
const LEVEL_SETTINGS:Array[Dictionary] = [
	{ "max_rifts": 2, "rift_spawn_interval": 10.0 },  # Level 1
	{ "max_rifts": 3, "rift_spawn_interval": 7.0 },   # Level 2
	{ "max_rifts": 3, "rift_spawn_interval": 5.0 },   # Level 3+
]


func get_level_settings() -> Dictionary:
	return LEVEL_SETTINGS[clampi(current_level - 1, 0, LEVEL_SETTINGS.size() - 1)]
