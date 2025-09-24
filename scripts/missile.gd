extends CharacterBody3D


var is_player_missile = true
@export var target:Node3D
@export var speed = 3000


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	
	if target:
		var direction = (target.position - global_position).normalized()
		velocity = direction * speed * delta
		look_at(direction)
		move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	pass


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("reach")
	
	var shape_owner = body.shape_owner_get_owner(body_shape_index)
	if body.is_in_group("enemies") && is_player_missile && shape_owner.name == "HitRegister" :
		print("hit")
		body.take_damage(50)
		queue_free()
	if body.is_in_group("Player") && !is_player_missile:
		body.take_damage(500)
