require 'Settings'
require 'Deejay'
require 'Crowds'
require 'NoteGenerator'
require 'Note'

StateRound = {}

local _stage

function ValidOneKey(key)
	for _, note in ipairs(_stage.Notes) do
		if not (_stage.IsInsideHitzone(note) or _stage.HasLeftHitzone(note)) then break end

		if note.state == Note.Hit then
			_stage.HitCount= _stage.HitCount + 1
		elseif not Stage.HasLeftHitzone(note) and note.state ~= Note.Hit and note.state ~= Note.Miss and note.value == key then
			note:setState(Note.Hit)

			Deejay.yo:stop()
			Deejay.yo:setPitch(0.90 + note.value * 0.05)
			Deejay.yo:play()

			if note.direction == Note.Right then
				_stage.PlayerLeft:setState('attack')
			else
				_stage.PlayerRight:setState('attack')
			end

			if _stage.HitCount >= 3 and math.random(0, 10) > 8 then
				Deejay['oooh' .. math.random(1, 3)]:play()
				_stage.HitCount = 0
			end
			return
		end
	end

	if NoteGenerator.GetDirection() == Note.Right then
		_stage.PlayerLeft:setState('dammage')
		_stage.ScoreLeft = math.max(Stage.ScoreLeft - 0.25, 0)
	else
		_stage.PlayerRight:setState('dammage')
		_stage.ScoreRight = math.max(Stage.ScoreRight - 0.25, 0)
	end

	for _, note in ipairs(Stage.Notes) do
		if note.state == Note.Active or note.state == Note.Passive then
			note:setState(Note.Miss)
			_stage.HitCount = 0
			break
		end
	end
end

function StateRound.Load(stage)
	_stage = stage
end

function StateRound.Enter()
	Deejay.play('background')
	Deejay.play('cheers')

	NoteGenerator.Generate(Stage.RoundCount == 1 and Stage.NotesPerRound/2 or Stage.NotesPerRound)
	NoteGenerator.ToggleDirection()

	GamePad:RegisterEvent(ValidOneKey)
end

function StateRound.Leave()
	Deejay.stop('background')
	Deejay.play('scratch')
	Deejay.stop('cheers')
	Deejay.cheers:setVolume(1)

	_stage.HitCount = 0

	GamePad:UnregisterEvent(ValidOneKey)
end

function StateRound.Update(dt)
	_stage.PlayerLeft:update(dt)
	_stage.PlayerRight:update(dt)
	Crowds.Update(dt)
	NoteGenerator.Update(dt)

	if Deejay.cheers:getVolume() > 0.2 then
		Deejay.cheers:setVolume(Deejay.cheers:getVolume() - 0.005)
	end

	for i, note in ipairs(_stage.Notes) do
		-- Is player right hit
		if note.direction == Note.Right
		and note.state == Note.Hit
		and _stage.PlayerRight:intersects(note.x, note.y) then
			_stage.PlayerRight:setState('dammage')
			_stage.ScoreLeft = Stage.ScoreLeft + 1
			note:SetAlive(false)
		-- Is player left hit
		elseif note.direction == Note.Left
		and note.state == Note.Hit
		and _stage.PlayerLeft:intersects(note.x, note.y) then
			_stage.PlayerLeft:setState('dammage')
			_stage.ScoreRight = _stage.ScoreRight + 1
			note:SetAlive(false)
		elseif note.x > Settings.ScreenWidth + Settings.NoteSize
			or note.x < -Settings.NoteSize then
			note:SetAlive(false)
		end

		if _stage.IsInsideHitzone(note) and note.state == Note.Passive then
			note:setState(Note.Active)
		end

		if _stage.HasLeftHitzone(note) and note.state ~= Note.Hit then
			note:setState(Note.Miss)
		end

		note:Update(dt)
	end

	local newNote = NoteGenerator.GetNextNote()
	while newNote do
		table.insert(_stage.Notes, newNote)
		newNote = NoteGenerator.GetNextNote()
	end

	if _stage.ScoreLeft >= Settings.ScoreToWin or _stage.ScoreRight >= Settings.ScoreToWin then
		_stage.SetState('victory')
	elseif # _stage.Notes == 0 and NoteGenerator.RemainingNotes() == 0 then
		_stage.SetState('interlude')
	end
end

function StateRound.Draw()

end
