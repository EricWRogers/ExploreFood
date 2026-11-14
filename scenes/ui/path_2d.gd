extends Path2D


@onready var line_2d: Line2D = $Line2D

func update_line_from_path() -> void:
	var curve: Curve2D = self.curve
	if curve:
		# get_baked_points() returns a PackedVector2Array approximating the curve
		line_2d.points = curve.get_baked_points()
