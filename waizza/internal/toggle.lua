-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

local root = require 'waizza.internal.root'

local TYPE_OF = 'toggle' -- constant

--- Input module
-- @module M
local M = root:new()

--- event message hashes
M.events = {
	on_value_change = hash("on_value_change"),		-- on vlaue change message
}

----------------------------------------------------------------------------------------------------
-- Private interface
----------------------------------------------------------------------------------------------------
local function checkbox_pressed(o)
	o:check(not o.checked)
	
	--play callback list
	o:do_actions(M.events.on_value_change)
end

local function radio_pressed(o)
	--only set check value if it's uncheck 
	if not o.checked then
		o:check(true)

		--uncheck other radio buttons in same group
		o.group:child_value_change(o)
		
		--play callback list
		o:do_actions(M.events.on_value_change)
	end
end

local function pressed(o)
	if o.group then
		radio_pressed(o)
	else
		checkbox_pressed(o)
	end
end

local function pick_node(ui, action)
	return root.pick_node(ui, TYPE_OF, action)
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
		local node = pick_node(ui, action)
		if node then
			pressed(node)
		end
	end
end
----------------------------------------------------------------------------------------------------
-- Public interface
----------------------------------------------------------------------------------------------------

--- Input Constructor
-- @tparam string id Input ID must be identical with Node ID
-- @tparam string uiname Root GUI Name
-- @param table config Config table for input apperance (background sprites, and padding)
-- @param string placeholder Placeholder text
-- @param bool setfocus set auto focus
function M:new (id, uiname, config, group, checked)
	local o = {}

	assert(id, "Input id is not defined")
	assert(uiname, "Name of the GUI that the input attached need to be defined")

	setmetatable(o, self)
	self.__index = self

	o.id = id
	o.gui = uiname
	o.config = config
	o.group = group or nil
	o.checked = checked or false
	o.node = gui.get_node(hash(id))
	o.actions = {
		[M.events.on_value_change] = {}
	}

	if group then
		group:add(o)
	end
	o:register(TYPE_OF, on_input)
	return o
end

--Change check value without triggering action
function M:check(toggle)
	if self.checked == toggle then
		return
	end
	
	self.checked = toggle
	--change sprite
	self:play_sprite(toggle and 'focus' or 'normal')
end

return M