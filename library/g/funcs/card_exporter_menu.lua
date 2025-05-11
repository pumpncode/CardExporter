local function config_export_tab()
	return {
		n = G.UIT.ROOT,
		config = {
			emboss = 0.05,
			minh = 6,
			r = 0.1,
			minw = 10,
			align = "cm",
			padding = 0.2,
			colour = G.C.BLACK
		},
		nodes = {
			UIBox_button({ label = { "Export Cards" }, button = "create_output", colour = G.C.ORANGE, minw = 5, minh = 0.7, scale = 0.6 }),
			--UIBox_button({label = {"Test Shader"}, button = "test_shader", colour = G.C.ORANGE, minw = 5, minh = 0.7, scale = 0.6}),
			{
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					create_text_input({
						colour = G.C.RED,
						hooked_colour = darken(copy_table(G.C.RED), 0.3),
						w = 4.5,
						h = 1,
						max_length = 100,
						extended_corpus = true,
						prompt_text = "Mod IDs, 'Balatro' for non-mod objects",
						ref_table = G,
						ref_value = "EXPORT_FILTER",
						keyboard_offset = 1,
					}),
				},
			}, --textbox
		},
	}
end

G.FUNCS.CardExporter_Menu = function(e)
	local tabs = create_tabs({
		snap_to_nav = true,
		tabs = {
			{
				chosen = true,
				tab_definition_function = function()
					return config_export_tab()
				end
			},
		}
	})
	G.FUNCS.overlay_menu {
		definition = create_UIBox_generic_options({
			back_func = "options",
			contents = { tabs }
		}),
		config = { offset = { x = 0, y = 10 } }
	}
end
