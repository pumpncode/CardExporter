local output_root = SMODS.load_file("library/_common/output_root.lua")() -- Put your Lua here
local timer
local function draw_sprite_single(card, sprite, shader, canvas, shadername, _shadow_height)
	love.graphics.push()
	shader = shader or G.SHADERS.dissolve
	shadername = shadername or "dissolve"
	local spriteargs = sprite.ARGS or {}
	local _draw_major = sprite.role.draw_major or sprite
	local args = card.ARGS or {}
	local prep = spriteargs.prep_shader or {}
	if _shadow_height then
		sprite.VT.y = sprite.VT.y - _draw_major.shadow_parrallax.y * _shadow_height
		sprite.VT.x = sprite.VT.x - _draw_major.shadow_parrallax.x * _shadow_height
		sprite.VT.scale = sprite.VT.scale * (1 - 0.2 * _shadow_height)
	end

	args.send_to_shader = args.send_to_shader or nil
	prep.cursor_pos = prep.cursor_pos or {}
	prep.cursor_pos[1] = _draw_major.tilt_var and _draw_major.tilt_var.mx * G.CANV_SCALE or
		0 * G.CANV_SCALE
	prep.cursor_pos[2] = _draw_major.tilt_var and _draw_major.tilt_var.my * G.CANV_SCALE or
		0 * G.CANV_SCALE
	if shader == G.SHADERS.vortex then
		shader:send('vortex_amt', G.TIMERS.REAL - (G.vortex_time or 0))
	else
		shader:send('screen_scale', G.TILESCALE * G.TILESIZE * (_draw_major.mouse_damping or 1) * G.CANV_SCALE)
		shader:send('hovering', ((_shadow_height) or true and 0 or (_draw_major.hover_tilt or 0) * (1)))
		shader:send("dissolve", math.abs(_draw_major.dissolve or 0))
		shader:send("time", 123.33412 * (_draw_major.ID / 1.14212 or 12.5123152) % 3000)
		shader:send("texture_details", sprite:get_pos_pixel())
		shader:send("image_details", sprite:get_image_dims())
		shader:send("burn_colour_1", _draw_major.dissolve_colours and _draw_major.dissolve_colours[1] or G.C.CLEAR)
		shader:send("burn_colour_2", _draw_major.dissolve_colours and _draw_major.dissolve_colours[2] or G.C.CLEAR)
		shader:send("shadow", not not _shadow_height)
		if type(args.send_to_shader) == 'table' and args.send_to_shader.betmma == true then
			for k, v in ipairs(args.send_to_shader.extra) do
				shader:send(v.name, v.val or (v.func and v.func()) or v.ref_table[v.ref_value])
			end

			args.send_to_shader = nil
		end

		if shadername == 'tentacle' then shader:send("real_time", G.TIMERS.REAL - (G.vortex_time or 0)) end
		if args and args.send_to_shader and shader ~= G.SHADERS.dissolve then
			shader:send(
				SMODS.Shaders[shadername] and
				(SMODS.Shaders[shadername].original_key or SMODS.Shaders[shadername].path:gsub(".fs", "")) or shadername,
				args.send_to_shader)
		end
	end

	local p_shader = SMODS.Shader.obj_table[shadername]
	if p_shader and type(p_shader.send_vars) == "function" then
		local sh = G.SHADERS[shadername]
		local parent_card = sprite.role.major and sprite.role.major:is(Card) and sprite.role.major
		local send_vars = p_shader.send_vars(sprite, parent_card)
		if type(send_vars) == "table" then
			for key, value in pairs(send_vars) do
				sh:send(key, value)
			end
		end
	end

	love.graphics.setShader(shader, shader)
	love.graphics.push()
	if sprite.sprite_pos.x ~= sprite.sprite_pos_copy.x or sprite.sprite_pos.y ~= sprite.sprite_pos_copy.y then
		sprite
			:set_sprite_pos(sprite.sprite_pos)
	end


	love.graphics.setColor(overlay or G.BRUTE_OVERLAY or G.C.WHITE)
	love.graphics.pop()
	love.graphics.draw(sprite.atlas.image, sprite.sprite, 0, 0, 0, 2, 2)
	sprite.under_overlay = G.under_overlay
	love.graphics.pop()
	love.graphics.setShader()
	if _shadow_height then
		sprite.VT.y = sprite.VT.y + _draw_major.shadow_parrallax.y * _shadow_height
		sprite.VT.x = sprite.VT.x + _draw_major.shadow_parrallax.x * _shadow_height
		sprite.VT.scale = sprite.VT.scale / (1 - 0.2 * _shadow_height)
	end
	return canvas, shader, shadername
