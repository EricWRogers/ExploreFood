extends StaticBody3D

#list of all recipes

#list of current foods in array

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

#sort through all the foods in current food array
#for each food in food array, whittle down list of recipes
#when only one recipe is left, instansiate product from that recipe
#if no recipe is found, make disgusting food

func _on_area_3d_body_entered(body: Node3D) -> void:
	pass
