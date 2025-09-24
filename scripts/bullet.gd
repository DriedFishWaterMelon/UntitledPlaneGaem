extends Area3D

@onready var speed = 1000
var direction
var is_from_player = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	

func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	pass


func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	var shape_owner = body.shape_owner_get_owner(body_shape_index)
	
	if body.is_in_group("enemies") && is_from_player && shape_owner.name == "HitRegister":
		if AudioManager.hit.is_playing():
			await get_tree().create_timer(1).timeout
			AudioManager.hit.play()
		else:
			AudioManager.hit.play()
			
		if body:
			body.take_damage(10)
		queue_free()
	if body.is_in_group("Player")  && !is_from_player:
		body.take_damage(20)
		if AudioManager.hit.is_playing():
			print("playing")
			await get_tree().create_timer(2).timeout
			AudioManager.hit.play()
		else:
			AudioManager.hit.play()
		queue_free()
