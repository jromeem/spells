extends Control

# conjure a spell by typing something (i.e. pyri)
# press enter
# cast a spell with E queue animation in front of dino sprite
@onready var spelling: LineEdit = $"../Conjuring/Spelling"
@onready var spell_container: FlowContainer = $"../Conjuring/SpellContainer"
@onready var Pyri: PackedScene = preload("res://scenes/pyri.tscn")
var ready_spell = ''

func _on_valid_spellword(spell):
	if (spell == 'pyri'):
		ready_spell = spell
	else:
		ready_spell = ''

func _ready() -> void:
	spelling.connect("valid_spellword", _on_valid_spellword)

func _physics_process(delta: float) -> void:
	var casting = Input.is_action_just_pressed("cast_spell")
	if (casting):
		print('casting!', ready_spell)
		if (ready_spell == 'pyri'):
			var spell_node = Pyri.instantiate()
			add_child(spell_node)
			spell_node.fire()
