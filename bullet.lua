local Class = require "class"
local Actor = require "actor"

local Bullet = Actor:inherit()

function Bullet:init(x, y, vx, vy)
	self:init_actor(x, y, 32, 16)
	self.is_bullet = true

	self.friction_x = 1
	self.friction_y = 1
	self.gravity = 0

	self.speed = 300
	self.dir = dir
	
	self.vx = vx or 0
	self.vy = vy or 0

	self.damage = 2
end

function Bullet:update(dt)
	self:apply_movement(dt)
end

function Bullet:draw()
	rect_color(COL_YELLOW, "fill", self.x, self.y, self.w, self.h)
end

function Bullet:on_collision(col)
	if not self.is_removed and col.other.is_solid then
		self:remove()
	end
end

return Bullet