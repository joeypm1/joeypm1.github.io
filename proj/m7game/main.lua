--c l i e n t and server

local PM = require "playmat"
local push = require "push"
local sock = require "sock"
local bitser = require "bitser"
local binser = require "binser"
local trace = require "trace"
plrDataTable = {}
typing = false
shift = false
ctrl = false
mapimg = nil
cmdPrefix = "/"
client = nil
clientName = ""
clientColor = "blue"
lastClientId = ""
discSuccess = false
connected = false
disconnect = false
disconnectExit = false
ip, port = "73.244.29.108", 6096 -- doesn't do anything, just sets the variable

server = nil
cCount = 0
hosting = false
hostip, hostport = "*", 6096
refreshTimer = 0

showPhysSims = false

local commands = {
	{com = "help", desc = "Displays commands and their descriptions (ex. /help 1) (ex2. /help alias)", alias = "h"},
	{com = "alias", desc = "Displays aliases to commands", alias = "a"},
	{com = "var", desc = "", alias = "v"},
	{com = "testcom", desc = "Test command description", alias = "tc"},
	{com = "connect", desc = "Connects to a server (ex. /connect localhost:6096)", alias = "conn"},
	{com = "disconnect", desc = "Disconnects from the server you are connected to", alias = "disc"},
	{com = "nick", desc = "Changes your name (ex. /nick grandpa)"},
	{com = "color", desc = "Changes the color that your messages appear in (ex. /color purple)"},
	{com = "serverhost", desc = "Host server (ex. /serverhost 1234)", alias = "shost"}
}

