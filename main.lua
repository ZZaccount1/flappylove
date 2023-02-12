--Screen
SCREEN_WIDTH = 500-100
SCREEN_HEIGHT = 750-100

--Engine
isDebug = false

--Sleep function
local clock = os.clock
function sleep(n)-- seconds
local t0 = clock()
while clock() - t0 <= n do end
end

--Pipes
firstYPipes = 0

--Physics
gravity = 0.5

isDead = false

--UI
UI={}
UI.fontSize = 40

--Debug
speed = 0.001
debugBird_lb = {}
debugBird_rt = {}

score = 0

function clamp(value, minV, maxV)
    local result = math.min(maxV, math.max(value, minV))

    return result
end

function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end
  

function checkBirdCollision(whatPipe)
    Pipe_lb={}
    Pipe_rt={}
    Bird_lb={}
    Bird_rt={}

    Pipe_lb.x = Pipes[whatPipe].x
    Pipe_lb.y = Pipes[whatPipe].y + Pipes.sizeY
    Pipe_rt.x = Pipes[whatPipe].x + Pipes.sizeX
    Pipe_rt.y = Pipes[whatPipe].y

    Bird_lb.x = Bird.x - Bird.colliderX/2
    Bird_lb.y = Bird.y + Bird.colliderY/2
    Bird_rt.x = Bird.x + Bird.colliderX/2
    Bird_rt.y = Bird.y - Bird.colliderY/2

    if isDebug then
        debugBird_lb = Bird_lb
        debugBird_rt = Bird_rt
    end

    if
        --Right Top
       ((Bird_rt.x >= Pipe_lb.x and Bird_rt.x <= Pipe_rt.x) and
        (Bird_rt.y <= Pipe_lb.y and Bird_rt.y >= Pipe_rt.y))
        or
        --Left Bottom
       ((Bird_lb.x >= Pipe_lb.x and Bird_lb.x <= Pipe_rt.x) and
        (Bird_lb.y <= Pipe_lb.y and Bird_lb.y >= Pipe_rt.y)) 
       or
       --Right Bottom
       ((Bird_rt.x >= Pipe_lb.x and Bird_rt.x <= Pipe_rt.x) and
        (Bird_lb.y <= Pipe_lb.y and Bird_lb.y >= Pipe_rt.y))
       or
       --Left Top
       ((Bird_lb.x >= Pipe_lb.x and Bird_lb.x <= Pipe_rt.x) and
        (Bird_rt.y <= Pipe_lb.y and Bird_rt.y >= Pipe_rt.y))
        then
       return true
    end

    return false
end

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}

    animation.quads.x = 0
    animation.quads.y = 0

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
            if x == 0 then
                animation.quads.x = 1
                goto continue
            end
            animation.quads.x = animation.quads.x + 1
            ::continue::
        end
        animation.quads.y = animation.quads.y + 1
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end

function love.load()
    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)

    --require
    require("bird")
    require("pipes")

    resetPipesPos(0)
    resetPipesPos(1)

    --Place bird in the middle of the screen
    Bird.x = SCREEN_WIDTH / 3
    Bird.y  = SCREEN_HEIGHT / 2

    --Sprites
    love.graphics.setDefaultFilter("nearest", "nearest") --Removes blurriness
    animation = newAnimation(love.graphics.newImage("sprites/birds.png"), 17, 12, 0.5)
    Pipes.sprites = newAnimation(love.graphics.newImage("sprites/Pipes.png"), 26, 175)
    background = love.graphics.newImage('sprites/bg.png')

    pipes_sw, pipes_sh = Pipes.sprites.quads[1]:getTextureDimensions()
    pipes_avg = ((pipes_sw/Pipes.sprites.quads.x) + (pipes_sh/Pipes.sprites.quads.y)) / 2 / 100

    --UI
    gameFont = love.graphics.newFont(UI.fontSize)
end

function love.update(dt)
    sleep(speed)   

    if isDead then
        return 0
    end
    
    if Bird.y + Bird.size > SCREEN_HEIGHT then
        isDead = true
    else
        Bird.dy = Bird.dy + gravity
    end
    
    Bird.y = Bird.y + Bird.dy
    
    --Pipes
    updatePipesPos()

    if checkBirdCollision(0) or checkBirdCollision(1) or checkBirdCollision(2) or checkBirdCollision(3)  then
        isDead = true
    end

    --Animation
    animation.currentTime = animation.currentTime + dt
    if animation.currentTime >= animation.duration then
        animation.currentTime = animation.currentTime - animation.duration
    end

    --Score
    if Bird.x >= BottomPipe.x + (pipes_sw/2) and Pipes.FirstPipesLine.scored == false then
        score = score + 1
        Pipes.FirstPipesLine.scored = true
    end
    if Bird.x >= BottomPipe2.x + (pipes_sw/2*Pipes.size*pipes_avg) and Pipes.SecondPipesLine.scored == false then
        score = score + 1
        Pipes.SecondPipesLine.scored = true
    end
