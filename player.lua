local Class = require "class"
local Actor = require "actor"
local Guns = require "guns"
local images = require "images"
require "util"
require "constants"

local Player = Actor:inherit()

function Player:init(n, x, y, controls)
	n = n or 1
	x = x or 0
	y = y or 0
	self:init_actor(x, y, 10, 10, images.ant)

	self.n = n
	self.controls = controls
	self:init_last_input_state()

	self.rot = 0
	self.visual_rot = 0
	self.mid_x = self.x + floor(self.w / 2)
	self.mid_y = self.y + floor(self.h / 2)
	self.move_dir_x = 1
	
	-- Speed 
	self.speed = 100
	self.gravity = 0
	-- self.friction_x = 1
	self.default_friction = 0.6
	self.friction_x = self.default_friction
	self.friction_y = self.default_friction

	-- Climbing
	self.up_vect = {x=0, y=-1}
	self.is_grounded = false

	-- Jump
	self.jump_speed = 450
	self.buffer_jump_timer = 0
	self.coyote_time = 0
	self.default_coyote_time = 7

	-- Wall sliding & jumping
	self.is_walled = false
	self.wall_jump_kick_speed = 300
	self.wall_slide_speed = 50
	self.is_wall_sliding = false

	-- Visuals
	self.color = ({COL_RED, COL_GREEN, COL_CYAN, COL_YELLOW})[self.n]
	self.color = self.color or COL_RED
	self.flip_x = 1

	-- Shooting & guns (keep it or ditch for family friendliness?)
	self.gun = Guns.Machinegun:new()
	self.is_shooting = false
	
	-- Cursor
	self.cu_x = 0
	self.cu_y = 0
	self.mine_timer = 0
	self.cu_target = nil
	self.cu_range = 3
	
	-- Inventory
	self.holding = nil
	self.mine_mode = true

	-- Debug 
	self.dt = 1
end

function Player:update(dt)
	--print("the dt:", dt)
	self.dt = dt

	-- Movement
	self:do_movement(dt)
	--self:do_jumping(dt)
	self:update_actor(dt)
	self:do_ledge_climbing(dt)
	
	self:do_conditional_gravity(dt)
	self:do_gravity(dt)

	self.mid_x = self.x + floor(self.w/2)
	self.mid_y = self.y + floor(self.h/2)
	self:compute_rotation()

	-- Mine 
	self:update_cursor(dt)
	if self.holding then
		self:place(dt)
	else
		self:mine(dt)
	end

	self:update_button_state()
end

function Player:draw()
	self:draw_actor(self.flip_x, 1, self.visual_rot)

	-- Cursor
	if self.cu_target or true then
		rect_color(COL_WHITE, "line", self.cu_x*BW, self.cu_y*BW, BLOCK_WIDTH, BLOCK_WIDTH)
	end

	if self.holding then
		gfx.draw(self.holding.sprite, self.x-8, self.y-8)
	end

	if self.cu_target and self.mine_timer > 0 then
		local ratio = self.mine_timer / self.cu_target.mine_time
		local w = 16

		rect_color(COL_WHITE, "line", self.cu_x*w, self.cu_y*w - 8, w, 4)
		rect_color(COL_WHITE, "fill", self.cu_x*w, self.cu_y*w - 8, ratio*w, 4)
	end

	print_outline(self.color, COL_WHITE, concat("P", self.n), self.x, self.y-16*2)
	if game.debug_mode then
		line_color(COL_RED, self.mid_x, self.mid_y, self.mid_x + self.up_vect.x*16, self.mid_y + self.up_vect.y*16)
	end
end

