extends CanvasLayer

var ter_count = 0
var but_count = 0
var waf_count = 0
var tear_count = 0
var meat_count = 0
var dough_count = 0



@onready var entry_button: MarginContainer = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton
@onready var entry_button_2: MarginContainer = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton2
@onready var entry_button_3: MarginContainer = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton3
@onready var entry_button_4: MarginContainer = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton4
@onready var entry_button_5: MarginContainer = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton5
@onready var entry_button_6: MarginContainer = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton6
@onready var terryamnt: Label = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton/Panel2/MarginContainer2/terryamnt
@onready var waffleamt: Label = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton2/Panel2/MarginContainer2/waffleamt
@onready var butteramt: Label = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton3/Panel2/MarginContainer2/butteramt
@onready var tearamt: Label = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton4/Panel2/MarginContainer2/tearamt
@onready var doughamt: Label = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton5/Panel2/MarginContainer2/doughamt
@onready var meatamt: Label = $MarginContainer2/TextureRect2/InformationPanel/Ingredients/EntryButton6/Panel2/MarginContainer2/meatamt

const FLAT_SANDWICH_PIECE = preload("uid://oypgd3m7jgju")
var cam_pos
var current_sandwich = []
var id_check
var pot_saved
var cooking = false

func _ready() -> void:
	Manager.assemblerui = self
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("exit"):
		if cooking:
			return
		Manager.player.alive = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		self.hide()
		
func snapshot():
	pot_saved = Manager.food_in_pot.duplicate()
	update_visual()
		
func update_sandwich(tex, type_of):
	current_sandwich.append(tex)
	if current_sandwich.size() >= 5:
		$MarginContainer.position.y += 62 
	var layer = FLAT_SANDWICH_PIECE.instantiate()
	$MarginContainer/MarginContainer3/VBoxContainer.add_child(layer)
	match type_of:
		"terry":
			id_check = 1
		"waffle":
			id_check = 2
		"butter":
			id_check = 3
		"babytear":
			id_check = 5
		"meatball":
			id_check = 8
		"doughbaby":
			id_check = 7
	for item in Manager.food_in_pot:
		var item_check = load(item).instantiate()
		if item_check.id == id_check:
			Manager.food_in_pot.erase(item)
	update_visual()
	layer.texture = tex
	


func update_visual():
	reset()
	for item in Manager.food_in_pot:
		var item_check = load(item).instantiate()
		match item_check.id:
			1:
				ter_count += 1
				entry_button.show()
			3:
				but_count += 1
				entry_button_3.show()
			2:
				waf_count += 1
				entry_button_2.show()
			5:
				tear_count += 1
				entry_button_4.show()
			8:
				meat_count += 1
				entry_button_6.show()
			7:
				dough_count += 1
				entry_button_5.show()
		print(item_check)
	terryamnt.text = str(ter_count)
	waffleamt.text = str(waf_count)
	butteramt.text = str(but_count)
	tearamt.text = str(tear_count)
	meatamt.text = str(meat_count)
	doughamt.text = str(dough_count)
	print(str(dough_count))

func reset():
	entry_button.hide()
	entry_button_2.hide()
	entry_button_3.hide()
	entry_button_4.hide()
	entry_button_5.hide()
	entry_button_6.hide()
	ter_count = 0
	but_count = 0
	waf_count = 0
	tear_count = 0
	meat_count = 0
	dough_count = 0
	
func reset_sandwich():
	reset()
	Manager.food_in_pot = pot_saved
	snapshot()
	for child in $MarginContainer/MarginContainer3/VBoxContainer.get_children():
		child.queue_free()
	current_sandwich.clear()
	
func assemble():
	if pot_saved.is_empty():
		return
	snapshot()
	Manager.current_assembler.set_collision_layer_value(10, false)
	Manager.current_assembler.sandwich_start()
	# you assembled create sandwich
	Manager.player.alive = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.hide()
	current_sandwich.clear()
	reset_sandwich()
