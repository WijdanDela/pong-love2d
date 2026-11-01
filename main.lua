
local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600

local PADDLE_SPEED = 350
local BALL_SPEED_X = 180
local BALL_SPEED_Y = 260
local SPEED_INCREASE = 1.05
local WINNING_SCORE = 5

local player1 = {
    x = 30,
    y = 250,
    width = 15,
    height = 100,
    speed = PADDLE_SPEED
}

local player2 = {
    x = 755,
    y = 250,
    width = 15,
    height = 100,
    speed = PADDLE_SPEED
}

local ball = {
    x = 390,
    y = 290,
    width = 20,
    height = 20,
    dx = BALL_SPEED_X,
    dy = BALL_SPEED_Y
}

local player1Score = 0
local player2Score = 0

local gameOver = false
local winner = ""

local function resetBall(direction)
    ball.x = WINDOW_WIDTH / 2 - ball.width / 2
    ball.y = WINDOW_HEIGHT / 2 - ball.height / 2

    ball.dx = BALL_SPEED_X * direction
    ball.dy = BALL_SPEED_Y
end

local function resetGame()
    player1Score = 0
    player2Score = 0

    player1.y = 250
    player2.y = 250

    gameOver = false
    winner = ""

    resetBall(1)
end

local function checkCollision(a, b)
    return a.x < b.x + b.width
       and a.x + a.width > b.x
       and a.y < b.y + b.height
       and a.y + a.height > b.y
end

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.window.setTitle("Pong Game")
end

function love.update(dt)

    if gameOver then
        return
    end

    -- Player 1 movement
    if love.keyboard.isDown("w") then
        player1.y = player1.y - player1.speed * dt
    end

    if love.keyboard.isDown("s") then
        player1.y = player1.y + player1.speed * dt
    end

    -- Player 2 movement
    if love.keyboard.isDown("up") then
        player2.y = player2.y - player2.speed * dt
    end

    if love.keyboard.isDown("down") then
        player2.y = player2.y + player2.speed * dt
    end

    -- Keep paddles inside the window
    player1.y = math.max(0, math.min(
        player1.y, WINDOW_HEIGHT - player1.height
    ))

    player2.y = math.max(0, math.min(
        player2.y, WINDOW_HEIGHT - player2.height
    ))

    -- Move ball
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt

    -- Top collision
    if ball.y <= 0 then
        ball.y = 0
        ball.dy = math.abs(ball.dy)
    end

    -- Bottom collision
    if ball.y + ball.height >= WINDOW_HEIGHT then
        ball.y = WINDOW_HEIGHT - ball.height
        ball.dy = -math.abs(ball.dy)
    end

    -- Player 1 collision
    if ball.dx < 0 and checkCollision(ball, player1) then
        ball.x = player1.x + player1.width
        ball.dx = math.abs(ball.dx) * SPEED_INCREASE
        ball.dy = ball.dy * SPEED_INCREASE
    end

    -- Player 2 collision
    if ball.dx > 0 and checkCollision(ball, player2) then
        ball.x = player2.x - ball.width
        ball.dx = -math.abs(ball.dx) * SPEED_INCREASE
        ball.dy = ball.dy * SPEED_INCREASE
    end

    -- Scoring system
    if ball.x + ball.width <= 0 then
        player2Score = player2Score + 1
        resetBall(1)
    end

    if ball.x >= WINDOW_WIDTH then
        player1Score = player1Score + 1
        resetBall(-1)
    end

    -- Check winner
    if player1Score >= WINNING_SCORE then
        winner = "PLAYER 1 WINS!"
        gameOver = true
    elseif player2Score >= WINNING_SCORE then
        winner = "PLAYER 2 WINS!"
        gameOver = true
    end
end

function love.keypressed(key)
    if gameOver and key == "return" then
        resetGame()
    end
end

function love.draw()

    love.graphics.clear(0.05, 0.05, 0.08)

    -- Center line
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(
        WINDOW_WIDTH / 2, 0,
        WINDOW_WIDTH / 2, WINDOW_HEIGHT
    )

    -- Player 1
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.rectangle(
        "fill",
        player1.x,
        player1.y,
        player1.width,
        player1.height
    )

    -- Player 2
    love.graphics.setColor(1, 0.5, 0.2)
    love.graphics.rectangle(
        "fill",
        player2.x,
        player2.y,
        player2.width,
        player2.height
    )

    -- Ball
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        "fill",
        ball.x,
        ball.y,
        ball.width,
        ball.height
    )

    -- Scores
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(player1Score, 350, 30, 0, 2, 2)
    love.graphics.print(player2Score, 430, 30, 0, 2, 2)

    -- Game Over screen
    if gameOver then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle(
            "fill", 150, 200, 500, 200
        )

        love.graphics.setColor(1, 1, 1)

        local font = love.graphics.newFont(32)
        love.graphics.setFont(font)

        love.graphics.printf(
            "GAME OVER",
            150, 225, 500, "center"
        )

        love.graphics.printf(
            winner,
            150, 275, 500, "center"
        )

        local smallFont = love.graphics.newFont(18)
        love.graphics.setFont(smallFont)

        love.graphics.printf(
            "Press ENTER to play again",
            150, 330, 500, "center"
        )
    end
end
