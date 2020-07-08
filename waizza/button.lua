-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

--- Button module
-- @module Button


local wz_pairs = require('waizza.wz_pairs')

--Meta class
local Button = {}


--- event message hashes
Button.events = {
    click = hash("button_click"),		-- button click message
    release = hash("button_release"),		-- button release message
    pointer_enter = hash("button_pointer_enter"),        -- button pointer enter message
    pointer_exit = hash("button_pointer_exit")        -- button pinter exit message
}

----------------------------------------------------------------------------------------------------
-- Private interface
----------------------------------------------------------------------------------------------------
local map = {}
map.activenode = -1
local function add(o)
    if not map[o.gui] then
        map[o.gui] = {}
    end
    map[o.gui][o.id] = o
end

local function compare_layer(a, b)
    return a.layer > b.layer
end

local function pick_node(ui, action)
    for id, node in wz_pairs(map[ui], compare_layer) do 
        if node.interactable and gui.pick_node(node.node, action.x, action.y) then
            return node
        end
    end

    return nil
end

local function play_sprite(o, sprite)
    if not o.config then 
        return 
    end
    
    local anim = hash(o.config[sprite])
    gui.play_flipbook(o.node, anim)
end

local function do_actions(o, event)
    for i, callback in  pairs(o.actions[event]) 
    do
        callback()
    end
end

local function pressed(o)
    o.ispressed = true

    --change sprite
    play_sprite(o, 'pressed')    
    
    --play callback list
    do_actions(o, Button.events.click)
end

local function release(o)
    if not o.ispressed then
        return
    end

    o.ispressed = false
    if not o.interactable then
        return
    end

    --change sprite
    play_sprite(o, 'normal')
    
    --play callback list
    do_actions(o, Button.events.release)
end

local function remove_active(ui)
    if map.activenode == -1 then
        return
    end

    local o  = map[ui][map.activenode] 
    if not o then
        return
    end
    
    map.activenode = -1

    o.ishover = false
    o.ispressed = false

    --change sprite
    play_sprite(o, 'normal')

    --play callback list
    do_actions(o, Button.events.pointer_exit)
end

local function set_active_node(o)
    if map.activenode ~= -1 and map.activenode ~= o.id then
        remove_active(o.gui)
    end
    
    map.activenode = o.id
    o.ishover = true

    --change sprite
    play_sprite(o, 'hover')

    --play callback list
    do_actions(o, Button.events.pointer_enter)
end
----------------------------------------------------------------------------------------------------
-- Public interface
----------------------------------------------------------------------------------------------------

--- Button Constructor
-- @tparam string id Button ID must be identical with Node ID
-- @tparam string uiname Root GUI Name
-- @param table config Config table for button sprites    
-- @param number layer Button with larger layer number get pick node if two or more button is in the same pixel point
function Button:new (id, uiname, config, layer)
    local o = {}

    assert(id, "Button id is not defined")
    assert(uiname, "Name of the GUI that the button attached need to be defined")
    
    setmetatable(o, self)
    self.__index = self

    o.id = id
    o.gui = uiname
    o.node = gui.get_node(hash(id))
    o.ishover = false
    o.ispressed = false
    o.interactable = true
    o.config = config
    o.layer = layer or 0
    o.actions = {
        [Button.events.click] = {},
        [Button.events.release] = {},
        [Button.events.pointer_enter] = {},
        [Button.events.pointer_exit] = {}
    }

    add(o)
    return o
end

--- Button Event Listeners
-- @tparam hash event hash defined in Button.events
-- @tparam function callback Callback function for the event
function Button:add_action(event, callback)
    local index = #self.actions[event]
    self.actions[event][index] = callback
end

--- Clear Button Event Listeners
-- @tparam hash event hash defined in Button.events
function Button:remove_actions(event)
    self.actions[event] = {}
end

--- Set Button Visiblilty
-- @tparam bool toggle Visibility
function Button:set_enable(toggle)
    gui.set_enabled(self.node, toggle)
    self.interactable = toggle 
    self.ishover = false
    self.ispressed = false

    --reset anim to normal if it is set to interactable
    if self.interactable then
        play_sprite(self, 'normal')
    end
end

--- Set Button Interactivity (Button is visible, but can not click nor hover)
-- @tparam bool toggle Interactable
function Button:set_interactable(toggle)
    self.interactable = toggle
    local sprite = toggle and 'normal' or 'disabled' -- toggle ? 'normal' : 'disabled'
    play_sprite(self, sprite)
end

--- Button input handler
-- Call this handler from your root gui on_input function
-- @tparam string gui Root GUI Name
-- @tparam hash action_id Action ID
-- @tparam table action Action table
function Button.on_input(gui, action_id, action)
    --[[Checking button click --]]
    if action_id == hash("touch") and action.pressed 
    then
        local node = pick_node(gui, action)
        if node then
            pressed(node)
        end
    elseif action_id == hash("touch") and action.released
    then
        local node = pick_node(gui, action)
        if node then
            release(node)
        end
    end
    
    --[[Checking button hover enter and exit --]]
    if action_id == nil then 
        local node = pick_node(gui, action)
        if node then
            if not node.ishover then
                set_active_node(node)
            end
        else
            remove_active(gui)
        end
    end
end

return Button