require "util"
local Class = require "class"
local Gun = require "gun"

local Guns = Class:inherit()

function Guns:init()
	self.Machinegun = Gun:inherit()

	self.Machinegun.init = function(self)
		self:init_gun()
		self.ammo = 1000
		self.cooldown = 0.1
	end
end

return Guns:new()