local function runCommand(command, arg1)
	if command == "help" then
		if arg1 == "" or arg1 == "1" then
			trace.print("-=Help page=- total commands:"..#commands, trace.styles.green)
			for i=1,5 do
				if commands[i] then
					trace.print(i..": "..commands[i].com..": "..commands[i].desc)
				end
			end
		elseif arg1 == "2" then
			trace.print("-=Help page "..arg1.."=-", trace.styles.green)
			for i=6,10 do
				if commands[i] then
					trace.print(i..": "..commands[i].com..": "..commands[i].desc)
				end
			end
		elseif arg1 == "3" then
			trace.print("-=Help page "..arg1.."=-", trace.styles.green)
			for i=11,15 do
				if commands[i] then
					trace.print(i..": "..commands[i].com..": "..commands[i].desc)
				end
			end
			
		else
			for k,v in pairs(commands) do
				if arg1 == v.com or arg1 == v.alias then
					trace.print("-=Help page: "..v.com.."=-", trace.styles.green)
					trace.print(k..": "..v.com..": "..v.desc)
				end
			end
		end
		
	end
	if command == "alias" then
		if arg1 == "" or arg1 == "1" then
			trace.print("-=Aliases=-", trace.styles.green)
			for i=1,5 do
				if commands[i] and commands[i].alias then
					trace.print(i.." = "..commands[i].com..": "..commands[i].alias)
				end
			end
		elseif arg1 == "2" then
			trace.print("-=Alias page "..arg1.."=-", trace.styles.green)
			for i=6,10 do
				if commands[i] and commands[i].alias then
					trace.print(i.." = "..commands[i].com..": "..commands[i].alias)
				end
			end
		elseif arg1 == "3" then
			trace.print("-=Alias page "..arg1.."=-", trace.styles.green)
			for i=11,15 do
				if commands[i] and commands[i].alias then
					trace.print(i.." = "..commands[i].com..": "..commands[i].alias)
				end
			end
			
		else
			for k,v in pairs(commands) do
				if v.alias then
					if arg1 == v.com or arg1 == v.alias then
						trace.print("-=Alias: "..v.com.."=-", trace.styles.green)
						trace.print(k.." = "..v.com..": "..v.alias)
					end
				else
					if arg1 == v.com then
						trace.print("-=No alias for "..v.com.."=-", trace.styles.green)
					end
				end
			end
		end
	end
	if command == "var" then
		if arg1 == "" or arg1 == " " or arg1 == "list" then
			local list = ""
			for k, v in pairs(_G) do
				list = list..tostring(k).." "
			end
			trace.print(list,trace.styles.green)
		else
			if type(_G[arg1]) == "table" then
				for k, v in pairs(_G[arg1]) do
					trace.print(k.." = "..v, trace.styles.green)
				end
			else
				trace.print(arg1.." = "..tostring(_G[arg1]), trace.styles.green)
			end
		end
	end
	if command == "testcom" then
		trace.print("test command worked. arg1="..tostring(arg1))
	end
	if command == "connect" then
		if arg1 == "" or arg1 == " " then
			trace.print("type '/connect main' to connect to the main server (if open)", trace.styles.red)
		else
			if connected == false then
				if arg1:find(":") == nil then
					ip = arg1
					port = 6096
				else
					ip, port = string.match(arg1, "(.+):(.+)")
				end
				if arg1 == "main" then
					ip = "73.244.29.108"
					port = 6096
				end
				connectToServer(ip,port)
			else
				trace.print("you are already connected to a server")
			end
		end
	end
	if command == "disconnect" then
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
		if arg1 == "" then
			if client then
				clientName = tostring(client:getConnectId())
			else
				clientName = "0"
			end
		else
			clientName = arg1
		end
		trace.print("name set to "..clientName)
	end
	if command == "color" then
		if arg1 ~= "" then
			clientColor = tostring(arg1)
			trace.print("color set to "..clientColor,trace.styles[clientColor])
		else
			local s1 = ""
			for k,v in pairs(trace.styles) do
				s1 = s1..k..", "
			end
			s1 = string.sub(s1, 1, s1:len()-2)
			trace.print("colors: "..s1)
		end
	end
	if command == "serverhost" then
		if arg1 == "" or arg1 == " " then
			if hosting == false then
				hostServer(6096)
				connectToServer("localhost",6096)
			end
		else
			if hosting == false then
				arg1num = tonumber(arg1)
				if arg1num then
					hostServer(arg1num)
					connectToServer("localhost",arg1num)
				end
			end
		end
	end
end

function love.load()
	love.window.setTitle("m7")
	love.mouse.setRelativeMode(false)
	love.graphics.setDefaultFilter('nearest','nearest')
	trace.limit = 10
	trace.hlimit = 150

	love.filesystem.setIdentity("m7game")

	gameResX, gameResY = 960, 540 --game resolution
	screenResX, screenResY = 960, 540 --window resolution
	push:setupScreen(gameResX,gameResY,screenResX,screenResY,{fullscreen = false, resizable = true, stretched = false, canvas = true})
	pw1 = love.graphics.newCanvas(1920,1025)
	
	cam = PM.newCamera(gameResX,gameResY) --Sets up a new camera, resolution is 800 x 600 by default.
	cam:setPosition(0,0)
	cam:setZoom(48)
	cam:setOffset(0.8)

	mapdata = love.filesystem.newFileData("resources/map.png")
	spriteimg = love.graphics.newImage("resources/sprite.png")
	ballimg = love.graphics.newImage("resources/ball.png")
	plrRotSpeed = 80
	plrMoveSpeed = 80
	
	trace.print("haha this is so funny i will share it with my friends and family", trace.styles.red)
	--typing = true
	--trace.tS = "/connect "..ip..":"..port
	
	--physics oh shit
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)
	obj = {}
	obj.g1 = {}
	obj.g1.body = love.physics.newBody(world,200,400)
	obj.g1.shape = love.physics.newRectangleShape(10000,50)
	obj.g1.fixture = love.physics.newFixture(obj.g1.body, obj.g1.shape, 1)
	obj.g1.fixture:setFriction(1)
	
	obj.b1 = {}
	obj.b1.body = love.physics.newBody(world, 0, 200, "dynamic")
	obj.b1.shape = love.physics.newCircleShape(20)
	obj.b1.fixture = love.physics.newFixture(obj.b1.body, obj.b1.shape, 0.25)
	obj.b1.fixture:setRestitution(0.5)
	obj.b1.fixture:setFriction(1)
	obj.b1.body:setSleepingAllowed(false)
	b1b = obj.b1.body
	
	obj.g2 = {}
	obj.g2.body = love.physics.newBody(world,0,800)
	obj.g2.shape = love.physics.newRectangleShape(10000,50)
	obj.g2.fixture = love.physics.newFixture(obj.g2.body, obj.g2.shape, 1)
	obj.g2.fixture:setFriction(1)
	
	obj.b2 = {}
	obj.b2.body = love.physics.newBody(world, 200, 600, "dynamic")
	obj.b2.shape = love.physics.newCircleShape(20)
	obj.b2.fixture = love.physics.newFixture(obj.b2.body, obj.b2.shape, 0.25)
	obj.b2.fixture:setRestitution(0.5)
	obj.b2.fixture:setFriction(1)
	obj.b2.body:setSleepingAllowed(false)
	b2b = obj.b2.body
	b1b:setPosition(100,200)
	b2b:setPosition(125,600)
	
	--network stuff (client)
