-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

local root = require 'waizza.internal.root'
local slider = require 'waizza.internal.slider'

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

local function move_x(self, amount)
	local node = self.node_table

	local total_amt = gui.get_size(node.content).x - gui.get_size(node.viewport).x
	local movement = total_amt * amount
	local pos = gui.get_position(node.content)
	gui.set_position(node.content, vmath.vector3(-movement, pos.y, pos.z))
end

local function move_y(self, amount)
	local node = self.node_table

	local total_amt = gui.get_size(node.content).y - gui.get_size(node.viewport).y
	local movement = total_amt * amount
	local pos = gui.get_position(node.content)
	gui.set_position(node.content, vmath.vector3(pos.x, movement, pos.z))
end

local function get_node(self)
	local node = {}
	
	node.viewport = gui.get_node(path(self.id, 'viewport'))
	node.content = gui.get_node(path(self.id, 'content'))
	
	node.slider_v = slider:new(path(self.id, 'slider_v'), self.gui, slider.VERTICAL)
	node.slider_v:add_action(slider.events.on_value_change, function(s)
		move_y(self, s.value)
	end)

	node.slider_h = slider:new(path(self.id, 'slider_h'), self.gui, slider.HORIZONTAL)
	node.slider_h:add_action(slider.events.on_value_change, function(s)
		move_x(self, s.value)
	end)
	

	node.slider_v:set_enable(not self.touchonly and self.vertical)
	node.slider_h:set_enable(not self.touchonly and self.horizontal)
	
	return node
end

local function pick_node(ui, action)
	return root.pick_node(ui, TYPE_OF, action)
end

--- Button input handler
-- @tparam string gui Root GUI Name
-- @tparam hash action_id Action ID
-- @tparam table action Action table
local function on_input(ui, action_id, action)

end
----------------------------------------------------------------------------------------------------
-- Public interface
----------------------------------------------------------------------------------------------------

--- Input Constructor
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
	o.node = o.node_table.knob

	o.actions = {
		[M.events.on_value_change] = {}
	}

	o:register(TYPE_OF, on_input)
	return o
end

return M