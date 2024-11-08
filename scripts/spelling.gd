extends LineEdit

var isConjuring = false
var allowed_characters = "[A-Za-z]"
@onready var line_edit: LineEdit = $"."
@export var spellword = ''
@onready var label: RichTextLabel = $"../Label"

signal invalid_spellword(word)
signal valid_spellword(word)
signal prefix_detected(prefix)
signal root_detected(root)
signal suffix_detected(suffix)

func _on_conjure_start():
	isConjuring = !isConjuring
	line_edit.visible = true
	line_edit.grab_focus()

func _on_conjure_end():
	isConjuring = !isConjuring
	label.text = spellword
	line_edit.visible = false
	line_edit.text = ''

# Define roots, prefixes, and suffixes for validation
var lesser_roots = ["pyri", "aqua", "volt", "zeph", "terr", "lux", "nox", "ferrum"]
var higher_roots = ["ignis", "glaci", "fulgur", "aether", "gaia", "lumen", "umbra", "prisma", "corpus", "mentis", "luxus", "chron", "sensus", "vita", "mortis", "ordo"]
var roots = lesser_roots + higher_roots

var prefixes = {
	"targeting": ["ma", "in", "ex"],
	"amplification": ["ka", "epi", "tri"],
	"control": ["ra", "su", "pa"],
	"utility": ["ve", "xo", "dis"]
}

var suffixes = {
	"power": ["lo", "ri", "sha"],
	"duration": ["len", "tan"],
	"effect_modifiers": ["nu", "dra", "via", "tos", "rum", "sol"]
}

func flatten_array(nested_array: Array) -> Array:
	var flat_array = []
	for subarray in nested_array:
		for element in subarray:
			flat_array.append(element)
	return flat_array

# Custom function to check if a string begins with a substring at a specific index
func begins_with_at_index(string: String, substring: String, index: int) -> bool:
	if index < 0 or index >= string.length():
		return false  # Index out of bounds
	return string.substr(index, substring.length()) == substring

func is_valid_spell(spell_input: String) -> bool:
	# Make a copy of the input to work with
	var remaining_text = spell_input
	
	# Track detected components for highlighting
	var detected_prefixes = []
	var detected_root = ""
	var detected_suffixes = []
	
	# Track used categories to ensure one prefix/suffix per category
	var used_prefix_categories = {}
	var used_suffix_categories = {}
	
	# Step 1: Detect prefixes
	var prefix_found = true
	while prefix_found and remaining_text.length() > 0:
		prefix_found = false
		for category in prefixes:
			if category in used_prefix_categories:
				continue  # Skip if category already used
				
			for prefix in prefixes[category]:
				if remaining_text.begins_with(prefix):
					detected_prefixes.append(prefix)
					prefix_detected.emit(prefix)
					used_prefix_categories[category] = true
					remaining_text = remaining_text.substr(prefix.length())
					prefix_found = true
					break
	
	# Step 2: Detect root (mandatory)
	var root_found = false
	for root in roots:
		if remaining_text.begins_with(root):
			detected_root = root
			root_detected.emit(root)
			remaining_text = remaining_text.substr(root.length())
			root_found = true
			break
	
	if not root_found:
		return false  # No valid root found
	
	# Step 3: Detect suffixes
	while remaining_text.length() > 0:
		var suffix_found = false
		
		# Try to match a suffix
		for category in suffixes:
			if category in used_suffix_categories:
				continue  # Skip if category already used
				
			for suffix in suffixes[category]:
				if remaining_text.begins_with(suffix):
					detected_suffixes.append(suffix)
					suffix_detected.emit(suffix)
					emit_signal("suffix_detected", suffix)
					used_suffix_categories[category] = true
					remaining_text = remaining_text.substr(suffix.length())
					suffix_found = true
					break
			
			if suffix_found:
				break
		
		if not suffix_found:
			return false  # Unknown component found
		
		# If we've processed all remaining text, break the loop
		if remaining_text.length() == 0:
			break
	
	# All text should be consumed by valid components
	if remaining_text.length() > 0:
		return false
	
	# Highlight all components at once
	var spell_container: FlowContainer = $"../SpellContainer"
	spell_container.highlight_valid_spell_components(detected_prefixes, detected_root, detected_suffixes)
	
	return true

func _on_text_changed(new_text: String) -> void:
	# Only allow a-zA-Z characters
	var regex = RegEx.new()
	regex.compile("[^a-zA-Z]")
	spellword = regex.sub(new_text, "", true).strip_edges()
	
	# If the cleaned text is different from input, update the LineEdit
	if spellword != new_text:
		text = spellword
		set_caret_column(spellword.length())
	
	# Convert to lowercase for consistent validation
	var lowercase_spell = spellword.to_lower()
	
	if is_valid_spell(lowercase_spell):
		valid_spellword.emit(spellword)
	else:
		invalid_spellword.emit(spellword)
		spellword = ''
		
# Optional: Add this function to restrict input characters in real-time
func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSPACE or event.keycode == KEY_DELETE:
			return
		
		var typed_char = char(event.unicode)
		if not typed_char.to_lower().is_valid_identifier():
			get_viewport().set_input_as_handled()

func _ready():
	var player_node = get_node("../..")
	player_node.connect("conjuring_started", _on_conjure_start)
	player_node.connect("conjuring_ended", _on_conjure_end)
	line_edit.visible = false
