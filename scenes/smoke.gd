extends Node3D



func set_direction(direction : Vector3):
	$VFX_Stylized_Smoke.process_material.direction = direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
