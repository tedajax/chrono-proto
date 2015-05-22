require 'camera'
require 'bullet'
require 'player'
require 'input'

function love.load(arg)
    player = create_player(320, 240)

    Input = init_input()
    Bullets = create_bullet_manager(100)
    Camera = create_camera()

    love.graphics.setBackgroundColor(22, 22, 22)
end

function love.keypressed(key, is_repeat)
    if key == "escape" then
        love.event.quit()
    end
end

function love.update(dt)
    Input:update(dt)
    player.target.x, player.target.y = love.mouse.getPosition()
    player:update(dt)
    Bullets:update(dt)
end

function love.draw(dt)
    Camera:push()
    player:render(dt)
    Bullets:render(dt)
    Camera:pop()

    love.graphics.setColor(0, 255, 0)
    love.graphics.print("FPS : "..tostring(love.timer.getFPS()), 5, 5)
end