function create_button(name, keys, mbuttons)
    local button = {}

    button.name = name
    button.state = false
    button.old_state = false
    button.keys = {}
    button.mbuttons = {}
    for _, k in ipairs(keys or {}) do table.insert(button.keys, k) end
    for _, m in ipairs(mbuttons or {}) do table.insert(button.mbuttons, m) end

    button.update = function(self)
        self.old_state = self.state
        self.state = false
        for _, k in ipairs(self.keys) do
            if love.keyboard.isDown(k) then
                self.state = true
                break
            end
        end

        for _, m in ipairs(self.mbuttons) do
            if love.mouse.isDown(m) then
                self.state = true
                break
            end
        end
    end

    button.isDown = function(self) return self.state end
    button.pressed = function(self) return self.state and not self.old_state end
    button.released = function(self) return not self.state and self.old_state end
    button.changed = function(self) return self.state ~= self.old_state end

    return button
end

AxisMode = {
    KEYBOARD = 0,
    MOUSE_POSITION = 1
}

AxisMousePosMode = {
    NONE = 0,
    X = 1,
    Y = 2
}

function create_axis(name, keys, mbuttons, mposmode)
    local axis = {}

    axis.name = name
    axis.value = 0
    axis.old_value = 0
    axis.keys = {}
    axis.mbuttons = {}
    axis.scale = 1
    axis.mouse_pos_mode = mposmode or AxisMousePosMode.NONE
    axis.current_mode = AxisMode.KEYBOARD
    local mx, my = get_normalized_mouse_position()
    axis.last_mouse_pos = { x = mx, y = my }

    for _, k in ipairs(keys or {}) do table.insert(axis.keys, k) end
    for _, m in ipairs(mbuttons or {}) do table.insert(axis.mbuttons, m) end

    axis.update = function(self)
        self.old_value = self.value

        local new_value = 0
        local no_input = true
        for _, k in ipairs(self.keys) do
            if love.keyboard.isDown(k[1]) then
                new_value = new_value + k[2] * self.scale
                no_input = false
            end
        end
        for _, m in ipairs(self.mbuttons) do
            if love.mouse.isDown(m[1]) then
                new_value = new_value + m[2] * self.scale
                no_input = false
            end
        end

        self.value = new_value

        -- even if we are using mouse position for this axis
        -- if a key or mouse button is used instead then
        -- we will not calculate the mouse axis mapping
        if not no_input then
            self.current_mode = AxisMode.KEYBOARD
            return
        end


        no_input = true 
        -- if we didn't get a value from keys or mouse buttons
        -- and we are using mouse position then use it
        if self.mouse_pos_mode == AxisMousePosMode.X then
            local x = get_normalized_mouse_position()
            if x ~= self.last_mouse_pos.x then
                self.last_mouse_pos.x = x
                self.value = x * self.scale
                self.current_mode = AxisMode.MOUSE
                no_input = false
            end
        elseif self.mouse_pos_mode == AxisMousePosMode.Y then
            local _, y = get_normalized_mouse_position()
            if y ~= self.last_mouse_pos.y then
                self.last_mouse_pos.y = y
                self.value = y * self.scale
                self.current_mode = AxisMode.MOUSE
                no_input = false
            end
        end

        if no_input then
            if self.current_mode == AxisMode.KEYBOARD then
                self.value = new_value
            elseif self.current_mode == AxisMode.MOUSE then
                self.value = self.old_value
            end
        end
    end

    axis.getValue = function(self) return self.value end
    axis.changed = function(self) return self.value ~= self.old_value end

    return axis
end

-- Returns 'normalized' mouse coordinates (-1, -1) top left corner, (1, 1) bottom right, (0, 0) center
function get_normalized_mouse_position()
    local x, y = love.mouse.getPosition()

    x = x / SCREEN_WIDTH * 2 - 1
    y = y / SCREEN_HEIGHT * 2 - 1

    return x, -y
end

function init_input()
    local input = {}
    input.buttons = {}
    input.axes = {}
    
    input.buttons.fire = create_button("fire", { "z", "left", "right", "up", "down" }, { "l" })

    input.axes.horizontal = create_axis("horizontal", { {"a", -1}, {"d", 1} })
    input.axes.vertical = create_axis("vertical", { {"s", -1}, {"w", 1} })
    input.axes.hlook = create_axis("hlook", { {"left", -1}, {"right", 1} }, {}, AxisMousePosMode.X)
    input.axes.vlook = create_axis("vlook", { {"down", -1}, {"up", 1} }, {}, AxisMousePosMode.Y)

    input.EMPTY = create_empty_input_snapshot(input)

    input.button_changed = nil
    input.axis_changed = nil

    input.axis_mode = AxisMode.KEYBOARD

    input.changed_this_frame = false

    input.update = function(self, dt)
        self.changed_this_frame = false
        for k, b in pairs(self.buttons) do
            b:update()
            if b:changed() then
                self.changed_this_frame = true
            end
        end

        for k, a in pairs(self.axes) do
            a:update()
            if a:changed() then
                self.changed_this_frame = true
            end
        end
    end

    input.getButton = function(self, name)
        return self.buttons[name]
    end

    input.getButtonDown = function(self, name)
        return self:getButton(name):isDown()
    end

    input.getButtonPressed = function(self, name)
        return self:getButton(name):pressed()
    end

    input.getButtonReleased = function(self, name)
        return self:getButton(name):released()
    end

    input.getAxis = function(self, name)
        return self.axes[name]
    end

    input.getAxisValue = function(self, name)
        return self:getAxis(name):getValue()
    end

    return input
end

function create_input_snapshot(input)
    local snapshot = {}
    snapshot.buttons = {}
    snapshot.axes = {}

    for _, b in pairs(input.buttons) do
        snapshot.buttons[b.name] = b.state
    end

    for _, a in pairs(input.axes) do
        snapshot.axes[a.name] = a.value
    end

    return snapshot
end

function create_empty_input_snapshot(input)
    local snapshot = {}
    snapshot.buttons = {}
    snapshot.axes = {}

    for _, b in pairs(input.buttons) do
        snapshot.buttons[b.name] = false
    end

    for _, a in pairs(input.axes) do
        print(a.name)
        snapshot.axes[a.name] = 0
    end

    return snapshot
end

function render_input_debug(input)
    local red = { 255, 0, 0, 127 }
    local white = { 255, 255, 255, 127 }
    local color = white

    local bcount = 0
    for _, b in pairs(input.buttons) do
        if b:isDown() then color = red else color = white end
        love.graphics.setColor(unpack(color))
        love.graphics.circle("fill", (bcount + 1) * 20, 40, 16)
        bcount = bcount + 1
    end

    local acount = 0
    for _, a in pairs(input.axes) do
        love.graphics.setColor(unpack(white))
        love.graphics.rectangle("fill", 10, (acount + 1) * 25 + 50, 200, 20)
        love.graphics.setColor(unpack(red))
        love.graphics.rectangle("fill", 110, (acount + 1) * 25 + 50, a:getValue() * 100, 20)
        acount = acount + 1
    end
end