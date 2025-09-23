extends Area3D

@onready var speed = 1000
var direction

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
	if body.is_in_group("enemies"):
		print("hit")
		body.take_damage(5)
