local Class = require "class"

local Actor = Class:inherit()

function Actor:init_actor(x, y, w, h)
	self.x = x or 0
	self.y = y or 0
	self.w = w or 32
	self.h = h or 32

	self.vx = 0
	self.vy = 0

	self.default_gravity = 40
	self.gravity = self.default_gravity
	self.gravity_cap = 800
	self.friction_x = 0.8 -- This assumes that the game is running at 60FPS
	self.friction_y = 1 -- By default we don't apply friction to the Y axis for gravity

	self.speed_cap = 10000
	self.is_solid = false

	self.is_grounded = false

	self.wall_col = nil
	
	self.is_removed = false
	collision:add(self, self.x, self.y, self.w, self.h)
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

function Actor:apply_movement(dt)
	self:do_gravity(dt)

	-- apply friction
	self.vx = self.vx * self.friction_x
	self.vy = self.vy * self.friction_y
	
	-- apply position
	local goal_x = self.x + self.vx * dt
	local goal_y = self.y + self.vy * dt

	local actual_x, actual_y, cols, len = collision:move(self, goal_x, goal_y)
	self.x = actual_x
	self.y = actual_y
	
	-- react to collisions
	self.is_grounded = false
	self.wall_col = nil
	for _,col in pairs(cols) do
		if col.type ~= "cross" then
			-- save wall collision
			if col.other.is_solid then
				self.wall_col = col
			end

			-- cancel velocity
			if col.normal.x ~= 0 then   self.vx = 0   end
			if col.normal.y ~= 0 then   self.vy = 0   end
			
			-- is grounded
			if col.normal.y == -1 then
				self.is_grounded = true
			end

			self:on_collision(col)
		end
	end

	-- Cap velocity
	local cap = self.speed_cap
	self.vx = clamp(self.vx, -cap, cap)
	self.vy = clamp(self.vy, -cap, cap)
end

function Actor:draw()
	error("draw not implemented")
end

function Actor:on_collision(col)
	-- Implement on_collision
end

function Actor:remove()
	if not self.is_removed then
		self.is_removed = true
		collision:remove(self)
	end
end

return Actor