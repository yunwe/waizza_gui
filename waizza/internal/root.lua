-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

--- Root module 
-- @module M

local wz_pairs = require('waizza.util.wz_pairs')

local M = {}
----------------------------------------------------------------------------------------------------
-- Private interface
----------------------------------------------------------------------------------------------------
local input_events = {}

local map = {}
map.activenode = -1

local function compare_layer(a, b)
	local default_layer = {
		button = 0
	}

	local a_layer = a.layer or default_layer[a.typeof] or 1000
	local b_layer = b.layer or default_layer[b.typeof] or 1000
	
	return a_layer > b_layer
end

local function add(o)
	if not map[o.gui] then
		map[o.gui] = {}
	end
	map[o.gui][o.id] = o
end
----------------------------------------------------------------------------------------------------
-- Public interface
----------------------------------------------------------------------------------------------------
function M:new()
	local o = {} 
	o.interactable = true
	
	setmetatable(o, self)
	self.__index = self
	
	return o
end

function M:register(typeof, callback)
	--add to map
	add(self)

	--set callback for later use
	self.typeof = typeof
	if callback then
		input_events[typeof] = callback	
	end
end

function M:play_sprite(sprite)
	if not self.config then 
		return 
	end

	local anim = hash(self.config[sprite])
	gui.play_flipbook(self.node, anim)
end

--- Add Event Listeners
-- @tparam hash event hash defined in [type].events
-- @tparam function callback Callback function for the event
function M:add_action(event, callback)
	local index = #self.actions[event]
	self.actions[event][index] = callback
end

--- Clear Event Listeners
-- @tparam hash event hash defined in Button.events
function M:remove_actions(event)
	self.actions[event] = {}
end

function M:do_actions(event)
	for i, callback in pairs(self.actions[event]) 
	do
		callback(self)
	end
end
----------------------------------------------------------------------------------------------------
-- Public static interface
----------------------------------------------------------------------------------------------------
function M.pick_node(ui, typeof, action)
	for id, node in wz_pairs(map[ui], compare_layer) do 
		if node.typeof == typeof and node.interactable and gui.pick_node(node.node, action.x, action.y) then
			return node
		end
	end

	return nil
end

function M.set_active(o)
	if map.activenode ~= -1 and map.activenode ~= o.id then
		M.remove_active(o.gui)
	end

	map.activenode = o.id
end

function M.get_active(ui)
	if map.activenode == -1 then
		return
	end
	return map[ui][map.activenode] 
end

function M.remove_active(ui)
	map.activenode = -1
end

function M.on_input(ui, action_id, action)
	for typeof, callback in pairs(input_events) do
		callback(ui, action_id, action)
	end
end

return M