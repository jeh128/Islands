extends Node

export var world_seed: int = 0;

func _ready() -> void:
	pass

func generate() -> void:
	seed(world_seed)
	
	
