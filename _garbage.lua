-- This file is for functions, classes that are unused but I figure
-- I might have an use for later on. 

-- Offset x and y
	-- This is a fucking mess please gosh help me get out of this pile of convoluted hell
	local mid_x = self.x + self.w/2
	local mid_y = self.y + self.h/2
	local offset_x = self.x + spr_w2 - self.spr_ox
	local offset_y = self.y + spr_h2 - self.spr_oy

	local o_ang = atan2(offset_y - mid_y, offset_x - mid_x) + rot
	local o_rad = dist(offset_x - mid_x, offset_y - mid_y)
	local ox, oy = cos(o_ang)*o_rad, sin(o_ang)*o_rad

	local x = self.x + ox
	local y = self.y + oy



-- Terraria-like world generation
for ix=0, map_w-1 do
	-- Big hill general shape
	local by1 = noise(seed, ix / 7)
	by1 = by1 * 4

	-- Small bumps and details
	local by2 = noise(seed, ix / 3)
	by2 = by2 * 1

	local by = map_mid_h + by1 + by2
	by = floor(by)
	print(concat("by ", by))

	for iy = by, map_h-1 do
		map:set_tile(ix, iy, 1)
	end
end


function Player:is_pressing_opposite_to_wall()
	-- Returns whether the player is near a wall AND is pressing a button
	-- corresponding to the opposite direction to that wall
	-- FIXME: there's a lot of repetition, find a way to fix this?
	local null_filter = function()
		return "cross"
	end
	collision:move(self.wall_collision_box, self.x, self.y, null_filter)
	
	-- Check for left wall
	local nx = self.x - self.wall_jump_margin 
	local x,y, cols, len = collision:move(self.wall_collision_box, nx, self.y, null_filter)
	for _,col in pairs(cols) do
		if col.other.is_solid and col.normal.x == 1 and self:button_down("right") then
			print("WOW", love.math.random(10,100))
			return true, 1
		end
	end

	-- Check for right wall
	local nx = self.x + self.wall_jump_margin 
	local x,y, cols, len = collision:move(self.wall_collision_box, nx, self.y, null_filter)
	for _,col in pairs(cols) do
		if col.other.is_solid and col.normal.x == -1 and self:button_down("left")then
			return true, -1
		end
	end

	return false, nil
end