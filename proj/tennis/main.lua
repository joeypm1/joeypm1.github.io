local PM = require "playmat"
local push = require "push"
local sock = require "sock"
local bitser = require "bitser"
local binser = require "binser"
local trace = require "trace"
local tween = require "tween"

plrDataTable = {}
typing = false
shift = false
ctrl = false

mapimg = nil
cmdPrefix = "/"
plrDataTable = {}
client = nil
clientName = "Sbeve"
clientColor = "yellow"
lastClientId = ""
discSuccess = false
connected = false
disconnect = false
disconnectExit = false
bgColor = trace.styles.blue
ballColor = trace.styles.white

padRot = {r = 0}
padSide = 1 --0 is left, 1 is right
lastPadSide = 1 -- this is the last pad side of the OTHER player
pad2Side = 1
pad2Rot = {r = 0}
padTween = tween.new(0.1, padRot, {r = 0}, 'linear')
playerPos = {x = 0, y = 0}
playerSpeed = 0.1
cam = nil
tweenTo
 = {x = 100, y = 3}
camTweenTo = {r=0,x=0,y=0,z=0,o=0,f=0}
camTween = tween.new(0.5, camTweenTo, {r = math.pi/2}, 'linear')
playerTween = tween.new(playerSpeed, playerPos, {x = tweenTo.x, y = tweenTo.y}, 'linear')
cheats = false

team = 1 --what side the player is on
mx, my, mwx, mwy = 0, 0, 0, 0
bx, by, bh = 0,0,0
obx, oby, obh = 0,0,0
ob = false
showPhysSims = false
pCam = 0
wallmode = false

server = nil
hosting = false
ip, port = "*", 6096
refreshTimer = 0
cCount = nil
compression = false

commands = {
	{com = "testcommand", desc = "Displays the arguments to the command", alias = "testcom"},
	{com = "help", desc = "Displays commands and their descriptions (ex. /help 1) (ex2. /help alias)", alias = "h"},
	{com = "alias", desc = "Displays aliases to commands", alias = "a"},
	{com = "var", desc = "Displays the value of a variable", alias = "v"},
	{com = "connect", desc = "Connects to a server (ex. /connect localhost:6096)", alias = "conn"},
	{com = "disconnect", desc = "Disconnects from the server you are connected to", alias = "disc"},
	{com = "nick", desc = "Changes your name (ex. /nick grandpa)"},
	{com = "color", desc = "Changes the color that your messages appear in (ex. /color purple)"},
	{com = "background", desc = "Changes the color of the background", alias = "bg"},
	{com = "ballcolor", desc = "Changes the color of the ball", alias = "bc"},
	{com = "serverhost", desc = "Host server", alias = "shost"},
	{com = "serverclose", desc = "Closes server", alias = "sclose"}
}