function Player:do_movement(dt)
	--if self.wall_col then print("wall_col ", self.wall_col.normal.x, self.wall_col.normal.y)  end

	-- compute movement dir
	local dir = {x=0, y=0}
	if self:button_down('left') then   dir.x = dir.x - 1   end
	if self:button_down('right') then   dir.x = dir.x + 1   end

	-- Movement vector corresponds to up vect rotated accordly
	local move_vect = {x=0, y=0}
	if dir.x == -1 then   
		self.flip_x = -1
		move_vect.x = self.up_vect.y
		move_vect.y = -self.up_vect.x
	end 
	if dir.x == 1  then
		self.flip_x = 1
		move_vect.x = -self.up_vect.y
		move_vect.y = self.up_vect.x
	end
	
	-- Apply velocity 
	self.vx = self.vx + move_vect.x * self.speed
	self.vy = self.vy + move_vect.y * self.speed
end

-- On collision, climb
function Player:on_collision(col)
	if not col.other.is_solid then   return    end
	--if not self.is_sticky then    return    end
	
	local col_normal = col.normal
	local dot = col_normal.x * self.up_vect.x + col_normal.y * self.up_vect.y

	-- if vectors are opposite, then is grounded
	if dot <= -1 then
		self.is_grounded = true
	end

	-- React to wall climbing
	if dot ~= 0 then   return   end -- Vectors are not orthogonal (perpendicular)
	
	local up_ang = atan2(self.up_vect.y, self.up_vect.x) 
	local normal_ang = atan2(col_normal.y, col_normal.x) 
	local diff = (normal_ang - up_ang) % pi2
	if diff < pi then
		self.vx, self.vy = -self.vy, self.vx
	else
		self.vx, self.vy = self.vy, -self.vx
	end

	-- Set "up" to collision vector
	self.up_vect = col_normal 
end

function Player:do_ledge_climbing(dt)
	--if not self.is_sticky then    return    end
	-- Snap to walls if "falling off" ledge

	-- Check if grounded given current orientation
	local old_grounded = self.is_grounded

	local ground_offset = 8
	local goal_x = self.x - self.up_vect.x*ground_offset
	local goal_y = self.y - self.up_vect.y*ground_offset

	local actual_x, actual_y, cols, len = collision:check(self, goal_x, goal_y)
	local is_col = false
	for _,col in pairs(cols) do
		if col.other.is_solid then
			-- The player is grounded, so snap it nearest wall
			is_col = true
			if self.is_sticky then   self:move_to(goal_x, goal_y)  end
		end
	end
	
	self.is_grounded = is_col

	-- Move around ledge
	if old_grounded and not is_col then
		-- Round movement vector to nearest cardinal direction
		local move_ang = atan2(self.vy, self.vx)
		move_ang = floor(4 * move_ang/pi2)
		move_ang = pi2 * (move_ang / 4)
		-- Normalisze movement vector
		local move_x = round(cos(move_ang)) 
		local move_y = round(sin(move_ang))
		local move_vect = {x = move_x, y = move_y}

		-- Compare up vector and movement vector
		--- This will define around which way the player is turning in a corner 
		local up_ang = atan2(self.up_vect.y, self.up_vect.x)
		local diff = (move_ang - up_ang) % pi2 
		
		if diff < pi then
			-- Right turn
			--   +- - - - >
			--   :  +-----
			--   :  |
			self.vx, self.vy = -self.vy, self.vx 
		else
			-- Left turn
			--  < - - - +
			--  ------+ : 
			--        | :
			self.vx, self.vy = self.vy, -self.vx
		end

		-- Set "up" to the movement direction
		self.up_vect = move_vect
	end
end

function Player:compute_rotation()
	local rot = atan2(self.up_vect.y, self.up_vect.x) + pi/2
	self.rot = rot 

	local spr_w2 = floor(self.sprite:getWidth() / 2)
	local spr_h2 = floor(self.sprite:getHeight() / 2)

	local x = self.x + spr_w2 - self.spr_ox
	local y = self.y + spr_h2 - self.spr_oy
	if self.sprite then
		gfx.draw(self.sprite, x, y, rot, fx, fy, spr_w2, spr_h2)
	end

	self.rot = wrap_to_pi(self.rot)
	
	-- Lerp rotation
	local epsilon = 0.01
	if abs(self.visual_rot - self.rot) > epsilon then
		self.visual_rot = lerp_angle(self.visual_rot, self.rot, 0.4)
	else 
		self.visual_rot = self.rot
	end
