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
-- Private interface
----------------------------------------------------------------------------------------------------

function M.child_value_change(active_child)
	if not active_child.checked then
		return
	end

	local group = active_child.group
	for id, child in pairs(group.children) do 
		if id ~= active_child.id then
			child:check(false)
		end
	end
end
----------------------------------------------------------------------------------------------------
-- Public interface
----------------------------------------------------------------------------------------------------

--- ToggleGroup Constructor
-- @tparam string id Input ID must be identical with Node ID
-- @tparam string uiname Root GUI Name
function M:new (id, uiname)
	local o = {}

	assert(id, "Input id is not defined")
	assert(uiname, "Name of the GUI that the input attached need to be defined")

	setmetatable(o, self)
	self.__index = self

	o.id = id
	o.gui = uiname
	o.children = {}
	
	return o
end

--- Add a child toggle to group
-- @param userdata child Toggle component
function M:add(child)
	assert(not self.children[child.id], child.id .. " is alrady added to " .. self.id)
	self.children[child.id] = child
end


--- Return the active toggle in the group
-- @return userdata child Active toggle
function M:result()
	for id, child in pairs(self.children) do 
		if child.checked then
			return child
		end
	end
end

return M