function runCommand(command, args)
	if command == "help" then
		if args[1] == nil or args[1] == "1" then
			trace.print("-=Help page=- total commands:"..#commands, trace.styles.green)
			for i=1,5 do
				if commands[i] then
					trace.print(i..": "..commands[i].com..": "..commands[i].desc, trace.styles.white)
				end
			end
		elseif args[1] == "2" then
			trace.print("-=Help page 2=-", trace.styles.green)
			for i=6,10 do
				if commands[i] then
					trace.print(i..": "..commands[i].com..": "..commands[i].desc, trace.styles.white)
				end
			end
		elseif args[1] == "3" then
			trace.print("-=Help page "..args[1].."=-", trace.styles.green)
			for i=11,15 do
				if commands[i] then
					trace.print(i..": "..commands[i].com..": "..commands[i].desc, trace.styles.white)
				end
			end
		else
			for k,v in pairs(commands) do
				if args[1] == v.com or args[1] == v.alias then
					trace.print("-=Help page: "..v.com.."=-", trace.styles.green)
					trace.print(k..": "..v.com..": "..v.desc, trace.styles.white)
				end
			end
		end
	end
	if command == "alias" then
		if args[1] == nil or args[1] == "1" then
			trace.print("-=Aliases=-", trace.styles.green)
			for i=1,5 do
				if commands[i] and commands[i].alias then
					trace.print(i.." = "..commands[i].com..": "..commands[i].alias)
				end
			end
		elseif args[1] == "2" then
			trace.print("-=Alias page "..args[1].."=-", trace.styles.green)
			for i=6,10 do
				if commands[i] and commands[i].alias then
					trace.print(i.." = "..commands[i].com..": "..commands[i].alias)
				end
			end
		elseif args[1] == "3" then
			trace.print("-=Alias page "..args[1].."=-", trace.styles.green)
			for i=11,15 do
				if commands[i] and commands[i].alias then
					trace.print(i.." = "..commands[i].com..": "..commands[i].alias)
				end
			end
			
		else
			for k,v in pairs(commands) do
				if v.alias then
					if args[1] == v.com or args[1] == v.alias then
						trace.print("-=Alias: "..v.com.."=-", trace.styles.green)
						trace.print(k.." = "..v.com..": "..v.alias)
					end
				else
					if args[1] == v.com then
						trace.print("-=No alias for "..v.com.."=-", trace.styles.green)
					end
				end
			end
		end
	end
	if command == "var" then
		if args[1] == nil or args[1] == " " or args[1] == "list" then
			local list = ""
			for k, v in pairs(_G) do
				list = list..tostring(k).." "
			end
			if list ~= nil then trace.print(tostring(list)) end
		elseif args[1] == "get" or args[1] == "g" and args[2] ~= nil then
			if type(_G[args[2]]) == "table" then
				for k, v in pairs(_G[args[2]]) do
					trace.print(k.." = "..v, trace.styles.green)
				end
			else
				trace.print(args[2].." = "..tostring(_G[args[2]]), trace.styles.green)
			end
		elseif args[1] == "set" or args[1] == "s" and args[2] ~= nil then
			local oldValue = tostring(_G[args[2]])
			if type(_G[args[2]]) ~= "table" then
				if args[3] == "true" then
					_G[args[2]] = true
					trace.print("variable "..args[2].." = "..tostring(_G[args[2]]).." (bool); was "..oldValue, trace.styles.green)
				elseif args[3] == "false" then
					_G[args[2]] = false
					trace.print("variable "..args[2].." = "..tostring(_G[args[2]]).." (bool); was "..oldValue.." (boolean)", trace.styles.green)
				elseif tonumber(args[3]) ~= nil then
					_G[args[2]] = tonumber(args[3])
					trace.print("variable "..args[2].." = "..tostring(_G[args[2]]).." (num); was "..oldValue, trace.styles.green)
				else
					_G[args[2]] = args[3]
					trace.print("variable "..args[2].." = "..tostring(_G[args[2]]).." (str); was "..oldValue, trace.styles.green)
				end
			end
		end
	end
	if command == "connect" then
		if args[1] == nil or args[1] == " " then
			trace.print("type '/connect main' to connect to the main server (if open)", trace.styles.red)
		else
			if connected == false then
				if args[1]:find(":") == nil then
					ipq = args[1]
					portq = 6096
				else
					ipq, portq = string.match(args[1], "(.+):(.+)")
				end
				if args[1] == "main" then
					ipq = "73.244.29.108"
					portq = 6096
				end
				connectToServer(ipq,portq)
			else
				trace.print("you are already connected to a server")
			end
		end
	end
	if command == "disconnect" then -- not used yet
		if client then
			client:send("disconnect2", {clientId = lastClientId})
			client:disconnectLater()
			disconnect = true
			connected = false
		else
			trace.print("you are not connected to a server")
		end
	end
	if command == "nick" then
		if args[1] == nil then
			if client then
				clientName = tostring(client:getConnectId())
			else
				clientName = "0"
			end
		else
			local fullname = ""
			for k,v in pairs(args) do
				if v ~= nil then fullname = fullname..v end
			end
			clientName = fullname
		end
		trace.print("name set to "..clientName)
	end
	if command == "color" then
		if args[1] ~= "" then
			for k,v in pairs(trace.styles) do
				if args[1] == tostring(k) then
					clientColor = tostring(args[1])
					trace.print("color set to "..clientColor,trace.styles[clientColor])
				end
			end
		else
			local s1 = ""
			for k,v in pairs(trace.styles) do
				s1 = s1..k..", "
			end
			s1 = string.sub(s1, 1, s1:len()-2)
			trace.print("colors: "..s1)
		end
	end
	if command == "background" then
		if args[1] == nil or args[1] == " " then
			local s1 = ""
			for k,v in pairs(trace.styles) do
				s1 = s1..k..", "
			end
			s1 = string.sub(s1, 1, s1:len()-2)
			trace.print("colors: "..s1)
		else
			for k,v in pairs(trace.styles) do
				if args[1] == tostring(k) then
					bgColor = trace.styles[args[1]]
					trace.print("background color changed to "..args[1])
				end
			end
		end
	end
	if command == "ballcolor" then
		if args[1] == nil or args[1] == " " then
			local s1 = ""
			for k,v in pairs(trace.styles) do
				s1 = s1..k..", "
			end
			s1 = string.sub(s1, 1, s1:len()-2)
			trace.print("colors: "..s1)
		else
			for k,v in pairs(trace.styles) do
				if args[1] == tostring(k) then
					ballColor = trace.styles[args[1]]
					trace.print("ball color changed to "..args[1])
				end
			end
		end
	end
	if command == "serverhost" then
		if args[1] == nil or args[1] == " " then
			if hosting == false then
				hostServer(6096)
				connectToServer("localhost",6096)
			end
		else
			if hosting == false then
				local hport = tonumber(args[1])
				if hport then
					hostServer(hport)
					connectToServer("localhost",hport)
				end
			end
		end
	end
	if command == "serverclose" then
		server:destroy()
	end
	if command == "testcommand" then
		local string = "arguments: "
		for i=1,#args do
			string = string..tostring(args[i]).." "
		end
		trace.print(string, trace.styles.white)
	end
end

function love.load()
	love.window.setTitle("tennis")
	love.mouse.setRelativeMode(false)
	love.graphics.setDefaultFilter('nearest','nearest')
	
	trace.limit = 7
	trace.hlimit = 75
	font = love.graphics.newImageFont("resources/font.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\">")
	love.graphics.setFont(font)
	--love.graphics.setNewFont(12)
	trace.print("left click=swing paddle",trace.styles.red)
	trace.print("m=switch team",trace.styles.red)
	trace.print("f1=display physics simulations",trace.styles.red)
	trace.print("f2=bring ball to your side",trace.styles.red)
	trace.print("f3=toggle wall mode (singleplayer)",trace.styles.red)
	trace.print("f11=toggle full screen",trace.styles.red)
	
	gameResX, gameResY = 960*2, 540*2 --game resolution
	screenResX, screenResY = 960, 540 --window resolution
	push:setupScreen(gameResX,gameResY,screenResX,screenResY,{fullscreen = false, resizable = true, stretched = false, canvas = true})
	canvas = love.graphics.newCanvas(gameResX, gameResY)
	pw1 = love.graphics.newCanvas(400, 1025)
	
	tableimg = love.graphics.newImage("resources/table.png")
	paddleimg = love.graphics.newImage("resources/paddle.png")
	netimg = love.graphics.newImage("resources/net.png")
	playerimg = love.graphics.newImage("resources/sprite.png")
	ballimg = love.graphics.newImage("resources/ball.png")
	wallimg = love.graphics.newImage("resources/wall.png")
	
	cam = PM.newCamera(gameResX,gameResY)
	camDefs = {r=math.pi/2,x=tableimg:getWidth()/2,y=tableimg:getHeight()/2,z=230,o=0.4,f=0.7}
	cam:setPosition(camDefs.x,camDefs.y)
	cam:setZoom(camDefs.z)
	cam:setOffset(camDefs.o)
	cam:setFov(camDefs.f)

	plrRotSpeed = 80
	plrMoveSpeed = 80
	
	--physics oh shit
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)
	obj = {}
	obj.g1 = {}
	obj.g1.body = love.physics.newBody(world,tableimg:getWidth()/2,400)
	obj.g1.shape = love.physics.newRectangleShape(tableimg:getWidth(),50)
	obj.g1.fixture = love.physics.newFixture(obj.g1.body, obj.g1.shape, 1)
	obj.g1.fixture:setFriction(1)
	obj.g1.fixture:setFilterData(1,1,0)
	
	obj.b1 = {}
	obj.b1.body = love.physics.newBody(world, 80--[[bx]], 0, "dynamic")
	obj.b1.shape = love.physics.newCircleShape(20)
	obj.b1.fixture = love.physics.newFixture(obj.b1.body, obj.b1.shape, 0.1)
	obj.b1.fixture:setRestitution(0.75)
	obj.b1.fixture:setFriction(1)
	obj.b1.fixture:setFilterData(1,1,0)
	obj.b1.body:setSleepingAllowed(false)
	b1b = obj.b1.body
	
	obj.g2 = {}
	obj.g2.body = love.physics.newBody(world,tableimg:getHeight()/2,800)
	obj.g2.shape = love.physics.newRectangleShape(tableimg:getHeight(),50)
	obj.g2.fixture = love.physics.newFixture(obj.g2.body, obj.g2.shape, 1)
	obj.g2.fixture:setFriction(1)
	obj.g2.fixture:setFilterData(1,0,1)
	
	obj.b2 = {}
	obj.b2.body = love.physics.newBody(world, 20--[[by]], 400, "dynamic")
	obj.b2.shape = love.physics.newCircleShape(20)
	obj.b2.fixture = love.physics.newFixture(obj.b2.body, obj.b2.shape, 0.1)
	obj.b2.fixture:setRestitution(0.75)
	obj.b2.fixture:setFriction(1)
	obj.b2.fixture:setFilterData(1,0,1)
	obj.b2.body:setSleepingAllowed(false)
	b2b = obj.b2.body
	
	obj.f = {} --fence
	obj.f.body = love.physics.newBody(world,tableimg:getHeight()/2,750)--pos
	obj.f.shape = love.physics.newRectangleShape(10,50)--size
	obj.f.fixture = love.physics.newFixture(obj.f.body, obj.f.shape, 1)
	obj.f.fixture:setFriction(1)
	obj.f.fixture:setFilterData(1,0,1)
	
	obj.w = {} --wall (wallmode)
	obj.w.body = love.physics.newBody(world,tableimg:getHeight()/2,700)--position
	obj.w.shape = love.physics.newRectangleShape(10,175)--size
	obj.w.fixture = love.physics.newFixture(obj.w.body, obj.w.shape, 1)
	obj.w.fixture:setFriction(1)
	obj.w.fixture:setFilterData(1,0,0)
	
	obj.r = {} --racket
	obj.r.body = love.physics.newBody(world,100,725)--pos
	obj.r.shape = love.physics.newRectangleShape(0,0,4,100,-0.5) --size
	obj.r.fixture = love.physics.newFixture(obj.r.body, obj.r.shape, 1)
	obj.r.fixture:setFriction(0)
	obj.r.fixture:setFilterData(1,0,0)
