require 'Note'
require 'GamePad'

NoteGenerator = {}

local _patterns = {}

-- patterns length == 1
_patterns[1] = {
	{GamePad.A},
	{GamePad.B},
	{GamePad.X},
	{GamePad.Y}
}
-- patterns length == 2
_patterns[2] = {
	{GamePad.A, GamePad.B},
	{GamePad.B, GamePad.X},
	{GamePad.X, GamePad.Y},
	{GamePad.Y, GamePad.Y}
}
-- patterns length == 3
_patterns[3] = {
	{GamePad.A, GamePad.Y, GamePad.Y},
	{GamePad.B, GamePad.X, GamePad.B},
	{GamePad.X, GamePad.Y, GamePad.Y},
	{GamePad.A, GamePad.A, GamePad.B}
}
-- patterns length == 4
_patterns[4] = {
	{GamePad.A, GamePad.Y, GamePad.A, GamePad.Y},
	{GamePad.B, GamePad.X, GamePad.X, GamePad.B},
	{GamePad.X, GamePad.Y, GamePad.Y, GamePad.X},
	{GamePad.A, GamePad.A, GamePad.B, GamePad.B}
}



local __upcomingValues = {}
local __notes = {}
local __direction = 1
local __notesPerInterval = Settings.DefaultNotesPerInterval
local __timeInterval = Settings.DefaultNoteGenerationInterval
local __tick = 0
local __timeout = 0
local __lastY = (Settings.NoteMaxOffsetY + Settings.NoteMinOffsetY) / 2
local _isRunning = true
local _pauseCountdown = 0

local tablePop = function(tab)
	if #tab == 0 then
		return nil
	end
	return table.remove(tab, 1)
end

function NoteGenerator.Update(dt)

	if __notesPerInterval == 0 
		or _isRunning == false
		or #__upcomingValues == 0 then
		return
	end

	if __timeout > 0 then
		__timeout = __timeout - dt
		return
	end

	__tick = __tick + dt
	if __tick >= __timeInterval / __notesPerInterval then

		if (__lastY + Settings.NoteSize >= Settings.NoteMaxOffsetY) then
			__lastY = __lastY - math.random(1,2) * Settings.NoteSize
		elseif (__lastY - Settings.NoteSize <= Settings.NoteMinOffsetY) then
		 	__lastY = __lastY + math.random(1,2) * Settings.NoteSize
		else
			__lastY = __lastY + (math.random(1,2) % 2 == 0 and 1 or -1) *
				math.random(1,2) * Settings.NoteSize
		end
		local new_note = Note.New(tablePop(__upcomingValues),
		 	__direction < 0 and Settings.NoteStartRightX or Settings.NoteStartLeftX,
		 	__lastY,
		 	__direction, Note.Passive)
		table.insert(__notes, new_note)

		_pauseCountdown = _pauseCountdown - 1
		if _pauseCountdown == 0 then
			NoteGenerator.Timeout(3*math.random())
			_pauseCountdown = math.random(3, 7)
		end

		__tick = 0
	end
end

function NoteGenerator.Generate(count)
	_noteCount = 0
	_pauseCountdown = math.random(3, 7)
	while count > 0 do
		local idx = 1 + math.random(1,count) % #_patterns
		local pattern = _patterns[idx][math.random(1,#_patterns[idx])];

		for _,button in ipairs(pattern) do
			if (count == 0) then
				return; -- double check :3
			end
			table.insert(__upcomingValues, button)
			count = count - 1
		end
	end
end

function NoteGenerator.RemainingNotes()
	return #__upcomingValues
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

function NoteGenerator.GetNotesPerInterval(npi)
	return __notesPerInterval
end

function NoteGenerator.GetTimeInterval(ti)
	return __timeInterval
end

function NoteGenerator.GetNextNote()
	return tablePop(__notes)
end

function NoteGenerator.Stop()
	_isRunning = false
end

function NoteGenerator.Start()
	_isRunning = true
end

function NoteGenerator.Timeout(t)
	__timeout = t
end