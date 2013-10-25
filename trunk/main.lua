require 'Settings'
require 'Note'

local testNote

function love.load(arg)
	love.graphics.setMode(Settings.ScreenWidth, Settings.ScreenHeight)

	Note.Load()
	testNote = Note.New()
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.push('quit')
	elseif key == 'return' then
		testNote.state = (testNote.state + 1) % 4
	end
end

function love.keyreleased(key)

end

function love.draw()
	testNote:Draw()
end

function love.update(dt)
	testNote:Update(dt)
end
