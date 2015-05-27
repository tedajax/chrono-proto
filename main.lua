require 'camera'
require 'bullet'
require 'enemy'
require 'player'
require 'input'
require 'recording'

function love.load(arg)
    World = {}
    love.physics.setMeter(64)
    World.physics = love.physics.newWorld(0, 0, true)
    World.physics:setCallbacks(begin_contact, end_contact, pre_solve, post_solve)
    World.Width = 1000
    World.Height = 1000

    player = create_player(0, 0)
    player_controller = create_player_controller(player)
    -- Recorder = create_recording()

    -- RecordedPlayers = {}

    Input = init_input()
    Bullets = create_bullet_manager(1000)
    
    Enemies = {}
    for i = 1, 25 do
        local test_enemy = create_enemy((i - 12) * 50, 500)
        local test_enemy_seeker = create_enemy_seeker_controller(test_enemy)
        test_enemy_seeker:set_target(player.position)
        table.insert(Enemies, test_enemy)
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

function begin_contact(a, b, coll)
    print("begin contact")
end

function end_contact(a, b, coll)
    print("end contact")
end

function pre_solve(a, b, coll)
    -- print("pre solve")
end

function post_solve(a, b, coll, normal1, tangent1, normal2, tangent2)
    -- print("post solve")
end

function love.update(dt)
    World.physics:update(dt)

    -- Recorder:update(dt)
    Input:update(dt)
    player:update(dt)

    for i, e in ipairs(Enemies) do
        e:update(dt)
    end

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

    for i, e in ipairs(Enemies) do
        e:render(dt)
    end

    Bullets:render(dt)
    Camera:pop()

    love.graphics.setColor(0, 255, 0)
    love.graphics.print("FPS : "..tostring(love.timer.getFPS()), 5, 5)

    -- render_input_debug(Input)
end