require 'camera'
require 'bullet'
require 'player'
require 'input'
require 'recording'

function love.load(arg)
    World = {}
    World.Width = 1000
    World.Height = 1000

    player = create_player(0, 0)
    player_controller = create_player_controller(player)
    Recorder = create_recording()

    RecordedPlayers = {}

    Input = init_input()
    Input.button_changed = on_button_changed
    Input.axis_changed = on_axis_changed
    Bullets = create_bullet_manager(1000)
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
    Recorder:update(dt)
    Input:update(dt)
    player:update(dt)

    Recorder:add_snapshot(player.position, player.orientation, player.is_firing)

    for i, p in ipairs(RecordedPlayers) do
        p:update(dt)
    end
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
    for i, p in ipairs(RecordedPlayers) do
        p:render(dt)
    end
    Bullets:render(dt)
    Camera:pop()

    love.graphics.setColor(0, 255, 0)
    love.graphics.print("FPS : "..tostring(love.timer.getFPS()), 5, 5)

    -- render_input_debug(Input)
end