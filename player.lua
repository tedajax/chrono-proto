function create_player(x, y)
    player = {}
    player.position = { x = x, y = y }
    player.target = { x = 0, y = 0}
    player.orientation = 0
    player.radius = 16
    player.speed = 300
    player.fire_delay = 0.1
    player.fire_timer = 0
    player.is_firing = false

    player.update = function(self, dt)
        local movex = Input:getAxis("horizontal") * self.speed * dt
        local movey = Input:getAxis("vertical") * self.speed * dt

        self.position.x = self.position.x + movex
        self.position.y = self.position.y + movey

        self.orientation = math.deg(math.atan2(self.target.y - self.position.y, self.target.x - self.position.x))

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