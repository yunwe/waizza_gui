-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

--- Input module
-- @module M
local root = require('waizza.internal.root')
local TYPE_OF = 'input' -- constant

local M = root:new()

----------------------------------------------------------------------------------------------------
-- Private interface
----------------------------------------------------------------------------------------------------
local function path(id, part)
	local mid = string.format('%s/%s', id, part)
	return hash(mid)
end

-- calculate text width with font with respect to trailing space
local function get_text_width(node, text)
	local font = gui.get_font(node)
	local scale = gui.get_scale(node)
	local text_width = gui.get_text_metrics(font, text .. '.', 0, false, 0, 0).width
	local dot_width = gui.get_text_metrics(font, '.', 0, false, 0, 0).width
	
	return (text_width - dot_width) * scale.x
end

local function get_node(id)
	local node = {}
	node.root = gui.get_node(path(id, 'input'))
	node.cursor = gui.get_node(path(id, 'cursor'))
	node.cursor_color = gui.get_color(node.cursor)
	node.placeholder = gui.get_node(path(id, 'placeholder'))
	node.text = gui.get_node(path(id, 'text'))
	return node
end

local function cursor_on(o)
	local transparent = vmath.vector4(0, 0, 0, 0)
	local cursor = o.node_table.cursor
	gui.set_enabled(cursor, true)
	gui.set_color(cursor, o.node_table.cursor_color)
	gui.animate(cursor, gui.PROP_COLOR, transparent, gui.EASING_LINEAR, 0.5, 0.3, nil, gui.PLAYBACK_LOOP_PINGPONG)
end

local function cursor_off(o)
	local cursor = o.node_table.cursor
	gui.set_enabled(cursor, false)
	gui.cancel_animation(cursor, gui.PROP_COLOR)
end

local function set_cursor_pos(o, pos)
	pos = pos or 0
	local cursor = o.node_table.cursor
	local text_node = o.node_table.text
	
	local text_len = o.text:len()
	if pos < 0 or pos > text_len then
		return
	end 

	o.cursor_pos = pos
	local x_pos = get_text_width(text_node, string.sub(o.text, 1, pos)) + o.config.padding
	gui.set_position(cursor, vmath.vector3(x_pos, 0, 0))
end

local function pick_node(ui, action)
	return root.pick_node(ui, TYPE_OF, action)
end

local function type_char(ui, char)
	local o = root.get_active(ui)
	if o and o.typeof == TYPE_OF then
		local s1 = o.text:sub(1, o.cursor_pos)
		local s2 = o.text:sub(o.cursor_pos+1)
		
		o:set_text(s1 .. char .. s2)
		set_cursor_pos(o, o.cursor_pos + 1)
	end
end

local function delete_char(ui)
	local o = root.get_active(ui)
	if o and o.typeof == TYPE_OF then
		if o.cursor_pos <= 0 then
			return
		end 
		
		local s1 = o.text:sub(1, o.cursor_pos - 1)
		local s2 = o.text:sub(o.cursor_pos + 1)
		
		o:set_text(s1 .. s2)
		set_cursor_pos(o, o.cursor_pos - 1)
	end
end

local function move_cursor(ui, amount)
	local o = root.get_active(ui)
	if o and o.typeof == TYPE_OF then
		set_cursor_pos(o, o.cursor_pos + amount)
	end
end
	
local function remove_active(ui)
	local o = root.get_active(ui)
	if o and o.typeof == TYPE_OF then
		root.remove_active(ui)
		o:remove_focus()
	end
end

--- Button input handler
-- @tparam string gui Root GUI Name
-- @tparam table node GUI Node
-- @tparam hash action_id Action ID
-- @tparam table action Action table
local function on_input(ui, action_id, action)
	--[[Checking button click --]]
	if action_id == hash("touch") and action.pressed 
	then
		remove_active(ui)
		local node = pick_node(ui, action)
		if node then
			node:focus()
		end
	end

	--[[Checking text type --]]
	if action_id == hash("text") then
		type_char(ui, action.text)
	end

	if action_id == hash("backspace") and action.pressed
	then
		delete_char(ui)
	end
	if action_id == hash("left") and action.pressed
	then
		move_cursor(ui, -1)
	end
	if action_id == hash("right") and action.pressed
	then
		move_cursor(ui, 1)
	end
end

----------------------------------------------------------------------------------------------------
-- Public interface
----------------------------------------------------------------------------------------------------


--- Input Constructor
-- @tparam string id Input ID must be identical with Node ID
-- @tparam string uiname Root GUI Name
-- @param table config Config table for input background sprites    
-- @param number layer Input with larger layer number get pick node if two or more button is in the same pixel point
-- @param bool setfocus set auto focus
function M:new (id, uiname, keyboard, config, placeholder, layer, setfocus)
	local o = {}

	assert(id, "Input id is not defined")
	assert(uiname, "Name of the GUI that the input attached need to be defined")
	
	setmetatable(o, self)
	self.__index = self
	
	
	o.id = id
	o.gui = uiname
	o.keyboard = keyboard or gui.KEYBOARD_TYPE_DEFAULT
	o.config = config
	o.placeholder = placeholder or nil
	o.layer = layer or 0
	o.isfocus = setfocus or false
	o.text = ""
	o.cursor_pos = 0
	o.node_table = get_node(id)
	o.node = o.node_table.root
	o:clear()

	o:register(TYPE_OF, on_input)
	return o
end

function M:clear()
	local node = self.node_table
	
	self:set_text('')
	self:play_sprite("normal")
	
	--reset cursor
	set_cursor_pos(self, 0)
	cursor_off(self)
end

function M:focus()
	root.set_active(self)
	
	self.isfocus = true
	local node = self.node_table
	
	gui.set_enabled(node.placeholder, false)
	
	cursor_on(self)
	self:play_sprite("focus")

	gui.reset_keyboard()
	gui.show_keyboard(self.keyboard, true)
end

function M:remove_focus()
	self.isfocus = false
	local node = self.node_table

	gui.set_enabled(node.placeholder, self.text == '')
	cursor_off(self)
	self:play_sprite("normal")

	gui.hide_keyboard()
end

function M:set_text(text)
	self.text = text
	local node = self.node_table

	gui.set_enabled(node.placeholder, text:len() <= 0)
	gui.set_text(node.text, self.text)
end

return M

