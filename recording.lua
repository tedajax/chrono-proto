function create_recording()
    local recording = {}
    recording.timestamp = 0
    recording.snapshots = {}
    recording.snapshots.count = 0

    recording.update = function(self, dt)
        self.timestamp = self.timestamp + dt
    end

    recording.add_snapshot = function(self, snapshot)
        snapshot.timestamp = self.timestamp
        self.snapshots[self.snapshots.count] = snapshot
        self.snapshots.count = self.snapshots.count + 1
    end

    recording.reset = function(self)
        self.timestamp = 0
        self.snapshots = {}
        self.snapshots.count = 0
    end

    return recording
end

function create_recording_player(recording)
    local player = {}

    player.timestamp = 0
    player.snapshots = {}
    player.current_index = 0

    player.snapshots.count = recording.snapshots.count
    for i = 0, recording.snapshots.count - 1 do
        player.snapshots[i] = recording.snapshots[i]
    end

    player.update = function(self, dt)
        self.timestamp = self.timestamp + dt
        while self.current_index < self.snapshots.count and self.snapshots[self.current_index].timestamp <= self.timestamp do
            self.current_index = self.current_index + 1
        end
    end

    player.getSnapshot = function(self)
        if self.current_index < self.snapshots.count then
            return self.snapshots[self.current_index]
        else
            print(self.snapshots.count)
            return Input.EMPTY
        end
    end

    player.reset = function(self)
        self.timestamp = 0
        self.current_index = 0
    end

    return player
end