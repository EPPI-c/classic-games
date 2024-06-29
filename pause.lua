local h = require("helper")

local pause = {}

function pause:init(stateMachine, gameState)
	self.unpauseButtonImg = love.graphics.newImage("figures/UNPAUSE.png")
	self.sm = stateMachine
	self.gameState = gameState
end

function pause:createAssets()
	local unpause_button_width, _ = self.unpauseButtonImg:getDimensions()
	local unpause_button_x = ScreenAreaWidth - 10 - unpause_button_width
	local unpause_button_y = 10
	self.unpauseButton = h.createButton(unpause_button_x, unpause_button_y, self.unpauseButtonImg, function()
		self.sm:changeState(self.gameState, true)
	end)
end

function pause:update(_) end

function pause:changedState() end

function pause:draw()
	self.gameState:draw()
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", 0, 0, ScreenAreaWidth, ScreenAreaHeight)
	self.unpauseButton:draw()
end

function pause:mousePressed(x, y, _, _, _)
	if self.unpauseButton:checkClick(x, y) then
		return
	end
	self.sm:changeState(self.gameState)
end

function pause:keypressed(key)
	if key == "escape" then
		self.sm:changeState(self.gameState, true)
		return
	end
	self.sm:changeState(self.gameState)
end

return pause
