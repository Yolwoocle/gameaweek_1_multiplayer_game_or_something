local Class = require "class"
local Actor = require "actor"
require "util"

local Tile = Class:inherit()

function Tile:init(x,y,w)
	self.ix = x
	self.iy = y
	self.x = x * w
	self.y = y * w
	self.w = w
	self.h = w
	self.is_solid = false
end

function Tile:update(dt)
	--
end

function Tile:draw()
	if self.is_solid then
		love.graphics.setColor(rgb(255,255,255))
	else
		if (self.ix+self.iy)%2 == 0 then
			love.graphics.setColor(rgb(0,0,0))
		else
			love.graphics.setColor(rgb(20,20,20))
		end
	end

	love.graphics.rectangle("fill",self.x, self.y, self.w,self.w)
end

return Tile