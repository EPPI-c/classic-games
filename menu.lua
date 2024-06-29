local h = require("helper")

local menu = {}

function menu:init(stateMachine, gameState, hs)
	self.startButtonImg = love.graphics.newImage("figures/START.png")
	self.sm = stateMachine
	self.gameState = gameState
	self.hs = hs
end

function menu:createAssets()
	local start_button_width, start_button_height = self.startButtonImg:getDimensions()
	local start_button_x = (ScreenAreaWidth - start_button_width) / 2
	local start_button_y = (ScreenAreaHeight - start_button_height) / 3
	self.startButton = h.createButton(start_button_x, start_button_y, self.startButtonImg, function()
		self.sm:changeState(self.gameState)
	end)
end

function menu:draw()
	love.graphics.setColor(1, 1, 1)
	self.startButton:draw()
	love.graphics.setColor(255, 215, 0)
	local font = love.graphics.newFont(20)
	love.graphics.setFont(font)
	love.graphics.print("HIGHSCORE: " .. self.hs, 10, 10)
end

function menu:changedState(hs)
	self.hs = tostring(hs)
end

function menu:mousePressed(x, y, _, _, _)
	self.startButton:checkClick(x, y)
end

function menu:keypressed(_)
	self.sm:changeState(self.gameState)
end

function menu:update(_) end

return menu
