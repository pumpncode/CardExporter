local function process_sticker(center)
	local item = {}
	output_image(center)
	item.name = localize { type = 'name_text', set = 'Other', key = center.key }
	local loc_vars = nil
	if item.key == 'banana' then
		loc_vars = { G.GAME.probabilities.normal or 1, 10 }
	elseif item.key == "perishable" then
		loc_vars = { G.GAME.perishable_rounds or 1, G.GAME.perishable_rounds }
	elseif item.key == "pinned" then
		loc_vars = { key = "cry_pinned_consumeable" }
	elseif item.key == "eternal" then
		loc_vars = { key = "cry_eternal_voucher" }
	elseif item.key == "rental" then
		loc_vars = { G.GAME.rental_rate or 1 }
	elseif center.loc_vars and type(center.loc_vars) == 'function' then
		--local res = center:loc_vars() or {}
		--loc_vars = res.vars or {}
	end
	item.description = localize { type = 'raw_descriptions', key = center.key, set = "Other", nodes = {}, vars = loc_vars }
	item.key = center.key
	item.set = "Sticker"
	if center.mod then
		item.mod = center.mod.id
	end
	item.tags = {}
	item.image_url = CheckForOverride("images/" .. center.key:gsub("?", "_") .. ".png")
	if item.name then
		sets["Sticker"][item.key] = item
		print(tprint(item))
	end
end
