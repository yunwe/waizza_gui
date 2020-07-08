-- Waizza Gui - Sample GUI Implimentation
--
-- Sample table for button config (name of the sprites at different button state)
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

local M = {
	[hash("btn")] = {
		normal = "button_01",
		hover = "button_02",
		pressed = "button_03",
		disabled = "button_04"
	},
	[hash("input")] = {
		normal = "input_01",
		focus = "input_02"
	}
}

return M