end

function love.draw()
	push:start()
	love.graphics.setBackgroundColor(0,0,0)
	if mapimg then
		if server or client then
			PM.drawPlane(cam, mapimg)
		end
		local camxs, camys, cams = PM.toScreen(cam, cam.x, cam.y)
		local cambxs, cambys, cambs = PM.toScreen(cam, bx, by)
		local length = string.len(clientName)
		--ball lmao & nametags
		love.graphics.setColor(1,0,0)
		if tonumber(bx) ~= nil and tonumber(by) ~= nil and tonumber(bh) ~= nil then
			love.graphics.draw(ballimg, cambxs, cambys-cambs, 0, cambs/43.25, cambs/43.25, ballimg:getWidth()/2, bh)
			--PM.placeSprite(cam, ballimg, bx, by, 0, 15, 15, ballimg:getWidth()/2, bh)
		end
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill", cambxs-(length+11)/2*cambs, cambys-16*cambs, (length+11)*cambs, 2.75*cambs, 1*cambs, 1*cambs)
		love.graphics.setColor(1,1,1)
		love.graphics.printf({{trace.styles[clientColor].r,trace.styles[clientColor].g,trace.styles[clientColor].b},clientName.."'s ball"}, cambxs, cambys-16*cambs, 200, "center", 0, cambs/6, cambs/6, 200/2)
		--player
		PM.placeSprite(cam, spriteimg, cam.x,cam.y, 0, 8, 8)
		--nametags
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill", camxs-(length+3)/2*cams, camys-11*cams, (length+3)*cams, 2.75*cams, 1*cams, 1*cams)
		love.graphics.setColor(1,1,1)
		love.graphics.printf({{trace.styles[clientColor].r,trace.styles[clientColor].g,trace.styles[clientColor].b},clientName}, camxs, camys-11*cams, 200, "center", 0, cams/6, cams/6, 200/2)
	end
	if showPhysSims == true then love.graphics.draw(pw1, gameResX-400, 0, 0, 1, 1) end
	for k, v in pairs(plrDataTable) do
		if k ~= client:getConnectId() then
			local name, x, y, pbx, pby, pbh = string.match(v, "([^.]-),([-%d.]+),([-%d.]+),([-%d.]+),([-%d.]+),([-%d.]+)")
			if tonumber(x) ~= nil and tonumber(y) ~= nil and tonumber(pbx) ~= nil and tonumber(pby) ~= nil and tonumber(pbh) ~= nil then
				local wx, wy, ws = PM.toScreen(cam, tonumber(x), tonumber(y))
				local wx2, wy2, ws2 = PM.toScreen(cam, tonumber(pbx), tonumber(pby))
				local length = string.len(name)
				--player and nametag
				PM.placeSprite(cam, spriteimg, tonumber(x), tonumber(y), 0, 8, 8)
				love.graphics.setColor(0,0,0)
				love.graphics.rectangle("fill", wx-(length+3)/2*ws, wy-11*ws, (length+3)*ws, 2.75*ws, 1*ws, 1*ws)
				love.graphics.setColor(1,1,1)
				love.graphics.printf(name, wx, wy-11*ws, 200, "center", 0, ws/6, ws/6, 200/2)
				--ball lmao & nametag
				love.graphics.setColor(1,0,0)
				PM.placeSprite(cam, ballimg, tonumber(pbx), tonumber(pby), 0, 15, 15, ballimg:getWidth()/2, tonumber(pbh))
				love.graphics.setColor(0,0,0)
				love.graphics.rectangle("fill", wx2-(length+11)/2*ws2, wy2-16*ws2, (length+11)*ws2, 2.75*ws2, 1*ws2, 1*ws2)
				love.graphics.setColor(1,1,1)
				love.graphics.printf(name.."'s ball", wx2, wy2-16*ws2, 200, "center", 0, ws2/6, ws2/6, 200/2)
			end
		end
	end
	PM.renderSprites(cam)
	push:finish()
	love.graphics.print("fps "..love.timer.getFPS(), love.graphics.getWidth()/2, 0)
	if not mapimg and client then
		love.graphics.printf("not connected", love.graphics.getWidth()/2, love.graphics.getHeight()/2, 108, "center", 0, 1, 1, 54, 10)
	end
	trace.draw(0,0)