end

function love.draw()
	push:apply("start")
	love.graphics.draw(canvas, 0, 200, 0, 1, 1)
	if showPhysSims == true then love.graphics.draw(pw1, gameResX-400, 0, 0, 1, 1) end
	push:apply("end")
	if showPhysSims == true then
		love.graphics.print("fps "..love.timer.getFPS(), 0, 15*11)
		love.graphics.print("x "..playerPos.x.." y "..playerPos.y, 0, 15*12)
		love.graphics.print("bx "..bx.." by "..by.." bh "..bh, 0, 15*13)
	end
	trace.draw(15,15)
end

function love.update(dt)
	--physics
	world:update(dt)
	bx, by, bh = (b1b:getX()), (b2b:getX()), (-b2b:getY()+400)*12.2+4323
	if bh <= -1000 or bx > tableimg:getWidth() + 40 or bx < -40 then
		if team == 1 then
			b1b:setPosition(80,200) 
			b2b:setPosition(20,600)
		else
			b1b:setPosition(100,200)
			b2b:setPosition(230,600)
		end
		b1b:setLinearVelocity(0,0)
		b2b:setLinearVelocity(0,0)
		b1b:setAngularVelocity(0)
		b2b:setAngularVelocity(0)
	end
	pw1:renderTo(function()
		love.graphics.clear()
		love.graphics.setColor(0.28, 0.63, 0.05)
		local x1,y1,x2,y2,x3,y3,x4,y4 = obj.g1.body:getWorldPoints(obj.g1.shape:getPoints())
		love.graphics.polygon("fill", x1+pCam,y1,x2+pCam,y2,x3+pCam,y3,x4+pCam,y4)
		love.graphics.setColor(0.76, 0.18, 0.05)
		love.graphics.circle("fill", b1b:getX()+pCam, b1b:getY(), obj.b1.shape:getRadius())
		
		love.graphics.setColor(0.28, 0.63, 0.05)
		local x1,y1,x2,y2,x3,y3,x4,y4 = obj.g2.body:getWorldPoints(obj.g2.shape:getPoints())
		love.graphics.polygon("fill", x1+pCam,y1,x2+pCam,y2,x3+pCam,y3,x4+pCam,y4)
		love.graphics.setColor(0.76, 0.18, 0.05)
		love.graphics.circle("fill", b2b:getX()+pCam, b2b:getY(), obj.b2.shape:getRadius())

		--wall
		if wallmode == true then
			love.graphics.setColor(0.28, 0.63, 0.05)
			local x1,y1,x2,y2,x3,y3,x4,y4 = obj.w.body:getWorldPoints(obj.w.shape:getPoints())
			love.graphics.polygon("fill", x1+pCam,y1,x2+pCam,y2,x3+pCam,y3,x4+pCam,y4)
		else
			love.graphics.setColor(0.28, 0.63, 0.05)
			local x1,y1,x2,y2,x3,y3,x4,y4 = obj.f.body:getWorldPoints(obj.f.shape:getPoints())
			love.graphics.polygon("fill", x1+pCam,y1,x2+pCam,y2,x3+pCam,y3,x4+pCam,y4)
		end
		
		--racket
		love.graphics.setColor(1, 0, 0)
		local x1,y1,x2,y2,x3,y3,x4,y4 = obj.r.body:getWorldPoints(obj.r.shape:getPoints())
		love.graphics.polygon("fill", x1+pCam,y1,x2+pCam,y2,x3+pCam,y3,x4+pCam,y4)
		
		love.graphics.setColor(1, 1, 1)
	end)
	
	mx, my = push:toGame(love.mouse.getX(), love.mouse.getY())
	if mx and my then mwx, mwy = PM.toWorld(cam, mx, my) end
	
	canvas:renderTo(function()
		love.graphics.clear()
		love.graphics.setBackgroundColor(bgColor.r,bgColor.g,bgColor.b)
		PM.drawPlane(cam, tableimg)
		love.graphics.setColor(0,0,0,0.25)
		if ob == false then 
			PM.drawPlane(cam, ballimg, bx-11.5-bh/225, by-bh/300, 1/30+bh/100000, 1/30+bh/100000)
		else
			PM.drawPlane(cam, ballimg, obx-11.5-obh/225, oby-obh/300, 1/30+obh/100000, 1/30+obh/100000)
		end
		love.graphics.setColor(1,1,1)
		for i=0,36 do
			if wallmode == false then PM.placeSprite(cam, netimg, i*5, tableimg:getHeight()/2, 0, 6, 22)
			else PM.placeSprite(cam, wallimg, i*5, tableimg:getHeight()/2, 0, 6, 80) end
		end
		--paddle
		PM.placeSprite(cam, paddleimg, playerPos.x, playerPos.y, padRot.r, 30, 40, paddleimg:getWidth()/2, 400)
		for k, v in pairs(plrDataTable) do
			local x, y, r = string.match(v, "([-%d.]+),([-%d.]+),([-%d.]+)")
			if tonumber(x) ~= nil and tonumber(y) ~= nil and tonumber(r) ~= nil then
				PM.placeSprite(cam, paddleimg, tonumber(x), tonumber(y), pad2Rot.r, 30, 40, paddleimg:getWidth()/2, 400)
			end
		end
		--ball
		love.graphics.setColor(ballColor.r,ballColor.g,ballColor.b)
		if ob == false then
			if by <= tableimg:getHeight()/2 then PM.placeSprite(cam, ballimg, bx, by, 0, 20, 20, ballimg:getWidth()/2, bh+ballimg:getHeight()) end
			if by >= tableimg:getHeight()/2 then PM.placeSprite(cam, ballimg, bx, by, 0, 20, 20, ballimg:getWidth()/2, bh+ballimg:getHeight()) end
		elseif ob == true then
			if oby <= tableimg:getHeight()/2 then PM.placeSprite(cam, ballimg, obx, oby, 0, 20, 20, ballimg:getWidth()/2, obh+ballimg:getHeight()) end
			if oby >= tableimg:getHeight()/2 then PM.placeSprite(cam, ballimg, obx, oby, 0, 20, 20, ballimg:getWidth()/2, obh+ballimg:getHeight()) end
		end
		love.graphics.setColor(1,1,1)
		--PM.placeSprite(cam, playerimg, playerPos.x, playerPos.y, 0, 20, 15) 
		PM.renderSprites(cam)
	end)
	if typing == false then
		if love.keyboard.isDown("w") then
			cam.x=cam.x+math.cos(cam.r)*plrMoveSpeed*dt
			cam.y=cam.y+math.sin(cam.r)*plrMoveSpeed*dt
		elseif  love.keyboard.isDown("s") then
			cam.x=cam.x-math.cos(cam.r)*plrMoveSpeed*dt
			cam.y=cam.y-math.sin(cam.r)*plrMoveSpeed*dt
		end

		if love.keyboard.isDown("a") then
			cam.x=cam.x+math.cos(cam.r-math.pi/2)*plrMoveSpeed*dt
			cam.y=cam.y+math.sin(cam.r-math.pi/2)*plrMoveSpeed*dt
		elseif  love.keyboard.isDown("d") then
			cam.x=cam.x+math.cos(cam.r+math.pi/2)*plrMoveSpeed*dt
			cam.y=cam.y+math.sin(cam.r+math.pi/2)*plrMoveSpeed*dt
		end
		
		if love.keyboard.isDown("q") then
			cam:setRotation(cam:getRotation() - 0.05)
		elseif love.keyboard.isDown("e") then
			cam:setRotation(cam:getRotation() + 0.05)
		end
		
		if love.keyboard.isDown("r") then
			cam:setZoom(cam:getZoom() + 3)
		elseif love.keyboard.isDown("f") then
			cam:setZoom(cam:getZoom() - 3)
		end

		if love.keyboard.isDown("t") then
			cam:setFov(cam:getFov() + 1 * dt)
		elseif love.keyboard.isDown("g") then
			cam:setFov(cam:getFov() - 1 * dt)
		end
		
		if love.keyboard.isDown("left") then
			pCam = pCam + 10
		elseif love.keyboard.isDown("right") then
			pCam = pCam - 10
		end
	end
	
	if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
		plrMoveSpeed = 160
		shift = true
	else
		plrMoveSpeed = 80
		shift = false
	end
	if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
		ctrl = true
	else
		ctrl = false
	end
	
	if love.mouse.isDown(1) then
		if showPhysSims == false and shift == true and cheats == true then
			if bh > 1000 then b1b:applyForce(0,-30) end
			if bh < 1000 then b1b:applyForce(0,-70) end
			if bx > mwx then b1b:applyForce(-100,0) end
			if bx < mwx then b1b:applyForce(100,0) end
			if by > mwy then b2b:applyForce(-100,0) end
			if by < mwy then b2b:applyForce(100,0) end
		end
		if showPhysSims == true and shift == true and cheats == true then
			if mx and my then
				local mx2, my2 = mx-gameResX+400, my
				local bpx, bpy = b1b:getPosition()
				if bpx < mx2 then b1b:applyForce(50,0) end
				if bpx > mx2 then b1b:applyForce(-50,0) end
				if bpy < my2 then
					b1b:applyForce(0,50)
					b2b:applyForce(0,50)
				end
				if bpy > my2 then
					b1b:applyForce(0,-100)
					b2b:applyForce(0,-100)
				end
			end
		end
		if showPhysSims == true and ctrl == true and cheats == true then
			if mx and my then
				local mx2, my2 = mx-gameResX+400, my
				local bpx, bpy = b2b:getPosition()
				if bpx < mx2 then b2b:applyForce(50,0) end
				if bpx > mx2 then b2b:applyForce(-50,0) end
				if bpy < my2 then
					b2b:applyForce(0,50)
					b1b:applyForce(0,50)
				end
				if bpy > my2 then
					b2b:applyForce(0,-100)
					b1b:applyForce(0,-100)
				end
			end
		end
	end
	if love.mouse.isDown(2) then
		--[[if mwy < tableimg:getHeight()/2 and mwx <= 240 and mwx >= -60 then
			tweenTo = {x = mwx, y = mwy+25}
		elseif mwy >= tableimg:getHeight()/2 then
			tweenTo = {x = mwx, y = tableimg:getHeight()/2}
		elseif mwx > 240 then
			tweenTo = {x = 240, y = mwy+25}
		elseif mwx < -60 then
			tweenTo = {x = -60, y = mwy+25}
		end]]
		if tonumber(mwx) ~= nil and tonumber(mwy) ~= nil then tweenTo = {x = mwx, y = mwy} end
		playerTween = tween.new(playerSpeed, playerPos, {x = tweenTo.x, y = tweenTo.y}, 'linear')
		
		obj.r.body:setX(playerPos.y)
	end
	local complete = padTween:update(dt)
	local complete2 = playerTween:update(dt)
	local complete3 = camTween:update(dt)
	cam:setRotation(camTweenTo.r)
	
	--client stuff
	if client then
		client:update()
		if ip and port and not server then
			love.window.setTitle("client | "..ip..":"..port.." | "..client:getState().." | ping: "..client:getRoundTripTime())
		end
	end
	if connected == true then
		if disconnect == true and discSuccess == false then
			runCommand("disconnect")
		end
		if disconnect == true and discSuccess == true then
			trace.print("disconnected")
			client = nil
		end
		if disconnectExit == true and discSuccess == false then
			runCommand("disconnect")
		end
		if disconnectExit == true and discSuccess == true then
			trace.print("ready to exit")
			love.event.quit()
		end
	elseif connected == false then
		if disconnectExit == true then
			love.event.quit()
		end
	end
	if client then
		client:send("clientData", {
			client:getConnectId(),
			playerPos.x,
			playerPos.y,
			padSide,
			clientName
		})
	end
	--server stuff
	if server then
		server:update()
		if server and not client then
			love.window.setTitle("server | clients:"..cCount)
		elseif server and client then
			love.window.setTitle("server and client | clients:"..cCount.." | "..ip..":"..port.." | "..client:getState().." | ping: "..client:getRoundTripTime())
		end
		refreshTimer = refreshTimer + dt
		cCount = server:getClientCount()
		if client then
			client:update()
		end
		if cCount > 0 then
			if refreshTimer >= 5 then
				plrDataTable = {}
				server:sendToAll("refreshData") --asks clients to send their data every n seconds
				refreshTimer = 0
			end
		end
		server:sendToAllBut(client,"ballData",{bx,by,bh})
	end
