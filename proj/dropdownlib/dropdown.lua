--for making drop-down menus on the go
--programmed by joey :)

local dropdown = {
	options = {
		"Place a card", -- example
		"Remove this card",
		"Place a deck of 52",
	},
	enabled = false,
	x = 0, --x,y is where you clicked and what you should use to determine the position of the dropdown
	y = 0,
	posx = 0, --posx,posy is only if the dropdown is off screen and needs to be placed farther up
	posy = 0,
	sizex = 150,
	sizey = 20,
	fadeIn = true,
	fadeSpeed = 1/50,
}
local fade = 1

local function newDropDown(x,y,options)
	dropdown.options = options
	dropdown.x = x
	dropdown.y = y
	local font = love.graphics.newFont(12)
	local lengths = {}
	for i,v in ipairs(options) do
		local t = love.graphics.newText(font,v[2])
		local l = t:getWidth() + 10
		table.insert(lengths,l)
	end
	local maxl = math.max(unpack(lengths)) --determines how long the sizex should be
	dropdown.sizex = maxl
	if x > love.graphics.getWidth()-dropdown.sizex then
		dropdown.posx = dropdown.x - dropdown.sizex
	else
		dropdown.posx = dropdown.x
	end
	if y > love.graphics.getHeight()-dropdown.sizey*#options then
		dropdown.posy = dropdown.y - dropdown.sizey*#options
	else
		dropdown.posy = dropdown.y
	end
	if dropdown.fadeIn == true then
		fade = 0
	end
	dropdown.enabled = true
end

local function disable()
	
	dropdown.options = {}
	dropdown.enabled = false
	dropdown.x, dropdown.y = 0,0
	dropdown.posx, dropdown.posy = 0,0
end

local function draw(mx,my) --hook into love.draw
	if fade <= 1 then
		fade = fade + dropdown.fadeSpeed
	end
	if dropdown.enabled == true then
		for i,v in ipairs(dropdown.options) do
			if v[1] ~= 0 and mx > dropdown.posx and mx < dropdown.posx+dropdown.sizex and my > (dropdown.posy+i*dropdown.sizey)-dropdown.sizey and my < (dropdown.posy+i*dropdown.sizey) then
				love.graphics.setColor(127/255, 159/255, 255/255,fade) --color when item selected
			elseif v[1] == 0 and mx > dropdown.posx and mx < dropdown.posx+dropdown.sizex and my > (dropdown.posy+i*dropdown.sizey)-dropdown.sizey and my < (dropdown.posy+i*dropdown.sizey) then
				love.graphics.setColor(180/255,180/255,180/255,fade)
			else
				love.graphics.setColor(190/255, 190/255, 190/255,fade) --color when item not selected
			end
			love.graphics.rectangle("fill",dropdown.posx,(dropdown.posy+i*dropdown.sizey)-dropdown.sizey,dropdown.sizex,dropdown.sizey)
			love.graphics.setColor(0,0,0,fade)
			love.graphics.rectangle("line",dropdown.posx,(dropdown.posy+i*dropdown.sizey)-dropdown.sizey,dropdown.sizex,dropdown.sizey)
			love.graphics.setColor(0,0,0,fade)
			love.graphics.printf(v[2],dropdown.posx+5,(dropdown.posy+i*dropdown.sizey)-17,dropdown.sizex,"left")
			love.graphics.setColor(1,1,1)
		end
	end
end

local function click(mx,my,button) --hook into love.mousepressed
	if button == 1 then
		for i,v in ipairs(dropdown.options) do
			if dropdown.enabled == true and v[1] ~= 0 then
				if mx > dropdown.posx and mx < dropdown.posx+dropdown.sizex and my > (dropdown.posy+i*dropdown.sizey)-dropdown.sizey and my < (dropdown.posy+i*dropdown.sizey) then
					dropdown.enabled = false
					return dropdown.opCode(v[1])
				end
			end
		end
		dropdown.disable()
	end
end

dropdown.newDropDown = newDropDown
dropdown.disable = disable
dropdown.draw = draw
dropdown.click = click
dropdown.opCode = opCode
return dropdown