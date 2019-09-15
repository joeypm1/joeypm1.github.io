
local trace = {
	textl = { },
	stylel = { },
	styles = {
		white = { r = 255/255, g = 255/255, b = 255/255 },
		red = { r = 255/255, g = 127/255, b = 127/255 },
		green = { r = 191/255, g = 255/255, b = 127/255 },
		blue = { r = 127/255, g = 159/255, b = 255/255 },
		purple = { r = 160/255, g = 32/255, b = 240/255 },
		yellow = { r = 255/255, g = 255/255, b = 0/255 },
		cyan = { r = 0/255, g = 255/255, b = 255/255 },
		orange = { r = 255/255, g = 165/255, b = 0/255 },
		gray = { r = 190/255, g = 190/255, b = 190/255 },
		sky = { r = 135/255, g = 206/255, b = 250/255 },
		-- add your own style definitions here
		default = { r = 224/255, g = 224/255, b = 224/255 }
		--model = { r = /255, g = /255, b = /255 },
	},
	count = 0,
	limit = 32,
	hlimit = 60,
	tS = "", --typingString (the string that the user is typing)
	lastMsg = "",
	arrow = false, -- the arrow that appears before what the user types, just for looks
}
local function print(text, style)
	function multiple(t) -- dont use this externally, it's only for printing multiple lines in print
		if (trace.count > trace.limit) then -- scroll elements
			table.remove(trace.textl, 1)
			table.remove(trace.stylel, 1)
		else
			trace.count = trace.count + 11
		end
		trace.textl[trace.count] = t
		trace.stylel[trace.count] = style
	end
	if (style == nil) then -- no style given
		style = trace.styles.default
	end
	if (trace.count > trace.limit) then -- scroll elements
		table.remove(trace.textl, 1)
		table.remove(trace.stylel, 1)
	else -- add element
		trace.count = trace.count + 1
	end -- write data:
	if text:find("\n") then
		text = text:gsub("\n", " ")
	end
	if string.len(text) <= trace.hlimit then
		trace.textl[trace.count] = text
		trace.stylel[trace.count] = style
	elseif string.len(text) > trace.hlimit then
		local a = math.floor(string.len(text)/trace.hlimit)
		local t1 = string.sub(text, 1, trace.hlimit)
		local t2 = string.sub(text, (2-1)*trace.hlimit+1, 2*trace.hlimit)
		local t3 = string.sub(text, (3-1)*trace.hlimit+1, 3*trace.hlimit)
		local t4 = string.sub(text, (4-1)*trace.hlimit+1, 4*trace.hlimit)
		local t5 = string.sub(text, (5-1)*trace.hlimit+1, 5*trace.hlimit)
		local t6 = string.sub(text, (6-1)*trace.hlimit+1, 6*trace.hlimit)
		local t7 = string.sub(text, (7-1)*trace.hlimit+1, 7*trace.hlimit)
		local t8 = string.sub(text, (8-1)*trace.hlimit+1, 8*trace.hlimit)
		trace.textl[trace.count] = t1
		trace.stylel[trace.count] = style
		
		multiple(t2)
		if t3 ~= "" then multiple(t3) end
		if t4 ~= "" then multiple(t4) end
		if t5 ~= "" then multiple(t5) end
		if t6 ~= "" then multiple(t6) end
		if t7 ~= "" then multiple(t7) end
		if t8 ~= "" then multiple(t8) end
	end
end
local function type(key, shift, ctrl)
	if key == "space" then key = " " end
	if key == "backspace" then
		key = ""
		trace.tS = trace.tS:sub(1, -2)
	end
	if key == "return" then key = "" end
	if key == "lshift" or key == "rshift" then key = "" end
	if key == "capslock" then key = "" end
	if key == "lctrl" or key == "rctrl" then key = "" end
	if key == "lalt" or key == "ralt" then key = "" end
	if key == "up" then key = trace.lastMsg end
	if key == "down" then
		key = ""
		trace.tS = ""
	end
	if key == "c" and ctrl == true then
		key = ""
		love.system.setClipboardText(trace.tS)
		trace.print("copied text")
	end
	if key == "v" and ctrl == true then key = love.system.getClipboardText() end
	if shift == false then trace.tS = trace.tS..key end
	if shift == true then
		if key == "1" then key = "!" end
		if key == "2" then key = "@" end
		if key == "3" then key = "#" end
		if key == "4" then key = "$" end
		if key == "5" then key = "%" end
		if key == "6" then key = "^" end
		if key == "7" then key = "&" end
		if key == "8" then key = "*" end
		if key == "9" then key = "(" end
		if key == "0" then key = ")" end
		if key == "-" then key = "_" end
		if key == "=" then key = "+" end
		if key == "[" then key = "{" end
		if key == "]" then key = "}" end
		if key == ";" then key = ":" end
		if key == "'" then key = '"' end
		if key == ',' then key = "<" end
		if key == "." then key = ">" end
		if key == "/" then key = "?" end
		key = key:upper()
		trace.tS = trace.tS..key 
	end
end
local function printTyping(prefix, style)
	print(prefix .. trace.tS, style)
	trace.lastMsg = trace.tS
	trace.tS = ""
end
local function draw(x, y, prefix)
	local i, s, z
	-- default position parameters:
	if (x == nil) then x = 16 end
	if (y == nil) then y = 16 end
	if (prefix == nil) then prefix = '' end
	-- draw lines:
	for i = 1, trace.count do
		s = trace.stylel[i]
		z = prefix .. trace.textl[i] -- string to draw
		-- choose white/black outline:
		if s then
		if ((s.r < 160/255) and (s.g < 160/255) and (s.b < 160/255)) then
			love.graphics.setColor(255/255, 255/255, 255/255)
		else
			love.graphics.setColor(0, 0, 0)
		end
		end
		-- draw outline:
		--love.graphics.print(z, x + 1, y)
		--love.graphics.print(z, x - 0.5, y)
		--love.graphics.print(z, x, y + 1)
		--love.graphics.print(z, x, y - 0.5)
		-- draw color:
		if s then
		love.graphics.setColor(s.r, s.g, s.b)
		end
		love.graphics.print(z, x, y)
		love.graphics.setColor(1,1,1)
		-- concatenate prefix:
		prefix = prefix .. '\n'
	end
	love.graphics.setColor(1,1,1)
	if trace.arrow == true then
		love.graphics.print("> "..trace.tS, x, y+trace.limit*19.1)
	elseif trace.arrow == false then love.graphics.print(trace.tS, x, y+trace.limit*15.1) end
end

trace.print = print
trace.type = type
trace.printTyping = printTyping
trace.draw = draw

return trace
