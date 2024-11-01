extends AnimatedSprite2D

signal conjuring_started
signal conjuring_ended
@export var isConjuring = false
@onready var conjuring_fx: AnimatedSprite2D = $"."

func _ready() -> void:
	conjuring_fx.visible = false
	
func toggle_conjuring():
	isConjuring = !isConjuring
	print('toggle', isConjuring)
	conjuring_fx.visible = isConjuring
	if (isConjuring):
		print('play?')
		conjuring_fx.play("air")
		conjuring_started.emit()
	else:
		print('stop?')
		conjuring_fx.stop()
		conjuring_ended.emit()

func set_conjuring(setting):
	isConjuring = setting
	conjuring_fx.visible = setting
	if (isConjuring):
		conjuring_fx.play("air")
		conjuring_started.emit()
	else:
		conjuring_fx.stop()
		conjuring_ended.emit()

func _physics_process(delta):
	# get input and toggle conjuring
	var conjuringActive = Input.is_action_just_pressed("conjure")
	if (conjuringActive):
		toggle_conjuring()
	
	# while conjuring if presses ENTER button - same thing as ending
	if (isConjuring):
		var conjuringEnd = Input.is_action_just_pressed("conjure_end")
		if (conjuringEnd):
			set_conjuring(false)
