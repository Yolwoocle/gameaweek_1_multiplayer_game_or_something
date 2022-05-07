require "util"
local Class = require "class"
local Actor = require "actor"

local Enemy = Actor:inherit()

function Enemy:init(x,y)
	self:init_actor(x, y, 32, 32)
	self.life = 10
end

function Enemy:update(dt)
	self:apply_movement(dt)
	if self.life <= 0 then
		self:remove()
	end
end

function Enemy:draw()
	rect_color(COL_BLUE, "fill", self.x, self.y, self.w, self.h)
	print_color(COL_WHITE, self.life, self.x, self.y-32)
end

function Enemy:on_collision(col)
	if col.other.is_solid and col.normal.y == 0 then
		self.vx = -self.vx
	end

	if col.other.is_bullet then
		self.life = self.life - col.other.damage
	end
end

return Enemy