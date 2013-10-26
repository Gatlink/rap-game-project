require 'Settings'
require 'Stage'
require 'GamePad'

local _background

function love.load(arg)
	love.graphics.setMode(Settings.ScreenWidth, Settings.ScreenHeight)

	_background = love.graphics.newImage('assets/sprites/Background_00.png')

	Stage.Load()
end

function love.keyreleased(key)

end

function love.draw()
	love.graphics.draw(_background)

	Stage.Draw()
end

function love.update(dt)
	Stage.Update(dt)
end
