-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

--- Input module
-- @module M
local M = {}

--- input type constants
M.TYPE_TEXT = hash("text")
--[[	text = ,
	email = hash("email"),
	number = hash("number"),
	password = hash("password")
} --]]

----------------------------------------------------------------------------------------------------
-- Private interface
----------------------------------------------------------------------------------------------------
local function path(id, part)
	local mid = string.format('%s/%s', id, part)
	return hash(mid)
end

local function get_node(id)
	local node = {}
	node.root = gui.get_node(path(id, 'input'))
	node.cursor = gui.get_node(path(id, 'cursor'))
	node.placeholder = gui.get_node(path(id, 'placeholder'))
	node.text = gui.get_node(path(id, 'text'))
	return node
end

local function play_sprite(o, sprite)
	if not o.config then 
		return 
	end
	
	local anim = hash(o.config[sprite])
	gui.play_flipbook(o.node.root, anim)
end

local function cursor_on(o)
	local transparent = vmath.vector4(0, 0, 0, 0)
	local cursor = o.node.cursor
	gui.set_enabled(cursor, true)
	gui.animate(cursor, gui.PROP_COLOR, transparent, gui.EASING_LINEAR, 0.5, 0.3, nil, gui.PLAYBACK_LOOP_PINGPONG)
end

local function cursor_off(o)
	local cursor = o.node.cursor
	gui.set_enabled(cursor, false)
	gui.cancel_animation(cursor, gui.PROP_COLOR)
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
function M:new (id, uiname, inputtype, config, placeholder, layer, setfocus)
	local o = {}

	assert(id, "Input id is not defined")
	assert(uiname, "Name of the GUI that the input attached need to be defined")

	setmetatable(o, self)
	self.__index = self

	o.id = id
	o.gui = uiname
	o.type = inputtype or M.type.text
	o.config = config
	o.placeholder = placeholder or nil
	o.layer = layer or 0
	o.isfocus = setfocus or false
	o.interactable = true
	o.text = ""
	o.node = get_node(id)
	
	o:clear()
	
	return o
end

function M:clear()
	local node = self.node
	
	gui.set_enabled(node.placeholder, true)
	gui.set_text(node.text, "")
	
	cursor_off(self)
	play_sprite(self, "normal")
end

function M:focus()
	local node = self.node
	
	gui.set_enabled(node.placeholder, false)
	
	cursor_on(self)
	play_sprite(self, "focus")
end

return M

