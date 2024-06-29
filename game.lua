local h = require("helper")

local game = {}

function game:init(stateMachine, menuState, pauseState, hs)
	self.pauseButtonImg = love.graphics.newImage("figures/PAUSE.png")
	self.unusedPipes = {}
	self.pipes = {}
	self.sm = stateMachine
	self.menuState = menuState
	self.pauseState = pauseState
	self.hs = hs
end

function game:createAssets()
	self.bird = self.createBird()
	local pause_button_width, _ = self.pauseButtonImg:getDimensions()
	local pause_button_x = ScreenAreaWidth - 10 - pause_button_width
	local pause_button_y = 10
	self.pauseButton = h.createButton(pause_button_x, pause_button_y, self.pauseButtonImg, function()
		self.sm:changeState(self.pauseState)
	end, 0.6)
end

function game:reset()
	for _, pipe in pairs(self.pipes) do
		table.insert(self.unusedPipes, pipe)
	end
	self.pipes = {}
	self.bird:reset()
end

function game:update(dt)
	self.bird:accel(dt)
	self.bird:move(dt)
	for k, pipe in pairs(self.pipes) do
		pipe:move(dt)
		if pipe:isOut() then
			table.insert(self.unusedPipes, pipe)
			table.remove(self.pipes, k)
		end
		if pipe:colided(self.bird) or self.bird:fell() then
			if self.hs < self.bird.score then
				self.hs = self.bird.score
				h.writeHighScore(self.hs)
			end
			self:reset()
			self.sm:changeState(self.menuState, self.hs)
			return
		end
		pipe:score(self.bird)
	end
	local l = #self.pipes
	if l == 0 or self.pipes[l]:farenough() then
		local pipe = self:createPipe()
		table.insert(self.pipes, pipe)
	end
end

function game:changedState(dontJump)
	if not dontJump then
		self.bird:up()
	end
end

function game:draw()
	for _, pipe in pairs(self.pipes) do
		pipe:draw()
	end
	self.bird:draw()
	love.graphics.setColor(1, 0, 0)
	local font = love.graphics.newFont(30)
	love.graphics.setFont(font)
	love.graphics.print(tostring(self.bird.score), 10, 10)
	love.graphics.setColor(0.294, 0.412, 0.078)
	love.graphics.rectangle("fill", 0, PlayingAreaHeight, ScreenAreaWidth, ScreenAreaHeight - PlayingAreaHeight)
	if self.sm.state == self then
		self.pauseButton:draw()
	end
end

function game:mousePressed(x, y, _, _, _)
	if not self.pauseButton:checkClick(x, y) then
		self.bird:up()
	end
end

function game:keypressed(key)
	if key == "escape" then
		self.sm:changeState(self.pauseState)
		return
	end
	self.bird:up()
end

function game.createBird()
	local bird = {
		y = 200,
		ySpeed = 0,
		x = 62,
		width = 30,
		height = 25,
		score = 0,
		draw = function(self)
			love.graphics.setColor(0.87, 0.84, 0.27)
			love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		end,
		up = function(self)
			if self.y > 0 then
				self.ySpeed = -250
			end
		end,
		accel = function(self, dt)
			self.ySpeed = self.ySpeed + (515 * dt)
		end,
		move = function(self, dt)
			self.y = self.y + (self.ySpeed * dt)
		end,
		fell = function(self)
			if self.y > PlayingAreaHeight then
				return true
			else
				return false
			end
		end,
		reset = function(self)
			self.y = 200
			self.ySpeed = 0
			self.x = 62
			self.width = 30
			self.height = 25
			self.score = 0
		end,
	}
	return bird
end

function game:createPipe()
	local l = #self.unusedPipes
	if l ~= 0 then
		local pipe = table.remove(self.unusedPipes, l)
		pipe:reset()
		return pipe
	end
	local pipeSpaceYMin = 54
	local spaceHeight = 100
	local width = 54
	local spaceY = love.math.random(pipeSpaceYMin, PlayingAreaHeight - spaceHeight - pipeSpaceYMin)
	local y = 0
	local pipe = {
		passed = false,
		spaceHeight = spaceHeight,
		width = width,
		spaceY = spaceY,
		x = PlayingAreaWidth,
	}
	function pipe:colided(bird)
		if
			bird.x < (self.x + self.width)
			and (bird.x + bird.width) > self.x
			and (bird.y < self.spaceY or (bird.y + bird.height) > (self.spaceY + self.spaceHeight))
		then
			return true
		end
		return false
	end
	function pipe:_calcYdown()
		local a = (y - self.spaceY) / (PlayingAreaWidth - (PlayingAreaWidth - 50))
		local b = y - a * PlayingAreaWidth
		local height = a * self.x + b
		if self.spaceY > height then
			return height
		else
			return self.spaceY
		end
	end
	function pipe:_calcYup()
		local yf = self.spaceY + self.spaceHeight
		local a = (yf - PlayingAreaHeight) / ((PlayingAreaWidth - 50) - PlayingAreaWidth )
		local b = (PlayingAreaHeight)-(a * PlayingAreaWidth)
		local height = a * self.x + b
		if yf < height then
			return height
		else
			return yf
		end
	end
	function pipe:draw()
		love.graphics.setColor(0.37, 0.82, 0.28)
		local spaceYd = self:_calcYdown()
		local spaceYu = self:_calcYup()
		love.graphics.rectangle("fill", self.x, 0, self.width, spaceYd)
		love.graphics.rectangle(
			"fill",
			self.x,
			spaceYu,
			self.width,
			PlayingAreaHeight
		)
	end
	function pipe:isOut()
		if (self.x + self.width) < 0 then
			return true
		else
			return false
		end
	end
	function pipe:reset()
		self.passed = false
		self.spaceHeight = spaceHeight
		self.width = width
		self.x = PlayingAreaWidth
		self.spaceY = love.math.random(pipeSpaceYMin, PlayingAreaHeight - spaceHeight - pipeSpaceYMin)
	end
	function pipe:move(dt)
		self.x = self.x - (60 * dt)
	end
	function pipe:farenough()
		if PlayingAreaWidth - self.x - self.width >= self.width * 2 then
			return true
		else
			return false
		end
	end
	function pipe:score(bird)
		if self.passed then
			return false
		elseif self.x + self.width < bird.x then
			bird.score = bird.score + 1
			self.passed = true
			return true
		else
			return false
		end
	end
	return pipe
end

return game
