require 'objectpool'

BulletType = {
    UNKNOWN = 0,
    PLAYER = 1,
    ENEMY = 2
}

function create_bullet(handle)
    local bullet = {}
    bullet.position = { x = 0, y = 0 }
    bullet.type = BulletType.UNKNOWN
    bullet.speed = 10
    bullet.angle = 0
    bullet.active = false
    bullet.handle = handle
    bullet.destroy_flag = false
    bullet.radius = 4
    bullet.limits = { x = World.Width / 2 - bullet.radius, y = World.Height / 2 - bullet.radius }

    bullet.body = love.physics.newBody(World.physics, bullet.position.x, bullet.position.y, "dynamic")
    bullet.body:setMass(1)
    bullet.body:setActive(false)
    bullet.shape = love.physics.newCircleShape(bullet.radius)
    bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape)
    -- bullet.fixture:setFilterData(0, 1, 0)
    bullet.fixture:setUserData(create_collider_tag("Bullet", handle))

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
    manager.pool = create_object_pool(create_bullet, capacity)

    manager.add = function(self, type, x, y, r, angle)
        return self.pool:add(type, x, y, r, angle)
    end

    manager.remove = function(self, bullet)
        self.pool:remove(bullet)
    end

    manager.update = function(self, dt)
        self.pool:remove_flagged()
        self.pool:execute_obj_func("update", dt)
    end

    manager.render = function(self, dt)
        self.pool:execute_obj_func("render", dt)
    end

    manager.on_collision_begin = function(self, handle, other, coll)
        self.pool.objects[handle].destroy_flag = true
    end

    return manager
end