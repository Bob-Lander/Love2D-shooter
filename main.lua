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
  updatePlayer(dt)
  updateTorpedoes(dt)
end

function updatePlayer(dt)
  down = love.keyboard.isDown("down")
  up = love.keyboard.isDown("up")
  left = love.keyboard.isDown("left")
  right = love.keyboard.isDown("right")

  --Player movement 
  downUp = down or up
  leftRight = left or right

  speed = playerSpeed
  if(downUp and leftRight) then
    speed = speed / math.sqrt(2)
  end

  if down and yPos<love.graphics.getHeight()-playerHeight then
    yPos = yPos + dt * speed
  elseif up and yPos>0 then
    yPos = yPos - dt * speed
  end

  if right and xPos<love.graphics.getWidth()-playerWidth then
    xPos = xPos + dt * speed
  elseif left and xPos>0 then
    xPos = xPos - dt * speed
  end

  --Shockwave movement
  if love.keyboard.isDown("space") then
    shockwaveSpeed = shockwaveStartSpeed
    if(left) then
      shockwaveSpeed = shockwaveSpeed - player.speed/2
    elseif(right) then
      shockwaveSpeed = shockwaveSpeed + player.speed/2
    end
    spawnshockwave(player.xPos + player.width, player.yPos + player.height/2, shockwaveSpeed)
  end

  if shockwaveTimer > 0 then
    shockwaveTimer = torpedoTimer - dt
  else
    canFire = true
  end
end