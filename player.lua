local Class = require "class"
local Actor = require "actor"
local Guns = require "guns"
require "util"

local Player = Actor:inherit()

function Player:init(n, x, y, controls)
	n = n or 1
	x = x or 0
	y = y or 0
	self:init_actor(x, y, 32, 32)

	self.n = n
	self.controls = controls
	self:init_last_input_state()

	self.mid_x = self.x + floor(self.w / 2)
	self.mid_y = self.y + floor(self.h / 2)
	self.dir_x = 1
	
	self.is_walled = false

	self.speed = 100
	self.jump_speed = 1000
	self.wall_jump_kick_speed = 1000
	self.wall_slide_speed = 150
	self.is_wall_sliding = false

	self.color = ({COL_RED, COL_GREEN, COL_CYAN, COL_YELLOW})[self.n]
	self.color = self.color or COL_RED
	
	self.gun = Guns.Machinegun:new()
	self.is_shooting = false
	self.shoot_dir = 1
end

function Player:update(dt)
	-- Movement
	self:move(dt)
	self:do_wall_sliding(dt)
	self:do_jumping(dt)
	self:do_gravity(dt)
	self:apply_movement(dt)
	self.mid_x = self.x + floor(self.w/2)
	self.mid_y = self.y + floor(self.h/2)
	
	-- Gun
	self.gun:update(dt)
	self:shoot(dt)

	self:update_button_state()
end

function Player:draw()
	rect_color(self.color, "fill", self.x, self.y, 32, 32)
	print_color(COL_WHITE, concat("P",self.n), self.x, self.y)
end

function Player:move(dt)
	-- compute movement dir
	local dir = {x=0, y=0}
	if self:button_down('left') then   dir.x = dir.x - 1   end
	if self:button_down('right') then   dir.x = dir.x + 1   end

	if dir.x ~= 0 then
		self.dir_x = dir.x

		-- If not shooting, update shooting direction
		if not self.is_shooting then
			self.shoot_dir = dir.x
		end
	end

	-- Apply velocity 
	self.vx = self.vx + dir.x * self.speed
	self.vy = self.vy + dir.y * self.speed
end

function Player:do_wall_sliding(dt)
	-- Check if wall sliding
	self.is_wall_sliding = false
	if self.wall_col then
		local col_normal = self.wall_col.normal
		local is_walled = col_normal.y == 0
		local holding_left = self:button_down('left') and col_normal.x == 1
		local holding_right = self:button_down('right') and col_normal.x == -1
		
		local is_wall_sliding = is_walled and (holding_left or holding_right)
		self.is_wall_sliding = is_wall_sliding
	end

	-- Perform wall sliding
	if self.is_wall_sliding then
		self.gravity = 0
		self.vy = self.wall_slide_speed
	else
		self.gravity = self.default_gravity
	end
end

function Player:do_jumping(dt)
	if self:button_pressed('up') then
		-- Regular jump
		if self.is_grounded then 
			self:jump(dt)
		end
		-- Wall jump
		if self.is_wall_sliding then
			self:wall_jump(self.wall_col.normal)
		end
	end
end

function Player:jump(dt)
	self.vy = -self.jump_speed
end

function Player:wall_jump(normal)
	self.vx = normal.x * self.wall_jump_kick_speed
	self.vy = -self.jump_speed
end

function Player:shoot(dt)
	if self:button_down("fire") then
		self.is_shooting = true
		self.gun:shoot(dt, self, self.mid_x, self.mid_y, self.shoot_dir, 0)
	else
		self.is_shooting = false
	end
end

function Player:button_down(btn)
	-- TODO: move this to some input.lua or something
	local keys = self.controls[btn]
	if not keys then   return   end

	for i, k in pairs(keys) do
		if love.keyboard.isScancodeDown(k) then
			return true
		end
	end
	return false
end

function Player:init_last_input_state()
	self.last_input_state = {}
	for btn, _ in pairs(self.controls) do
		if btn ~= "type" then
			self.last_input_state[btn] = false
		end
	end
end

function Player:button_pressed(btn)
	-- This makes sure that the button state table assigns "true" to buttons
	-- that have been just pressed 
	local last = self.last_input_state[btn]
	local now = self:button_down(btn)
	return not last and now
end

function Player:update_button_state()
	for btn, v in pairs(self.last_input_state) do
		self.last_input_state[btn] = self:button_down(btn)
	end
end

return Player