extends Resource
class_name BaseNpc

@export var name_of : String
@export var icon : Texture2D

#var _saved_current_quest: Quest
#var _saved_current_quest_index: int = 0
#var _saved_is_quest_given: bool = false
#var _saved_friendship: int = 0
