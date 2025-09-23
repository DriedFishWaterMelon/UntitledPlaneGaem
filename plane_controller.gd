extends CharacterBody3D


@export var MAX_SPEED := 200
@export var BASE_SPEED := 80
@export var MIN_SPEED := 30
@export var acceleration := 15.5
@export var deacceleration := 15.5
@export var current_speed := 50.0
@export var fire_rate_rpm: float = 6000.0
@onready var fire_cooldown_timer = $gun_timer
@onready var missile_cooldown = $missile
@export var yaw_speed := 30.0
@export var pitch_speed := 45.0
@export var roll_speed := 45.5
@onready var muzzle_point = $MuzzlePoint

var base_fov = 90
var max_fov = 130
var min_fov = 70
var fov_accel = 30
var fov = 0
var is_reloading = false
var reload_time = 2.0
var rack_gun_ammo = 40
signal reloadsignal
@onready var camera = $Camera3D
@onready var bullet_scene = preload("res://bullet.tscn")
@onready var missile_scene = preload("res://missile.tscn")
@onready var ui_canvas = get_node("../ui")
@onready var plane_mesh = $Jet

var activate_weapon = "gun"

var weapon = {
	"gun": 511,
	"missile": 12,
}

var turn_input = Vector2()
#var gun_ammo = 511
#var missile = 48
func _ready() -> void:
	fire_cooldown_timer.wait_time = 60.0 / fire_rate_rpm
	missile_cooldown.wait_time = 2
	
	pitch_speed = deg_to_rad(pitch_speed)
	yaw_speed = deg_to_rad(yaw_speed)
	roll_speed = deg_to_rad(roll_speed)
	
	var ui = get_node("../ui/Control")
	
	if ui:
		ui.analog_input.connect(_on_control_analog_input)
		
	get_node("../ui").done_reload.connect(_on_finish_reloaded)
	
	
	
	
	
	
func _physics_process(delta: float) -> void:
	
	var initial_pov = 90
	
	if Input.is_action_just_pressed("look_behind"):
		$Camera3D.rotation_degrees = Vector3(-7.6, 180, 0.4)
	if Input.is_action_just_released("look_behind"):
		print("cancel")
		$Camera3D.rotation_degrees = Vector3(-7.6, -0.8, 0.4)
	
	if Input.is_action_pressed("right_mouse") && ($Camera3D.fov - $Camera3D.fov/10) > 2:
		initial_pov = $Camera3D.fov
		$Camera3D.fov = $Camera3D.fov - $Camera3D.fov/10
	elif Input.is_action_just_released("right_mouse"):
		$Camera3D.fov = initial_pov
	
	if Input.is_action_pressed("left_mouse") && activate_weapon == "gun":
		weapon_fire()
		
	
	if Input.is_action_pressed("ui_left"):
		rotate(basis.y,yaw_speed * delta)
	if Input.is_action_pressed("ui_right"):
		rotate(basis.y,-yaw_speed * delta)
	if Input.is_action_pressed("up"):
		rotate(basis.x,-pitch_speed * delta)
	if Input.is_action_pressed("down"):
		rotate(basis.x,pitch_speed * delta)
		
	var roll =Input.get_axis("roll_left","roll_right")
	
	
	
	# Player wants to accelerate
	if Input.is_action_pressed("accel"):
		
		$Camera3D.fov = lerp($Camera3D.fov,130.0,5 * delta)
		
		current_speed = move_toward(current_speed, MAX_SPEED, acceleration * delta)
		
		

	# Player wants to decelerate/brake
	elif Input.is_action_pressed("deaccel"):
		
		$Camera3D.fov = lerp($Camera3D.fov,70.0,3 * delta)
		
		current_speed = move_toward(current_speed, MIN_SPEED, deacceleration * delta)
		

	# NO input from the player, so return to base speed
	else:
		$Camera3D.fov = lerp($Camera3D.fov,90.9,2 * delta)
		
		var return_speed = deacceleration/2
		
		current_speed = move_toward(current_speed, BASE_SPEED, return_speed * delta)
	velocity = -basis.z * current_speed
	move_and_slide()
	
	get_node("../ui/Control/speed").text = "Speed: " + str(int(current_speed*10))
	
	var turn_dir = Vector3(-turn_input.y,-turn_input.x,-roll)
	apply_rotation(turn_dir,delta)
	turn_input = Vector2()
	#turn_input = Input.get_vector("left","right","down","up")
	
	

	