end

local function draw_sprite(card, sprite, shader, canvas, shadername, _shadow_height)
	if not sprite.states.visible then return end
	if sprite.draw_steps then
		for k, v in ipairs(sprite.draw_steps) do
			if sprite:is(Sprite) and v.shader then
				draw_sprite_single(card, sprite, G.SHADERS[v.shader] or nil, canvas,
					v.shader or nil, v.shadow_height)
			end
		end
	elseif sprite:is(Sprite) then
		draw_sprite_single(card, sprite, shader, canvas, shadername, _shadow_height)
	end

	for k, v in pairs(sprite.children) do
		if k ~= 'h_popup' and v:is(Sprite) then
			draw_sprite_single(card, v, G.SHADERS[v.shader] or shader, canvas,
				v.shader or shadername, _shadow_height)
		end
	end

	sprite.under_overlay = G.under_overlay
end

local function output_rendered_image(card)
	timer = 0
	local file_path_old = output_root .. "images/" .. card.config.center.key:gsub("?", "_") .. ".png"
	love.filesystem.createDirectory(output_root .. "images/" .. card.config.center.key:gsub("?", "_"))
	local exportcanvas


	for countdown = 120, 1, -1 do
		card.hovering = true
		card.states.hover.is = true
		G:update(1 / 30)
		G.real_dt = 1 / 30
		card:update(1 / 30)


		card.hover_tilt = 1
		local file_path = output_root ..
			"images/" ..
			card.config.center.key:gsub("?", "_") ..
			"/" .. card.config.center.key:gsub("?", "_") .. (121 - countdown) .. ".png"
		local w = 71 * G.SETTINGS.GRAPHICS.texture_scaling
		local h = 95 * G.SETTINGS.GRAPHICS.texture_scaling
		local canvas = love.graphics.newCanvas(w, h, {
			type = '2d',
			readable = true
		})

		love.graphics.push()
		local oldCanvas = love.graphics.getCanvas()
		love.graphics.setCanvas(canvas)
		local oldshader      = love.graphics.getShader()
		card.tilt_var        = {}

		card.tilt_var        = { mx = 0, my = 0, dx = 0, dy = 0, amt = 0 }
		card.ambient_tilt    = 0.2

		local tilt_factor    = 0.3
		card.states.focus.is = true
		local total_frames   = 120
		local aspect         = 71 / 95
		local t              = (timer % total_frames) / total_frames * 2 * math.pi

		-- Try these for a diagonal, skinny ellipse
		local a              = 0.85           -- horizontal radius
		local b              = 0.92           -- vertical radius
		local theta          = math.pi * 0.21 -- rotation in radians (0=vertical, pi/4=diagonal)

		local x              = a * math.cos(t) * math.cos(theta) - b * math.sin(t) * math.sin(theta)
		local y              = a * math.cos(t) * math.sin(theta) + b * math.sin(t) * math.cos(theta)

		card.hover_offset.x  = x * aspect
		card.hover_offset.y  = y
		if card.states.focus.is then
			card.tilt_var.mx, card.tilt_var.my =
				card.tilt_var.dx * card.T.w * G.TILESCALE * G.TILESIZE,
				card.tilt_var.dy * card.T.h * G.TILESCALE * G.TILESIZE
			card.tilt_var.amt = math.abs(card.hover_offset.y + card.hover_offset.x - 1 + card.tilt_var.dx +
				card.tilt_var.dy -
				1) * tilt_factor
		elseif card.states.hover.is then
			card.tilt_var.mx, card.tilt_var.my = 0, 0
			card.tilt_var.amt = math.abs(card.hover_offset.y + card.hover_offset.x - 1) * tilt_factor
		elseif card.ambient_tilt then
			local tilt_angle = G.TIMERS.REAL * (1.56 + (card.ID / 1.14212) % 1) + card.ID / 1.35122
			card.tilt_var.mx = ((0.5 + 0.5 * card.ambient_tilt * math.cos(tilt_angle)) * card.VT.w + card.VT.x + G.ROOM.T.x) *
				G.TILESIZE * G.TILESCALE
			card.tilt_var.my = ((0.5 + 0.5 * card.ambient_tilt * math.sin(tilt_angle)) * card.VT.h + card.VT.y + G.ROOM.T.y) *
				G.TILESIZE * G.TILESCALE
			card.tilt_var.amt = card.ambient_tilt * (0.5 + math.cos(tilt_angle)) * tilt_factor
		end

		card.ARGS.send_to_shader    = card.ARGS.send_to_shader or {}
		card.ARGS.send_to_shader[1] = math.min(card.VT.r * 3, 1) + G.TIMERS.REAL / 28 +
			0 + card.tilt_var.amt
		card.ARGS.send_to_shader[2] = G.TIMERS.REAL
		for k, v in pairs(card.children) do
			v.VT.scale = card.VT.scale
		end
		local export_steps = {
			shadow = {
				key = "shadow",
				func = function(card)
					card.ARGS.send_to_shader = card.ARGS.send_to_shader or {}
					card.ARGS.send_to_shader[1] = math.min(card.VT.r * 3, 1) + math.sin(G.TIMERS.REAL / 28) + 1 +
						0 + card.tilt_var.amt
					card.ARGS.send_to_shader[2] = G.TIMERS.REAL

					for k, v in pairs(card.children) do
						v.VT.scale = card.VT.scale
					end

					G.shared_shadow = card.sprite_facing == 'front' and card.children.center or card.children.back

					--Draw the shadow
					if not card.no_shadow and G.SETTINGS.GRAPHICS.shadows == 'On' and ((card.ability.effect ~= 'Glass Card' and not card.greyed and card:should_draw_shadow()) and ((card.area and card.area ~= G.discard and card.area.config.type ~= 'deck') or not card.area or card.states.drag.is)) then
						card.shadow_height = 0 * (0.08 + 0.4 * math.sqrt(card.velocity.x ^ 2)) +
							((((card.highlighted and card.area == G.play) or card.states.drag.is) and 0.35) or (card.area and card.area.config.type == 'title_2') and 0.04 or 0.1)
						draw_sprite(card, G.shared_shadow, G.SHADERS.dissolve, canvas, "dissolve", card.shadow_height)
					end
				end
			},
			particles = {
				key = "Particles",
				func = function(card)
					if card.children.particles then
						draw_sprite(card, card.children.particles, G.SHADERS.dissolve, canvas,
							"dissolve")
					end
				end
			},

			center = {
				key = "center",
				func = function(card)
					if (card.edition and card.edition.negative and not card.delay_edition) or (card.ability.name == 'Antimatter' and (card.config.center.discovered or card.bypass_discovery_center)) then
						draw_sprite(card, card.children.center, G.SHADERS.negative, canvas, "negative")
					elseif not card:should_draw_base_shader() then
						-- Don't render base dissolve shader.
					elseif not card.greyed and (get_betmma_shaders and get_betmma_shaders(card)) then
						--do nothing
					elseif not card.greyed then
						draw_sprite(card, card.children.center, G.SHADERS.dissolve,
							canvas, "dissolve")
					end

					if draw_betmma_shaders ~= nil then
						if get_betmma_shaders(card) then
							draw_sprite(card, card.children.center, G.SHADERS[get_betmma_shaders(card)], canvas,
								get_betmma_shaders(card))
							if card.children.front and card.ability.effect ~= 'Stone Card' then
								draw_sprite(card, card.children.front, G.SHADERS[get_betmma_shaders(card)], canvas,
									get_betmma_shaders(card))
							end
						end
					end
					local center = card.config.center
					if center.draw and type(center.draw) == 'function' then
						if center:is(Sprite) then
							draw_sprite(card, center,
								(center.shader and G.SHADERS[center.shader]) or G.SHADERS.dissolve, canvas,
								center.shader or "dissolve")
						end
						for k, v in pairs(center.children) do
							if v:is(Sprite) then
								draw_sprite(card, v, (v.shader and G.SHADERS[v.shader]) or G.SHADERS.dissolve, canvas,
									v.shader or "dissolve")
							end
						end
					end
				end
			},
			front =
			{
				key = "Front",
				func = function(card)
					if (card.edition and card.edition.negative and not card.delay_edition) or (card.ability.name == 'Antimatter' and (card.config.center.discovered or card.bypass_discovery_center)) then
						if card.children.front and (card.ability.delayed or (card.ability.effect ~= 'Stone Card' and not card.config.center.replace_base_card)) then
							draw_sprite(card, card.children.front, G.SHADERS.negative, canvas, "negative")
						end
					else
						if card.children.front and (card.ability.effect ~= 'Stone Card' and not card.config.center.replace_base_card) then
							draw_sprite(card, card.children.front, G.SHADERS.dissolve, canvas, "dissolve")
						end
					end

					if card.edition and not card.delay_edition then
						for k, v in pairs(G.P_CENTER_POOLS.Edition) do
							if card.edition[v.key:sub(3)] and v.shader then
								if type(v.draw) == 'function' then
									draw_sprite(card, v, G.SHADERS[v.shader], canvas, v.shader)
								else
									draw_sprite(card, card.children.center, G.SHADERS[v.shader], canvas, v.shader)
									if card.children.front and card.ability.effect ~= 'Stone Card' and not card.config.center.replace_base_card then
										draw_sprite(card, card.children.front, G.SHADERS[v.shader], canvas, v.shader)
									end
								end
							end
						end
					end
					if (card.edition and card.edition.negative) or (card.ability.name == 'Antimatter' and (card.config.center.discovered or card.bypass_discovery_center)) then
						draw_sprite(card, card.children.center, G.SHADERS.negative_shine, canvas, "negative_shine")
					end
				end
			},
			others = {
				key = "Others",
				func = function(card)
					for k, v in pairs(card.children) do
						if not SMODS.draw_ignore_keys[k] then
							draw_sprite(card, v,
								(v.shader and G.SHADERS[v.shader]) or G.SHADERS.dissolve, canvas, v.shader or "dissolve")
						end
					end
				end
			}
		}

		for _, k in ipairs(SMODS.DrawStep.obj_buffer) do
			if export_steps[k] then
				export_steps[k].func(card)
			end
		end

		card.under_overlay = G.under_overlay
		love.graphics.setCanvas(oldCanvas)
		love.graphics.setShader(oldshader)
		love.graphics.pop()
		if love.filesystem.getInfo(file_path) then love.filesystem.remove(file_path) end
		canvas:newImageData():encode('png', file_path)
		exportcanvas = canvas
		timer = timer + 1
	end
	timer = 0
	exportcanvas:newImageData():encode('png', file_path_old)
	----------------------------------------------------------------------
	--  FFMPEG EXPORT : forward + reverse (“boomerang”) – Per-frame palette GIF, best color, fast
	----------------------------------------------------------------------

	local image_folder  = output_root .. "images/"
		.. card.config.center.key:gsub("?", "_") .. "/"

	local base_name     = card.config.center.key:gsub("?", "_")

	local gif_path      = output_root .. "images/" .. base_name .. "_override.gif"
	local apng_path     = output_root .. "images/" .. base_name .. "_override.apng"
	local webp_path     = output_root .. "images/" .. base_name .. "_override.webp"
	local palette_path  = image_folder .. "palette.png" -- (not used for GIF anymore, but kept for APNG/WebP if needed)

	----------------------------------------------------------------------
	--  PLATFORM ABSTRACTION --------------------------------------------
	----------------------------------------------------------------------
	local IS_WINDOWS    = love.system.getOS():match("Windows")
	local NULL_REDIRECT = IS_WINDOWS and "> $null 2>&1" or "> /dev/null 2>&1"
	local SH_PREFIX     = IS_WINDOWS and "powershell.exe -command " or ""

	local QPATH         = IS_WINDOWS and '"%s"' or "'%s'"
	local QFILT         = IS_WINDOWS and "'%s'" or '"%s"'

	----------------------------------------------------------------------
	--  FFMPEG PRESENCE --------------------------------------------------
	----------------------------------------------------------------------
	local have_ffmpeg   = IS_WINDOWS and
		(os.execute('powershell.exe -command Get-Command ffmpeg '
			.. NULL_REDIRECT) == 0)
		or
		(os.execute('command -v ffmpeg ' .. NULL_REDIRECT) == 0)

	if not have_ffmpeg then
		print("[WARN] ffmpeg is not installed or not in PATH. Please install ffmpeg to enable export.")
		return
	end

	----------------------------------------------------------------------
	--  QUOTED PATHS -----------------------------------------------------
	----------------------------------------------------------------------
	local INPUT_PATTERN    = string.format(QPATH, image_folder .. base_name .. "%d.png")
	local PALETTE_Q        = string.format(QPATH, palette_path)
	local GIF_Q            = string.format(QPATH, gif_path)
	local APNG_Q           = string.format(QPATH, apng_path)
	local WEBP_Q           = string.format(QPATH, webp_path)

	----------------------------------------------------------------------
	--  FILTER GRAPHS ----------------------------------------------------
	--  1) build “boomerang” once with pivot frame removed
	--  2) GIF runs at 30 ms (100/3 fps); APNG/WebP stay at true 30 fps
	----------------------------------------------------------------------

	local boomerang        =
		"[0]split[fwd][tmp];" ..
		"[tmp]reverse,setpts=PTS-STARTPTS,trim=start_frame=1[rev];" ..
		"[fwd][rev]concat=n=2:v=1:a=0,setsar=1"

	-- GIF: per-frame palette, maximal color, dither, "tv static" effect
	local filt_gif         = boomerang ..
		",format=rgba,fps=100/3,split[a][b];" ..
		"[a]palettegen=reserve_transparent=1:stats_mode=single[p];" ..
		"[b][p]paletteuse=dither=bayer:bayer_scale=5:new=1"

	-- APNG / WebP: full RGBA, lossless, best color
	local filt_apng        = boomerang .. ",format=rgba,fps=30"
	local filt_webp        = filt_apng

	----------------------------------------------------------------------
	--  COMMAND STRINGS --------------------------------------------------
	----------------------------------------------------------------------

	local common_enc_flags = "-threads 0 -thread_type slice -vsync 0"

	-- GIF: one-step, per-frame palette, no standalone palette step needed!
	local ffmpeg_gif_cmd   = string.format(
		'%sffmpeg -y %s -f image2 -framerate 30 -i %s '
		.. '-filter_complex %s '
		.. '-gifflags +transdiff '
		.. '-color_primaries bt709 -colorspace bt709 -color_trc bt709 '
		.. '-loop 0 %s %s',
		SH_PREFIX, common_enc_flags, INPUT_PATTERN,
		string.format(QFILT, filt_gif), GIF_Q, NULL_REDIRECT
	)

	-- APNG: truecolor, max compression, lossless
	local ffmpeg_apng_cmd  = string.format(
		'%sffmpeg -y %s -f image2 -framerate 30 -i %s '
		.. '-filter_complex %s '
		.. '-plays 0 -pix_fmt rgba -compression_level 3 -gamma 0.45455 '
		.. '-color_primaries bt709 -colorspace bt709 -color_trc bt709 '
		.. '%s %s',
		SH_PREFIX, common_enc_flags, INPUT_PATTERN,
		string.format(QFILT, filt_apng), APNG_Q, NULL_REDIRECT
	)

	-- WebP: truecolor, lossless, full RGBA (best color)
	local ffmpeg_webp_cmd  = string.format(
		'%sffmpeg -y %s -f image2 -framerate 30 -i %s '
		.. '-filter_complex %s '
		.. '-lossless 1 -compression_level 6 -quality 100 -loop 0 '
		.. '-color_primaries bt709 -colorspace bt709 -color_trc bt709 '
		.. '%s %s',
		SH_PREFIX, common_enc_flags, INPUT_PATTERN,
		string.format(QFILT, filt_webp), WEBP_Q, NULL_REDIRECT
	)

	----------------------------------------------------------------------
	--  EXECUTION --------------------------------------------------------
	----------------------------------------------------------------------
	os.execute(ffmpeg_gif_cmd)  -- 1) GIF export: per-frame palette, best color, "tv static"
	os.execute(ffmpeg_apng_cmd) -- 2) 32-bit RGBA APNG, lossless, best color
	-- os.execute(ffmpeg_webp_cmd)   -- 3) optional lossless WebP, best color
end
return output_rendered_image
