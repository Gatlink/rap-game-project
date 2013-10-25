require 'Settings'
require 'Stage'
require 'GamePad'

local notes = {}


function love.load(arg)
	love.graphics.setMode(Settings.ScreenWidth, Settings.ScreenHeight)

	Stage.Load()
end

function love.keyreleased(key)

end

function love.draw()
	Stage.Draw()
end

function love.update(dt)
	Stage.Update(dt)
end
