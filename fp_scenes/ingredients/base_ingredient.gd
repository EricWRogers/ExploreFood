extends RigidBody3D
class_name BaseIngredient

@onready var splatter = preload("res://fp_scenes/ingredients/splatter.tscn")

@export_group("Base Info")
@export var food_name : String
@export var icon : Texture2D
@export var flavor_text : String

##determines spawn rate between 0 and 1. a value of 1 will always spawn and a value of 0 will never spawn
@export_group("Metadata")
@export var rarity_level : float
@export var rand_spin : bool = true
@export var id : int = 0
@export var color : Color
#@export var type : String
@export var value : int
@export var hunger_restore : int
#@export var processed_ingredient : PackedScene
@export var is_prepped: bool = false
@export var inventory_icon_FOV : float = 30.5

@export_group("Food Groups")
@export var food_group: FoodGroup
@export var flavor_profile: FlavorProfile
#@export var cook_group: CookGroup
##easier way to access all tags on ingredient at once
@onready var food_tags: Array = [food_group, flavor_profile]
@onready var arrow: Node3D = %CenterPivot
#@export_subgroup("Depreciated")
#@export var category : Manager.FoodType
#@export var flavor : Manager.FlavorType
@onready var mesh_instance: MeshInstance3D = $DeformableMeshInstance3D
@onready var overlay := mesh_instance.material_overlay as ShaderMaterial
@onready var next_pass := overlay.next_pass as ShaderMaterial

@export var tooltip_offset : float
##type of food that an ingredient is. Must always have a value
enum FoodGroup {
	BREAD,
	MEAT,
	VEGGIE,
	BUTTER, #butter is a temp food group to be able to easily include butter frog in our prototype. 
	EGG #added because i didnt want to chop up Terry as a meat. I dont have any egg recipes yet though srry
}
##tracks how food has been prepped, if it has been prepped
enum FlavorProfile {
	SWEET,
	SOUR,
	SALTY,
	SPICY,
	BITTER,
}
var _contact_point := Vector3.ZERO
var _has_contact := false
var _was_touching := false
var _held := false
var _held_point : Marker3D

func _become_dropped():
	_held = false
	contact_monitor = true
	set_collision_layer_value(1, true)

func _become_held(pnt):
	_held = true
	contact_monitor = false
	set_collision_layer_value(1, false)
	_held_point = pnt
	freeze = true
	
func _become_stored():
	hide()
func _become_visibly_held():
	show()

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	arrow.top_level = true
	#print("Overlay: ", overlay)
	#print("Next pass: ", overlay.next_pass)
	#print("Next pass is ShaderMaterial: ", overlay.next_pass is ShaderMaterial)
	
func _focus_obtain():
	if _held:
		return
	%Sprite3D.texture = InputManager.get_prompt("interact")
	$Node3D.show()
	%Sprite3D.scale = Vector3(.90, .90, .90)
	%Sprite3D.modulate = Color(0.0, 0.0, 0.0, 0.0)
	var tween
	if tween: tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(%Sprite3D, "scale", Vector3(0.55, 0.55, 0.55), 0.2)
	tween.tween_property(%Sprite3D, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	overlay.set_shader_parameter("transparency", 0.5)
	next_pass.set_shader_parameter("size", 1.1)
func _defocus():
	$Node3D.hide()
	%Sprite3D.scale = Vector3(.90, .90, .90)
	%Sprite3D.modulate = Color(0.0, 0.0, 0.0, 0.0)
	overlay.set_shader_parameter("transparency", 0.0)
	next_pass.set_shader_parameter("size", 0.0)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var count := state.get_contact_count()
	var touching := count > 0

	if touching:
		var point_sum := Vector3.ZERO
		var normal_sum := Vector3.ZERO
		for i in count:
			point_sum += state.get_contact_local_position(i)  # global space
			normal_sum += state.get_contact_local_normal(i)   # global space

		var point := point_sum / count
		var normal := normal_sum.normalized()
		if normal.is_zero_approx():
			normal = state.get_contact_local_normal(0)

		_contact_point = point
		_has_contact = true

		if not _was_touching:
			on_hit.call_deferred(point, normal, true)

	_was_touching = touching

func on_hit(point: Vector3 = Vector3.ZERO, normal: Vector3 = Vector3.ZERO, spawn : bool = false) -> void:
	%Bounce.play("bouncy")
	%CollisionSFX.play()
	if spawn:
		var splat_spawn = splatter.instantiate()
		get_tree().current_scene.add_child(splat_spawn)
		splat_spawn.global_position = point
		splat_spawn.global_basis = _basis_from_normal(normal)
		splat_spawn.rotate_object_local(Vector3.UP, randf() * TAU)
		splat_spawn.appear(color)
func _basis_from_normal(normal: Vector3) -> Basis:
	var y := normal.normalized()
	if y.is_zero_approx():
		return Basis.IDENTITY
	var ref := Vector3.FORWARD if absf(y.dot(Vector3.FORWARD)) < 0.99 else Vector3.RIGHT
	var x := ref.cross(y).normalized()
	var z := x.cross(y).normalized()
	return Basis(x, y, z)

func _process(_delta: float) -> void:
	if _held_point:
		global_position = _held_point.global_position
		global_rotation = _held_point.global_rotation
	$Node3D.global_position = global_position
	$Node3D.global_position.y = $Node3D.global_position.y + tooltip_offset
	arrow.global_position = global_position
	if not _has_contact:
		return

	var dir := _contact_point - global_position
	if dir.length_squared() < 0.0001:
		return

	# Avoid look_at failing when dir is parallel to the up vector
	var up := Vector3.UP
	if absf(dir.normalized().dot(Vector3.UP)) > 0.99:
		up = Vector3.RIGHT

	arrow.look_at(global_position + dir, up)
	
func _on_body_entered(body: Node) -> void:
	on_hit(Vector3.ZERO, Vector3.ZERO, false)
	
