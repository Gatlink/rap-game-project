require 'Settings'
require 'Stage'
require 'GamePad'
require 'Deejay'

local _background

function love.load(arg)
	love.graphics.setMode(Settings.ScreenWidth, Settings.ScreenHeight)
	math.randomseed(os.time())

	_background = love.graphics.newImage('assets/sprites/Background_00.png')

	Deejay.Load("assets/music")
	Stage.Load()
end

function love.keyreleased(key)

end

function love.draw()
	love.graphics.draw(_background)

	Stage.Draw()
end

function love.update(dt)
	Deejay.Update(dt)
	Stage.Update(dt)
end
