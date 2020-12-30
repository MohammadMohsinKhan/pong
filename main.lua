-- resolution of the game
WIDTH = 960
HEIGHT = 540

-- resolution of the text and other elements
TEXT_WIDTH = 432
TEXT_HEIGHT = 243

-- scores of the players
PLAYER_1_SCORE=0
PLAYER_2_SCORE=0

-- initial positions of the player paddles
PLAYER1_Y= 30
PLAYER2_Y= TEXT_HEIGHT-40

-- velocity at ehich the paddles move
PADDLE_VELOCITY = 200

-- initial position of the ball
BALLX = TEXT_WIDTH/2-2
BALLY = TEXT_HEIGHT/2-2

-- math.random(2) will either give us 1 or 2, if it gives us 1 BALLDX will be equal to -100 otherwise BALLDX will be equal to 100 similar for BALLDY
BALLDX = math.random(2) == 1 and -100 or 100
BALLDY = math.random(-50 , 50)

-- used to keep track of which state the prgram is in
GAME_STATE = 'start'

-- used to tell the program which player is going to serve
SERVING_PLAYER = 1

-- used to tell the program which player has won
WINNING_PLAYER = 1

-- number of human players
PLAYERS = 2

-- used to keep track of whether should be paued or played
music = 'play'

Class = require 'class'
push = require 'push'

-- imports the class of the paddles and the ball properties
require 'Paddle'
require 'Ball'

