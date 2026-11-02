extends Node

var level_progression:Array
var weapon_progression:Array[String] = ["fire", "laser"]
var sensor_progression:Array[String] = ["motion", "infrared", "spatial", "thermal"]

var show_tutorial:bool = true # Show tutorial once
var map_seed:int = 0  # 0 - roll a new layout on next level load
