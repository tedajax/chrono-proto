function init_input()
    local input = {}
    input.buttons = {}
    input.axes = {}

    input.buttons.fire = false

    input.axes.horizontal = 0
    input.axes.vertical = 0

    input.update = function(self, dt)
        if love.keyboard.isDown("z") or love.mouse.isDown("l") then
            self.buttons.fire = true
        else
            self.buttons.fire = false
        end

        self.axes.horizontal = 0
        if love.keyboard.isDown("a") then
            self.axes.horizontal = self.axes.horizontal - 1
        end
        if love.keyboard.isDown("d") then
            self.axes.horizontal = self.axes.horizontal + 1
        end

        self.axes.vertical = 0
        if love.keyboard.isDown("w") then
            self.axes.vertical = self.axes.vertical - 1
        end
        if love.keyboard.isDown("s") then
            self.axes.vertical = self.axes.vertical + 1
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