BulletType = {
    UNKNOWN = 0,
    PLAYER = 1,
    ENEMY = 2
}

function create_bullet(index)
    bullet = {}
    bullet.position = { x = 0, y = 0 }
    bullet.type = BulletType.UNKNOWN
    bullet.speed = 1000
    bullet.angle = 0
    bullet.active = false
    bullet.index = index
    bullet.destroy_flag = false

    bullet.activate = function(self, type, x, y, angle)
        self.type = type
        self.position.x = x
        self.position.y = y
        self.angle = angle
        self.active = true
        self.index = index
        self.destroy_flag = false
    end

    bullet.reset = function(self)
        self.type = BulletType.UNKNOWN
        self.position.x = 0
        self.position.y = 0
        self.angle = 0
        self.active = false
        self.index = 0
        self.destroy_flag = false
    end

    bullet.update = function(self, dt)
        local velocity = { x = math.cos(math.rad(self.angle)), y = math.sin(math.rad(self.angle)) }
        self.position.x = self.position.x + velocity.x * self.speed * dt
        self.position.y = self.position.y + velocity.y * self.speed * dt

        if not Camera:can_see(self.position.x, self.position.y) then
            self.destroy_flag = true
        end
    end

    bullet.render = function(self, dt)
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle("fill", self.position.x, self.position.y, 4, 11)
    end

    return bullet
end

function create_bullet_manager(capacity)
    manager = {}
    manager.bullets = {}
    manager.free_indices = {}
    manager.capacity = capacity
    for i = 1, capacity do
        manager.free_indices[i] = i
        manager.bullets[i] = create_bullet(i)
    end
    manager.free_head = capacity

    manager.next_index = function(self)
        assert(self.free_head > 1, "No more free spaces, increase capacity.")
        local result = self.free_indices[self.free_head]
        self.free_head = self.free_head - 1
        return result
    end

    manager.add = function(self, type, x, y, angle)
        local index = self:next_index()
        self.bullets[index]:activate(type, x, y, angle)
    end

    manager.remove = function(self, bullet)
        self.bullets[bullet.index]:reset()
        table.insert(self.free_indices, bullet.index)
        self.free_head = self.free_head + 1
    end

    manager.update = function(self, dt)
        for i = 1, self.capacity do
            if self.bullets[i].active then
                self.bullets[i]:update(dt)

                if self.bullets[i].destroy_flag then
                    self:remove(self.bullets[i])
                end
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