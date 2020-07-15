-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

local root = require 'waizza.internal.root'

local TYPE_OF = 'slider' -- constant

--- Slider module
-- @module M
local M = root:new()

--constants
M.HORIZONTAL = 0 
M.VERTICAL = 1

--- event message hashes
M.events = {
	on_value_change = hash("on_value_change"),		-- on vlaue change message
}
----------------------------------------------------------------------------------------------------
-- Private interface
----------------------------------------------------------------------------------------------------
local function path(id, part)
	local mid = string.format('%s/%s', id, part)
	return hash(mid)
end

local function get_node(id)
	local node = {}
	local base = gui.get_node(path(id, 'bg'))
	
	node.scale = gui.get_scale(base)
	node.size = gui.get_size(base)
	node.origin = gui.get_position(base)

	node.base = base
	node.fill = gui.get_node(path(id, 'fill'))
	node.knob = gui.get_node(path(id, 'knob'))
	node.border = gui.get_node(path(id, 'border'))
	return node
end

local function clamp(value, min, max)
	return value < min and min or value > max and max or value
end

local function get_val(o, action)
	local movement, width

	if o.direction == M.HORIZONTAL then
		movement =  action.x - o.node_table.origin.x
		width = o.node_table.size.x * o.node_table.scale.x
	else
		movement =  o.node_table.origin.y - action.y
		width = o.node_table.size.y * o.node_table.scale.y
	end 
	
	return clamp(movement / width, 0, 1)
end

local function left_to_right(prefab, val, padding)
	local origin = prefab.origin
	local width = prefab.size.x * prefab.scale.x
	local min = origin.x + padding.x
	local max = origin.x + width - padding.z
	local pos_x = clamp(origin.x + val * width, min, max) 
	gui.set_position(prefab.knob, vmath.vector3(pos_x, origin.y, origin.z))

	local slice9 = gui.get_slice9(prefab.fill)
	local min_fill = slice9.x + slice9.z
	local size_x = val * prefab.size.x 
	size_x = size_x < min_fill and min_fill or size_x
	gui.set_size(prefab.fill, vmath.vector3(size_x, prefab.size.y, 0))
end

local function top_to_bottom(prefab, val, padding)
	local origin = prefab.origin
	local height = prefab.size.y * prefab.scale.y
	local max = origin.y - padding.y
	local min = origin.y - height + padding.w
	local pos_y = clamp(origin.y - val * height, min, max) 
	
	gui.set_position(prefab.knob, vmath.vector3(origin.x, pos_y, origin.z))

	local slice9 = gui.get_slice9(prefab.fill)
	local min_fill = slice9.y + slice9.w
	local size = val * prefab.size.y
	size = size < min_fill and min_fill or size
	gui.set_size(prefab.fill, vmath.vector3(prefab.size.x, size, 0))
end

local function is_pressed(o)
	return o and o.typeof == TYPE_OF and o.ispressed
end

local function pressed(o, action)
	o.ispressed = true
	root.set_active(o)
	o:set(get_val(o, action))
end

local function moving(ui, action)
	local active = root.get_active(ui)
	if is_pressed(active) then
		active:set(get_val(active, action))
	end
end

local function release(ui, action)
	local active = root.get_active(ui)
	if is_pressed(active) then
		active.ispressed = false
	end
end

local function pick_node(ui, action)
	return root.pick_node(ui, TYPE_OF, action)
end

--- Button input handler
-- @tparam string gui Root GUI Name
-- @tparam hash action_id Action ID
-- @tparam table action Action table
local function on_input(ui, action_id, action)
	--[[Checking button click --]]
	if action_id == hash("touch") and action.pressed 
	then
		local node = pick_node(ui, action)
		if node then
			pressed(node, action)
		end
	elseif action_id == hash("touch") and action.released
	then
		release(ui, action)
	end

	--[[Checking dragging --]]
	if action_id == nil then 
		moving(ui, action)
	end
end
----------------------------------------------------------------------------------------------------
-- Public interface
----------------------------------------------------------------------------------------------------

--- Input Constructor
-- @tparam string id Slider ID must be identical with Template ID
-- @tparam string uiname Root GUI Name
-- @param number value The value of slider ( 0 < x < 1)
function M:new (id, uiname, direction, padding, value)
	local o = {}

	assert(id, "Input id is not defined")
	assert(uiname, "Name of the GUI that the input attached need to be defined")

	setmetatable(o, self)
	self.__index = self

	o.id = id
	o.gui = uiname
	o.direction = direction or M.HORIZONTAL
	o.padding = padding or vmath.vector4(0)
	o.node_table = get_node(id)
	o.node = o.node_table.knob
	o.ispressed = false
	
	o.actions = {
		[M.events.on_value_change] = {}
	}

	
	o:register(TYPE_OF, on_input)
	o:set(value or 0)

	
	return o
end

--- Set value to slider
-- @param number val The value of slider ( 0 <= val <= 1)
function M:set(val)
	if self.value == val then
		return
	end

	self.value = val
	self:do_actions(M.events.on_value_change)
	
	local prefab = self.node_table
	if self.direction == M.HORIZONTAL then
		left_to_right(prefab, val, self.padding)
	else
		top_to_bottom(prefab, val, self.padding)
	end
end

return M