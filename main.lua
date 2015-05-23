require 'camera'
require 'bullet'
require 'player'
require 'input'

function on_button_changed(name, state)
    if name == "fire" then
        Recorder:add_action(Action.Fire, state)
    end
end

function on_axis_changed(name, value)
    local a1 = Action.STOP
    local a2 = Action.STOP

    if name == "horizontal" then
        a1 = Action.MOVE_RIGHT
        a2 = Action.MOVE_LEFT
    elseif name == "vertical" then
        a1 = Action.MOVE_DOWN
        a2 = Action.MOVE_UP
    end

    if value > 0 then
        Recorder:add_action(a1, true)
        Recorder:add_action(a2, false)
    elseif value < 0 then
        Recorder:add_action(a1, false)
        Recorder:add_action(a2, true)
    else
        Recorder:add_action(a1, false)
        Recorder:add_action(a2, false)
    end
end

function love.load(arg)
    World = {}
    World.Width = 1000
    World.Height = 1000

    player = create_player(0, 0)
    player_controller = create_player_controller(player)
    Recorder = create_action_Recorder()

    recorded_players = {}

    Input = init_input()
    Input.button_changed = on_button_changed
    Input.axis_changed = on_axis_changed
    Bullets = create_bullet_manager(100)
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
        local recorded = create_player(0, 0)
        table.insert(recorded_players, recorded)
    end
end

function love.update(dt)
    Recorder:update(dt)
    Input:update(dt)
    player:update(dt)
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
    Bullets:render(dt)
    Camera:pop()

    love.graphics.setColor(0, 255, 0)
    love.graphics.print("FPS : "..tostring(love.timer.getFPS()), 5, 5)
end