local h = require("helper")
local sm = require("state")
local gameState = require("game")
local menuState = require("menu")
local pauseState = require("pause")

function love.load()
	local hsFile = "highscore.txt"
	local hs = h.loadHighScore(hsFile)
	ScreenAreaWidth, ScreenAreaHeight = love.graphics.getDimensions()
	PlayingAreaWidth = 400
	PlayingAreaHeight = 400
	gameState:init(sm, menuState, pauseState, hs)
	menuState:init(sm, gameState, hs)
	pauseState:init(sm, gameState)
	CreateAssets()
	sm:changeState(menuState)
end

function love.update(dt)
	sm.state:update(dt)
end

function love.keypressed(key)
	sm.state:keypressed(key)
end

function love.mousepressed(x, y, button, istouch, presses)
	sm.state:mousePressed(x, y, button, istouch, presses)
end

function love.draw()
	-- background
	love.graphics.setColor(0.14, 0.36, 0.46)
	love.graphics.rectangle("fill", 0, 0, ScreenAreaWidth, ScreenAreaHeight)
	sm.state:draw()
end

function love.resize(w, he)
	ScreenAreaWidth = w
	ScreenAreaHeight = he
	CreateAssets()
end

function CreateAssets()
	gameState:createAssets()
	menuState:createAssets()
	pauseState:createAssets()
end
