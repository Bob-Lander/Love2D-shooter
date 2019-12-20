function love.load()
  manateeImage = love.graphics.newImage("resources/images/manatee.png")
  shockwaveImage = love.graphics.newImage("resources/images/shockwave.png")

  player = {xPos = 0, yPos = 0, width = 64, height = 64, speed=200, img=submarineImage}
  shockwaves = {}

  canFire = false
  shockwaveTimerMax = 0.2
  shockwaveTimer = shockwaveTimerMax
  shockwaveStartSpeed = 100
  shockwaveMaxSpeed = 300
end

function love.draw()
  love.graphics.setColor(186, 255, 255)
  background = love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(255, 255, 255)

  love.graphics.draw(player.img, player.xPos, player.yPos, 0, 0.5, 0.5)
  for index, shockwave in ipairs(shockwaves) do
    love.graphics.draw(shockwave.img, shockwave.xPos, shockwave.yPos)
  end
end

function love.update(dt)
  downUp = love.keyboard.isDown("down") or love.keyboard.isDown("up")
  leftRight = love.keyboard.isDown("left") or love.keyboard.isDown("right")

  speed = playerSpeed
  if(downUp and leftRight) then
    speed = speed / math.sqrt(2)
  end

  if love.keyboard.isDown("down") and yPos<love.graphics.getHeight()-playerHeight then
    yPos = yPos + dt * speed
  elseif love.keyboard.isDown("up") and yPos>0 then
    yPos = yPos - dt * speed
  end

  if love.keyboard.isDown("right") and xPos<love.graphics.getWidth()-playerWidth then
    xPos = xPos + dt * speed
  elseif love.keyboard.isDown("left") and xPos>0 then
    xPos = xPos - dt * speed
  end
end