require 'Settings'
require 'Note'
require 'NoteGenerator'

Stage = {}

local _notes = {}
local _hitzoneWidth = Settings.ScreenWidth * Settings.HitzoneWidthRatio

-- function onA()
-- 	print("lol")
-- end

function Stage.Load()
	Note.Load()
	-- GamePad:RegisterEvent(GamePad.X, onA)
end

function Stage.Update(dt)
	NoteGenerator.Update(dt)

	local newNote = NoteGenerator.GetNextNote()
	while newNote do
		table.insert(_notes, newNote)
		newNote = NoteGenerator.GetNextNote()
	end

	for _, note in ipairs(_notes) do
		note:Update(dt)
	end
end

function Stage.Draw()
	love.graphics.setColor(223, 221, 21)
	love.graphics.rectangle('fill', Settings.ScreenWidth / 2  - _hitzoneWidth / 2, 0, _hitzoneWidth, Settings.ScreenHeight)
	love.graphics.setColor(255, 255, 255)

	for _, note in ipairs(_notes) do
		note:Draw()
	end
end
