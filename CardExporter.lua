--- STEAMODDED HEADER
--- MOD_NAME: Card Exporter
--- MOD_ID: CardExporter
--- MOD_AUTHOR: [elbe]
--- MOD_DESCRIPTION: Exports cards for external use
--- PRIORITY: 0
---
SMODS.load_file("ca.lua")() --third party json library

SMODS.load_file("library/g/funcs/create_output.lua")()
SMODS.load_file("library/g/funcs/card_exporter_menu.lua")()
SMODS.load_file("library/g/funcs/test_shader.lua")()
SMODS.load_file("library/card/hover.lua")()

local createOptionsRef = create_UIBox_options
function create_UIBox_options()
	G.EXPORT_FILTER = ""
	local contents = createOptionsRef()
	if G.STAGE == G.STAGES.RUN then
		local m = UIBox_button({
			minw = 5,
			button = "CardExporter_Menu",
			label = { "Card Exporter" },
			colour = G.C.SO_1.SPADES,
		})
		table.insert(contents.nodes[1].nodes[1].nodes[1].nodes, #contents.nodes[1].nodes[1].nodes[1].nodes + 1, m)
	end
	return contents
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

-------------------------------------------------
------------MOD CODE END-------------------------