end

function Player:do_conditional_gravity(dt)
	local is_walled = self.wall_col or self.is_grounded
	if not is_walled then --or self:button_down("jump") then
		self.is_sticky = false
	else
		self.is_sticky = true
	end

	if self.is_sticky then
		self.gravity = 0
		self.friction_y = self.default_friction
	else
		self.gravity = self.default_gravity
		self.friction_y = 1
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
 
function Player:update_cursor(dt)
	local old_cu_x = self.cu_x
	local old_cu_y = self.cu_y

	local tx = floor(self.mid_x / BLOCK_WIDTH) 
	local ty = floor(self.mid_y / BLOCK_WIDTH) 
	local dx, dy = self:target_nearest_tile(tx, ty, self.holding)

	-- Update target position
	self.cu_x = tx + dx
	self.cu_y = ty + dy

	-- Update target tile
	local target_tile = game.map:get_tile(self.cu_x, self.cu_y)
	self.cu_target = nil
	if target_tile then
		self.cu_target = target_tile
	end
	
	-- If changed cursor pos, reset cursor
	if (old_cu_x ~= self.cu_x) or (old_cu_y ~= self.cu_y) then
		self.mine_timer = 0
	end
end

function Player:target_nearest_tile(tx, ty, target_air)
	local dx, dy = 0, 0

	-- Target up and down 
	-- fix: this is messy af
	local btn_up = self:button_down("up")
	local btn_down = self:button_down("down")
	if btn_up or btn_down then
		dx, dy = 0, 0
		if self:button_down("left") or self:button_down("right") then  
			dx, dy = get_orthogonal(self.up_vect.x, self.up_vect.y, self.flip_x)  
		end
		if btn_up then
			dx = dx + self.up_vect.x    
			dy = dy + self.up_vect.y    
		end
		if btn_down then 
			dx = dx - self.up_vect.x    
			dy = dy - self.up_vect.y 
		end
	else
		-- By default, target sideways
		-- Find block within range 
		local side_x, side_y = get_orthogonal(self.up_vect.x, self.up_vect.y, self.flip_x)
		local mult = nil
		for i=0, self.cu_range do
			local target = game.map:get_tile(tx + side_x*i, ty + side_y*i)
			if target and target.is_targetable then
				mult = i
				break
			end
		end

		-- if targeting air
		if mult and target_air then    mult = max(0, mult-1)   end
		mult = mult or 1
		dx, dy = side_x*mult, side_y*mult
	end

	return dx, dy
end

function Player:target_nearest_air(tx, ty)

end

function Player:mine(dt)
	if not self.cu_target then   return    end
	if not self.cu_target.is_breakable then   return    end
	
	if self:button_down("mine") then
		-- Augment mine timer
		self.mine_timer = self.mine_timer + dt
		
		-- If mine timer at max
		if self.mine_timer > self.cu_target.mine_time then
			local drop = self.cu_target.drop
			game.map:set_tile(self.cu_x, self.cu_y, 0)
			local success = game.inventory:add(drop, 1)
			self.holding = drop
		end
	else
		-- Reset if not holding mine button
		self.mine_timer = 0
	end
end

function Player:place()
	if not self.holding then    return print("Player.place called while no item carried")    end
	if not self:button_pressed("mine") then    return    end
	
	-- If target is air, place blocks
	if self.cu_target and self.cu_target.id == 0 then
		local success = game.map:set_tile(self.cu_x, self.cu_y, self.holding.id)
		self.holding = nil
		if success then
		end
	end
end

return Player