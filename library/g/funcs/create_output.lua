local json = require "json"
local process_card = SMODS.load_file("library/_common/process_card.lua")()
local sets = SMODS.load_file("library/_common/sets.lua")()
local output_root = SMODS.load_file("library/_common/output_root.lua")()

local exports = SMODS.load_file("library/g/funcs/create_output/_exports.lua")()
local filter_list_from_string = exports.filter_list_from_string
local process_edition = exports.process_edition
local process_enhancement = exports.process_enhancement
local process_blind = exports.process_blind
local process_curse = exports.process_curse
local process_d6_side = exports.process_d6_side
local process_seal = exports.process_seal
local process_stake = exports.process_stake
local process_tag = exports.process_tag
local process_playing_card = exports.process_playing_card
local process_suit = exports.process_suit
local process_mod = exports.process_mod

local copy_command = 'cp -R "Mods/CardExporter/Template/." "' .. output_root .. '"' -- macOS version

local function copy_template()
	os.execute(copy_command)
end

G.FUNCS.create_output = function(e)
	local mod_filter = filter_list_from_string(G.EXPORT_FILTER or "")
	local clean_filter = {}
	print(tprint(mod_filter))
	if #mod_filter == 1 and mod_filter[1] == "" then
		table.insert(clean_filter, "Balatro")
		for k, _ in pairs(SMODS.Mods) do
			table.insert(clean_filter, k)
		end
	else
		for _, v in ipairs(mod_filter) do
			if v == "Balatro" then
				table.insert(clean_filter, "Balatro")
			end
			if SMODS.Mods[v] then
				table.insert(clean_filter, v)
			end
		end
	end

	local card = nil
	if not love.filesystem.getInfo(output_root) then
		love.filesystem.createDirectory(output_root)
	end
	if not love.filesystem.getInfo(output_root .. "images") then
		love.filesystem.createDirectory(output_root .. "images")
	end

	for k, v in pairs(G.P_CENTERS) do
		if not v.mod then
			v.mod = {}
			v.mod.id = "Balatro"
		end
		if table.contains(clean_filter, v.mod.id) then
			print("Processing " .. k .. " | " .. tostring(v.set))
			v.unlocked = true
			v.discovered = true
			if v.set == "Edition" then
				card = Card(G.jokers.T.x + G.jokers.T.w / 2, G.jokers.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, v)
				card:set_edition(v.key, true, true)
				card:hover()
				process_edition(sets, card)
			elseif v.set == "Enhanced" then
				-- card = Card(G.jokers.T.x + G.jokers.T.w / 2, G.jokers.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, v)
				-- card:set_ability(v, true, true)
				-- card:hover()
				-- process_enhancement(card)
			elseif v.set == "Sticker" then
				card = create_card("Default", G.jokers, nil, nil, nil, nil, "c_base", nil)
				card:set_sticker(v, true, true)
				card:hover()
			elseif not v.set or v.set == "Other" or v.set == "Default" or v.set == "Back" then
			elseif not v.no_collection then
				card = create_card(v.set, G.jokers, v.legendary, v.rarity, nil, nil, v.key, nil)
				card = SMODS.create_card({
					set = v.set,
					area = G.jokers,
					skip_materialize = true,
					legendary = v.legendary,
					rarity = v.rarity,
					key = v.key
				})
				card:hover()
				process_card(sets, card)
			end
			if card then
				card:stop_hover()
				G.jokers:remove_card(card)
				card:remove()
			end
			card = nil
		end
	end

	for k, v in pairs(G.P_BLINDS) do
		if not v.mod then
			v.mod = {}
			v.mod.id = "Balatro"
		end
		if table.contains(clean_filter, v.mod.id) then
			print("Processing " .. k .. " | " .. tostring(v.set))
			v.discovered = true
			process_blind(sets, v)
		end
	end

	if G.P_CURSES then
		for k, v in pairs(G.P_CURSES) do
			if not v.mod then
				v.mod = {}
				v.mod.id = "Balatro"
			end
			if table.contains(clean_filter, v.mod.id) then
				print("Processing " .. k .. " | " .. tostring(v.set))
				v.discovered = true
				process_curse(sets, v)
			end
		end
	end

	if G.P_D6_SIDES then
		for k, v in pairs(G.P_D6_SIDES) do
			if not v.mod then
				v.mod = {}
				v.mod.id = "Balatro"
			end
			if table.contains(clean_filter, v.mod.id) then
				print("Processing " .. k .. " | " .. tostring(v.set))
				process_d6_side(sets, v)
			end
		end
	end

	for k, v in pairs(G.P_SEALS) do
		if not v.mod then
			v.mod = {}
			v.mod.id = "Balatro"
		end
		if table.contains(clean_filter, v.mod.id) then
			print("Processing " .. k .. " | " .. tostring(v.set))
			v.discovered = true
			card = create_card("Default", G.jokers, nil, nil, nil, nil, "c_base", nil)
			card:set_seal(v.key, true)
			card:hover()
			process_seal(sets, card, v)
			if card then
				card:stop_hover()
				G.jokers:remove_card(card)
				card:remove()
			end
			card = nil
		end
	end

	if G.P_SKILLS then
		for k, v in pairs(G.P_SKILLS) do
			if not v.mod then
				v.mod = {}
				v.mod.id = "Balatro"
			end
			if table.contains(clean_filter, v.mod.id) then
				print("Processing " .. k .. " | " .. tostring(v.set))
				v.discovered = true
				card = Card(G.jokers.T.x + G.jokers.T.w / 2, G.jokers.T.y, G.CARD_W, G.CARD_H, nil, v,
					{ bypass_discovery_center = true })
				card:hover()
				process_card(sets, card)
				if card then
					card:stop_hover()
					G.jokers:remove_card(card)
					card:remove()
				end
				card = nil
			end
		end
	end

	for k, v in pairs(G.P_STAKES) do
		if not v.mod then
			v.mod = {}
			v.mod.id = "Balatro"
		end
		if table.contains(clean_filter, v.mod.id) then
			print("Processing " .. k .. " | " .. tostring(v.set))
			v.discovered = true
			process_stake(sets, v)
		end
	end

	for k, v in pairs(SMODS.Stickers) do
		--if table.contains(clean_filter, v.mod.id) then
		--print("Processing " .. k .. " | " .. tostring(v.set))
		--v.discovered = true
		--process_sticker(v)
		--end
	end

	for k, v in pairs(G.P_TAGS) do
		if not v.mod then
			v.mod = {}
			v.mod.id = "Balatro"
		end
		if table.contains(clean_filter, v.mod.id) then
			print("Processing " .. k .. " | " .. tostring(v.set))
			v.discovered = true
			local temp_tag = Tag(v.key, true)
			local _, temp_tag_sprite = temp_tag:generate_UI()
			temp_tag_sprite:hover()
			process_tag(sets, temp_tag)
			temp_tag_sprite:stop_hover()
			temp_tag_sprite:remove()
			temp_tag = nil
		end
	end

	for k, v in pairs(G.P_CARDS) do
		if not v.mod then
			v.mod = {}
			v.mod.id = "Balatro"
		end
		if table.contains(clean_filter, v.mod.id) then
			print("Processing " .. k .. " | " .. tostring(v.suit))
			card = create_playing_card({ front = G.P_CARDS[k] }, G.hand, true, true, { G.C.SECONDARY_SET.Spectral })
			card:hover()
			process_playing_card(sets, card, v, k)
			if card then
				card:stop_hover()
				G.jokers:remove_card(card)
				card:remove()
			end
		end
	end

	for k, v in pairs(SMODS.Suits) do
		if not v.mod then
			v.mod = {}
			v.mod.id = "Balatro"
		end
		if table.contains(clean_filter, v.mod.id) then
			print("Processing " .. k .. " | " .. tostring(v.key))
			process_suit(sets, v)
		end
	end

	local base_mod = {
		display_name = "Balatro",
		id = "Balatro",
		badge_colour = G.C.RED
	}
	process_mod(sets, base_mod)

	for k, v in pairs(SMODS.Mods) do
		if table.contains(clean_filter, k) then
			print("Processing " .. k .. " | " .. tostring(v.name))
			process_mod(sets, v)
		end
	end

	local output = json.encode(sets)
	if love.filesystem.getInfo(output_root .. "cards.js") then
		love.filesystem.remove(output_root .. "cards.js")
	end
	love.filesystem.write(output_root .. "cards.js", "cards = " .. output:gsub("'", "\\'")) --outputting to js file/object to get around browser security annoyances
	copy_template()
	print("complete")
end
