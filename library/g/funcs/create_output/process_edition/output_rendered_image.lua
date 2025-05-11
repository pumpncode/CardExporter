local output_root = SMODS.load_file("library/_common/output_root.lua")()

local function output_rendered_image(card)
	local file_path = output_root .. "images/" .. card.config.center.key:gsub("?", "_") .. ".png"
	local w = 71 * G.SETTINGS.GRAPHICS.texture_scaling
	local h = 95 * G.SETTINGS.GRAPHICS.texture_scaling

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

	love.graphics.setShader()
	love.graphics.setCanvas(oldCanvas)
	love.graphics.pop()

	if love.filesystem.getInfo(file_path) then
		love.filesystem.remove(file_path)
	end
	canvas:newImageData():encode('png', file_path)
end

return output_rendered_image
