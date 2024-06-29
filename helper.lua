local helper = {}
function helper.createButton(xp, yp, image, clicked, opacity)
	opacity = opacity or 1
	local width, height = image:getDimensions()
	return {
		x = xp,
		y = yp,
		image = image,
		width = width,
		height = height,
		draw = function(self)
			love.graphics.setColor(1, 1, 1, opacity)
			love.graphics.draw(self.image, self.x, self.y)
		end,
		checkClick = function(self, x, y)
			if x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height then
				clicked()
				return true
			end
			return false
		end,
	}
end

function helper.loadHighScore(hsFile)
	if love.filesystem.getInfo(hsFile, "file") then
		local data, _ = love.filesystem.read(hsFile)
		return tonumber(data)
	end
	return 0
end

function helper.writeHighScore(hsFile, hs)
	love.filesystem.write(hsFile, tostring(hs))
end

return helper