end

function love.mousemoved(x, y, dx, dy)
	local mwx, mwy = PM.toWorld(cam, x, y)
	if love.mouse.getRelativeMode() == true then
		--cam:setRotation(cam:getRotation() + dx/plrRotSpeed)
	else
		
	end
	
	--cam.x = cam.x - dy/10
	--cam.y = cam.y + dx/10
	
	--padRot = padRot + dx/40
	--if padRot < -1.5 then padRot = -1.5 elseif padRot > 1.5 then padRot = 1.5 end
end

function love.mousepressed(x, y, button)
	local mwx, mwy = PM.toWorld(cam, x, y)
	if button == 1 then
		if padRot.r <= 0 then
			padTween = tween.new(0.1, padRot, {r = 2}, 'inQuad')
			padSide = 1
		end
		if padRot.r > 0 then
			padTween = tween.new(0.1, padRot, {r = -2}, 'inQuad')
			padSide = 0
		end
		if bh >= -10 and bh <= 750 then --ball hitting script
			if team == 1 and by >= playerPos.y-5 and by < playerPos.y+15 and bx > playerPos.x-25 and bx < playerPos.x+25 then
				b1b:applyLinearImpulse(love.math.random(-1,1),-7)
				b2b:applyLinearImpulse(6,-10)
			end
			if team == 2 and by <= playerPos.y+5 and by > playerPos.y-15 and bx > playerPos.x-25 and bx < playerPos.x+25 then
				b1b:applyLinearImpulse(love.math.random(-1,1),-7)
				b2b:applyLinearImpulse(-6,-10)
			end
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
	if key == "f1" then
		showPhysSims = not showPhysSims
	end
	if key == "f2" then
		if team == 1 then
			b1b:setPosition(80,200) 
			b2b:setPosition(20,600)
		else
			b1b:setPosition(100,200)
			b2b:setPosition(230,600)
		end
		b1b:setLinearVelocity(0,0)
		b2b:setLinearVelocity(0,0)
		b1b:setAngularVelocity(0)
		b2b:setAngularVelocity(0)
	end
	if key == "f3" then
		if wallmode == false then
			wallmode = true
			obj.w.fixture:setFilterData(1,0,1)
		else
			wallmode = false
			obj.w.fixture:setFilterData(1,0,0)
		end
	end
	if key == "f11" then
		push:switchFullscreen()
	end
	if key == "lalt" then
		love.mouse.setRelativeMode(not love.mouse.getRelativeMode())
	end
	if key == "m" then
		if typing == false then
			if team == 1 then
				team = 2
				tweenTo = {x=78,y=251}
				playerTween = tween.new(playerSpeed, playerPos, {x = tweenTo.x, y = tweenTo.y}, 'linear')
				camTween = tween.new(0.5, camTweenTo, {r = -math.pi/2}, 'linear')
				cam:setPosition(camDefs.x,camDefs.y)
				cam:setZoom(camDefs.z)
				cam:setOffset(camDefs.o)
				cam:setFov(camDefs.f)
			elseif team == 2 then
				team = 1
				tweenTo = {x=100,y=3}
				playerTween = tween.new(playerSpeed, playerPos, {x = tweenTo.x, y = tweenTo.y}, 'linear')
				camTween = tween.new(0.5, camTweenTo, {r = math.pi/2}, 'linear')
				cam:setPosition(camDefs.x,camDefs.y)
				cam:setZoom(camDefs.z)
				cam:setOffset(camDefs.o)
				cam:setFov(camDefs.f)
			end
		end
	end
	if key == cmdPrefix and typing == false then
		typing = true
	end
	if key == "return" and typing == false then
		typing = true
	elseif key == "return" and typing == true then
		local isCommand = false
		local s1 = string.sub(trace.tS, 1, 1)
		for k, v in pairs(commands) do
			if s1 == cmdPrefix then
				local m, n = string.find(trace.tS, tostring(v.com)) --command
				local m2, n2 = string.find(trace.tS, tostring(v.alias)) --command alias
				
				local tSnoc = ""
				if m == 2 and tonumber(n) == tonumber(string.len(tostring(v.com)))+1 then tSnoc = string.sub(trace.tS, n+2)
				elseif m2 == 2 and tonumber(n2) == tonumber(string.len(v.alias))+1 then tSnoc = string.sub(trace.tS, n2+2) end
				local args = {}
				for word in tSnoc:gmatch("%w+") do
					table.insert(args, word)
				end
				
				if m == 2 and tonumber(n) == tonumber(string.len(tostring(v.com)))+1 then
					runCommand(tostring(v.com), args)
					trace.tS = ""
					isCommand = true
				elseif m2 == 2 and tonumber(n2) == tonumber(string.len(v.alias))+1 then
					runCommand(tostring(v.com), args)
					trace.tS = ""
					isCommand = true
				end
			end
		end
		if isCommand == false and trace.tS ~= "" then
			trace.printTyping(clientName..": ", trace.styles[clientColor])
			trace.tS = ""
		end
		isCommand = false
		typing = false
	end
	if typing == true then
		trace.type(key, shift, ctrl)
		trace.arrow = true
	else
		trace.arrow = false
	end
