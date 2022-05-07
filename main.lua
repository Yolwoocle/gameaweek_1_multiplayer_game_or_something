local Class = require "class"
local Game = require "game"

game = nil 
is_fullscreen = false

function love.load(arg)
	love.window.setMode(0, 0, {fullscreen = true, vsync = true})
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	WINDOW_WIDTH = 800
	WINDOW_HEIGHT = 600

	love.window.setTitle("Cool game")
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = false
	})

	-- enable key repeat so backspace can be held down to trigger love.keypressed multiple times.
  --love.keyboard.setKeyRepeat(true)
	
	-- Load fonts
	local font_regular = love.graphics.newFont("fonts/Poppins-Regular.ttf", 24)
	love.graphics.setFont(font_regular)
	
	game = Game:new()
end

t = 0
fdt = 1/60 -- fixed frame delta time
local function fixed_update()
	--update that happens at the fixed fdt interval
	game:update(fdt)
end

function love.update(dt)
	t = t + dt
	local cap = 50
	local i = 0
	while t > fdt and cap > 0 do
		t = t - fdt
		fixed_update()
		cap = cap - 1
		i=i+1
	end
end

function love.draw()
	game:draw()
end

function love.keypressed(key, scancode, isrepeat)
	if key == "f5" then
		if love.keyboard.isDown("lshift") then
			love.event.quit("restart")
		end

	elseif key == "f4" then
		if love.keyboard.isDown("lshift") then
			love.event.quit()
		end
	
	elseif key == "f11" then
		--is_fullscreen = not is_fullscreen
		love.window.setFullscreen(is_fullscreen)
	end

	if game.keypressed then  game:keypressed(key, scancode, isrepeat)  end
end

function love.keyreleased(key, scancode)
	if game.keyreleased then  game:keyreleased(key, scancode)  end
end

function love.mousepressed(x, y, button, istouch, presses)
	if game.mousepressed then   game:mousepressed(x, y, button)   end
end

--function love.quit()
--	game:quit()
--end

function love.resize(w, h)
	WINDOW_WIDTH = w
	WINDOW_HEIGHT = h
	if game.resize then   game:resize(w,h)   end
end

function love.textinput(text)
	if game.textinput then  game:textinput(text)  end
end