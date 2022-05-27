local bump = require "lib.bump.bump"
local Class = require "class"
require "constants"

local Collision = Class:inherit()

function Collision:init()
	self.world = bump.newWorld(BLOCK_WIDTH)
end

function Collision:add(o, x, y, w, h)
	if not x then
		x, y, w, h = o.x, o.y, o.w, o.h
	end
	self.world:add(o, x,y,w,h)
end

--[[
function Collision:add(self, o)
	local x, y = o.x - o.w, o.y - o.h
	local w, h = o.w * 2, o.h * 2
	self.world:add(o, x,y,w,h)
end
--]]

function Collision:remove(o)
	self.world:remove(o)
end

function Collision:update(o,x,y,w,h)
	if not x then
		x, y, w, h = o.x, o.y, o.w, o.h
	end
	self.world:update(o,x,y,w,h)
end

function Collision:move(o, goal_x, goal_y, filter)
	-- Attempts to move object `o` and returns data about the collision
	filter = filter or self.filter
	goal_x = goal_x
	goal_y = goal_y

	local actual_x, actual_y, cols, len = self.world:move(o, goal_x, goal_y, filter)
	return actual_x, actual_y, cols, len
end 

function Collision.filter(item, other)
	-- By default, do not react to collisions
	local type = "cross"

	if other.is_solid then
		type = "slide"
	end

	return type
end

return Collision