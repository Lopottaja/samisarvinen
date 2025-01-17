function love.load()
  --assetit
  hasFailed = false
  tie = love.graphics.newImage("tie.png")
  resolution = {x=840, y=650}
  tausta = love.graphics.newCanvas(resolution.x,resolution.y*2)
  love.graphics.setCanvas(tausta)
  love.graphics.draw(tie,0,0)
  love.graphics.draw(tie,0,resolution.y)
  samisarvinen = love.graphics.newImage("samisarvinen.png")
  deadSprite = love.graphics.newImage("samisarvinen.png")
  love.graphics.setCanvas()
  rullaus = resolution.y*-1
  nopeus = 100--pelin nopeus, pikseliä sekunnissa
  carSpeed = 200 --Movement speed of the player

  obstacles = {{isHostile = false, isDead = false, sprite = samisarvinen, x = 240, y = 0},{isHostile = true, sprite = love.graphics.newImage("barrel.png"), x = 480, y = 0}}
  
  auto = love.graphics.newImage("auto.png")
  autoX,autoY = 240,400
  suunta="eteen"

  tynnyri = {isHostile = true, sprite = love.graphics.newImage("barrel.png"), x = math.random(130,620), y = 0}
  
  prum = love.audio.newSource("prum.wav","static")
  prum:setLooping(true)
  prum:play()
  
  au = love.audio.newSource("au.mp3","static")
  
  pistelaskuri=0
  piste2=false
end

function törmäys(ax1,ay1,aw,ah, bx1,by1,bw,bh)
  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end

function die()
  hasFailed = true
end

function love.update(dt)
  if not hasFailed then
    --Background movement
    rullaus=rullaus+dt*nopeus
    if rullaus>=0 then rullaus=resolution.y*-1 end

    for i,v in ipairs(obstacles) do
      --Scroll object down the road
      obstacles[i].y=obstacles[i].y+dt*nopeus

      --Remove objects that are offscreen
      if obstacles[i].y>resolution.y+5 then
        table.remove(obstacles, i)
        break
      end

      --Test collisions to objects
      if törmäys(obstacles[i].x+20,obstacles[i].y+20,60,60,autoX,autoY,92,180) then
        if obstacles[i].isHostile then
          die()
          return
        elseif not obstacles[i].isDead then
          obstacles[i].isDead = true
          obstacles[i].sprite = deadSprite
          table.remove(obstacles, i)
          pistelaskuri=pistelaskuri+1
          love.audio.play(au)
        else
          return
        end
      end

    end

    --Add samisarvinen to objects
    if math.random(0,20000)<nopeus then
      if math.random(1,10)<3 then
        table.insert(obstacles, tynnyri)
      else
        table.insert(obstacles, {isHostile = false, isDead = false, sprite = samisarvinen, x = math.random(130,620), y = 0})
      end
    end

    --Player input and movement
    if love.keyboard.isDown("left","a") then
      suunta = "vasen"
    elseif love.keyboard.isDown("right","d") then
      suunta = "oikea"
    else
      suunta = "eteen"
    end
    if suunta == "vasen" and autoX>130 then autoX=autoX-dt*carSpeed*(nopeus/100) end
    if suunta == "oikea" and autoX<620 then autoX=autoX+dt*carSpeed*(nopeus/100) end
    if suunta == "vasen" and math.floor(autoX)==130 then suunta="eteen" end
    if suunta == "oikea" and math.ceil(autoX)==620 then suunta="eteen" end
    
    --Increase game speed infinitely
    nopeus=nopeus+dt
  end
end


function love.draw()
  if not hasFailed then
    --tie, sami, auto
    love.graphics.draw(tausta,0,rullaus)
    for i,v in ipairs(obstacles) do
      love.graphics.draw(obstacles[i].sprite, obstacles[i].x, obstacles[i].y)
    end
    love.graphics.draw(auto,math.ceil(autoX),autoY,0,0.35,0.35)
    
    --hitboxit
    --[[love.graphics.rectangle("line",samisarvinenX+20,samisarvinenY+20,60,60)
    love.graphics.rectangle("line",autoX,autoY,92,180)--]]
    
    --pisteet
    love.graphics.print(pistelaskuri,60,30)
  else
    --TODO Fail screen, showing high score
    love.graphics.clear(0,0,255,50)
    love.graphics.printf("Hävisit pelin! Pisteesi: "..pistelaskuri, 100, 300, 640, "center")
  end
end
