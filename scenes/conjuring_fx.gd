extends AnimatedSprite2D

signal conjuring_started
signal conjuring_ended
@export var isConjuring = false
@onready var conjuring_fx: AnimatedSprite2D = $"."

func _ready() -> void:
	conjuring_fx.visible = false

func _physics_process(delta):
	# get input
	var conjuringActive = Input.is_action_just_pressed("conjure")
	
	if (conjuringActive):
		isConjuring = !isConjuring
		if (isConjuring):
			conjuring_fx.visible = isConjuring
			conjuring_started.emit()
			conjuring_fx.play("air")
		else:
			conjuring_fx.visible = isConjuring
			conjuring_ended.emit()
			conjuring_fx.stop()
