-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com


local root = require 'waizza.internal.root'

local TYPE_OF = 'toggle_group' -- constant

--- ToggleGroup module
-- @module M
local M = root:new()
----------------------------------------------------------------------------------------------------
-- Public interface
----------------------------------------------------------------------------------------------------

--- Input Constructor
-- @tparam string id Input ID must be identical with Node ID
-- @tparam string uiname Root GUI Name
-- @param bool allow_switch_off Is it allowed that no toggle is switched on
function M:new (id, uiname, allow_switch_off)
	local o = {}

	assert(id, "Input id is not defined")
	assert(uiname, "Name of the GUI that the input attached need to be defined")

	setmetatable(o, self)
	self.__index = self

	o.id = id
	o.gui = uiname
	o.allow_switch_off = allow_switch_off or false
	o.children = {}
	
	return o
end

function M:add(child)
	assert(not self.children[child.id], child.id .. " is alrady added to " .. self.id)
	self.children[child.id] = child
end

function M:child_value_change(active_child)
	for id, child in pairs(self.children) do 
		if id ~= active_child.id then
			child:check(false)
		end
	end
end

return M