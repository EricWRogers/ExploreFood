extends Node3D

func _ready() -> void:
	Manager.askers_request.clear()
	Manager.current_customers = 0
	if Manager.waffledimension:
		$"../Portal4".unlock()
		$"../MoneySign3".queue_free()
	if !Manager.collected_food.is_empty():
		for item in Manager.collected_food:
			var fooditem = load(item).instantiate()
			fooditem.rarity_level = 1
			get_tree().current_scene.add_child(fooditem)
			fooditem.freeze = false
			fooditem.global_position = $"../CollectedFoodSpawn".global_position
			if fooditem.has_method("kill_frog"):
				fooditem.kill_frog()
			await get_tree().create_timer(0.3).timeout
		Manager.collected_food.clear()
	if !Manager.showed_sell:
		showsell()
		Manager.showed_sell = true
	Manager.kitchen = self
	if Manager.kitchen_tut > 0:
		$"../Portal2".unlock()
		if Manager.breakfast_unlocked == true:
			$"../Portal4".unlock()
	Manager.kitchen_tut += 1
	#if Manager.kitchen_tut == 2 or Manager.kitchen_tut == 3:
		#$"../SellingTutorial".show()
	#elif Manager.kitchen_tut == 1:
		#pass
	#else:
		#$"../SellingTutorial".hide()
	
func showwaffle():
	$"../AnimationPlayer".play("waffledim")
	$"../WaffleDimension".make_current()
func showmeat():
	$"../AnimationPlayer".play("sell")
	$"../Selling".make_current()
func showsell():
	$"../AnimationPlayer".play("meatdim")
	$"../MeatPieDimension".make_current()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$"../Player/CharacterBody3D/Head/Camera3D".make_current()
