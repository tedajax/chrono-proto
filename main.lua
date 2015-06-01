require 'camera'
require 'bullet'
require 'enemy'
require 'player'
require 'input'
require 'recording'
require 'collision'

function tostrnil(t)
    if t == nil then
        return "nil"
    else
        return tostring(t)
    end
end

function love.load(arg)
    World = {}
    love.physics.setMeter(64)
    World.physics = love.physics.newWorld(0, 0, true)
    World.physics:setCallbacks(on_begin_contact, on_end_contact, on_pre_solve, on_post_solve)
    World.Width = 1000
    World.Height = 1000

    player = create_player(0, 0)
    player_controller = create_player_controller(player)
    -- Recorder = create_recording()

    -- RecordedPlayers = {}

    Input = init_input()
    Bullets = create_bullet_manager(1000)

    Enemies = create_enemy_manager(100)
    for i = 1, 25 do
        local e = Enemies:add((i - 12) * 50, 500, create_enemy_seeker_controller())
        e.controller:set_target(player.position)
    end

    Camera = create_camera()
    Camera:look_at(0, 0)
    CameraController = create_camera_controller(Camera)
    CameraController.target = player

    love.graphics.setBackgroundColor(22, 22, 22)

end

function love.keypressed(key, is_repeat)
    if key == "escape" then
        love.event.quit()
    elseif key == "r" then
        Recorder:add_snapshot(player.position, player.orientation, false)
        local recorded = create_player(0, 0)
        for i, p in ipairs(RecordedPlayers) do
            p:reset()
        end
        table.insert(RecordedPlayers, recorded)
        local recorded_controller = create_player_recording_controller(recorded, Recorder)
        Recorder:reset()
        player:reset()
    end
end

function love.update(dt)
    World.physics:update(dt)

    -- Recorder:update(dt)
    Input:update(dt)
    player:update(dt)

    Enemies:update(dt)

    -- Recorder:add_snapshot(player.position, player.orientation, player.is_firing)

    -- for i, p in ipairs(RecordedPlayers) do
    --     p:update(dt)
    -- end
    Bullets:update(dt)
    CameraController:update(dt)
end

function render_background(width, height, segments)
    love.graphics.setColor(0, 255, 0)
    local halfseg = segments / 2
    local halfwidth = width / 2
    local halfheight = height / 2
    local tilewidth = width / segments
    local tileheight = height / segments
    for x = -halfseg, halfseg  do
        local wx = x * tilewidth
        for y = -halfseg, halfseg do
            local wy = y * tileheight
            love.graphics.line(-halfwidth, wy, halfwidth, wy)
        end
        love.graphics.line(wx, -halfheight, wx, halfheight)
    end
end

function love.draw(dt)
    Camera:push()

    render_background(World.Width, World.Height, 10)

    player:render(dt)
    -- for i, p in ipairs(RecordedPlayers) do
    --     p:render(dt)
    -- end

    Enemies:render(dt)
    Bullets:render(dt)
    Camera:pop()

    love.graphics.setColor(0, 255, 0)
    love.graphics.print("FPS : "..tostring(love.timer.getFPS()), 5, 5)

    -- render_input_debug(Input)
end