function create_camera(x, y)
    camera = {}
    camera.position = { x = x or 0, y = y or 0}
    camera.rotation = 0
    camera.zoom = 1

    camera.move = function(self, x, y)
        local x = x or 0
        local y = y or 0
        self.position.x = self.position.x + x
        self.position.y = self.position.y + y
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