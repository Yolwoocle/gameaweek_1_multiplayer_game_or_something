require "util"
local Class = require "class"
local Enemy = require "enemy"

local Enemies = Class:inherit()

function Enemies:init()
	self.Bug = Enemy:inherit()

	self.Bug.init = function(self, x, y)
		self:init_enemy(x,y)
		self.life = 10
		self.color = rgb(0,50,190)
	end
end

return Enemies:new()