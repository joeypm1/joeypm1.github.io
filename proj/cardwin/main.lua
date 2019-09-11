--winning solitaire
--programmed by joey :)

function love.load()
	love.window.setTitle("winning solitaire")
	canvas = love.graphics.newCanvas()
	max = false
	
	card = love.graphics.newImage("resources/1.png")
	cards = {} --cards order: clubs 1-13, diamonds 14-26, hearts 27-39, spades 40-52, other 53-65 
	for i=1,52 do
		cards[i] = love.graphics.newImage("resources/"..i..".png")
	end
	
	gravity = 120
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*gravity, false)
	obj = {}
	obj.g = {}
	obj.g.body = love.physics.newBody(world,love.graphics.getWidth()/2,love.graphics.getHeight())
	obj.g.shape = love.physics.newRectangleShape(love.graphics.getWidth(),1)
	obj.g.fixture = love.physics.newFixture(obj.g.body, obj.g.shape, 1)
	
	obj.cards = {}
end

function love.draw()
	local mx, my = love.mouse.getX(), love.mouse.getY()
	love.graphics.draw(canvas,0,0)
	
	love.graphics.print("fps: "..love.timer.getFPS().." press 1-5 to limit framerate",0,0)
	love.graphics.print("gravity: 9.81*"..gravity.." use scroll wheel to change",0,15)
	love.graphics.setBackgroundColor(0,128/255,0)
	--love.graphics.draw(cards[1], mx, my, 0, 1, 1, cards[1]:getWidth()/2, cards[1]:getHeight()/2)

	love.graphics.polygon("fill", obj.g.body:getWorldPoints(obj.g.shape:getPoints()))
end

function love.update(dt)
	world:update(dt)
	local mx, my = love.mouse.getX(), love.mouse.getY()
	canvas:renderTo(function()
		if clear == true then
			love.graphics.clear()
			for _,c in pairs(obj.cards) do
				if c.body:isDestroyed() == false then
					c.body:destroy()
					c = nil
				end
			end
			clear = false
		end
		for _,c in pairs(obj.cards) do
			if c.body:isDestroyed() == false then
				love.graphics.draw(cards[c.num],c.body:getX(),c.body:getY(),0,1,1,cards[1]:getWidth()/2, cards[1]:getHeight()/2)
			end
		end
	end)
	
	for _,c in pairs(obj.cards) do
		if c.body:isDestroyed() == false and c.body:getY() > love.graphics.getHeight() then
			c.body:destroy()
			c = nil
		end
	end
	
	if love.keyboard.isDown("left") then
		for _,c in pairs(obj.cards) do
			if c.body:isDestroyed() == false then c.body:applyForce(-600,0) end
		end
	elseif love.keyboard.isDown("right") then
		for _,c in pairs(obj.cards) do
			if c.body:isDestroyed() == false then c.body:applyForce(600,0) end
		end
	end
	if love.keyboard.isDown("up") then
		for _,c in pairs(obj.cards) do
			if c.body:isDestroyed() == false then c.body:applyForce(0,-4000) end
		end
	elseif love.keyboard.isDown("down") then
		for _,c in pairs(obj.cards) do
			if c.body:isDestroyed() == false then c.body:applyForce(0, 2000) end
		end
	end
	
	if love.mouse.isDown(2) then
		c = {}
		c.body = love.physics.newBody(world, mx, my, "dynamic")
		c.body:setLinearVelocity(math.random(-300,300), math.random(-100,200))
		c.shape = love.physics.newRectangleShape(card:getWidth(),card:getHeight())
		c.fixture = love.physics.newFixture(c.body, c.shape)
		c.fixture:setRestitution(0.7)
		c.fixture:setFriction(0)
		c.fixture:setFilterData(2,1,0)
		c.num = math.random(1,#cards)
		table.insert(obj.cards, c)
	end
	
end

function love.mousepressed(x,y,button)
	if button == 1 then
		c = {}
		c.body = love.physics.newBody(world, x, y, "dynamic")
		c.body:setLinearVelocity(math.random(-300,300), 0)
		c.shape = love.physics.newRectangleShape(card:getWidth(),card:getHeight())
		c.fixture = love.physics.newFixture(c.body, c.shape)
		c.fixture:setRestitution(0.7)
		c.fixture:setFriction(0)
		c.fixture:setFilterData(2,1,0)
		c.num = math.random(1,#cards)
		table.insert(obj.cards, c)
	end
end

function love.keypressed(k)
	max = love.window.isMaximized()
	if k == "escape" then love.event.quit() end
	if k == "space" then for _,c in pairs(obj.cards) do if c.body:isDestroyed() == false then c.body:applyLinearImpulse(0,-500) end end end
	if k == "c" then clear = true end
	if k == "1" then
		love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(),{vsync = 0})
		if max == true then love.window.maximize() end
	end
	if k == "2" then
		love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(),{vsync = 1})
		if max == true then love.window.maximize() end
	end
	if k == "3" then
		love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(),{vsync = 2})
		if max == true then love.window.maximize() end
	end
	if k == "4" then
		love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(),{vsync = 3})
		if max == true then love.window.maximize() end
	end
	if k == "5" then
		love.window.updateMode(love.graphics.getWidth(), love.graphics.getHeight(),{vsync = 4})
		if max == true then love.window.maximize() end
	end
end

function love.wheelmoved(x,y)
	if y > 0 then
		gravity = gravity + 20
		world:setGravity(0,9.81*gravity)
	elseif y < 0 then
		gravity = gravity - 20
		world:setGravity(0,9.81*gravity)
	end
end

function love.resize(w,h)
	canvas = nil
	canvas = love.graphics.newCanvas(w,h)
	obj.g.body:destroy()
	obj.g.body = love.physics.newBody(world,w/2,h)
	obj.g.shape = love.physics.newRectangleShape(w,1)
	obj.g.fixture = love.physics.newFixture(obj.g.body, obj.g.shape, 1)
end