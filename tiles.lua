require "util"
local Class = require "class"
local Tile = require "tile"
local images = require "images"

local Tiles = Class:inherit()

local function make_tile(init)
	local tile = Tile:inherit()
	tile.init = init
	return tile
end

function Tiles:init()
	self.tiles = {}
	
	-- Air
	self.tiles[0] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = 0
		
		self.name = "air"
		self.sprite = nil
	end)

	-- Grass
	self.tiles[1] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = 1
		self.name = "grass"
		self.sprite = images.grass
		
		self.is_solid = true
		self.mine_time = .5
	end)

	-- Dirt
	self.tiles[2] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = 2

		self.name = "dirt"
		self.sprite = images.dirt
		self.is_solid = true
		self.mine_time = .5
	end)
end

function Tiles:new_tile(n, x, y, w, ...)
	local tile_class = self.tiles[n]
	local tile = tile_class:new(x, y, w, ...)

	-- Init collision box
	if tile.is_solid then
		collision:add(tile, tile.x, tile.y, tile.w, tile.w)
	end

	return tile
end

return Tiles:new()