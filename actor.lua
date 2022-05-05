local Class = require "class"

local Actor = Class:inherit()

function Actor:init_actor(x,y)
	self.x = x or 0
	self.y = y or 0

	self.dx = 0
	self.dy = 0

	self.gravity = 60
	self.friction = 0.6 -- This assumes that the game is running at 60FPS
	self.speed_cap = 10000

	self.is_grounded = false
end

function Actor:update()
	error("update not implemented")
end

function Actor:do_gravity(dt)
	self.dy = self.dy + self.gravity
end

function Actor:apply_movement(dt)
	-- apply friction
	self.dx = self.dx * self.friction
	self.dy = self.dy -- We don't apply friction to the Y axis for gravity
	
	-- apply position
	local goal_x = self.x + self.dx * dt
	local goal_y = self.y + self.dy * dt

	local actual_x, actual_y, cols, len = collision:move(self, goal_x, goal_y)
	self.x = actual_x
	self.y = actual_y
	
	-- cancel velocity
	self.is_grounded = false
	for _,col in pairs(cols) do
		if col.normal.x ~= 0 then   self.dx = 0   end
		if col.normal.y ~= 0 then   self.dy = 0   end
		-- is grounded
		if col.normal.y == -1 then
			self.is_grounded = true
		end
	end

	-- Cap velocity
	local cap = self.speed_cap
	self.dx = clamp(self.dx, -cap, cap)
	self.dy = clamp(self.dy, -cap, cap)
end

function Actor:draw()
	error("draw not implemented")
end

return Actor