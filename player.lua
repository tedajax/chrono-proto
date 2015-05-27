function create_player(x, y)
    local player = {}
    player.position = { x = x, y = y }
    player.orientation = 0
    player.radius = 16
    player.speed = 300
    player.fire_delay = 0.01
    player.fire_timer = 0
    player.is_firing = false
    player.limits = { x = World.Width / 2 - player.radius, y = World.Height / 2 - player.radius }

    player.body = love.physics.newBody(World.physics, player.position.x, player.position.y, "kinematic")
    player.shape = love.physics.newCircleShape(player.radius)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.body:setUserData("Player")

    player.controller = nil

    player.reset = function(self)
        self.position.x = 0
        self.position.y = 0
        self.controller:reset()
    end

    player.update = function(self, dt)
        if self.controller ~= nil then self.controller:update(dt) end

        self:enforce_boundaries()

        self.body:setX(self.position.x)
        self.body:setY(self.position.y)

        if self.is_firing then
            self:fire(self.orientation, dt)
        else
            self.fire_timer = 0
        end
    end

    player.enforce_boundaries = function(self)
        if self.position.x < -self.limits.x then self.position.x = -self.limits.x end
        if self.position.x > self.limits.x then self.position.x = self.limits.x end
        if self.position.y < -self.limits.y then self.position.y = -self.limits.y end
        if self.position.y > self.limits.y then self.position.y = self.limits.y end
    end

    player.fire = function(self, angle, dt)
        if self.fire_timer <= 0 then
            Bullets:add(BulletType.PLAYER, self.position.x, self.position.y, self.radius, angle)
            self.fire_timer = self.fire_delay
        else
            self.fire_timer = self.fire_timer - dt
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
    local controller = {}
    controller.player = player
    controller.player.controller = controller

    controller.reset = function(self)
    end

    controller.update = function(self, dt)
        local movex = Input:getAxisValue("horizontal") * self.player.speed * dt
        local movey = -Input:getAxisValue("vertical") * self.player.speed * dt

        self.player.position.x = self.player.position.x + movex
        self.player.position.y = self.player.position.y + movey

        local vlook, hlook = -Input:getAxisValue("vlook"), Input:getAxisValue("hlook")
        if vlook ~= 0 or hlook ~= 0 then
            self.player.orientation = math.deg(math.atan2(vlook, hlook))
        end

        self.player.is_firing = Input:getButtonDown("fire")
    end

    return controller
end

function create_player_recording_controller(player, recording)
    local controller = {}
    controller.player = player
    controller.player.controller = controller
    controller.recording = recording

    controller.action_player = create_recording_player(recording)

    controller.buttons = {}
    controller.buttons.left = false
    controller.buttons.right = false
    controller.buttons.up = false
    controller.buttons.down = false
    controller.buttons.fire = false

    controller.reset = function(self)
        self.action_player:reset()
    end

    controller.update = function(self, dt)
        self.action_player:update(dt)

        local snapshot = self.action_player:getSnapshot()

        if snapshot == nil then return end

        self.player.position.x = snapshot.position.x
        self.player.position.y = snapshot.position.y
        self.player.orientation = snapshot.orientation
        self.player.is_firing = snapshot.is_firing
    end

    return controller
end