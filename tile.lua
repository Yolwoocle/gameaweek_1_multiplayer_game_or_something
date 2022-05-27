local Class = require "class"
local Actor = require "actor"
require "util"

local Tile = Class:inherit()

function Tile:init_tile(x, y, w, spr)
	self.type = "tile"
	self.name = "tile"

	self.mine_time = 0

	self.ix = x
	self.iy = y
	self.x = x * w
	self.y = y * w
	self.w = w
	self.h = w
	self.is_solid = false
	self.sprite = spr
end

function Tile:update(dt)
	--
end

function Tile:draw()
	if self.sprite then
		gfx.draw(self.sprite, self.x, self.y)
	end
end

return Tile