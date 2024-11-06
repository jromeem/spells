extends FlowContainer

# Highlight the corresponding glyphs based on the detected components
func highlight_all_components(components: Array):
	# Reset all highlights first to ensure a clean start
	reset_highlights()
	
	# Iterate through each component and highlight the corresponding glyph
	for component in components:
		for category_container in get_children():
			for glyph in category_container.get_children():
				if glyph.name.to_lower() == component:
					glyph.color = Color("#b51666df")  # Highlight color
					break  # Stop searching for this component once found

# Reset all glyphs to their default state
func reset_highlights():
	for category_container in get_children():
		for glyph in category_container.get_children():
			glyph.color = Color("#7e5e43a5")  # Reset to original color

# Modified functions to collect components and call highlight_all_components
func _on_prefix_detected(_prefix):
	pass
	
func _on_root_detected(_root):
	pass

func _on_suffix_detected(_suffix):
	pass

func _on_invalid_spellword(spellword) -> void:
	#print('invalid spell!', spellword)
	reset_highlights()

func _on_valid_spellword(spellword) -> void:
	print('valid spell! ', spellword)
	pass

# Collects and highlights all components together for a single valid spellword
func highlight_valid_spell_components(prefixes: Array, root: String, suffixes: Array):
	var all_components = prefixes + [root] + suffixes
	#print('allcompo', all_components)
	highlight_all_components(all_components)
