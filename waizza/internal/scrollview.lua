-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

local root = require 'waizza.internal.root'
local Slider = require 'waizza.internal.slider'

local TYPE_OF = 'scrollview' -- constant

--- Slider module
-- @module M
local M = root:new()

--- event message hashes
M.events = {
	on_value_change = hash("on_value_change"),		-- on vlaue change message
}
----------------------------------------------------------------------------------------------------
-- Private interface
----------------------------------------------------------------------------------------------------
local function path(id, part)
	local mid = string.format('%s/%s', id, part)
	return mid
end

local function set_position(self, pos)
	local content = self.node_table.content
	gui.set_position(content, pos)
	self:do_actions(M.events.on_value_change)
end

local function move_x(self, amount)
	local node = self.node_table

	local total_amt = gui.get_size(node.content).x - gui.get_size(node.viewport).x
	local movement = total_amt * amount
	local pos = gui.get_position(node.content)
	set_position(self, vmath.vector3(-movement, pos.y, pos.z))
end

local function move_y(self, amount)
	local node = self.node_table

	local total_amt = gui.get_size(node.content).y - gui.get_size(node.viewport).y
	local movement = total_amt * amount
	local pos = gui.get_position(node.content)
	set_position(self, vmath.vector3(pos.x, movement, pos.z))
end

local function get_node(self)
	local node = {}
	
	node.viewport = gui.get_node(path(self.id, 'viewport'))
	node.content = gui.get_node(path(self.id, 'content'))
	
	node.slider_v = Slider:new(path(self.id, 'slider_v'), self.gui, Slider.VERTICAL)
	node.slider_v:add_action(Slider.events.on_value_change, function(s)
		move_y(self, s.value)
	end)

	node.slider_h = Slider:new(path(self.id, 'slider_h'), self.gui, Slider.HORIZONTAL)
	node.slider_h:add_action(Slider.events.on_value_change, function(s)
		move_x(self, s.value)
	end)

	node.slider_v:set_enable(not self.touchonly and self.vertical)
	node.slider_h:set_enable(not self.touchonly and self.horizontal)
	
	return node
end

local function pick_node(ui, action)
	return root.pick_node(ui, TYPE_OF, action)
end

local function clamp(value, min, max)
	return value < min and min or value > max and max or value
end

local function is_pressed(o)
	return o and o.typeof == TYPE_OF and o.ispressed
end

local function pressed(o, action)
	o.ispressed = true
	o.origin = action
	o.gap = gui.get_position(o.node_table.content)
	root.set_active(o)
end

local function moving(ui, action)
	local active = root.get_active(ui)
	if is_pressed(active) then
		local size = gui.get_size(active.node_table.content) - gui.get_size(active.node_table.viewport)
		local x = active.horizontal and action.x - active.origin.x or 0
		local y = active.vertical and action.y - active.origin.y or 0
		
		x = clamp(active.gap.x + x, -size.x, 0)
		y = clamp(active.gap.y + y, 0, size.y)

		active.node_table.slider_h:set(-x / size.x)
		active.node_table.slider_v:set(y / size.y)
		
		set_position(active, vmath.vector3(x, y, 0))
	end
end

local function release(ui, action)
	local active = root.get_active(ui)
	if is_pressed(active) then
		active.ispressed = false
		active.origin = nil
		active.gap = nil
	end
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

--- ScrollView Constructor
-- @tparam string id Slider ID must be identical with Template ID
-- @tparam string uiname Root GUI Name
-- @param bool horizontal Move in horizontal direction
-- @param bool vertical Move in vertical direction
-- @param bool touchonly Hide both slider
function M:new (id, uiname, horizontal, vertical, touchonly)
	local o = {}

	assert(id, "Input id is not defined")
	assert(uiname, "Name of the GUI that the input attached need to be defined")

	setmetatable(o, self)
	self.__index = self

	o.id = id
	o.gui = uiname
	o.horizontal = horizontal
	o.vertical =  vertical
	o.touchonly =  touchonly

	o.node_table = get_node(o)
	o.node = o.node_table.viewport

	o.actions = {
		[M.events.on_value_change] = {}
	}

	o:register(TYPE_OF, M.events, on_input)
	return o
end

return M