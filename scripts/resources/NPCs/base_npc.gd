extends Resource
class_name BaseNpc

@export var name_of : String
@export var icon : Texture2D

@export var current_quest: Quest
@export var current_quest_index: int = 0
@export var is_quest_given: bool = false
@export var friendship: int = 0
