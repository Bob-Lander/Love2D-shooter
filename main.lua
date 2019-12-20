function love.load()
  manateeImage = love.graphics.newImage("resources/images/manatee.png")
  shockwaveImage = love.graphics.newImage("resources/images/shockwave.png")
  squidImage = love.graphics.newImage("resources/images/squid.png")
  sharkImage = love.graphics.newImage("resources/images/submarine.png")
  swordfishImage = love.graphics.newImage("resources/images/swordfish.png")

  shockwaveTimerMax = 0.3
  shockwaveTimer = shockwaveTimerMax
  shockwaveStartSpeed = 100
  shockwaveMaxSpeed = 300

  squidSpeed = 200
  sharkSpeed = 250
  swordfishSpeed = 300
  chargeSpeed = 500

  spawnTimerMax = 0.5

  startGame()
end

function startGame()
  player = {xPos = 0, yPos = 0, width = 100, height = 64, speed=200, img=manateeImage}
  shockwaves = {}
  enemies = {}

  canFire = true
  shockwaveTimer = shockwaveTimerMax
  spawnTimer = 0
end

function love.draw()
  love.graphics.setColor(0, 0, 160)
  background = love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(player.img, player.xPos, player.yPos, 0, 0.5, 0.5)
  for index, shockwave in ipairs(shockwaves) do
    love.graphics.draw(shockwave.img, shockwave.xPos, shockwave.yPos, 0, 0.3, 0.3)
  end
end

function love.update(dt)
  updatePlayer(dt)
  updateShockwaves(dt)
end

function updatePlayer(dt)
  down = love.keyboard.isDown("down")
  up = love.keyboard.isDown("up")
  left = love.keyboard.isDown("left")
  right = love.keyboard.isDown("right")

  --Player movement 
  downUp = down or up
  leftRight = left or right

  speed = player.speed
  if(downUp and leftRight) then
    speed = speed / math.sqrt(2)
  end

  if down and player.yPos<love.graphics.getHeight()-player.height then
    player.yPos = player.yPos + dt * speed
  elseif up and player.yPos>0 then
    player.yPos = player.yPos - dt * speed
  end

  if right and player.xPos<love.graphics.getWidth()-player.width then
    player.xPos = player.xPos + dt * speed
  elseif left and player.xPos>0 then
    player.xPos = player.xPos - dt * speed
  end

  --Shockwave movement
  if love.keyboard.isDown("space") then
    shockwaveSpeed = shockwaveStartSpeed
    if(left) then
      shockwaveSpeed = shockwaveSpeed - player.speed/2
    elseif(right) then
      shockwaveSpeed = shockwaveSpeed + player.speed/2
    end
    spawnShockwave(player.xPos + player.width, player.yPos, shockwaveSpeed)
  end

  if shockwaveTimer > 0 then
    shockwaveTimer = shockwaveTimer - dt
  else
    canFire = true
  end
end

function spawnShockwave(x, y, speed)
  if canFire then
    shockwave = {xPos = x, yPos = y, width = 16, height=16, speed=speed, img = shockwaveImage}
    table.insert(shockwaves, shockwave)

    canFire = false
    shockwaveTimer = shockwaveTimerMax
  end
end

function updateShockwaves(dt)
  for index, shockwave in ipairs(shockwaves) do
    shockwave.xPos = shockwave.xPos + dt * shockwave.speed
    if shockwave.speed < shockwaveMaxSpeed then
      shockwave.speed = shockwave.speed + dt * 100
    end
    if shockwave.xPos > love.graphics.getWidth() then
      table.remove(shockwaves, index)
    end
  end
end