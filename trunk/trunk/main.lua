require 'Settings'
require 'Note'
require 'NoteGenerator'

local notes = {}

function love.load(arg)
	love.graphics.setMode(Settings.ScreenWidth, Settings.ScreenHeight)

	Note.Load()
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
	for i,note in ipairs(notes) do
		note:Draw()
	end
end

function love.update(dt)

	NoteGenerator.Update(dt)

	local new_note = NoteGenerator.GetNextNote()
	while new_note do 
		table.insert(notes, new_note)
		new_note = NoteGenerator.GetNextNote()
	end

	for i,note in ipairs(notes) do
		note:Update(dt)
	end
end
