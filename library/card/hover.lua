local process_card = SMODS.load_file("library/_common/process_card.lua")()

local output_on_hover = false

local card_hover_ref = Card.hover
Card.hover = function(self)
	card_hover_ref(self)

	if output_on_hover == true then
		process_card(sets, self)
	end
end
