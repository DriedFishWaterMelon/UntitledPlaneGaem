extends Control

@export var RADIUS = 70
@export var DEAD_ZONE = 0.1
var is_mouse_lock = true


var mouse_pose = Vector2()
signal analog_input(analog:Vector2)

func _ready() -> void:
	
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	Input.warp_mouse(position)
	
	
func _process(delta: float) -> void:
	
	$speed.position = mouse_pose + Vector2(70,0)
	
	if Input.is_action_just_pressed("ui_cancel") && is_mouse_lock:
		print("ese")
		
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		var is_mouse_lock = false
		print(is_mouse_lock)
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	if Input.is_action_just_pressed("mouse_lock") :
		print("K")
		
		mouse_mode_to_control()
		print(is_mouse_lock)
		
	var local_mouse = get_local_mouse_position()
	if local_mouse.length() < RADIUS:
		mouse_pose = local_mouse
	else:
		mouse_pose = local_mouse.normalized() * RADIUS
		
	Input.warp_mouse(position+mouse_pose)
	
	var analog = Vector2(mouse_pose.x/RADIUS,-mouse_pose.y/RADIUS)
	
	if analog.length() > DEAD_ZONE:
		analog_input.emit(analog)
	queue_redraw()
		
		
		

func _draw() -> void:
	draw_arc(Vector2(0,0),RADIUS,0,360,40,Color.WHITE,1,true)
	#draw_circle(Vector2(0,0),DEAD_ZONE*100,Color.RED)
	draw_arc(mouse_pose,20,0,360,40,Color.WHITE,1,true)
	
	
func mouse_mode_to_visible():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func mouse_mode_to_control():
	is_mouse_lock = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	Input.warp_mouse(position)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_lock") :
		print("K")
		
		mouse_mode_to_control()
		print(is_mouse_lock)
