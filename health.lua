function create_health(max)
    local health = {}

    health.max = max
    health.current = health.max

    health.regen_per_second = 0
    health.decay_per_second = 0

    health.is_dead = false

    health.respawn = function(self)
        self.current = max
        self.is_dead = false
        self.regen_per_second = 0
        self.decay_per_second = 0
    end

    health.tick = function(self, dt)
        if self.is_dead then return end

        local delta = (self.regen_per_second - self.decay_per_second) * dt
        self.current = self.current + delta

        if self.current > self.max then self.current = self.max end
        if self.current <= 0 then
            self.current = 0
            self.is_dead = true
        end
    end

    health.change = function(self, amount)
        if self.is_dead then return end

        self.current = self.current + amount

        if self.current > self.max then
            self.current = self.max
        elseif self.current <= 0 then
            self.current = 0
            self.is_dead = true
        end
    end

    health.damage = function(self, amount)
        self:change(-amount)
    end

    health.heal = function(self, amount)
        self:change(amount)
    end

    return health
end