-- Waizza Gui - Sample GUI Implimentation
--
-- Sample table for button config (name of the sprites at different button state)
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

local M = {
	[hash("btn-yellow")] = {
		normal = "yellow_btn_01",
		hover = "yellow_btn_02",
		pressed = "yellow_btn_03",
		disabled = "btn__04"
	},
	[hash("btn-close")] = {
		normal = "close_button_01",
		hover = "close_button_02",
		pressed = "close_button_03",
		disabled = "close_button_04"
	}
}

return M