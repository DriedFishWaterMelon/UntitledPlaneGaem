extends CharacterBody3D


var is_player_missile = true
@export var target:Node3D
@export var speed = 2700
var base_speed = 2700
var speed_reduce = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	
	if speed > base_speed:
		speed -= 100 * delta
	
	if speed < base_speed:
		speed = base_speed
	
	if target:
		var direction = (target.position - global_position).normalized()
		velocity = direction * speed * delta
		$Node3D.set_direction(direction)
		look_at(direction)
		move_and_slide()
	else:
		var direction
		if velocity.length_squared() > 0:
			direction = velocity.normalized()
		velocity = direction * speed * delta
		$Node3D.set_direction(direction)
		look_at(direction)
		move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	pass


func _on_timer_timeout() -> void:
	
	target = null


func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("reach")
	
	var shape_owner = body.shape_owner_get_owner(body_shape_index)
	print(body.get_groups())
	print(is_player_missile)
	if body.is_in_group("enemies") && is_player_missile && shape_owner.name == "HitRegister" :
		print("hit")
		body.take_damage(50)
		queue_free()
	if body.is_in_group("Player") && !is_player_missile:
		print("hit player")
		body.take_damage(1000)
		
func add_initial_speed(value):
	speed += value
