Bird = {}

Bird.x=0
Bird.y=0
Bird.size=3

Bird.jumpForce = -10

Bird.dy = 2

Bird.colliderSize = Bird.size * 1.25
Bird.colliderX = 35
Bird.colliderY = 35

function resetBird()
    Bird.x = SCREEN_WIDTH / 3
    Bird.y  = SCREEN_HEIGHT / 2
    Bird.dy = 0
end