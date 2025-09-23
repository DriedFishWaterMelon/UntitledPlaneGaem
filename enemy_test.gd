extends Node3D

@onready var target = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#$Enemy.target_pos = $Area3D.position
	#$Enemy.look_at($Area3D.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		target.position.y += 10 * delta
	if Input.is_action_pressed("ui_down"):
		target.position.y -= 10 * delta
	if Input.is_action_pressed("ui_left"):
		target.position.x -= 10 * delta
	if Input.is_action_pressed("ui_right"):
		target.position.x += 10 * delta
