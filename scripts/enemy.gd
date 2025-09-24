class_name EnemyAircraft
extends CharacterBody3D

# --- Public Variables (Inspectable) ---
# Set the target position in the Godot editor.
@export var target_pos: Vector3 = Vector3(100, 50, -100)

@export_group("Flight Model")
# The normal cruising speed when flying straight.
@export var base_speed: float = 30.0
# How quickly the aircraft can roll and pitch towards the target.
@export var turn_speed: float = 2.5
# How quickly the speed adjusts during turns.
@export var speed_acceleration: float = 4.0
# How much speed is lost in a sharp turn (0.0 = no loss, 1.0 = 100% loss).
@export var turn_drag_multiplier: float = 0.4


# --- Private Variables ---
var current_speed: float = 0.0

# Initialize the speed when the scene starts.
func _ready() -> void:
	current_speed = base_speed

# Handle all movement and rotation logic in the physics loop.
func _physics_process(delta: float) -> void:
	# --- Rotation Logic ---
	handle_rotation(delta)
	
	# --- Speed & Velocity Logic ---
	handle_speed_and_movement(delta)
	
	# --- Apply Movement ---
	move_and_slide()


# This function calculates and applies the roll and pitch.
func handle_rotation(delta: float) -> void:
	# Get the essential direction vectors.
	var forward_dir: Vector3 = -global_transform.basis.z # Direction the nose is pointing
	var right_dir: Vector3 = global_transform.basis.x   # Direction of the right wing
	var dir_to_target: Vector3 = (target_pos - global_position).normalized()

	# 1. CALCULATE ROLL: Is the target to our left or right?
	# We use the dot product to project the target direction onto our "right" vector.
	# - Positive result: Target is to the right -> Roll right.
	# - Negative result: Target is to the left -> Roll left.
	var roll_influence: float = right_dir.dot(dir_to_target)
	
	# 2. CALCULATE PITCH: Is the target above or below us?
	# We use the dot product again, but with our "up" vector.
	# This part is simplified because once we roll, "pitching up" (relative to the aircraft)
	# will correctly steer us towards the target.
	# We find the angle between our forward vector and the target direction.
	var pitch_dot: float = forward_dir.dot(dir_to_target)
	# We want to pitch up if the target is in front of us. We only stop pitching
	# when the dot product is close to 1 (meaning we are facing the target).
	var pitch_influence: float = 1.0 - pitch_dot

	# 3. APPLY ROTATIONS
	# We rotate the aircraft around its own local axes.
	# We apply a negative roll because a positive roll_influence (target is right)
	# should correspond to a clockwise roll (negative Z rotation).
	rotate_object_local(Vector3.FORWARD, -roll_influence * turn_speed * delta)
	
	# Pitch up (around the local X-axis) to turn towards the target.
	# This only works correctly because we have already rolled!
	rotate_object_local(Vector3.RIGHT, pitch_influence * turn_speed * delta)


# This function handles the speed changes and sets the velocity.
func handle_speed_and_movement(delta: float) -> void:
	var forward_dir: Vector3 = -global_transform.basis.z
	var dir_to_target: Vector3 = (target_pos - global_position).normalized()
	
	# How much are we turning? We can measure this by how far our "forward"
	# vector is from the ideal "direction to target" vector.
	# A dot product of 1.0 means we're flying straight at the target (no turn).
	# A dot product of 0.0 means we're at a 90-degree angle (max turn).
	# A dot product of -1.0 means we're facing the opposite way.
	var turn_intensity: float = 1.0 - abs(forward_dir.dot(dir_to_target))
	turn_intensity = clamp(turn_intensity, 0.0, 1.0) # Keep it in a 0-1 range.

	# Calculate the target speed. The more intense the turn, the lower the speed.
	var target_speed: float = lerp(base_speed, base_speed * (1.0 - turn_drag_multiplier), turn_intensity)

	# Smoothly adjust our current speed towards the target speed.
	current_speed = lerp(current_speed, target_speed, speed_acceleration * delta)
	
	# The velocity is always forward, based on the aircraft's current orientation.
	velocity = forward_dir * current_speed
