function lerp(a, b, t)
    return a + (b - a) * t
end

function create_camera(x, y)
    local camera = {}
    camera.position = { x = x or 0, y = y or 0}
    camera.rotation = 0
    camera.zoom = 1

    camera.move = function(self, x, y)
        local x = x or 0
        local y = y or 0
        self.position.x = self.position.x + x
        self.position.y = self.position.y + y
    end

    camera.look_at = function(self, x, y)
        self.position.x = x - SCREEN_WIDTH / 2
        self.position.y = y - SCREEN_HEIGHT / 2
    end

    camera.push = function(self)
        love.graphics.push()
        love.graphics.rotate(-math.rad(self.rotation))
        love.graphics.scale(1 / self.zoom, 1 / self.zoom)
        love.graphics.translate(-self.position.x, -self.position.y)
    end

    camera.pop = function(self)
        love.graphics.pop()
    end

    camera.left  = function(self) return self.position.x end
    camera.right = function(self) return self.position.x + SCREEN_WIDTH end
    camera.top  = function(self) return self.position.y end
    camera.bottom = function(self) return self.position.y + SCREEN_HEIGHT end

    camera.can_see = function(self, x, y)
        return x >= self:left() and x <= self:right() and
            y <= self:bottom() and y >= self:top()
    end

    return camera
end

function create_camera_controller(camera)
    local controller = {}
    controller.camera = camera
    controller.target = nil
    controller.limits = { x = 32, y = 32 }

    controller.update = function(self, dt)
        if self.target == nil then return end

        self:lerping(dt)
        -- self:bounds_checking(dt)
    end

    controller.bounds_checking = function(self, dt)
        local tx, ty = self.target.position.x, self.target.position.y
        local left = self.camera.position.x + SCREEN_WIDTH / 2 - self.limits.x
        local right = self.camera.position.x + SCREEN_WIDTH / 2 + self.limits.x
        local top = self.camera.position.y + SCREEN_HEIGHT / 2 - self.limits.y
        local bottom = self.camera.position.y + SCREEN_HEIGHT / 2 + self.limits.y

        if tx < left then
            self.camera:move(-math.abs(left - tx))
        end

        if tx > right then
            self.camera:move(math.abs(right - tx))
        end

        if ty < top then
            self.camera:move(0, -math.abs(top - ty))
        end

        if ty > bottom then
            self.camera:move(0, math.abs(bottom - ty))
        end
    end

    controller.lerping = function(self, dt)
        local tx = self.target.position.x - SCREEN_WIDTH / 2
        local ty = self.target.position.y - SCREEN_HEIGHT / 2

        self.camera.position.x = lerp(self.camera.position.x, tx, 8 * dt)
        self.camera.position.y = lerp(self.camera.position.y, ty, 8 * dt)
    end

    return controller
end