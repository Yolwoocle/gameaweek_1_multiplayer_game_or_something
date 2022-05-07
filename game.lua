local Class = require "class"
local Collision = require "collision"
local Player = require "player"
local Enemy = require "enemy"
local Bullet = require "bullet"
local TileMap = require "tilemap"

local Game = Class:inherit()

function Game:init()
	-- Global singletons
	collision = Collision:new()

	self.map = TileMap:new(24, 18)
	self.map:init_box()

	self.actors = {}
	self:init_players()
	self:new_actor(Enemy:new(64,64))
end

function Game:update(dt)
	self.map:update(dt)
	for k,actor in pairs(self.actors) do
		actor:update(dt)
	end

	-- Delete actors
	for i = #self.actors, 1, -1 do
		local actor = self.actors[i]
		if actor.is_removed then
			table.remove(self.actors, i)
		end
	end
end

function Game:draw()
	self.map:draw()
	for k,actor in pairs(self.actors) do
		actor:draw()
	end

	self:draw_debug()
end

function Game:new_actor(actor)
	table.insert(self.actors, actor)
end

function Game:draw_debug()
	local items, len = collision.world:getItems()
	for i,it in pairs(items) do
		local x,y,w,h = collision.world:getRect(it)
		rect_color({0,1,0},"line", x, y, w, h)
	end
	
	-- Print FPS
	rect_color({0,0,0,0.5}, "fill", 0, 0, 50, 32)
	print_color(COL_WHITE, love.timer.getFPS(), 0, 0)
end

function Game:init_players()
	self.players = {}
	self.players[1] = Player:new(1, 128, 128, {
		type = "keyboard",
		left = {"a"},
		right = {"d"},
		up = {"w"},
		fire = {"c", "v", "f"},
	})
	self.players[2] = Player:new(2, 256, 128, {
		type = "keyboard",
		left = {"left"},
		right = {"right"},
		up = {"up"},
		fire = {",", ".", "/"},
	})
	
	for _, ply in pairs(self.players) do
		self:new_actor(ply)
	end
end

function Game:keypressed(key, scancode, isrepeat)
	for i, ply in pairs(self.players) do
		--ply:keypressed(key, scancode, isrepeat)
	end
end

function Game:keyreleased(key, scancode)
	for i, ply in pairs(self.players) do
		--ply:keyreleased(key, scancode)
	end
end

return Game