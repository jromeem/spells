extends CharacterBody2D

var isConjuring = false
@export var speed = 80
@onready var animated_sprite: AnimatedSprite2D = $DinoSprite

func _on_conjure_start():
	isConjuring = !isConjuring
	speed = 0
	
func _on_conjure_end():
	isConjuring = !isConjuring
	speed = 80

func _ready():
	var conjuring = get_node("ConjuringFX/AnimatedSprite2D")
	conjuring.connect("conjuring_started", _on_conjure_start)
	conjuring.connect("conjuring_ended", _on_conjure_end)

func _physics_process(_delta):
	if (isConjuring):
		animated_sprite.play("step")
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
