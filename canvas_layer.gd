extends CanvasLayer

@onready var reload_progress_bar = $ProgressBar
var reloadtime
signal done_reload


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reloadtime = get_node("../Player").reload_time
	get_node("../Player").reloadsignal.connect(Reloading_bar)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if get_node("../Player").is_reloading:
		#
		#Reloading_bar()
		
	if reload_progress_bar.value == reload_progress_bar.max_value:
		done_reload.emit()
		reload_progress_bar.value = 0
		$Reloading.visible = false


func Reloading_bar():
	
	reload_progress_bar.value = 0
	var tween = create_tween()
	tween.tween_property(reload_progress_bar, "value", reload_progress_bar.max_value, reloadtime)
	$Reloading.visible = true
	
