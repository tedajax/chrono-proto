function create_player(x, y)
    player = {}
    player.position = { x = x, y = y }
    player.orientation = 0
    player.radius = 16
    player.speed = 300
    player.fire_delay = 0.1
    player.fire_timer = 0
    player.is_firing = false
    player.limits = { x = World.Width / 2 - player.radius, y = World.Height / 2 - player.radius }

    player.input = {}
    player.input.buttons = {}
    player.input.axes = {}

    player.input.buttons.fire = false
    player.input.axes.horizontal = 0
    player.input.axes.vertical = 0
    player.input.axes.hlook = 0
    player.input.axes.vlook = 0

    player.getButton = function(self, name) return player.input.buttons[name] end
    player.getAxis = function(self, name) return player.input.axes[name] end

    player.controller = nil

    player.update = function(self, dt)
        if self.controller ~= nil then self.controller:update(dt) end

        local movex = self:getAxis("horizontal") * self.speed * dt
        local movey = self:getAxis("vertical") * self.speed * dt

        self.position.x = self.position.x + movex
        self.position.y = self.position.y + movey

        if self.position.x < -self.limits.x then self.position.x = -self.limits.x end
        if self.position.x > self.limits.x then self.position.x = self.limits.x end
        if self.position.y < -self.limits.y then self.position.y = -self.limits.y end
        if self.position.y > self.limits.y then self.position.y = self.limits.y end

        self.orientation = math.deg(math.atan2(self:getAxis("vlook"), self:getAxis("hlook")))

        if Input:getButton("fire") then
            if self.fire_timer <= 0 then
                local rad = math.rad(self.orientation)
                local bx = math.cos(rad) * self.radius + self.position.x
                local by = math.sin(rad) * self.radius + self.position.y
                Bullets:add(BulletType.PLAYER, bx, by, self.orientation)
                self.fire_timer = self.fire_delay
            else
                self.fire_timer = self.fire_timer - dt
            end
        else
            self.fire_timer = 0
        end
    end

    player.render = function(self, dt)
        love.graphics.setColor(90, 90, 90)
        love.graphics.circle("fill", self.position.x, self.position.y, self.radius)

        love.graphics.setColor(200, 200, 200)
        love.graphics.circle("line", self.position.x, self.position.y, self.radius)

        local rads = math.rad(self.orientation)
        local x1 = self.position.x
        local y1 = self.position.y
        local x2 = math.cos(rads) * self.radius + x1
        local y2 = math.sin(rads) * self.radius + y1
        love.graphics.setColor(200, 200, 200)
        love.graphics.line(x1, y1, x2, y2)
    end

    return player
end

function create_player_controller(player)
    controller = {}
    controller.player = player
    controller.player.controller = controller

    controller.update = function(dt)
        player.input.buttons.fire = Input:getButton("fire")
        player.input.axes.horizontal = Input:getAxis("horizontal")
        player.input.axes.vertical = Input:getAxis("vertical")

        local mousex, mousey = love.mouse.getPosition()
        mousex = mousex / SCREEN_WIDTH * 2 - 1
        mousey = mousey / SCREEN_HEIGHT * 2 - 1
        player.input.axes.hlook = mousex
        player.input.axes.vlook = mousey
    end

    return controller
end

function create_player_recording_controller(player, recording)
    controller = {}

    return controller
end