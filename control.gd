extends Control

@export var RADIUS = 70
@export var DEAD_ZONE = 0.1



var mouse_pose = Vector2()
signal analog_input(analog:Vector2)

func _ready() -> void:
	
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	Input.warp_mouse(position)
	
func _process(delta: float) -> void:
	
	$speed.position = mouse_pose + Vector2(70,0)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
		
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
