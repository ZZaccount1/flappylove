Pipes = {}
TopPipe = {}
BottomPipe = {}
TopPipe2 = {}
BottomPipe2 = {}

Pipes[0] = TopPipe
Pipes[1] = BottomPipe
Pipes[2] = TopPipe2
Pipes[3] = BottomPipe2

Pipes.x = 0
Pipes.y = 200

Pipes.minY = 100
Pipes.maxY = 500

Pipes.size = 3
Pipes.sizeX = 75
Pipes.sizeY = 525
Pipes.spawnX = SCREEN_HEIGHT - Pipes.sizeX
Pipes.deleteX = -Pipes.sizeX

Pipes.PipesGap = 200

Pipes.newPipesLineGap = 350

Pipes.speed = 5

TopPipe.x = 0
TopPipe.y = 0

BottomPipe.x = 0
BottomPipe.y = 0

TopPipe2.x = 0
TopPipe2.y = 0

BottomPipe2.x = 0
BottomPipe2.y = 0

Pipes.FirstPipesLine = {}
Pipes.SecondPipesLine = {}
Pipes.FirstPipesLine.scored = false
Pipes.SecondPipesLine.scored = false

test = 0

function updatePipesPos()
    TopPipe.x = TopPipe.x - Pipes.speed
    --TopPipe.y = Pipes.y - Pipes.PipesGap / 2 - Pipes.sizeY

    BottomPipe.x = BottomPipe.x - Pipes.speed
    --BottomPipe.y = Pipes.y + Pipes.PipesGap / 2
    
    TopPipe2.x = TopPipe2.x  - Pipes.speed
    --TopPipe2.y = Pipes.y - Pipes.PipesGap / 2 - Pipes.sizeY

    BottomPipe2.x = BottomPipe2.x - Pipes.speed
    --BottomPipe2.y = Pipes.y + Pipes.PipesGap / 2

    if TopPipe.x <= Pipes.deleteX or BottomPipe.x <= Pipes.deleteX then
        TopPipe.x = Pipes.spawnX
        BottomPipe.x = Pipes.spawnX
        resetPipesPos(0)
    end

    if TopPipe2.x <= Pipes.deleteX or BottomPipe2.x + Pipes.newPipesLineGap <= Pipes.deleteX then
        TopPipe2.x = Pipes.spawnX
        BottomPipe2.x = Pipes.spawnX
        resetPipesPos(1)
    end
end

function resetPipesPos(whatPipeLine)
    firstPipesLine = love.math.random(Pipes.minY, Pipes.maxY)
    secondPipesLine = love.math.random(Pipes.minY, Pipes.maxY)

    if whatPipeLine == 0 then
        TopPipe.x = Pipes.spawnX
        TopPipe.y = firstPipesLine - Pipes.PipesGap / 2 - Pipes.sizeY

        BottomPipe.x = Pipes.spawnX
        BottomPipe.y = firstPipesLine + Pipes.PipesGap / 2
        Pipes.FirstPipesLine.scored = false
    elseif whatPipeLine == 1 then
        TopPipe2.x = TopPipe.x + Pipes.newPipesLineGap
        TopPipe2.y = secondPipesLine - Pipes.PipesGap / 2 - Pipes.sizeY
    
        BottomPipe2.x = BottomPipe.x + Pipes.newPipesLineGap
        BottomPipe2.y = secondPipesLine + Pipes.PipesGap / 2
        Pipes.SecondPipesLine.scored = false
    end

end