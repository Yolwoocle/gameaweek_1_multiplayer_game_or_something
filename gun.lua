require "util"
local Class = require "class"
local Bullet = require "bullet"

local Gun = Class:inherit()

function Gun:init_gun()
	self.bul_w = 8
	self.bul_h = 8

	self.ammo = 1000
	self.bullet_speed = 500

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
		self:fire_bullet(dt, player, x, y, self.bul_w, self.bul_h, dx, dy)
	end
end	

function Gun:fire_bullet(dt, player, x, y, bul_w, bul_h, dx, dy)
	local spd_x = dx * self.bullet_speed 
	game:new_actor(Bullet:new(x, y, bul_w, bul_h, spd_x, 0))
	
	self.cooldown_timer = self.cooldown
end

return Gun