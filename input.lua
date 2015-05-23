function init_input()
    local input = {}
    input.buttons = {}
    input.axes = {}

    input.buttons.fire = false

    input.axes.horizontal = 0
    input.axes.vertical = 0

    input.button_changed = nil
    input.axis_changed = nil

    input.update = function(self, dt)
        local old_fire = self.buttons.fire
        if love.keyboard.isDown("z") or love.mouse.isDown("l") then
            self.buttons.fire = true
        else
            self.buttons.fire = false
        end

        if self.buttons.fire ~= old_fire then
            input.button_changed("fire", self.buttons.fire)
        end


        local old_horizontal = self.axes.horizontal
        self.axes.horizontal = 0
        if love.keyboard.isDown("a") then
            self.axes.horizontal = self.axes.horizontal - 1
        end
        if love.keyboard.isDown("d") then
            self.axes.horizontal = self.axes.horizontal + 1
        end

        if old_horizontal ~= self.axes.horizontal then
            input.axis_changed("horizontal", self.axes.horizontal)
        end

        local old_vertical = self.axes.vertical
        self.axes.vertical = 0
        if love.keyboard.isDown("w") then
            self.axes.vertical = self.axes.vertical - 1
        end
        if love.keyboard.isDown("s") then
            self.axes.vertical = self.axes.vertical + 1
        end

        if old_vertical ~= self.axes.vertical then
            input.axis_changed("vertical", self.axes.vertical)
        end
    end

    input.getButton = function(self, name)
        return self.buttons[name]
    end

    input.getAxis = function(self, name)
        return self.axes[name]
    end

    return input
end