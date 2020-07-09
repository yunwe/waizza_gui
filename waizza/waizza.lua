-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

--- User Interface module 
-- @module M

local Root = require('waizza.internal.root')
local Button = require('waizza.internal.button')
local Input = require('waizza.internal.input')


local M = {}
M.button = Button
M.input = Input

function M.on_input(ui, action_id, action)
	Root.on_input(ui, action_id, action)
end

return M