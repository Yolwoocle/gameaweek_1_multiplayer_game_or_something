local Class = require "class"

local Actor = Class:inherit()

function Actor:init_actor(x, y, w, h, spr)
	self.x = x or 0
	self.y = y or 0
	self.w = w or 32
	self.h = h or 32

	self.vx = 0
	self.vy = 0

	self.default_gravity = 20
	self.gravity = self.default_gravity
	self.gravity_cap = 400
	self.default_friction = 0.8
	self.friction_x = self.default_friction -- This assumes that the game is running at 60FPS
	self.friction_y = 1 -- By default we don't apply friction to the Y axis for gravity

	self.speed_cap = 10000
	self.is_solid = false

	self.is_grounded = false
	self.is_walled = false

	self.wall_col = nil
	
	self.is_removed = false
	collision:add(self, self.x, self.y, self.w, self.h)

	-- Visuals
	if spr then
		self.sprite = spr 
		self.spr_w = self.sprite:getWidth()
		self.spr_h = self.sprite:getHeight()
		self.spr_ox = floor((self.spr_w - self.w) / 2)
		self.spr_oy = self.spr_h - self.h 
	end
end

function Actor:update()
	error("update not implemented")
end

function Actor:do_gravity(dt)
	self.vy = self.vy + self.gravity
	if self.gravity > 0 then
		self.vy = min(self.vy, self.gravity_cap)
	end	
end

function Actor:update_actor(dt)
	self:do_gravity(dt)

	-- apply friction
	self.vx = self.vx * self.friction_x
	self.vy = self.vy * self.friction_y
	
	-- apply position
	local goal_x = self.x + self.vx * dt
	local goal_y = self.y + self.vy * dt
	self:move_to(goal_x, goal_y)

	-- Cap velocity
	local cap = self.speed_cap
	self.vx = clamp(self.vx, -cap, cap)
	self.vy = clamp(self.vy, -cap, cap)
end

function Actor:draw()
	error("draw not implemented")
end

function Actor:move_to(goal_x, goal_y)
	local actual_x, actual_y, cols, len = collision:move(self, goal_x, goal_y)
	self.x = actual_x
	self.y = actual_y
	
	-- react to collisions
	--local old_grounded = self.is_grounded
	local old_wall_col = table.clone(self.wall_col)
	--self.is_grounded = false
	self.wall_col = nil
	for _,col in pairs(cols) do
		self:on_collision(col)
		self:react_to_collision(col)
	end

	-- Grounding events
	-- TODO: we don't need this many methods, just on_wall suffices
	if not old_grounded and self.is_grounded then
		self:on_grounded()
	end
	if old_grounded and not self.is_grounded then
		self:on_leaving_ground()
	end

	-- Leave collision event
	if old_wall_col and not self.wall_col then
		self:on_leaving_wall()
	end
end

 r = 0
function Actor:draw_actor(fx, fy, rot)
	r = r +0.05
	fx = fx or 1
	fy = fy or 1 
	rot = rot or 0
	--rot = rot + r

	local spr_w2 = floor(self.sprite:getWidth() / 2)
	local spr_h2 = floor(self.sprite:getHeight() / 2)

	-- Offset x and y
	local mid_x, mid_y = self.x + self.w/2, self.y + self.h/2
	local up_offset = spr_h2 - self.h/2
	local ox, oy = cos(rot - pi/2), sin(rot - pi/2)
	local ox, oy = ox*up_offset, oy*up_offset
	local x, y = mid_x + ox, mid_y + oy
	if self.sprite then
		gfx.draw(self.sprite, x, y, rot, fx, fy, spr_w2, spr_h2)
	end
end

function Actor:react_to_collision(col)
	-- wall col
	if col.other.is_solid then
		-- save wall collision
		self.wall_col = col
		
		-- cancel velocity
		if col.normal.x ~= 0 then   self.vx = 0   end
		if col.normal.y ~= 0 then   self.vy = 0   end
		
		--[[		
		-- is grounded
		if col.normal.y == -1 then
			self.is_grounded = true
		end
		--]]
	end
end

function Actor:on_collision(col)
	-- Implement on_collision
end

function Actor:on_grounded()
	-- 
end

function Actor:on_leaving_ground()

end

function Actor:on_leaving_wall()

end

function Actor:remove()
	if not self.is_removed then
		self.is_removed = true
		collision:remove(self)
	end
end

return Actor