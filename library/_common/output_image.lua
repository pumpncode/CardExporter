local output_root = SMODS.load_file("library/_common/output_root.lua")()

local output_images = true

local function output_image(card)
	if not card.atlas and card.set then
		card.atlas = card.set
	end
	if output_images and G.ASSET_ATLAS and G.ASSET_ATLAS[card.atlas] and not G.ASSET_ATLAS[card.atlas].image_data then
		for _, v in ipairs(G.asset_atli) do
			if v.name == card.set then
				local sprite_path = v.path
				G.ASSET_ATLAS[card.atlas].image_data = love.image.newImageData(sprite_path)
			end
		end
	end
	if output_images and G.ASSET_ATLAS and G.ASSET_ATLAS[card.atlas] and G.ASSET_ATLAS[card.atlas].image_data then
		local file_path = output_root .. "images/" .. card.key:gsub("?", "_") .. ".png"
		local w = (G.ASSET_ATLAS[card.atlas].px * G.SETTINGS.GRAPHICS.texture_scaling)
		local h = (G.ASSET_ATLAS[card.atlas].py * G.SETTINGS.GRAPHICS.texture_scaling)
		local newImageData = love.image.newImageData(w, h)
		local newImageDataSoul = nil
		local newImageDataExtra = nil

		local canvas = love.graphics.newCanvas(w, h, { type = '2d', readable = true })
		newImageData:paste(G.ASSET_ATLAS[card.atlas].image_data, 0, 0, card.pos.x * w, card.pos.y * h, w, h)
		if card.soul_pos then
			if card.soul_pos.extra then
				newImageDataExtra = love.image.newImageData(w, h)
				newImageDataExtra:paste(G.ASSET_ATLAS[card.atlas].image_data, 0, 0, card.soul_pos.extra.x * w,
					card.soul_pos.extra.y * h, w, h)
			end
			newImageDataSoul = love.image.newImageData(w, h)
			newImageDataSoul:paste(G.ASSET_ATLAS[card.atlas].image_data, 0, 0, card.soul_pos.x * w, card.soul_pos.y * h,
				w, h)
		end

		love.graphics.push()
		local prevcanvas = love.graphics.getCanvas()
		love.graphics.setColor(255, 255, 255, 255)
		canvas = love.graphics.newCanvas(w, h)
		love.graphics.setCanvas(canvas)
		love.graphics.draw(love.graphics.newImage(newImageData), 0, 0)
		if newImageDataSoul then
			if newImageDataExtra then
				love.graphics.draw(love.graphics.newImage(newImageDataExtra), 0, 0)
			end
			love.graphics.draw(love.graphics.newImage(newImageDataSoul), 0, 0)
		end
		love.graphics.setCanvas(prevcanvas)
		newImageData = canvas:newImageData()
		love.graphics.pop()

		if love.filesystem.getInfo(file_path) then
			love.filesystem.remove(file_path)
		end
		newImageData:encode("png", file_path)
	end
end

return output_image