end

function love.update(dt)
	if client and disconnect == false and disconnectExit == false then
		client:send("clientData", {
			client:getConnectId(),
			cam.x,
			cam.y,
			clientName,
			bx,
			by,
			bh
		})
	end

	--physics lmao
	world:update(dt)
	bx, by, bh = (b1b:getX()), (b2b:getX()), ballimg:getHeight()-b1b:getY()*4+330*4
	pw1:renderTo(function()
		love.graphics.clear()
		love.graphics.setColor(0.28, 0.63, 0.05)
		love.graphics.polygon("fill", obj.g1.body:getWorldPoints(obj.g1.shape:getPoints()))
		love.graphics.setColor(0.76, 0.18, 0.05)
		love.graphics.circle("fill", b1b:getX(), b1b:getY(), obj.b1.shape:getRadius())
		
		love.graphics.setColor(0.28, 0.63, 0.05)
		love.graphics.polygon("fill", obj.g2.body:getWorldPoints(obj.g2.shape:getPoints()))
		love.graphics.setColor(0.76, 0.18, 0.05)
		love.graphics.circle("fill", b2b:getX(), b2b:getY(), obj.b2.shape:getRadius())
		
		love.graphics.setColor(1, 1, 1)
	end)
	
	if love.mouse.isDown(1) then
		if showPhysSims == false and shift == true and love.mouse.getRelativeMode() == false then
			if bh > 1000 then b1b:applyForce(0,-30) end
			if bh < 1000 then b1b:applyForce(0,-100) end
			if bx > mwx then b1b:applyForce(-50,0) end
			if bx < mwx then b1b:applyForce(50,0) end
			if by > mwy then b2b:applyForce(-50,0) end
			if by < mwy then b2b:applyForce(50,0) end
		elseif showPhysSims == false and shift == true and love.mouse.getRelativeMode() == true then
			if bh > 1000 then b1b:applyForce(0,-30) end
			if bh < 1000 then b1b:applyForce(0,-100) end
			if bx > cam.x then b1b:applyForce(-50,0) end
			if bx < cam.x then b1b:applyForce(50,0) end
			if by > cam.y then b2b:applyForce(-50,0) end
			if by < cam.y then b2b:applyForce(50,0) end
		end
		if showPhysSims == true and shift == true then
			if mx and my then
				local mx2, my2 = mx-gameResX+400, my
				local bpx, bpy = b1b:getPosition()
				if bpx < mx2 then b1b:applyForce(100,0) end
				if bpx > mx2 then b1b:applyForce(-100,0) end
				if bpy < my2 then
					b1b:applyForce(0,50)
					b2b:applyForce(0,50)
				end
				if bpy > my2 then
					b1b:applyForce(0,-300)
					b2b:applyForce(0,-300)
				end
			end
		end
		if showPhysSims == true and ctrl == true then
			if mx and my then
				local mx2, my2 = mx-gameResX+400, my
				local bpx, bpy = b2b:getPosition()
				if bpx < mx2 then b2b:applyForce(100,0) end
				if bpx > mx2 then b2b:applyForce(-100,0) end
				if bpy < my2 then
					b2b:applyForce(0,50)
					b1b:applyForce(0,50)
				end
				if bpy > my2 then
					b2b:applyForce(0,-300)
					b1b:applyForce(0,-300)
				end
			end
		end
	end
	
	mx, my = push:toGame(love.mouse.getX(), love.mouse.getY())
	if mx and my then mwx, mwy = PM.toWorld(cam, mx, my) end
	
	if typing ~= true and client then
		if love.keyboard.isDown("q") then
			cam:setRotation(cam:getRotation() - 4 * dt,0)
		elseif love.keyboard.isDown("e") then
			cam:setRotation(cam:getRotation() + 4 * dt)
		end
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
		if love.keyboard.isDown("r") and cam:getZoom() < 300 then
			cam:setZoom(cam:getZoom() + 3)
		elseif love.keyboard.isDown("f") and cam:getZoom() > 3 then
			cam:setZoom(cam:getZoom() - 3)
		end
		if love.keyboard.isDown("t") and cam:getFov() < 5 then
			cam:setFov(cam:getFov() + 1 * dt)
		elseif love.keyboard.isDown("g") and cam:getFov() > 0.1 then
			cam:setFov(cam:getFov() - 1 * dt)
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
	
	--client stuff
	if client then
		client:update()
		if ip and port and not server then
			love.window.setTitle("m7client | "..ip..":"..port.." | "..client:getState().." | ping: "..client:getRoundTripTime())
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
	
	--server stuff
	if server then
		server:update()
		if server and not client then
			love.window.setTitle("m7server | clients:"..cCount)
		elseif server and client then
			love.window.setTitle("m7server and client | clients:"..cCount.." | "..ip..":"..port.." | "..client:getState().." | ping: "..client:getRoundTripTime())
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
	end
