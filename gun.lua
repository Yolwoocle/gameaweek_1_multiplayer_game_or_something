require "util"
local Class = require "class"
local Bullet = require "bullet"

local Gun = Class:inherit()

function Gun:init_gun()
	self.ammo = 1000
	self.bullet_speed = 1000

	self.cooldown = 0.3
	self.cooldown_timer = 0
end

function Gun:update(dt)
	self.cooldown_timer = max(self.cooldown_timer - dt, 0)
end

function Gun:draw()
	--
end

function Gun:shoot(dt, player, x, y, dx, dy)
	if self.ammo > 0 and self.cooldown_timer <= 0 then
		self:fire_bullet(dt, player, x, y, dx, dy)
	end
end	

function Gun:fire_bullet(dt, player, x, y, dx, dy)
	local spd_x = dx * self.bullet_speed 
	game:new_actor(Bullet:new(x, y, spd_x, 0))
	
	self.cooldown_timer = self.cooldown
end

return Gun