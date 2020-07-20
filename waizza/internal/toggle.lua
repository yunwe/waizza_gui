-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

local root = require 'waizza.internal.root'
local ToggleGroup = require 'waizza.internal.toggle_group'

local TYPE_OF = 'toggle' -- constant

--- Toggle module
-- @module M
local M = root:new()

--- event message hashes
M.events = {
	on_value_change = hash("on_value_change"),		-- on vlaue change message
}

----------------------------------------------------------------------------------------------------
-- Private interface
----------------------------------------------------------------------------------------------------
local function pressed(o)
	if o.group then
		--only set check value if it's uncheck 
		if not o.checked then
			o:check(true)
		end
	else
		o:check(not o.checked)
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

--- Toggle Constructor
-- @tparam string id Input ID must be identical with Node ID
-- @tparam string uiname Root GUI Name
-- @param table config Config table for input apperance (background sprites, and padding)
-- @param userdata group ToggleGroup
-- @param bool checked set on
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
	o.node = gui.get_node(hash(id))
	
	if group then
		group:add(o)
	end

	o:register(TYPE_OF, M.events, on_input)
	o:check(checked or false)
	return o
end

--Change check value
-- @param bool toggle check value
function M:check(toggle)
	if self.checked == toggle then
		return
	end
	
	self.checked = toggle
	if self.group then
		--uncheck other radio buttons in same group
		ToggleGroup.child_value_change(self)
	end
	
	--change sprite
	self:play_sprite(toggle and 'focus' or 'normal')

	--play callback list
	self:do_actions(M.events.on_value_change)
end

return M