end

function love.mousemoved(x, y, dx, dy)
	if love.mouse.getRelativeMode() == true then
		cam:setRotation(cam:getRotation() + dx/plrRotSpeed)
	end
end

function love.mousepressed(x, y, b)
	if b == 1 then
		PM.placeSprite(cam, spriteimg, mwx, mwy, 0, 8, 8)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		disconnectExit = true
	end
	if key == "lalt" then
		if love.mouse.getRelativeMode() == true then
			love.mouse.setRelativeMode(false)
		elseif love.mouse.getRelativeMode() == false then
			love.mouse.setRelativeMode(true)
		end
	end
	if key == "f1" then
		trace.print("connectId="..client:getConnectId())
		trace.print("index="..client:getIndex())
	end
	if key == "f2" then
		plrDataTable = {}
		trace.print("cleared player data table", trace.styles.red)
	end
	if key == "f3" then
		showPhysSims = not showPhysSims
	end
	if key == "f4" then
		b1b:setPosition(cam.x,200)
		b2b:setPosition(cam.y,600)
		b1b:setLinearVelocity(0,0)
		b2b:setLinearVelocity(0,0)
		b1b:setAngularVelocity(0)
		b2b:setAngularVelocity(0)
	end
	if key == "f11" then
		push:switchFullscreen()
	end
	if key == cmdPrefix and typing == false then
		typing = true
	end
	if key == "return" and typing == false then
		typing = true
	elseif key == "return" and typing == true then
		local isCommand = false
		for k, v in pairs(commands) do
			local s1 = string.sub(trace.tS, 1, 1)
			if s1 == cmdPrefix then
				local m, n = string.find(trace.tS, tostring(v.com)) --command
				local m2, n2 = string.find(trace.tS, tostring(v.alias)) --command alias
				if m == 2 and tonumber(n) == tonumber(string.len(tostring(v.com)))+1 then
					local arg = string.sub(trace.tS, n+2)
					runCommand(tostring(v.com), arg)
					trace.tS = ""
					isCommand = true
				elseif m2 == 2 and tonumber(n2) == tonumber(string.len(v.alias))+1 then
					local arg = string.sub(trace.tS, n2+2)
					runCommand(tostring(v.com), arg)
					trace.tS = ""
					isCommand = true
				end
			end
		end
		if isCommand == false and trace.tS ~= "" then
			if connected == true and hosting == false then
				client:send("message", {clientName..": "..trace.tS, tostring(clientColor)})
				trace.printTyping(clientName..": ", trace.styles[clientColor])
			end
			if hosting == true then
				server:sendToAll("messageClient", {clientName.." (host)- "..trace.tS, tostring(clientColor)})
				trace.printTyping(clientName.." (host)- ", trace.styles[clientColor])
			end
			if connected == false and hosting == false then
				trace.printTyping(clientName..": ", trace.styles[clientColor])
			end
		end
		trace.tS = ""
		isCommand = false
		typing = false
	end
	if typing == true then
		trace.type(key, shift, ctrl)
		trace.arrow = true
	else trace.arrow = false end
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