end

function love.wheelmoved(x, y)
	if y > 0 then
		cam:setOffset(cam:getOffset() + y/40)
	elseif y < 0 then
		cam:setOffset(cam:getOffset() + y/40)
	end
end

function love.resize(w, h)
	push:resize(w, h)
end

function hostServer(port)
	hosting = true
	server = sock.newServer("*", port, 20)
	server:setSerialization(bitser.dumps, bitser.loads)
	if compression == true then server:enableCompression() end
	trace.print("hosting server on port "..port)
	
	cCount = 0
	
	server:on("connect", function(data, clientf)
		--server:sendToPeer(server:getPeerByIndex(clientf:getIndex()), "image", mapdata)
		server:sendToAllBut(clientf, "messageClient", {"client "..client:getConnectId().." connected", "green"})
	end)
	server:on("disconnect", function(data, clientf)
	end)
	server:on("disconnect2", function(data, clientf)
		local clientfName = "nil"
		for k, v in pairs(plrDataTable) do
			if k == data.clientId then
				clientfName = string.match(v, "([^.]-),")
				plrDataTable[k] = nil
			end
		end
		server:sendToPeer(server:getPeerByIndex(clientf:getIndex()), "discSuccess")
		--trace.print("client "..data.clientId.." ("..clientfName..") disconnected", trace.styles.red)
		server:sendToAllBut(clientf, "messageClient", {"client "..data.clientId.." ("..clientfName..") disconnected", "red"})
	end)
	server:setSchema("message", {
		"msg",
		"color"
	})
	server:on("message", function(data, clientf)
		trace.print(data.msg, trace.styles[data.color])
		if hosting == true and connected == true then
			if cCount > 2 then
				server:sendToAllBut(client, "messageClient", data) --this is what's causing the problem
			end
		elseif hosting == true and connected == false then
			if cCount > 1 then
				server:sendToAllBut(client, "messageClient", data)
			end
		end
	end)
	server:setSchema("clientData", {
		"clientId",
		"x",
		"y",
		"padSide",
		"clientName"
	})
	server:on("clientData", function(data, clientf)
		if data.clientId ~= client:getConnectId() then
		plrDataTable[data.clientId] = data.clientName..","..data.x..","..data.y..","..data.padSide
		pad2Side = data.padSide
			if pad2Side ~= lastPadSide then
				if pad2Side == 0 then
					pad2Side = 0
					padTween = tween.new(0.1, pad2Rot, {r = -2}, 'inQuad')
				elseif pad2Side == 1 then
					padTween = tween.new(0.1, pad2Rot, {r = 2}, 'inQuad')
				end
				lastPadSide = pad2Side
			end
		end
		if cCount > 1 then
			server:sendToAllBut(clientf, "otherPlayersClientData", {data.clientId, data.x, data.y, data.padSide, data.clientName})
		end
	end)
