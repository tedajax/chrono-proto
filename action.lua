Action = {
    MOVE_LEFT = 0,
    MOVE_RIGHT = 1,
    MOVE_UP = 2,
    MOVE_DOWN = 3,
    FIRE = 4,
    STOP = 5
}

function copy_action(action)
    return {
        action_type = action.action_type,
        state = action.state,
        timestamp = action.timestamp
    }
end

function create_action_recorder()
    recorder = {}

    recorder.timestamp = 0
    recorder.actions = {}
    recorder.actions.count = 0

    recorder.update = function(self, dt)
        self.timestamp = self.timestamp + dt
    end

    recorder.add_action = function(self, action_type, state)
        action = { action_type = action_type, state = state, timestamp = self.timestamp }
        self.actions.count = self.actions.count + 1
        self.actions[self.actions.count] = action
    end

    recorder.reset = function(self)
        self.actions.count = 0
        self.timestamp = 0
    end

    return recorder
end

function create_action_player(recorder, receiver)
    local player = {}

    player.timestamp = 0
    player.timescale = 0
    player.actions = {}
    player.current_action = 0

    for i, v in ipairs(recorder.actions) do
        player.actions[i - 1] = copy_action(v)
    end
    player.actions.count = recorder.actions.count

    -- Receiver must contain following functions
    -- receive_action(self, action)
    player.receiver = receiver

    player.start = function(self)
        self.timestamp = 0
        self.current_action = 0
        self.timescale = 1
    end

    player.update = function(self, dt)
        self.timestamp = self.timestamp + dt * self.timescale
        while self.current_action < self.actions.count and self.actions[self.current_action].timestamp <= self.timestamp do
            self.receiver:receive_action(self.actions[self.current_action])
            self.current_action = self.current_action + 1
        end
    end

    return player
end