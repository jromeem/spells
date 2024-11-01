extends LineEdit

var isConjuring = false
var allowed_characters = "[A-Za-z]"
@onready var line_edit: LineEdit = $"."
@export var spellword = ''
@onready var rich_text_label: RichTextLabel = $"../RichTextLabel"

signal invalid_spellword
signal valid_spellword
signal prefix_detected(prefix)
signal root_detected(root)
signal suffix_detected(suffix)

func _on_conjure_start():
	isConjuring = !isConjuring
	line_edit.visible = true
	line_edit.grab_focus()

func _on_conjure_end():
	isConjuring = !isConjuring
	rich_text_label.text = spellword
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
func begins_with_at_index(str: String, substring: String, index: int) -> bool:
	if index < 0 or index >= str.length():
		return false  # Index out of bounds
	return str.substr(index, substring.length()) == substring

func is_valid_spell(spellword: String) -> bool:
	var components = []
	var all_prefixes = flatten_array(prefixes.values())
	var all_suffixes = flatten_array(suffixes.values())
	var used_prefix_categories = {}
	var used_suffix_categories = {}

	# Collect all valid prefixes (one per category)
	var detected_prefixes = []
	for category in prefixes:
		for prefix in prefixes[category]:
			if spellword.begins_with(prefix) and category not in used_prefix_categories:
				components.append(prefix)
				detected_prefixes.append(prefix)
				emit_signal("prefix_detected", prefix)
				spellword = spellword.substr(prefix.length(), spellword.length() - prefix.length())
				used_prefix_categories[category] = true
				break  # Move to the next category

	# Find and extract the root in the remaining string
	var root_found = ""
	for root in roots:
		if spellword.begins_with(root):
			root_found = root
			components.append(root)
			emit_signal("root_detected", root)
			spellword = spellword.substr(root.length(), spellword.length() - root.length())
			break

	if root_found == "":
		return false  # No valid root found

	# Collect all valid suffixes (one per category) in the correct order
	var detected_suffixes = []
	var remaining_spellword = spellword  # Keep track of the remaining spellword for suffix parsing

	# Iterate from left to right to detect suffixes
	var i = 0
	while i < remaining_spellword.length():
		var matched_suffix = false  # Flag to indicate if a suffix was matched
		for category in suffixes:
			for suffix in suffixes[category]:
				# Use the custom function to check if the substring starts at index `i`
				if begins_with_at_index(remaining_spellword, suffix, i) and category not in used_suffix_categories:
					components.append(suffix)
					detected_suffixes.append(suffix)
					emit_signal("suffix_detected", suffix)
					used_suffix_categories[category] = true
					i += suffix.length()  # Move index forward by the length of the matched suffix
					matched_suffix = true  # Set the flag to true
					break  # Break out of the inner loop once a match is found
			if matched_suffix:
				break  # Break out of the category loop if a match is found
		if not matched_suffix:
			i += 1  # Move to the next character if no suffix is matched

	# Ensure the `spellword` is emptied properly after suffix parsing
	if i == remaining_spellword.length():
		spellword = ""  # Mark spellword as fully parsed

	# Ensure the spellword is fully parsed with no leftover text
	if spellword != "":
		return false

	# Emit a signal to highlight all components at once
	var spell_container: FlowContainer = $"../SpellContainer"
	
	spell_container.highlight_valid_spell_components(detected_prefixes, root_found, detected_suffixes)

	return true

func _on_text_changed(new_text: String) -> void:
	spellword = new_text.strip_edges()
	if is_valid_spell(spellword):
		rich_text_label.text = "Valid Spell: " + spellword
	else:
		invalid_spellword.emit()
		rich_text_label.text = "Invalid Spell"

func _ready():
	var conjuring = get_node("../../Conjuring/AnimatedSprite2D")
	conjuring.connect("conjuring_started", _on_conjure_start)
	conjuring.connect("conjuring_ended", _on_conjure_end)
	line_edit.visible = false
