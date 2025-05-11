return {
	process_card = SMODS.load_file("./process_card.lua")(),
	sets = SMODS.load_file("./sets.lua")(),
	get_name_from_table = SMODS.load_file("./get_name_from_table.lua")(),
	get_desc_from_table = SMODS.load_file("./get_desc_from_table.lua")(),
	convert_to_hex = SMODS.load_file("./convert_to_hex.lua")(),
	check_for_override = SMODS.load_file("./check_for_override.lua")(),
	output_image = SMODS.load_file("./output_image.lua")(),
	output_root = SMODS.load_file("./output_root.lua")(),
}
