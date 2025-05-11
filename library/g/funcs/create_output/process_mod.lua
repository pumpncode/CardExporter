local convert_to_hex = SMODS.load_file("library/_common/convert_to_hex.lua")()

local function process_mod(sets, mod)
	local item = {}
	item.name = mod.display_name
	item.id = mod.id
	item.description = mod.description
	item.badge_colour = convert_to_hex(mod.badge_colour)
	if item.name then
		sets["Mods"][item.id] = item
	end
end

return process_mod
