function load_image(name)
	local im = love.graphics.newImage("images/"..name)
	im:setFilter("nearest", "nearest")
	return im 
end
function load_image_table(name, n, w, h)
	if not n then  error("number of images `n` not defined")  end
	local t = {}
	for i=1,n do 
		t[i] = load_image(name..tostr(i))
	end
	t.w = w
	t.h = h
	return t
end

local images = {}
images.magnet = load_image("magnet.png")

return images