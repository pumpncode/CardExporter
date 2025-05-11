G.FUNCS.test_shader = function(e)
	local w = 71 * G.SETTINGS.GRAPHICS.texture_scaling
	local h = 95 * G.SETTINGS.GRAPHICS.texture_scaling
	local card = G.jokers.cards[1]

	local canvas = love.graphics.newCanvas(w, h, { type = '2d', readable = true })
	love.graphics.push()
	local oldCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(canvas)

	love.graphics.clear(0, 0, 0, 0)
	love.graphics.setColor(1, 1, 1, 1)

	if card.edition and card.edition.type and G.SHADERS[card.edition.type] then
		love.graphics.setShader(G.SHADERS[card.edition.type])
	else
		if card.edition then
			local edition_key = card.edition.key
			if edition_key and SMODS.Centers[edition_key] and G.SHADERS[SMODS.Centers[edition_key].shader] then
				love.graphics.setShader(G.SHADERS[SMODS.Centers[edition_key].shader])
			end
		end
	end
	love.graphics.draw(
		card.children.center.atlas.image,
		card.children.center.sprite,
		0, 0, 0, 2, 2
	)

	--love.graphics.setShader()
	-- love.graphics.setCanvas(oldCanvas)
	-- love.graphics.pop()
end
