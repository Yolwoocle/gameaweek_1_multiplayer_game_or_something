require "util"
local Class = require "class"

local WorldGenerator = Class:inherit()

function WorldGenerator:init(map, seed)
	self.map = map
	self.seed = seed or love.math.random(-999999, 999999)
	self.rng = love.math.newRandomGenerator(self.seed)
	self.noise_scale = 7
	self.scale_y = 3

	self.vegetation_ids = {
		{0, 5}, -- Id, Weight
		{3, 1}, -- mush
	}
end

function WorldGenerator:generate(seed)
	local map = self.map
	local seed = self.seed
	local seed_details = self.seed + 50.3242
	
	local map_w = map.width
	local map_h = map.height
	local map_mid_w = floor(map.width / 2) 
	local map_mid_h = floor(map.height / 2)

	map:reset()

	-- Box around map 
	self:make_box()

	-- Generate cave
	-- [[
	map:for_all_tiles(function(tile, x, y)
		local s = 7
		local n = noise01(seed, x/s, y/s) 
		local thresh = distsqr(x/map_mid_w, y/map_mid_h, 1, 1) 

		if n < thresh + noise(seed_details, x/s, y/s)*0.5 then 
			map:set_tile(x, y, 2)
		end
	end)
	--]]

	-- Grassify
	self:grassify()
end

function WorldGenerator:make_box()
	local map = self.map
	
	for ix=0, map.width-1 do
		map:set_tile(ix, 0, 1)
		map:set_tile(ix, map.height-1, 1)
	end

	for iy=1, map.height-2 do
		map:set_tile(0, iy, 1)
		map:set_tile(map.width-1, iy, 1)
	end
end

function WorldGenerator:grassify()
	local map = self.map

	map:for_all_tiles(function(tile, x, y)
		if y == 0 then    return    end
		if y-1 < 0 then    return    end

		if tile.name == "dirt" and map:get_tile(x, y-1).name == "air" then
			map:set_tile(x, y, 1)
			self:set_vegetation(x, y-1)
		end
	end)
end

function WorldGenerator:set_vegetation(x, y)
	local vegetal_id = random_weighted(self.vegetation_ids, self.rng)
	-- print("VEGETAL", vegetal_id)
	self.map:set_tile(x, y, vegetal_id)
end

function WorldGenerator:draw()
	if self.canvas then
		gfx.draw(self.canvas, 0,0)
	end
end

return WorldGenerator