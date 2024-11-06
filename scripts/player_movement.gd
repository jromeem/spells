extends CharacterBody2D

var isConjuring = false
signal conjuring_started
signal conjuring_ended

@export var speed = 80
@onready var animated_sprite: AnimatedSprite2D = $DinoSprite
@onready var conjuring_fx: AnimatedSprite2D = $"ConjuringFX/Conjuring2DSprite"

func _on_conjuring_started():
	isConjuring = true
	speed = 0
	
func _on_conjuring_ended():
	isConjuring = false
	speed = 80

func _ready() -> void:
	conjuring_fx.visible = false
	
func toggle_conjuring():
	isConjuring = !isConjuring
	conjuring_fx.visible = isConjuring
	if (isConjuring):
		conjuring_fx.play("air")
		conjuring_started.emit()
	else:
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

func _physics_process(_delta):
	# get input and toggle conjuring
	var conjuringActive = Input.is_action_just_pressed("conjure")
	if (conjuringActive):
		toggle_conjuring()
	
	if (isConjuring):
		animated_sprite.play("step")
		var conjuringEnd = Input.is_action_just_pressed("conjure_end")
		if (conjuringEnd):
			set_conjuring(false)
	else:
		# get input
		var direction = Input.get_vector("left", "right", "up", "down");
		
		if direction.x > 0:
			animated_sprite.flip_h = false
		elif direction.x < 0:
			animated_sprite.flip_h = true
			
		if direction.x == 0 && direction.y == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")

		# apply movement
		velocity = direction * speed
		
		move_and_slide()