-- this function runs once to load in important elements such as the music, font, ball and apaddle properties
function love.load()
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- sounds used during the game
    sounds = {
        ['paddle_hit'] = love.audio.newSource('Blip_Select8.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('Hit_Hurt3.wav', 'static'),
        ['score_sound'] = love.audio.newSource('Explosion15.wav', 'static'),
        }

    game = love.audio.newSource('game.mp3', 'static')
    game:setLooping(true)
    
    --game fonts used in the game
    GAME_FONT= love.graphics.newFont('8-bit-pusab.ttf', 8)
    SCORE_FONT= love.graphics.newFont('8-bit-pusab.ttf', 32)
    SMALL_FONT = love.graphics.newFont('8-bit-pusab.ttf', 4)
    
    -- sets up the screen
    push:setupScreen(TEXT_WIDTH, TEXT_HEIGHT, WIDTH, HEIGHT, {
        fullscreen = false,
        vsync= true,
        resizable = true
    })

    -- assigns the paddle and ball classes to variable
    player1 = Paddle(5 , 120 , 5 , 20)
    player2 = Paddle(TEXT_WIDTH-10 , 120 , 5 , 20)
    ball = Ball( TEXT_WIDTH/2-2,  TEXT_HEIGHT/2-2, 4, 4 )
end 

-- allows the screen to be resizable
function love.resize(w, h)
    push:resize(w, h)
end

-- this function runs the main game logic
function love.update(dt)

    -- plays the game music
    if music == 'play' then
        love.audio.play(game)
    elseif music == 'pause' then
        love.audio.pause(game)
    end

    if GAME_STATE == 'play' then

        -- tells the program what to do when the ball hits the paddle
         if ball:collides(player1) then 
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            sounds['paddle_hit']:play()
        end
    
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
            sounds['paddle_hit']:play()
        end
        
        -- tells the program what to do if the ball hits the top or bottom
        if ball.y <=0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
    
        if ball.y >= TEXT_HEIGHT-4 then
            ball.y = TEXT_HEIGHT-4
            ball.dy = -ball.dy
            sounds['wall_hit']:play() 
        end
        
        -- allows the user to move the paddles
        if love.keyboard.isDown('w') then 
            player1.dy = -PADDLE_VELOCITY
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_VELOCITY
        else
            player1.dy = 0 
        end
        
        -- allows the second paddle to be controlled by a human player
        if PLAYERS == 2 then
            if love.keyboard.isDown('up') then 
            player2.dy = -PADDLE_VELOCITY
            elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_VELOCITY
            else
            player2.dy = 0
            end
        -- this contains the logic for the bot
        elseif PLAYERS == 1 then
            if ball.x >  TEXT_WIDTH / 3 and ball.dx >= 0 then 
                if player2.y + 2 < ball.y then
                    if PLAYER_1_SCORE <= 3 then
                        player2.dy = 65
                    elseif PLAYER_1_SCORE <=7 then
                        player2.dy = 70
                    else
                        player2.dy = 74
                    end
                elseif player2.y + 2 > ball.y then
                    if PLAYER_1_SCORE <= 3 then
                        player2.dy = -65
                    elseif PLAYER_1_SCORE <=7 then
                        player2.dy = -70
                    else
                        player2.dy = -74
                    end
                elseif player2.y + 2 == ball.y then
                    player2.dy = 0
                end
            else 
                player2.dy = 0
            end
        end
        
        -- tells the program to add score to the player who scored
        if ball.x <=0 then
            PLAYER_2_SCORE = PLAYER_2_SCORE + 1
            sounds['score_sound']:play()
            ball:reset()
            ball.dx = 150
            SERVING_PLAYER = 2
            if PLAYER_2_SCORE == 10 then
                WINNING_PLAYER = 2
                GAME_STATE = 'victory'
            else
                GAME_STATE = 'serve'
            end
        end

        if ball.x >= TEXT_WIDTH - 4 then
            PLAYER_1_SCORE = PLAYER_1_SCORE + 1
            sounds['score_sound']:play()
            ball:reset()
            ball.dx = -150
            SERVING_PLAYER = 1
            if PLAYER_1_SCORE == 10 then
                WINNING_PLAYER = 1
                GAME_STATE = 'victory'
            else
                GAME_STATE = 'serve'
            end
        end
        
        ball:update(dt)
        player1:update(dt)
        player2:update(dt)
    end
end 


-- this function is used for the game setting controls
function love.keypressed(key)
    
    if GAME_STATE == 'start' then
        if key == 'tab' then
            if PLAYERS == 1 then
                PLAYERS =2
            elseif PLAYERS == 2 then
                PLAYERS = 1
            end
        end        
    end
    if key == 'escape' then 
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if GAME_STATE == 'start' then
            GAME_STATE = 'play'
        elseif GAME_STATE == 'serve' then
            GAME_STATE = 'play'
        elseif GAME_STATE == 'victory' then
            PLAYER_1_SCORE = 0 
            PLAYER_2_SCORE = 0 
            GAME_STATE = 'play'
        end
    elseif key == 'r' then
        love.event.quit("restart")
    elseif key == 'f' then
        toggleFullscreen()
    end  
    
    if key == 'm' then
        if music == 'play' then
            music = 'pause'
        elseif music == 'pause' then
            music = 'play'
        end
    end
end

-- this function is used to display text, the paddles and the balls
function love.draw()
    push:start()
    
    love.graphics.clear(36/255, 64/255, 76/255, 1)
    
    ball:render()

    player1:render()
    player2:render()
    
    love.graphics.setFont(GAME_FONT)
    
    if GAME_STATE == 'start' then
        love.graphics.printf("PRESS ENTER TO PLAY!", 0, 18, TEXT_WIDTH, 'center')
        love.graphics.printf(PLAYERS .. " PLAYER MODE!", 0, 30, TEXT_WIDTH, 'center')

    elseif GAME_STATE == 'serve' then 
        love.graphics.printf("PRESS ENTER TO SERVE!", 0, 18, TEXT_WIDTH, 'center')
        love.graphics.printf("PLAYER " .. SERVING_PLAYER .. "'S SERVE!", 0, 30, TEXT_WIDTH, 'center')
    elseif GAME_STATE == 'victory' then
        love.graphics.printf("PLAYER " .. WINNING_PLAYER .. " HAS WON!", 0, 18, TEXT_WIDTH, 'center')
        love.graphics.printf("PRESS ENTER TO RESET", 0, 30, TEXT_WIDTH, 'center')
    end

    FPSCounter()

    love.graphics.setFont(SCORE_FONT)

    love.graphics.print(PLAYER_1_SCORE, TEXT_WIDTH/2 - 50 , TEXT_HEIGHT/3)
    love.graphics.print(PLAYER_2_SCORE, TEXT_WIDTH/2 + 30 , TEXT_HEIGHT/3)

    love.window.setTitle('Pong')

    love.graphics.setFont(SMALL_FONT)
    love.graphics.printf("TAB-CHANGE MODE  M-PLAY/PAUSE MUSIC  R-RESET GAME  F-TOGGLE FULLSCREEN  ESC-EXIT GAME", 0, 236, TEXT_WIDTH, 'left')
    
    push:finish()
end 

-- this function is used to show the FPS
function FPSCounter()
    love.graphics.setColor(0 , 1, 0, 1)
    love.graphics.setFont(GAME_FONT)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 20, 20)
    love.graphics.setColor(1 , 1, 1, 1)
end

-- this function is used to toggle fullscreen for the game window
function toggleFullscreen()
    local fs = love.window.getFullscreen()
    fs = not fs
    local rs = love.window.setFullscreen(fs, 'desktop')
    return rs and fs or nil
end


