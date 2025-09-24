extends Control


@onready var camera = $"../../Player/Camera3D"
@export var circle_radius = 20.0
@export var circle_color = Color.WHITE

var enemy_data = {}
var current_enemy_nodes = []
var locking_target = null
@export var locked_color = Color.RED


func _ready() -> void:
	var main_scene =($"../..")
	print(main_scene)
	main_scene.child_entered_tree.connect(_on_child_entered_tree)
	print($"../../Player/Camera3D")
	
	# Rest of your initialization code
	
	_update_enemies()
	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("target_lock"): # Make sure "target_lock" is a defined input action
		_on_target_lock_pressed()
	
	_check_for_updates()
	_track_enemies()
	
	
		
		
		
func _check_for_updates():
	var new_enemy_nodes = get_tree().get_nodes_in_group("enemies")
	if new_enemy_nodes.size() != current_enemy_nodes.size():
		_update_enemies()
func _update_enemies():
	for child in get_children():
		child.queue_free()
	enemy_data.clear()
	
	current_enemy_nodes = get_tree().get_nodes_in_group("enemies")
	for enemy in current_enemy_nodes:
		var indicator = Control.new()
		add_child(indicator)
		enemy_data[enemy] = indicator
		indicator.connect("draw", Callable(self, "_on_control_draw").bind(indicator))
		print( enemy)
		
func _track_enemies():
	var viewport_size = get_viewport_rect().size
	var camera_forward = -camera.global_transform.basis.z.normalized()
	
	for enemy in enemy_data.keys():
		if !is_instance_valid(enemy):
			continue
		var indicator = enemy_data[enemy]
		var enemy_to_camera = enemy.global_transform.origin - camera.global_transform.origin
		
		
		
		var screen_pos = camera.unproject_position(enemy.global_transform.origin)
		
		if enemy_to_camera.dot(camera_forward) < 0:
			# --- START: EDITED CODE ---

			# Define a margin so the indicator isn't perfectly flush with the edge
			var margin = 50.0

			# Get the center and the effective bounds (half-size minus margin)
			var screen_center = viewport_size / 2.0
			var screen_bounds = screen_center - Vector2(margin, margin)

			# Get the vector from the screen center to the off-screen target
			# We clamp the screen_pos to prevent it from being at the exact center,
			# which would cause a division by zero.
			var direction = screen_pos.move_toward(screen_center, 0.001) - screen_center

			# Calculate the scale required to extend the 'direction' vector to the screen_bounds
			var scale = 1.0
			if abs(direction.x / screen_bounds.x) > abs(direction.y / screen_bounds.y):
				# The position is limited by the horizontal (left/right) bounds
				scale = abs(screen_bounds.x / direction.x)
			else:
				# The position is limited by the vertical (top/bottom) bounds
				scale = abs(screen_bounds.y / direction.y)

				# The final position is the center plus the scaled direction vector
				indicator.position = screen_center + (direction * scale)
					
		else:
			
			var is_on_screen = (screen_pos.x >0 && screen_pos.x<viewport_size.x && screen_pos.y > 0 && screen_pos.y < viewport_size.y)
			indicator.position = screen_pos
			if is_on_screen:
				indicator.show
			else:
				indicator.show
				
				indicator.position.x = clamp(screen_pos.x, 0, viewport_size.x)
				indicator.position.y = clamp(screen_pos.y, 0, viewport_size.y)
			
		indicator.queue_redraw()
		
func _on_control_draw(control_to_draw):
	var color_to_draw = circle_color
	
	# Find which enemy this indicator belongs to
	for enemy in enemy_data.keys():
		if enemy_data[enemy] == control_to_draw:
			if enemy == locking_target:
				color_to_draw = locked_color
			break # Stop once you find the match
			
	control_to_draw.draw_arc(Vector2.ZERO,10,0,360,100,color_to_draw,0.5,true)
	
func _on_child_entered_tree(node):
	
	if node is Control and node != self:
		
		node.connect("draw",Callable(self,"_on_control_draw").bind(node))
		
func _on_target_lock_pressed():
	locking_target = null
	var min_distance = INF
	var mouse_pos = get_viewport().get_mouse_position()

	# Find the closest on-screen enemy
	for enemy in enemy_data.keys():
		var screen_pos = camera.unproject_position(enemy.global_transform.origin)
		var is_on_screen = (screen_pos.x > 0 and screen_pos.x < get_viewport_rect().size.x and screen_pos.y > 0 and screen_pos.y < get_viewport_rect().size.y)
		
		if is_on_screen:
			var distance = mouse_pos.distance_to(screen_pos)
			if distance < min_distance:
				min_distance = distance
				locking_target = enemy

		
