extends CharacterBody3D

@export var health = 100
@export var target_node: Node3D
@export var follow_distance_z = 50 
var fire_rate_rpm = 6000

@onready var missile_scene = preload("res://scenes/missile.tscn")
@onready var missileTimer =$missileTimer
@onready var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var gun_fire_timer = $gunFireTimer
@onready var gun_cooldown_timer = $GunCoolDownTimer


# --- AI Behavior Variables ---
# We rename IDLE to WANDER to better describe the new behavior.
enum State {CHASE, STRAFE, WANDER}

@export var move_speed = 120
# NEW: How far from the player the AI will wander.
@export var wander_radius = 7.0

# Store the current state and other behavior-related variables.
var current_state = State.WANDER
var strafe_direction = 1.0 # 1 for right, -1 for left
var gun_player_detection = false
var missile_player_detection = false
# NEW: This will store the random point we want to move to.
var wander_target_position: Vector3
var is_on_screen = false
var target
# Get the Timer node we added in the editor.
@onready var state_timer: Timer = $Timer


func _ready() -> void:
	gun_cooldown_timer.wait_time = 60.0 / fire_rate_rpm
	

func _physics_process(delta):
	
	
	if missile_player_detection && missileTimer.is_stopped() :
		pass
		#fire_missile(target)
	if gun_player_detection && gun_cooldown_timer.is_stopped():
		fire_gun()
	
	
	# Exit if there's no target.
	if not is_instance_valid(target_node):
		velocity = Vector3.ZERO
		return

	# Make the AI always face the target horizontally.
	var look_at_point = target_node.global_position
	look_at_point.y = global_position.y
	look_at(look_at_point)

	# The 'match' statement works like a switch, running code for the current state.
	match current_state:
		State.CHASE:
			chase_behavior(delta)
		State.STRAFE:
			strafe_behavior(delta)
		# UPDATED: We now call our new wander_behavior function.
		State.WANDER:
			wander_behavior(delta)
	
	move_and_slide()


## --- State Behaviors ---

func chase_behavior(delta):
	# --- MODIFIED LOGIC FOR "DOGFIGHT" BEHAVIOR ---

	# 1. Get the target's "back" direction vector.
	# In Godot, a Node3D's positive Z axis points "backwards" from its facing direction.
	# 'transform.basis.z' gives us this direction in world space.
	var back_direction = target_node.transform.basis.z

	# 2. Calculate the desired position.
	# This is a point in space 'follow_distance_z' meters behind the player.
	var target_behind_position = target_node.global_position + (back_direction * follow_distance_z)

	# 3. Calculate the direction from us to that "behind" point.
	var direction = (target_behind_position - global_position).normalized()
	
	# 4. Apply velocity to move towards that point.
	velocity = direction * move_speed
func strafe_behavior(delta):
	# Move sideways relative to where the AI is facing.
	velocity = transform.basis.x * strafe_direction * move_speed * 0.8

# --- MODIFIED: This function replaces idle_behavior ---
func wander_behavior(delta):
	# If we are close enough to our destination, stop moving.
	if global_position.distance_to(wander_target_position) < 0.5:
		velocity = Vector3.ZERO
		return
	
	# Otherwise, move towards the destination.
	var direction = (wander_target_position - global_position).normalized()
	velocity = direction * move_speed * 0.6 # Wandering is a bit slower than chasing


## --- Damage and State Logic ---

func take_damage(damage):
	health -= damage
	if health <= 0:
		AudioManager.kill.play()
		queue_free()





func _on_timer_timeout() -> void:
		# 1. Pick a new random state.
	var next_state_index = randi_range(0, State.size() - 1)
	current_state = State.values()[next_state_index]
	
	# 2. Set up the new state's variables.
	if current_state == State.STRAFE:
		strafe_direction = 1.0 if randf() > 0.5 else -1.0
	
	# --- MODIFIED: Logic for the WANDER state ---
	elif current_state == State.WANDER:
		# Pick a random point around the player to move to.
		var random_offset = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized() * wander_radius
		wander_target_position = target_node.global_position + random_offset
	
	# 3. Set the timer to a new random duration.
	state_timer.wait_time = randf_range(1.5, 3.5)
	#print("New State: ", State.keys()[next_state_index]) # For debugging


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	is_on_screen = true


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	is_on_screen = false


func _on_detection_node_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print(body)
		target = body
		missile_player_detection = true
		

		
		
func fire_missile(target):
	missileTimer.start()
	var new_missile = missile_scene.instantiate()
	get_tree().current_scene.add_child(new_missile)
	new_missile.is_player_missile = false
	new_missile.target = target
	print("enemy_missile_fire")
	new_missile.global_transform = $MuzzlePoint.global_transform
		
func fire_gun():
	gun_cooldown_timer.start()
	gun_fire_timer.start()
	var spread_amount: float = 0.02
	var new_bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(new_bullet)
	new_bullet.is_from_player = false
	var fire_direction = -$MuzzlePoint.global_transform.basis.z

	var spread = Vector3(
		randf_range(-spread_amount, spread_amount),
		randf_range(-spread_amount, spread_amount),
		0
	)

	var spread_direction = fire_direction.rotated(Vector3.UP, spread.x).rotated(Vector3.RIGHT, spread.y).normalized()

	new_bullet.global_transform = $MuzzlePoint.global_transform
	new_bullet.direction = spread_direction


func _on_detection_node_body_exited(body: Node3D) -> void:
	missile_player_detection = false


func _on_gun_fire_timer_timeout() -> void:
	gun_cooldown_timer.start()


func _on_gun_detection_node_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		
		gun_player_detection = true


func _on_gun_detection_node_body_exited(body: Node3D) -> void:
	
	gun_player_detection = false
