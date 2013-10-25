require 'Settings'
require 'Stage'

local notes = {}

function love.load(arg)
	love.graphics.setMode(Settings.ScreenWidth, Settings.ScreenHeight)

	Stage.Load()
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.push('quit')
	elseif key == "1" then
		GamePad:Onpress(0, GamePad.A)
	elseif key == "2" then
		GamePad:Onpress(0, GamePad.B)
	elseif key == "3" then
		GamePad:Onpress(0, GamePad.X)
	elseif key == "4" then
		GamePad:Onpress(0, GamePad.Y)
	end
end

function love.keyreleased(key)

end

function love.draw()
	Stage.Draw()
end

function love.update(dt)
	Stage.Update(dt)
end
