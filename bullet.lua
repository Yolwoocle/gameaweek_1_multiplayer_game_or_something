local Class = require "class"
local Actor = require "actor"

local Bullet = Actor:inherit()

function Bullet:init(x, y, w, h, vx, vy)
	self:init_actor(x, y, w, h)
	self.is_bullet = true

	self.friction_x = 1
	self.friction_y = 1
	self.gravity = 0

	self.speed = 300
	self.dir = dir
	
	self.vx = vx or 0
	self.vy = vy or 0

	self.life = 5

	self.damage = 2
end

function Bullet:update(dt)
	self:update_actor(dt)

	self.life = self.life - dt
	if self.life < 0 then
		self:remove()
	end
end

function Bullet:draw()
	rect_color(COL_YELLOW, "fill", self.x, self.y, self.w, self.h)
end

function Bullet:on_collision(col)
	
	if not self.is_removed and col.other.is_solid then
		self:remove()
	end
	
	if col.other.on_hit_bullet then
		col.other:on_hit_bullet(self, col)
		self:remove()
	end
	
	self:after_collision(col)
end

function Bullet:after_collision(col)
	local other = col.other
	if other.type == "tile" then
		game.map:set_tile(other.ix, other.iy, 0)
	end
end

return Bullet