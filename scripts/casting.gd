extends Control

# conjure a spell by typing something (i.e. pyri)
# press enter
# cast a spell with E queue animation in front of dino sprite
@onready var spelling: LineEdit = $"../Conjuring/Spelling"
@onready var spell_container: FlowContainer = $"../Conjuring/SpellContainer"
@onready var Pyri: PackedScene = preload("res://scenes/pyri.tscn")

func _on_valid_spellword(spell):
	print('cast something!', spell)
	var pyri_spell = Pyri.instantiate()
	add_child(pyri_spell)
	pyri_spell.fire()

func _ready() -> void:
	spelling.connect("valid_spellword", _on_valid_spellword)
	
