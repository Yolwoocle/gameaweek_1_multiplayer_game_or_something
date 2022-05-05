local Class = require "class"
local Actor = require "actor"

local Bullet = Actor:inherit()

function Bullet:init(x,y, dir)
	self:init_actor(x,y)
	self.speed = 300
	self.dir = dir
	self.dx = math.cos(dir) * self.speed
	self.dy = math.sin(dir) * self.speed
end

function Bullet:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

function Bullet:draw()
	love.graphics.setColor(1,1,0)
	love.graphics.rectangle("fill", self.x, self.y, 32, 32)
	love.graphics.setColor(1,1,1)
end

return Bullet