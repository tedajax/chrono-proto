function create_enemy(x, y)
    local enemy = {}

    enemy.position = { x = x or 0, y = y or 0 }
    enemy.orientation = 0
    enemy.width = 32
    enemy.height = 32
    enemy.speed = 200
    enemy.target = { x = 0, y = 0 }

    enemy.body = love.physics.newBody(World.physics, enemy.position.x, enemy.position.y, "kinematic")
    enemy.shape = love.physics.newRectangleShape(enemy.width, enemy.height)
    enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape)
    enemy.body:setUserData("Enemy")

    enemy.controller = nil

    enemy.update = function(self, dt)
        if self.controller ~= nil then self.controller:update(dt) end

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

function create_enemy_seeker_controller(enemy)
    local controller = {}

    controller.enemy = enemy
    controller.enemy.controller = controller

    controller.set_target = function(self, posTable)
        self.enemy.target = posTable
    end

    controller.update = function(self, dt)
        local diffx = self.enemy.target.x - self.enemy.position.x
        local diffy = self.enemy.target.y - self.enemy.position.y

        local dist = math.sqrt(diffx*diffx + diffy*diffy)

        local velx = diffx / dist * self.enemy.speed * dt
        local vely = diffy / dist * self.enemy.speed * dt

        self.enemy.position.x = self.enemy.position.x + velx
        self.enemy.position.y = self.enemy.position.y + vely
    end

    return controller
end