function love.filedropped(file)
	if file and server then
		mapimg = love.graphics.newImage(file)
		mapdata = love.filesystem.newFileData(file)
		trace.print("map changed to "..file:getFilename())
		server:sendToAll("image", mapdata)
	--[[else
		spriteimg = love.graphics.newImage(file)
		spritedata = love.filesystem.newFileData(file)
		trace.print("sprite changed", trace.styles.green)
		if client then
			client:send("changeSprite", sprite)
		end]]
	end
end

function love.quit()
	
end

function hostServer(port)
	hosting = true
	server = sock.newServer("*", port, 20)
	server:setSerialization(bitser.dumps, bitser.loads)
	server:enableCompression()
	trace.print("hosting server on port "..port)
	mapimg = love.graphics.newImage("resources/map.png")
	
	cCount = 0
	
	server:on("connect", function(data, clientf)
		server:sendToPeer(server:getPeerByIndex(clientf:getIndex()), "image", mapdata)
		--trace.print("client "..client:getConnectId().." connected", trace.styles.green)
		server:sendToAllBut(clientf, "messageClient", {"client "..client:getConnectId().." connected", "green"})
	end)
	server:on("disconnect", function(data, clientf)
	end)
	server:on("disconnect2", function(data, clientf)
		local clientfName = "nil"
		for k, v in pairs(plrDataTable) do
			if k == data.clientId then
				clientfName, x, y, bx, by = string.match(v, "([^.]-),([-%d.]+),([-%d.]+),([-%d.]+),([-%d.]+)")
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
		server:sendToAllBut(clientf, "messageClient", {data.msg, data.color})
	end)
	server:setSchema("clientData", {
		"clientId",
		"x",
		"y",
		"clientName",
		"bx",
		"by",
		"bh"
	})
	server:on("clientData", function(data, clientf)
		plrDataTable[data.clientId] = data.clientName..","..data.x..","..data.y..","..data.bx..","..data.by..","..data.bh
		if cCount > 1 then
			server:sendToAllBut(clientf, "otherPlayersClientData", {data.clientId, data.x, data.y, data.clientName, data.bx, data.by, data.bh})
		end
	end)
end

function connectToServer(ip,port)
	trace.print("trying connection to "..tostring(ip)..":"..tostring(port), trace.styles.purple)
	client = sock.newClient(tostring(ip), tonumber(port))
	client:setSerialization(bitser.dumps, bitser.loads)
	client:enableCompression()
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
		if hosting == false then trace.print(data.msg, trace.styles[data.color]) end
	end)
	client:setSchema("otherPlayersClientData", {
		"clientId",
		"x",
		"y",
		"clientName",
		"bx",
		"by",
		"bh"
	})
	client:on("otherPlayersClientData", function(data)
		if hosting == false then
			plrDataTable[data.clientId] = data.clientName..","..data.x..","..data.y..","..data.bx..","..data.by..","..data.bh
		end
	end)
	client:on("refreshData", function (data) 
		client:send("clientData", {
			client:getConnectId(),
			cam.x,
			cam.y,
			clientName,
			bx,
			by,
			bh
		})
	end)
	client:on("discSuccess", function (data)
		discSuccess = true
	end)
	client:connect()
	connected = true
	clientName = client:getConnectId()
end
