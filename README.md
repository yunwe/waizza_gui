# Waizza GUI

Waizza GUI is a simple GUI system for the [Defold](https://defold.com) game engine. It is inspired by [Unity3D](https://unity.com) Gui components.

Defold doesn't provide complex gui components. I used Unity3D for a long time and I wanted a gui library it's ready to use and more familiar to me. So I developed a reusable GUI library inspired by Unity3D. There are other great GUI libraries such as [Gooey](https://github.com/britzl/gooey), [DirtyLarry](https://github.com/andsve/dirtylarry).

#### Supported Components
- Button
- Input 
- Toggle (checkbox, radio button)
- Toggle Group
- Slider
- ScrollView

## Installation

You can use WaizzaGui in your own project by adding this project as a Defold library dependency. This library itself has depedency, therefore you also need to install that libaray too. Open your game.project file and in the dependencies field under project add:

- https://github.com/yunwe/waizza_gui/archive/master.zip
- https://github.com/d954mas/defold-utf8/archive/master.zip

## Input Bindings
**Key Trigger**
| Input        | Action           | 
| ------------- |:-------------:| 
| Backspace      | backspace | 
| Left      | left      | 
| Right | right      | 
| Enter | enter      | 

![](https://res.cloudinary.com/yunwe/image/upload/v1595139476/GitReadMePhoto/waizza_gui/Screenshot_at_Jul_19_12-41-11.jpg)

**Mouse Trigger**
| Input        | Action           | 
| ------------- |:-------------:| 
| Button 1      | touch |

![](https://res.cloudinary.com/yunwe/image/upload/v1595139476/GitReadMePhoto/waizza_gui/Screenshot_at_Jul_19_12-41-13.jpg)

**Text Trigger**
| Input        | Action           | 
| ------------- |:-------------:|
| Text      | text |
| Marked tet      | marked_text      | 

![](https://res.cloudinary.com/yunwe/image/upload/v1595139476/GitReadMePhoto/waizza_gui/Screenshot_at_Jul_19_12-41-12.jpg)

**IMPORTANT NOTE ON ANDROID**: Make sure that the Input Method in the Android section of the game.project file is set to HiddenInputField. This will ensure that virtual keyboard input works properly.

## Components
The libaray folder structure is as follow:

![](https://res.cloudinary.com/yunwe/image/upload/v1595143161/GitReadMePhoto/waizza_gui/folder_structure.png)

Waizza components modules are under internal folder. For clear usage, internal modules were combined in waizza.lua. Therefore, you can import only one module and access internal module via it.
```lua
local waizza = require 'waizza.waizza'

--alias
local Button = waizza.button
local Input = waizza.input
local Toggle = waizza.toggle
local ToggleGroup = waizza.toggle_group
local Slider = waizza.slider
local ScrollView = waizza.scroll_view
```

In order to get components working, it's important to acquire input focus from gui script and call waizza input handler function. Please note to define the gui name.
```lua
function init(self)
	msg.post(".", "acquire_input_focus")
	
	--define the name of the gui
	self.name = "main"
end

function on_input(self, action_id, action)
	--input handling for waizza gui components
	waizza.on_input(self.name, action_id, action)
end
```
The assets and prefabs are for reference only. The appearance of the gui components can be controlled from the config file and it is described in detail in later sections.

### Components
All components except toggle group is interactable. You can add or remove action with these API. In order to get handle in `waizza.on_input()`, gui components need to be constructed before hand. 

**Component:add_action(event, callback)**<br/>
Add Event Listeners<br/>
@param hash `event` hash defined in events<br/>
@param function `callback` Callback function for the event<br/>

**Component:remove_actions(event)**<br/>
Clear Event Listeners<br/>
@param hash `event` hash defined in events<br/>

**Example**
```lua
local submit_btn = Button:new('btn-submit', self.name, config)
submit_btn:add_action(Button.events.release, function() 
	print("submit button clicked.")
end) 
```

### Button
**Events**
- `click` - button click event
- `release` - button pointer up event
- `pointer_enter` - button pointer enter event
- `pointer_exit` - button pointer exit event

**Button:new (id, uiname, config, layer)**<br/>
Constructor function for button.<br/>
@param string `id` Button ID must be identical with Node ID<br/>
@param string `uiname` Root GUI Name<br/>
@param table `config` Config table for button sprites<br/>
@param number `layer` Button with larger layer number get pick node if two or more button is in the same pixel point
```lua
config =  {
		normal = "button_01",
		hover = "button_02",
		pressed = "button_03",
		disabled = "button_04"
	}
```
These are the id of the sprites and you need to load the *.atlas file in your gui. Please make sure all sprites have the *same size* and set your box node with normal sprite.

**Button:set_enable(toggle)**<br/>
Set Button Visiblilty<br/>
@tparam bool `toggle` Visibility  <br/>

**Button:set_interactable(toggle)**<br/>
Set Button Interactivity (Button is visible, but can not click nor hover)<br/>
@tparam bool `toggle` Interactable<br/>

### Input
There is a gui template for input in `prefabs` folder. 
Users can focus input with tab, and tab-indices are created sequentially with their declaration. 

**Events**
- `on_value_change` - on value change event

**Input:new (id, uiname, keyboard, config, placeholder, setfocus)**<br/>
Constructor function for input.<br/>
@param string `id` Input ID must be identical with Node ID<br/>
@param string `uiname` Root GUI Name<br/>
@param string `keyboard` keyboard constant (gui.KEYBOARD_TYPE_?)<br/>
@param table `config` Config table for input apperance (background sprites, and padding)<br/>
@param string `placeholder` Placeholder text<br/>
@param bool `setfocus` set auto focus<br/>
```lua
config =  {
		padding = 42,
		normal = "input_01",
		focus = "input_02"
	}
```
You can adjust the cursor position with the padding vlaue. The last two are sprite id(s). 

**Input:clear()**<br/>
Clear input text<br/>

**Input:focus()**<br/>
Set focus on input<br/>

**Input:remove_focus()**<br/>
Remove focus from input<br/>

**Input:set_text(text)**<br/>
Set text for input<br/>
@param string `text` Text to be stored in input<br/>

### Toggle & Toggle Group
Toggle is the component that can set on and off. If you need only one toggle can set on at single time, you must declare a toggle group for them. If you want check-boxes you can use toggle. If you want radio-buttons, you can use toggle with toggle group.

**Toggle Events**
- `on_value_change` - on value change event

**Toggle:new (id, uiname, config, group, checked)**<br/>
Constructor function for toggle<br/>
@tparam string `id` Input ID must be identical with Node ID<br/>
@tparam string `uiname` Root GUI Name<br/>
@param table `config` Config table for input apperance (background sprites, and padding)<br/>
@param userdata `group` ToggleGroup<br/>
@param bool `checked` set on<br/>

**Toggle:check(toggle)**<br/>
Change check value.<br/>
@param bool `toggle` check value<br/>

**ToggleGroup:new (id, uiname)**<br/>
ToggleGroup Constructor.<br/>
@param string `id` Input ID must be identical with Node ID<br/>
@param string `uiname` Root GUI Name<br/>

**ToggleGroup:add(child)**<br/>
Add a child toggle to group<br/>
@param userdata `child` Toggle component<br/>

**ToggleGroup:result()**<br/>
Return the active toggle in the group.<br/>
@return userdata `child` Active toggle<br/>

### Slider
There are two gui templates in `prefabs` folder, one for horizontal and one for vertical.

**Events**
- `on_value_change` - on value change event

**Directions**
- Slider.HORIZONTAL 
- Slider.VERTICAL 

**Slider:new (id, uiname, direction, padding, value)**<br/>
Constructor function for slider.<br/>
@tparam string `id` Slider ID must be identical with Template ID<br/>
@tparam string `uiname` Root GUI Name<br/>
@param number `direction` Direction constant<br/>
@param vector4 `padding` Padding for knob<br/>
@param number `value` The value of slider ( 0 < x < 1)<br/>

**Slider:set(val)**<br/>
Set value to slider<br/>
@param number `val` The value of slider ( 0 <= val <= 1)<br/>

**Slider:set_enable(toggle)**<br/>
Set slider Visiblilty<br/>
@param bool `toggle` Visibility<br/>

### ScrollView
There are two gui templates in `prefabs` folder. Don't remove or delete sliders if you don't need them. You can hide them from constructor.

**Events**
- `on_value_change` - on value change event

**ScrollView:new (id, uiname, horizontal, vertical, touchonly)**<br/>
Constructor function for scroll view.<br/>
@param string `id` Slider ID must be identical with Template ID<br/>
@param string `uiname` Root GUI Name<br/>
@param bool `horizontal` Move in horizontal direction<br/>
@param bool `vertical` Move in vertical direction<br/>
@param bool `touchonly` Hide both slider<br/>

---
![](https://res.cloudinary.com/yunwe/image/upload/v1595322042/GitReadMePhoto/waizza_gui/example.png)

The [demo project](https://www.sawyunwe.com/portfolio/waizza-gui/default/__htmlLaunchDir/waizza_gui/index.html) provides code samples for all possible use cases.



