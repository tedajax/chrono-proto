BulletType = {
    UNKNOWN = 0,
    PLAYER = 1,
    ENEMY = 2
}

function create_bullet(index)
    local bullet = {}
    bullet.position = { x = 0, y = 0 }
    bullet.type = BulletType.UNKNOWN
    bullet.speed = 10
    bullet.angle = 0
    bullet.active = false
    bullet.index = index
    bullet.destroy_flag = false
    bullet.radius = 4
    bullet.limits = { x = World.Width / 2 - bullet.radius, y = World.Height / 2 - bullet.radius }

    bullet.body = love.physics.newBody(World.physics, bullet.position.x, bullet.position.y, "dynamic")
    bullet.body:setMass(1)
    bullet.body:setActive(false)
    bullet.shape = love.physics.newCircleShape(bullet.radius)
    bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape)
    bullet.body:setUserData("Bullet")

    bullet.activate = function(self, type, x, y, radius, angle)
        self.type = type
        local radians = math.rad(angle)
        local r = radius + self.radius + 1
        local bx = math.cos(radians) * r + x
        local by = math.sin(radians) * r + y
        self.body:setActive(true)
        self.body:setX(bx)
        self.body:setY(by)
        self.angle = angle
        local ix = math.cos(math.rad(self.angle)) * self.speed
        local iy = math.sin(math.rad(self.angle)) * self.speed
        self.body:applyLinearImpulse(ix, iy)
        self.active = true
        self.destroy_flag = false
    end

    bullet.reset = function(self)
        self.type = BulletType.UNKNOWN
        self.body:setX(World.Width + 100)
        self.body:setY(World.Height + 100)
        self.body:setLinearVelocity(0, 0)
        self.body:setActive(false)
        self.angle = 0
        self.active = false
        self.destroy_flag = false
    end

    bullet.update = function(self, dt)
        -- local velocity = { x = math.cos(math.rad(self.angle)), y = math.sin(math.rad(self.angle)) }
        -- self.position.x = self.position.x + velocity.x * self.speed * dt
        -- self.position.y = self.position.y + velocity.y * self.speed * dt

        self.position.x = self.body:getX()
        self.position.y = self.body:getY()

        if self.position.x < -self.limits.x or self.position.x > self.limits.x or
           self.position.y < -self.limits.y or self.position.y > self.limits.y then
            self.destroy_flag = true
        end
    end

    bullet.render = function(self, dt)
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle("fill", self.position.x, self.position.y, self.radius, 11)
    end

    return bullet
end

function create_bullet_manager(capacity)
    local manager = {}
    manager.bullets = {}
    manager.free_indices = {}
    manager.capacity = capacity
    for i = 1, capacity do
        manager.free_indices[i] = i
        manager.bullets[i] = create_bullet(i)
    end
    manager.free_head = capacity

    manager.pop_index = function(self)
        assert(self.free_head > 1, "No more free spaces, increase capacity.")
        local result = self.free_indices[self.free_head]
        self.free_head = self.free_head - 1
        return result
    end

    manager.push_index = function(self, index)
        self.free_head = self.free_head + 1
        self.free_indices[self.free_head] = index
    end

    manager.add = function(self, type, x, y, r, angle)
        local index = self:pop_index()
        self.bullets[index]:activate(type, x, y, r, angle)
    end

    manager.remove = function(self, bullet)
        self.bullets[bullet.index]:reset()
        self:push_index(bullet.index)
    end

    manager.update = function(self, dt)
        for i = 1, self.capacity do
            if self.bullets[i].active and self.bullets[i].destroy_flag then
                self:remove(self.bullets[i])
            end
        end

        for i = 1, self.capacity do
            if self.bullets[i].active then
                self.bullets[i]:update(dt)
            end
        end
    end

    manager.render = function(self, dt)
        for i = 1, self.capacity do
            if self.bullets[i].active then
                self.bullets[i]:render(dt)
            end
        end
    end

    return manager
end