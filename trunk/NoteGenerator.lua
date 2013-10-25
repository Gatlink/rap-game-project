require 'Note'
require 'GamePad'

NoteGenerator = {}

local __upcomingValues = {}
local __notes = {}
local __direction = 1
local __notesPerInterval = 2
local __timeInterval = 1 --sec
local __tick = 0
local __lastY = (Settings.NoteMaxOffsetY + Settings.NoteMinOffsetY) / 2

local tablePop = function(tab)
	if #tab == 0 then
		return nil
	end
	return table.remove(tab, 1)
end

function NoteGenerator.Update(dt)

	if __notesPerInterval == 0 then
		return
	end

	__tick = __tick + dt
	if __tick >= __timeInterval / __notesPerInterval then

		if #__upcomingValues == 0 then
			local val = math.random(GamePad.A,GamePad.Y)
			local count = math.random(2)
			for i=1,count do
				table.insert(__upcomingValues, val)
			end
		end

		if (__lastY >= Settings.NoteMaxOffsetY) then
			__lastY = __lastY - Settings.NoteMarginY
		elseif (__lastY <= Settings.NoteMinOffsetY) then
			__lastY = __lastY + Settings.NoteMarginY
		else
			__lastY = __lastY + (math.random(1,2) % 2 == 0 and 1 or -1) * Settings.NoteMarginY
		end
		local new_note = Note.New(tablePop(__upcomingValues),
		 	__direction < 0 and Settings.NoteStartRightX or Settings.NoteStartLeftX,
		 	__lastY,
		 	__direction, Note.Passive)
		table.insert(__notes, new_note)
		__tick = 0
	end
end

function NoteGenerator.SetDirection(dir)
	__direction = dir
end

function NoteGenerator.ToggleDirection()
	__direction = -1 *  __direction
end

function NoteGenerator.SetNotesPerInterval(npi)
	__notesPerInterval = npi
end

function NoteGenerator.SetTimeInterval(ti)
	__timeInterval = ti
end

function NoteGenerator.GetNextNote()
	return tablePop(__notes)
end
