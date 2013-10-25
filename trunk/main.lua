require 'Settings'
require 'Note'

local testNote

function love.load(arg)
	love.graphics.setMode(Settings.ScreenWidth, Settings.ScreenHeight)

	Note.Load()
	testNote = Note.New(Note.A, 5, 5)
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
	elseif key == ' ' then
		testNote.value = (testNote.value) % 4 + 1
	end
end

function love.keyreleased(key)

end

function love.joystickpressed(pad, button)
	if button == 1 then
		GamePad:OnPress(pad, GamePad.A)
	elseif button == 2 then
		GamePad:OnPress(pad, GamePad.B)
	elseif button == 3 then
		GamePad:OnPress(pad, GamePad.X)
	elseif button == 4 then
		GamePad:OnPress(pad, GamePad.Y)
	end
end

function love.joystickreleased(pad, button)
end

function love.draw()
	testNote:Draw()
end

function love.update(dt)
	testNote:Update(dt)
end
