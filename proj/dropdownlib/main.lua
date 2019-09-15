local dropdown = require 'dropdown'

function dropdown.opCode(id)
	string = "pressed option "..id
	if id == 1 then --place rectangle
		local o = {"rect", "white", dropdown.x, dropdown.y, false}
		table.insert(objects,o)
	elseif id == 2 then
		local o = {"circ", "white", dropdown.x, dropdown.y}
		table.insert(objects,o)
	elseif id == 3 then
		local o = {"circ", "red", dropdown.x, dropdown.y}
		table.insert(objects,o)
	elseif id == 4 then
		local o = {"rect", "red", dropdown.x, dropdown.y, true}
		table.insert(objects,o)
	end
end

function love.load()
	love.window.updateMode(800,600,{resizable = true})
	love.window.setTitle("dropdown demo")
	local string = ""
	objects = {
		{"rect", "white", 100, 125, true},
	}
end

function love.draw()
	mx, my = love.mouse.getX(),love.mouse.getY()
	love.graphics.print(string,0,0,0,1.5,1.5)
	love.graphics.print("press 1 to toggle fading in, you can change the fade speed in the lib",0,30)
	for i,v in ipairs(objects) do
		love.graphics.setColor(1,1,1)
		if v[1] == "rect" and v[5] == false then love.graphics.rectangle("fill", v[3], v[4], 60, 20) end
		if v[1] == "circ" and v[2] == "white" then love.graphics.circle("fill", v[3], v[4], 20) end
		love.graphics.setColor(1,0,0)
		if v[1] == "circ" and v[2] == "red" then love.graphics.circle("fill", v[3], v[4], 20) end
		if v[1] == "rect" and v[5] == true then love.graphics.rectangle("fill", v[3], v[4], 60, 20, 12, 10) end
		love.graphics.setColor(1,1,1)
	end
	dropdown.draw(mx, my)
end

function love.mousepressed(x,y,button)
	dropdown.click(mx, my, button)
	
	if button == 2 then
		if dropdown.enabled == false then
			dropdown.newDropDown(mx, my, {
				{1, "place a rectangle"},
				{2, "place a circle"},
				{3, "place a red circle"},
				{4, "place a red rectangle with rounded edges"},
				{0, "this option will not highlight in blue and will not do anything"}
			})
		else dropdown.disable() end
	end
end

function love.keypressed(k)
	if k == "1" then
		dropdown.fadeIn = not dropdown.fadeIn
	end
end