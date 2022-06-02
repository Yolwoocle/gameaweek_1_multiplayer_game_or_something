require "util"
require "constants"
local Class = require "class"

local Inventory = Class:inherit()

function Inventory:init(x,y)
	self.inventory = {}
	self.size = 12
	for i=1, self.size do
		self.inventory[i] = {
			item = nil,
			quantity = 0,
		}
	end
end

function Inventory:update(dt)
	-- 
end

function Inventory:draw()
	local w = 18
	for i=1, self.size do
		local slot = self.inventory[i]
		local x = 4 + i*(w+4)
		local y = 4

		rect_color({0,0,0,0.5}, "fill", x, y, w, w)
		if slot.item and slot.quantity > 0 then
			gfx.draw(slot.item.sprite, x, y)
			print_color(COL_WHITE, slot.quantity, x, y)
		end
	end
end

function Inventory:add(item, quantity)
	if not item then   return   end
	if quantity <= 0 then   return    end
	
	quantity = quantity or 1

	for i=1, self.size do
		local slot = self.inventory[i]
		-- Increment quantity
		if slot.item and slot.item.id == item.id then
			slot.quantity = slot.quantity + quantity
			return True
		end

		-- New item
		if slot.item == nil or slot.quantity == 0 then
			slot.item = item
			slot.quantity = quantity
			return true
		end
	end
	return false
end

return Inventory