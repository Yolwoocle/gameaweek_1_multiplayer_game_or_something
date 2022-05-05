local Class = require "class"
local Actor = require "actor"
local Bullet = require "bullet"
require "util"

local Player = Actor:inherit()

function Player:init(n, x, y, controls)
	n = n or 1
	x = x or 0
	y = y or 0
	self:init_actor(x,y)

	self.n = n
	self.controls = controls

	self.x = x or 0
	self.y = y or 0

	self.w = 32
	self.h = 32

	self.mid_x = self.x + floor(self.w / 2)
	self.mid_y = self.y + floor(self.h / 2)

	self.dx = 0
	self.dy = 0

	self.is_dashing = false

	self.jump_speed = 1000
	self.speed = 400

	collision:add(self, self.x, self.y, self.w, self.h)
end

function Player:keypressed(key, scancode, isrepeat)
end

function Player:update(dt)
	self:move(dt)
	self:do_gravity(dt)
	self:apply_movement(dt)
	self.mid_x = self.x + floor(self.w/2)
	self.mid_y = self.y + floor(self.h/2)
	
	--self:shoot(dt)
end

function Player:draw()
	love.graphics.setColor(1,0,0)
	love.graphics.rectangle("fill", self.x, self.y, 32, 32)
	love.graphics.setColor(1,1,1)
	love.graphics.print(tostring(self.is_grounded), self.x, self.y-32)
	love.graphics.print(concat(math.floor(self.x)," ", math.floor(self.y)), 32, 32)
end

function Player:move(dt)
	-- compute movement dir
	local dir = {x=0, y=0}
	if self:button_down('left') then   dir.x = dir.x - 1   end
	if self:button_down('right') then   dir.x = dir.x + 1   end

	-- Apply velocity 
	self.dx = self.dx + dir.x * self.speed
	self.dy = self.dy + dir.y * self.speed

	-- Jump 
	if self:button_down('up') and self.is_grounded then 
		self:jump(dt)
	end
end

function Player:aim(dt)
	local mx, my = love.mouse.getPosition()
	self.dir = math.atan2(mx - self.x, my - self.y)
end

function Player:jump(dt)
	self.dy = -self.jump_speed
end

function Player:shoot(dt)
	if love.mouse.isDown(1) then
		game:new_actor(Bullet, self.mid_x, self.mid_y, self.dir)
	end
end

function Player:button_down(func)
	-- TODO: move this to some input.lua or something
	local keys = self.controls[func]
	if not keys then   return   end

	for i, k in pairs(keys) do
		if love.keyboard.isScancodeDown(k) then
			return true
		end
	end
	return false
end

return Player