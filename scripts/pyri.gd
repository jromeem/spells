class_name Pyri extends Area2D

@onready var pyri_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var pyri_loop = 0

func fire():
	pyri_loop = 0
	pyri_sprite.play("start")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pyri_sprite.stop()
	position.x = 30
	pyri_loop = 0

# for starting animation, looping an animation, then finishing animation
func _on_animation_finished():
	var anim = pyri_sprite.animation
	match (anim):
		"start":
			if (pyri_sprite.animation_finished):
				pyri_sprite.play("loop")
		"loop":
			if (pyri_sprite.animation_finished):
				pyri_loop += 1
				pyri_sprite.play("loop")
			if (pyri_loop > 3):
				pyri_sprite.play("end")
		"end":
			if (pyri_sprite.animation_finished):
				queue_free()