end

function love.draw()
    --Background
    love.graphics.draw(background, 0, 0, 0, 2.85, 2.85)
    
    --Bird
    local spriteNum = 3
    if Bird.dy < 1 then
        spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
    end 
    local sw, sh = animation.quads[spriteNum]:getTextureDimensions()
    love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], Bird.x, Bird.y, clamp(Bird.dy / math.abs(Bird.jumpForce), -1.5, 1.5), Bird.size, Bird.size, sw / animation.quads.x / 2, sh / animation.quads.y / 2)    
    
    --Pipes
    
    --TopPipe
    
    -- love.graphics.rectangle("fill", TopPipe.x, TopPipe.y, Pipes.sizeX, Pipes.sizeY)
    love.graphics.draw(Pipes.sprites.spriteSheet, Pipes.sprites.quads[1], TopPipe.x, TopPipe.y, 0, Pipes.size * pipes_avg, Pipes.size * pipes_avg, 0.5, 0)
    --print("sw: ", pipes_sw, " /2=", pipes_sw/2, "    ", "-sh: ", pipes_sh, " /2=", -pipes_sh/2)
    --print("TopPipe.x: ", TopPipe.x, "\tTopPipe.y: ", TopPipe.y, "\tPipes.Size: ", Pipes.size, "\tpipes_sw: ", pipes_sw, "\tpipes_sh: ", pipes_sh)
    --print("pipes_sw: ", pipes_sw, " /", Pipes.sprites.quads.x,"=", pipes_sw/Pipes.sprites.quads.x, "\tpipes_sh: ", pipes_sh, " /", Pipes.sprites.quads.y, "=", pipes_sh/Pipes.sprites.quads.y)
    --print("(",pipes_sw/Pipes.sprites.quads.x, " + ", pipes_sh/Pipes.sprites.quads.y,")", "/ 2 / 100", pipes_avg)
    
    --BottomPipe
    --love.graphics.rectangle("fill", BottomPipe.x, BottomPipe.y, Pipes.sizeX, Pipes.sizeY)
    love.graphics.draw(Pipes.sprites.spriteSheet, Pipes.sprites.quads[2], BottomPipe.x, BottomPipe.y, 0, Pipes.size * pipes_avg, Pipes.size * pipes_avg, 0.5, 0)

    --TopPipe2
    love.graphics.draw(Pipes.sprites.spriteSheet, Pipes.sprites.quads[1], TopPipe2.x, TopPipe2.y, 0, Pipes.size * pipes_avg, Pipes.size * pipes_avg, 0.5, 0)
    --love.graphics.rectangle("fill", TopPipe2.x, TopPipe2.y, Pipes.sizeX, Pipes.sizeY)
    
    --BottomPipe2
    love.graphics.draw(Pipes.sprites.spriteSheet, Pipes.sprites.quads[2], BottomPipe2.x, BottomPipe2.y, 0, Pipes.size * pipes_avg, Pipes.size * pipes_avg, 0.5, 0)
    -- llove.graphics.rectangle("fill", BottomPipe2.x, BottomPipe2.y, Pipes.sizeX, Pipes.sizeY)
    
    --Debug
    if isDebug then
        debugPointRadius = 5
        
        love.graphics.setColor(1,0,0)
        love.graphics.circle("fill", Bird_lb.x, Bird_lb.y, debugPointRadius) -- Left Bottom
        love.graphics.circle("fill", Bird_rt.x, Bird_rt.y, debugPointRadius) -- Right Top
        love.graphics.circle("fill", Bird_rt.x, Bird_lb.y, debugPointRadius) -- Right bottom
        love.graphics.circle("fill", Bird_lb.x, Bird_rt.y, debugPointRadius) -- Left top
        love.graphics.setColor(0,0,1)
        love.graphics.circle("fill", Bird.x, Bird.y, debugPointRadius)
        love.graphics.setColor(0,1,0)
        love.graphics.circle("fill", TopPipe.x, TopPipe.y, debugPointRadius)
        love.graphics.setColor(1,1,1)
    end

    --UI
    love.graphics.setFont(gameFont)
    --Score
    love.graphics.print(score, (SCREEN_WIDTH/2) - (UI.fontSize/2), 0)
end

function love.keypressed(key)
    if key == 'up' and not isDead then
        Bird.dy = Bird.jumpForce
    end
    
    if (key == "r" and isDead) then
        isDead = false
        score = 0
        resetBird()
        resetPipesPos(0)
        resetPipesPos(1)
    end

    --isDebug
    if key == "d" and isDebug then
        isDead = not isDead
    end

    if key == "o" and isDebug then
        speed = speed + 0.025
    end
    
    if key == "p" and isDebug then
        speed = speed - 0.025
    end
end