  function love.load()
  manateeImage = love.graphics.newImage("resources/images/manatee.png")
  shockwaveImage = love.graphics.newImage("resources/images/shockwave.png")
  squidImage = love.graphics.newImage("resources/images/squid.png")
  sharkImage = love.graphics.newImage("resources/images/shark.png")
  submarineImage = love.graphics.newImage("resources/images/submarine.png")

  shockwaveTimerMax = 0.3
  shockwaveTimer = shockwaveTimerMax
  shockwaveStartSpeed = 100
  shockwaveMaxSpeed = 300

  squidSpeed = 100
  sharkSpeed = 125
  submarineSpeed = 150
  chargeSpeed = 250

  spawnTimerMax = 5

  startGame()
end

function startGame()
  player = {xPos = 0, yPos = 0, width = 128, height = 64, speed=200, img=manateeImage}
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
  love.graphics.draw(player.img, player.xPos, player.yPos, player.angle, 0.5, 0.5)
  for index, shockwave in ipairs(shockwaves) do
    love.graphics.draw(shockwave.img, shockwave.xPos, shockwave.yPos, 0, 0.3, 0.3)
  end
  for index, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.xPos, enemy.yPos, 0, 0.3, 0.3)
  end
end

function love.update(dt)
  updatePlayer(dt)
  updateEnemies(dt)
  updateShockwaves(dt)
  checkCollisions()
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
    player.angle = 0.1
    --player.pSystem:setLinearAcceleration(-75, -15, -150, -15)
  elseif up and player.yPos>0 then
    player.yPos = player.yPos - dt * speed
    player.angle = -0.1
    --player.pSystem:setLinearAcceleration(-75, 15, -150, 15)
  else
    player.angle = 0
    --player.pSystem:setLinearAcceleration(-75, 0, -150, 0)
  end

  if right and player.xPos<love.graphics.getWidth()-player.width then
    player.xPos = player.xPos + dt * speed
    --player.pSystem:setLinearAcceleration(-75, -15, -150, -15)
  elseif left and player.xPos>0 then
    player.xPos = player.xPos - dt * speed
    --player.pSystem:setLinearAcceleration(-75, 15, -150, 15)
  end

  --Shockwave movement
  if love.keyboard.isDown("space") then
    shockwaveSpeed = shockwaveStartSpeed
    if(left) then
      shockwaveSpeed = shockwaveSpeed - player.speed/2
    elseif(right) then
      shockwaveSpeed = shockwaveSpeed + player.speed/2
    end
    spawnShockwave(player.xPos + player.width, player.yPos + player.height/3, shockwaveSpeed)
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

function updateEnemies(dt)
  if spawnTimer > 0 then
    spawnTimer = spawnTimer - dt
  else
    spawnEnemy()
  end

  for i=table.getn(enemies), 1, -1 do
    enemy=enemies[i]
    enemy.update = enemy:update(dt)
    if enemy.xPos < -enemy.width then
      table.remove(enemies, i)
    end
  end
end

Enemy = {xPos = love.graphics.getWidth(), yPos = 0, width = 64, height = 64}
function Enemy:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function spawnEnemy()
  y = love.math.random(0, love.graphics.getHeight() - 64)
  enemyType = love.math.random(0, 2)
  if enemyType == 0 then
    enemy = Enemy:new{yPos = y, speed = squidSpeed, img = squidImage, update=moveLeft}
  elseif enemyType == 1 then
    enemy = Enemy:new{yPos = y, speed = sharkSpeed, img = sharkImage, update=moveToPlayer}
  else
    enemy = Enemy:new{yPos = y, speed = submarineSpeed, img = submarineImage, update=chargePlayer}
  end
  table.insert(enemies, enemy)

  spawnTimer = spawnTimerMax
end

function moveLeft(obj, dt)
  obj.xPos = obj.xPos - obj.speed * dt
  return moveLeft
end

function moveToPlayer(obj, dt)
  xSpeed = math.sin(math.rad (60)) * obj.speed
  ySpeed = math.cos(math.rad (60)) * obj.speed
  if (obj.yPos - player.yPos) > 10 then
    obj.yPos = obj.yPos - ySpeed * dt
    obj.xPos = obj.xPos - xSpeed * dt
  elseif (obj.yPos - player.yPos) < -10 then
    obj.yPos = obj.yPos + ySpeed * dt
    obj.xPos = obj.xPos - xSpeed * dt
  else
    obj.xPos = obj.xPos - obj.speed * dt
  end
  return moveToPlayer
end

function chargePlayer(obj, dt)
  xDistance = math.abs(obj.xPos - player.xPos)
  yDistance = math.abs(obj.yPos - player.yPos)
  distance = math.sqrt(yDistance^2 + xDistance^2)
  if distance < 150 then
    obj.speed = chargeSpeed
    return moveLeft
  end 
  moveToPlayer(obj, dt)
  return chargePlayer
end

function checkCollisions()
  for index, enemy in ipairs(enemies) do
    if intersects(player, enemy) or intersects(enemy, player) then
      print("Player and ennemy collided")
      startGame()
    end

    for index2, shockwave in ipairs(shockwaves) do
      if intersects(enemy, shockwave) then
        print("Shockwave and ennemy collided")
        table.remove(enemies, index)
        table.remove(shockwaves, index2)
        break
      end
    end
  end
end

function intersects(rect1, rect2)
  if rect1.xPos < rect2.xPos and rect1.xPos + rect1.width > rect2.xPos and
     rect1.yPos < rect2.yPos and rect1.yPos + rect1.height > rect2.yPos then
    return true
  else
    return false
  end
end