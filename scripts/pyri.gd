extends Area2D
@onready var pyri_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var pyri_loop = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pyri_sprite.play("start")

# for starting animation, looping an animation, then finishing animation
func _on_animation_finished():
	var anim = pyri_sprite.animation
	match (anim):
		"start":
			print('start animation')
			if (pyri_sprite.animation_finished):
				pyri_sprite.play("loop")
		"loop":
			print('loop animation')
			if (pyri_sprite.animation_finished):
				pyri_loop += 1
				pyri_sprite.play("loop")
			if (pyri_loop > 3):
				pyri_sprite.play("end")
		"end":
			print('end animation')
			if (pyri_sprite.animation_finished):
				queue_free()
