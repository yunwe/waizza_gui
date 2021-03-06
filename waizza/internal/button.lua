-- Waizza Gui 
--
-- © 2020 Saw Yu Nwe, Waizza Studio
-- https://sawyunwe.com, https://waizza.com

local root = require('waizza.internal.root')
local TYPE_OF = 'button' -- constant


--- Button module
-- @module Button
local Button = root:new() --Button class inherit from root

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
--- Button state[mouse/pointer pressed] call from on_input
-- @tparam table o Button
local function pressed(o)
    o.ispressed = true

    --change sprite
    o:play_sprite('pressed')    
    
    --play callback list
    o:do_actions(Button.events.click)
end

--- Button state[mouse/pointer release] call from on_input
-- @tparam table o Button
local function release(o)
    if not o.ispressed then
        return
    end

    o.ispressed = false
    if not o.interactable then
        return
    end

    --change sprite
    o:play_sprite('normal')
    
    --play callback list
    o:do_actions(Button.events.release)
end

--- Button state[on mouse/pointer hover] call from on_input
-- @tparam table o Button
local function set_hover(o)
    root.set_active(o)
    o.ishover = true

    --change sprite
    o:play_sprite('hover')

    --play callback list
    o:do_actions(Button.events.pointer_enter)
end

--- pick node from ui, filter with type
-- @string ui Active UI Name
-- @tparam table action Action table
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
    elseif action_id == hash("touch") and action.released
    then
        local node = pick_node(ui, action)
        if node then
            release(node)
        end
    end

    --[[Checking button hover enter and exit --]]
    if action_id == nil then 
        local node = pick_node(ui, action)
        if node then
            if not node.ishover then
                set_hover(node)
            end
        else
            root.remove_active(ui, TYPE_OF)
        end
    end
end

--- Button state[on mouse/pointer exit] call from root.remove_active(ui, typeof)
function Button:remove_active()
    self.ishover = false
    self.ispressed = false

    --change sprite
    self:play_sprite('normal')
    self:do_actions(Button.events.pointer_exit)
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
    o.config = config
    o.layer = layer or 0
    
    o:register(TYPE_OF, Button.events, on_input)
    return o
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
        self:play_sprite('normal')
    end
end

--- Set Button Interactivity (Button is visible, but can not click nor hover)
-- @tparam bool toggle Interactable
function Button:set_interactable(toggle)
    self.interactable = toggle
    local sprite = toggle and 'normal' or 'disabled' -- toggle ? 'normal' : 'disabled'
    self:play_sprite(sprite)
end

return Button