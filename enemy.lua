require 'objectpool'
require 'health'

function create_enemy(handle)
    local enemy = {}

    enemy.handle = handle
    enemy.active = false
    enemy.destroy_flag = false

    enemy.position = { x = 0, y = 0 }
    enemy.orientation = 0
    enemy.width = 32
    enemy.height = 32
    enemy.speed = 200

    -- physics
    enemy.body = love.physics.newBody(World.physics, enemy.position.x, enemy.position.y, "kinematic")
    enemy.body:setActive(false)
    enemy.shape = love.physics.newRectangleShape(enemy.width, enemy.height)
    enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape)
    -- enemy.fixture:setFilterData(-2, 1, 0)
    enemy.fixture:setUserData(create_collider_tag("Enemy", enemy.handle))

    enemy.health = create_health(10)

    enemy.controller = nil

    enemy.activate = function(self, x, y, controller)
        self.position.x = x
        self.position.y = y
        self.body:setActive(true)
        self.body:setX(self.position.x)
        self.body:setY(self.position.y)
        self.controller = controller
        self.controller.enemy = self
        self.active = true
        self.destroy_flag = false
        self.health:respawn()
    end

    enemy.reset = function(self)
        self.active = false
        self.destroy_flag = false
        self.controller = nil
        self.body:setActive(false)
    end

    enemy.update = function(self, dt)
        if self.controller ~= nil then self.controller:update(dt) end

        self.health:tick(dt)

        if self.health.is_dead then self.destroy_flag = true end

        self.body:setX(self.position.x)
        self.body:setY(self.position.y)
    end

    enemy.render = function(self, dt)
        love.graphics.setColor(255, 0, 0)
        local tlx, tly = self.position.x - self.width / 2, self.position.y - self.height / 2
        love.graphics.rectangle("fill", tlx, tly, self.width, self.height)
    end

    return enemy
end

function create_enemy_seeker_controller()
    local controller = {}

    controller.enemy = nil
    controller.target = { x = 0, y = 0 }

    controller.set_target = function(self, target)
        self.target = target
    end

    controller.update = function(self, dt)
        local diffx = self.target.x - self.enemy.position.x
        local diffy = self.target.y - self.enemy.position.y

        local dist = math.sqrt(diffx*diffx + diffy*diffy)

        local velx = diffx / dist * self.enemy.speed * dt
        local vely = diffy / dist * self.enemy.speed * dt

        self.enemy.position.x = self.enemy.position.x + velx
        self.enemy.position.y = self.enemy.position.y + vely
    end

    return controller
end

function create_enemy_manager(capacity)
    local manager = {}

    manager.pool = create_object_pool(create_enemy, capacity)

    manager.add = function(self, x, y, controller)
        return self.pool:add(x, y, controller)
    end

    manager.remove = function(self, enemy)
        self.pool:remove(enemy)
    end

    manager.update = function(self, dt)
        self.pool:remove_flagged()
        self.pool:execute_obj_func("update", dt)
    end

    manager.render = function(self, dt)
        self.pool:execute_obj_func("render", dt)
    end

    manager.get_enemy = function(self, handle)
        return self.pool.objects[handle]
    end

    manager.on_collision_begin = function(self, handle, other, coll)
        local data = other:getUserData()

        if data.tag == ColliderTag.Bullet then
            local enemy = self:get_enemy(handle)
            enemy.health:damage(2)
        end
    end

    return manager
end