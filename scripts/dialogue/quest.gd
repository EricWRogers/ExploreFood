class_name Quest extends Resource


## dialogue that plays when starting the quest
@export var start_quest: Array[String]

## dialogue that plays if the quest has already begun
@export var reminder: Array[String]

## dialogue that plays if player passes quest
@export var pass_quest: Array[String]

## dialogue that plays if player fails quest
@export var fail_quest: Array[String]

## item that the NPC is requesting
@export var quest_item: PackedScene
