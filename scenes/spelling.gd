extends LineEdit

var isConjuring = false
var allowed_characters = "[A-Za-z]"
@onready var line_edit: LineEdit = $"."

func _on_conjure_start():
	isConjuring = !isConjuring
	line_edit.visible = true
	line_edit.grab_focus()

func _on_conjure_end():
	isConjuring = !isConjuring
	line_edit.visible = false
	line_edit.text = ''

func _ready():
	var conjuring = get_node("../../Conjuring/AnimatedSprite2D")
	conjuring.connect("conjuring_started", _on_conjure_start)
	conjuring.connect("conjuring_ended", _on_conjure_end)
	line_edit.visible = false
	
func _process(delta: float) -> void:
		# get input
	var conjuringActive = Input.is_action_just_pressed("conjure")
	if (conjuringActive):
		isConjuring = true

func _on_text_changed(new_text: String) -> void:
	var old_caret_position = caret_column

	var word = ''
	var regex = RegEx.new()
	regex.compile(allowed_characters)
	for valid_character in regex.search_all(new_text):
		word += valid_character.get_string()
	set_text(word)

	caret_column = old_caret_position
