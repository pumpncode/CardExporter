local check_for_override = SMODS.load_file("library/_common/check_for_override.lua")()
local output_image = SMODS.load_file("library/_common/output_image.lua")()

local function process_blind(sets, blind)
	local item = {}
	output_image(blind)
	if not sets["Blind"] then
		sets["Blind"] = {}
	end
	if not sets["Blind"][blind.key] then
		item.key = blind.key
		item.name = localize { type = 'name_text', key = blind.key, set = 'Blind' }

		local loc_vars = nil
		if item.name == 'The Ox' then
			loc_vars = { localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands') }
		end
		if blind.loc_vars and type(blind.loc_vars) == 'function' then
			local res = blind:loc_vars() or {}
			loc_vars = res.vars or {}
		end
		item.description = localize { type = 'raw_descriptions', key = blind.key, set = 'Blind', vars = loc_vars or blind.vars }

		if blind.mod and blind.mod.id ~= "Aura" and blind.mod.id ~= "aure_spectral" then
			item.mod = blind.mod.id
		end
		item.tags = {}
		item.image_url = check_for_override("images/" .. blind.key:gsub("?", "_") .. ".png")
		if item.name then
			sets["Blind"][item.key] = item
		end
	end
end

return process_blind