end

function connectToServer(ip,port)
	trace.print("trying connection to "..tostring(ip)..":"..tostring(port), trace.styles.purple)
	client = sock.newClient(tostring(ip), tonumber(port))
	client:setSerialization(bitser.dumps, bitser.loads)
	if compression == true then client:enableCompression() end
	client:on("connect", function(data)
		lastClientId = client:getConnectId()
		trace.print("you connected to the server", trace.styles.green)
	end)
	client:on("disconnect", function(data)
		trace.print("you disconnected from the server")
		connected = false
	end)
	client:on("image", function(data)
		if not server then
			local file = love.filesystem.newFileData(data, "map")
			local receivedImage = love.image.newImageData(file)
			mapimg = love.graphics.newImage(receivedImage)
			trace.print("map received", trace.styles.green)
		end
	end)
	client:setSchema("messageClient", {
		"msg",
		"color"
	})
	client:on("messageClient", function(data)
		trace.print(data.msg, trace.styles[data.color])
	end)
	client:setSchema("otherPlayersClientData", {
		"clientId",
		"x",
		"y",
		"padSide",
		"clientName"
	})
	client:on("otherPlayersClientData", function(data)
		plrDataTable[data.clientId] = data.x..","..data.y..","..data.padSide
		if server == nil then
			pad2Side = data.padSide
			if pad2Side ~= lastPadSide then
				if pad2Side == 0 then
					pad2Side = 0
					padTween = tween.new(0.1, pad2Rot, {r = -2}, 'inQuad')
				elseif pad2Side == 1 then
					padTween = tween.new(0.1, pad2Rot, {r = 2}, 'inQuad')
				end
				lastPadSide = pad2Side
			end
		end
	end)
	client:setSchema("ballData", {
		"bx",
		"by",
		"bh"
	})
	client:on("ballData", function (data)
		obx = data.bx
		oby = data.by
		obh = data.bh
		ob = true
	end)
	client:on("refreshData", function (data) 
		client:send("clientData", {
			client:getConnectId(),
			playerPos.x,
			playerPos.y,
			padSide,
			clientName
		})
	end)
	client:on("discSuccess", function (data)
		discSuccess = true
	end)
	client:connect()
	connected = true
	clientName = client:getConnectId()
end