func apply_rotation(vector,delta):
	rotate(basis.z,vector.z * roll_speed * delta)
	rotate(basis.x,vector.x * pitch_speed * delta)
	rotate(basis.y,vector.y * yaw_speed * delta)
	
	if vector.x < 0:
		plane_mesh.rotation.x = lerp_angle(plane_mesh.rotation.x,deg_to_rad(-10) * vector.x,delta)
	elif vector.x >0:
		plane_mesh.rotation.x = lerp_angle(plane_mesh.rotation.x,deg_to_rad(10) * -vector.x,delta)
	else:
		plane_mesh.rotation.x = lerp_angle(plane_mesh.rotation.x,0,delta)
	
	if vector.y < 0:
		plane_mesh.rotation.z = lerp_angle(plane_mesh.rotation.z,deg_to_rad(-45) * vector.y,delta)
	elif vector.y > 0:
		plane_mesh.rotation.z = lerp_angle(plane_mesh.rotation.z,deg_to_rad(45) * -vector.y,delta)
	else :
		plane_mesh.rotation.z = lerp_angle(plane_mesh.rotation.z,0,delta)

func _on_control_analog_input(analog: Vector2) -> void:
	
	turn_input = analog
	
func _on_finish_reloaded():
	is_reloading = false
	if weapon.gun >= 40 - rack_gun_ammo:
		weapon.gun -= 40 - rack_gun_ammo
		rack_gun_ammo += 40 - rack_gun_ammo
		
		
	elif weapon.gun < 40 - rack_gun_ammo:
		rack_gun_ammo += weapon.gun
		weapon.gun = 0
		
	get_node("../ui/Control/Gun").text = "M61A1 Vulcan" +"
	" + "Round: " + str(int(rack_gun_ammo)) + "/" + str(int(weapon.gun))

func _reload_the_gun():
	is_reloading = true
	reloadsignal.emit()
	
func update_fov(value):
	if camera.fov <= 2 && camera.fov <= 178:
		camera.fov = value
func get_fov():
	return camera.fov

func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("reload"):
		if activate_weapon == "gun" && rack_gun_ammo < 40:
			
			_reload_the_gun()
	
	if event.is_action_pressed("left_mouse") && activate_weapon == "missile":
		weapon_fire()
		
	if Input.is_action_just_released("left_mouse") && activate_weapon == "gun":
		$MuzzleFlash.visible = false
	if Input.is_action_just_pressed("change_weapon"):
		if activate_weapon == "gun":
			activate_weapon = "missile"
			get_node("../ui/Control/Gun").text = "AIM-9 Sidewinder" +"
	" + "Amount: " + str(int(weapon.missile))
			
			print(activate_weapon)
		else:
			activate_weapon = "gun"

			get_node("../ui/Control/Gun").text = "M61A1 Vulcan" +"
	" + "Round: " + str(int(rack_gun_ammo)) + "/" + str(int(weapon.gun))
			print(activate_weapon)
func weapon_fire():
	if activate_weapon == "gun" && fire_cooldown_timer.is_stopped() && rack_gun_ammo > 0:
		fire_cooldown_timer.start()
		var spread_amount: float = 0.02
		var new_bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(new_bullet)
		var fire_direction = -muzzle_point.global_transform.basis.z
	
		# --- Start of Bullet Spread Logic ---
		
		# 1. Create a random offset vector
		# This creates a random direction in a 2D circle (on the X and Y axes)
		# and then we use that to slightly alter the firing direction.
		var spread = Vector3(
			randf_range(-spread_amount, spread_amount),
			randf_range(-spread_amount, spread_amount),
			0
		)
		
		# 2. Apply the random offset to the fire direction
		# We use 'rotated' to apply the random offset relative to the original direction.
		# We then normalize it to make sure the bullet speed remains constant.
		var spread_direction = fire_direction.rotated(Vector3.UP, spread.x).rotated(Vector3.RIGHT, spread.y).normalized()
		
		# --- End of Bullet Spread Logic ---

		# Instantiate the new bullet
		
		
		# Set the bullet's starting position and new direction
		new_bullet.global_transform = $CollisionShape3D2.global_transform
		new_bullet.direction = spread_direction # Use the new direction with spread
		
		# Add the bullet to the scene
		
		
		# Decrease ammo count
		rack_gun_ammo -= 1
		get_node("../ui/Control/Gun").text = "M61A1 Vulcan" +"
	" + "Round: " + str(int(rack_gun_ammo)) + "/" + str(int(weapon.gun))
		$MuzzleFlash.visible = true
	
	if activate_weapon == "missile" && weapon.missile >0:
		print("missile")
		
		var target = get_node("../ui/Control2").locking_target
		var new_missile = missile_scene.instantiate()
		get_tree().current_scene.add_child(new_missile)
		new_missile.is_player_missile = true
		new_missile.target = target
		print(new_missile)
		new_missile.global_transform = $MuzzlePoint2.global_transform
		weapon.missile -=1
		get_node("../ui/Control/Gun").text = "AIM-9 Sidewinder" +"
	" + "Amount: " + str(int(weapon.missile))
		
