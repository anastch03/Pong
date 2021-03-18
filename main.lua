VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

PADDLE_WIDTH = 8
PADDLE_HEIGHT = 32
PADDLE_SPEED = 140

BALL_SIZE = 4

LARGE_FONT = love.graphics.newFont(32)
SMALL_FONT = love.graphics.newFont(14)

push = require 'push'

gameState = 'title'

sounds = {
    ['bounce'] = love.audio.newSource('audio/Meow.wav', 'static'),
    -- ['score'] = love.audio.newSource('audio/score.wav', 'static'),
    ['gameover'] = love.audio.newSource('audio/gameover.wav', 'static'),
    ['background'] = love.audio.newSource('audio/background.wav', 'stream')
}

player1 = {
    x = 10, 
    y = 10,
    score = 0
}

player2 = {
    x = VIRTUAL_WIDTH - 10 - PADDLE_WIDTH, 
    y = VIRTUAL_HEIGHT - 10 - PADDLE_HEIGHT,
    score = 0
}

ball = {
    x = VIRTUAL_WIDTH / 2 - BALL_SIZE / 2,
    y = VIRTUAL_HEIGHT / 2 - BALL_SIZE / 2
}


function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest")
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)
    resetBall()
    sounds['background']:setLooping(true)
    sounds['background']:play()
end

function love.update(dt)
    if love.keyboard.isDown('w') and player1.y > 0 then
        player1.y = player1.y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('s') and player1.y + PADDLE_HEIGHT < VIRTUAL_HEIGHT then
        player1.y = player1.y + PADDLE_SPEED * dt
    end
    if love.keyboard.isDown('up') and player2.y > 0 then
        player2.y = player2.y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('down') and player2.y + PADDLE_HEIGHT < VIRTUAL_HEIGHT then
        player2.y = player2.y + PADDLE_SPEED * dt
    end
    if gameState == 'play' then
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt
        --If ball touches the top and bottom edge, bounce
        if ball.y >= VIRTUAL_HEIGHT or ball.y <= 0 then
            ball.dy = -ball.dy
            -- love.audio.play(sounds['bounce'])
        end

        -- if ball collides with the paddles, bounce
        if collide(ball, player1) or collide(ball, player2) then
            ball.dx = -ball.dx
            -- love.audio.play(sounds['bounce'])
        end

        -- if ball goes beyond the either paddle's outer edge (towards the edge of the screen), reset ball, update score, and set game state to serve
        if ball.x < player1.x + PADDLE_WIDTH / 2 then
            resetBall()
            gameState = 'serve'
            player2.score = player2.score + 1
            -- love.audio.play(sounds['score'])
        end 
        if (ball.x + BALL_SIZE > player2.x + PADDLE_WIDTH / 2) then
            resetBall()
            gameState = 'serve'
            player1.score = player1.score + 1
            -- love.audio.play(sounds['score'])
        end
        if player1.score == 11 or player2.score == 11 then
            sounds['background']:stop()
            gameState = 'win'
            love.audio.play(sounds['gameover'])
        end
    end 

end

--checks if ball collides with either paddles
function collide(ball, paddle)
    return ball.y < paddle.y + PADDLE_HEIGHT and ball.y + BALL_SIZE > paddle.y and ball.x < paddle.x + PADDLE_WIDTH and ball.x + BALL_SIZE > paddle.x
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'return' then
        if gameState == 'title' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'win' then 
            player1.score = 0
            player2.score = 0
            gameState = 'serve'
        end
    end
end

function love.draw()
    push:start()
    love.graphics.clear(40/255, 45/255, 52/255, 255/255) --make background color 40/255, 45/255, 52/255, 255/255
    if gameState == 'title' then
        love.graphics.setFont(LARGE_FONT)
        love.graphics.printf('Pong', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT - 32,VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press Enter to Serve', 0, 16,VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(LARGE_FONT)
    if player1.score < 10 then
        love.graphics.print(player1.score, VIRTUAL_WIDTH / 2 - 36, VIRTUAL_HEIGHT / 2 - 16)
    else
        love.graphics.print(player1.score, VIRTUAL_WIDTH / 2 - 58, VIRTUAL_HEIGHT / 2 - 16)
    end
    love.graphics.print(player2.score, VIRTUAL_WIDTH / 2 + 16, VIRTUAL_HEIGHT / 2 - 16)
    love.graphics.setFont(SMALL_FONT)

    if gameState == 'win' then
        love.graphics.setFont(LARGE_FONT)
        love.graphics.printf('Game Over', 0, 16, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SMALL_FONT)
        local winner = player1.score == 11 and '1' or '2'
        love.graphics.printf('Player '..winner..' wins!', 0, 60, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to play again', 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')
    end 

    love.graphics.rectangle('fill', player1.x ,player1.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.rectangle('fill', player2.x, player2.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.rectangle('fill', ball.x, ball.y, BALL_SIZE, BALL_SIZE)
    push:finish()
end

function resetBall()
    ball.x = VIRTUAL_WIDTH/2 - BALL_SIZE/2
    ball.y = VIRTUAL_HEIGHT/2 - BALL_SIZE/2

    ball.dx = math.random(30) + 80
    if math.random(2) == 1 then
        ball.dx = -ball.dx
    end
    ball.dy = math.random(40) + 30

    if math.random(2) == 1 then
        ball.dy = -ball.dy
    end
end