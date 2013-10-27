require 'Settings'
require 'StageState'
require 'Deejay'
require 'Crowds'
require 'NoteGenerator'
require 'Note'

StateRound = {}
setmetatable(StateRound, StageState)

function ValidOneKey(key)
	if key == GamePad.Start then return end

	for _, note in ipairs(StateRound._stage.Notes) do
		if not (StateRound._stage.IsInsideHitzone(note) or StateRound._stage.HasLeftHitzone(note)) then break end

		if note.state == Note.Hit then
			StateRound._stage.HitCount= StateRound._stage.HitCount + 1
		elseif not Stage.HasLeftHitzone(note) and note.state ~= Note.Hit and note.state ~= Note.Miss and note.value == key then
			note:setState(Note.Hit)

			Deejay.yo:stop()
			Deejay.yo:setPitch(0.90 + note.value * 0.05)
			Deejay.yo:play()

			if note.direction == Note.Right then
				StateRound._stage.PlayerLeft:setState('attack')
			else
				StateRound._stage.PlayerRight:setState('attack')
			end

			if StateRound._stage.HitCount >= 3 and math.random(0, 10) > 8 then
				Deejay['oooh' .. math.random(1, 3)]:play()
				StateRound._stage.HitCount = 0
			end
			return
		end
	end

	if NoteGenerator.GetDirection() == Note.Right then
		StateRound._stage.PlayerLeft:setState('dammage')
		StateRound._stage.ScoreLeft = math.max(Stage.ScoreLeft - 0.25, 0)
	else
		StateRound._stage.PlayerRight:setState('dammage')
		StateRound._stage.ScoreRight = math.max(Stage.ScoreRight - 0.25, 0)
	end

	for _, note in ipairs(Stage.Notes) do
		if note.state == Note.Active or note.state == Note.Passive then
			note:setState(Note.Miss)
			StateRound._stage.HitCount = 0
			break
		end
	end
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

	StateRound._stage.HitCount = 0

	GamePad:UnregisterEvent(ValidOneKey)
end

function StateRound.Update(dt)
	StateRound._stage.PlayerLeft:update(dt)
	StateRound._stage.PlayerRight:update(dt)
	Crowds.Update(dt)
	NoteGenerator.Update(dt)

	if Deejay.cheers:getVolume() > 0.2 then
		Deejay.cheers:setVolume(Deejay.cheers:getVolume() - 0.005)
	end

	for i, note in ipairs(StateRound._stage.Notes) do
		-- Is player right hit
		if note.direction == Note.Right
		and note.state == Note.Hit
		and StateRound._stage.PlayerRight:intersects(note.x, note.y) then
			StateRound._stage.PlayerRight:setState('dammage')
			StateRound._stage.ScoreLeft = Stage.ScoreLeft + 1
			note:SetAlive(false)
		-- Is player left hit
		elseif note.direction == Note.Left
		and note.state == Note.Hit
		and StateRound._stage.PlayerLeft:intersects(note.x, note.y) then
			StateRound._stage.PlayerLeft:setState('dammage')
			StateRound._stage.ScoreRight = StateRound._stage.ScoreRight + 1
			note:SetAlive(false)
		elseif note.x > Settings.ScreenWidth + Settings.NoteSize
			or note.x < -Settings.NoteSize then
			note:SetAlive(false)
		end

		if StateRound._stage.IsInsideHitzone(note) and note.state == Note.Passive then
			note:setState(Note.Active)
		end

		if StateRound._stage.HasLeftHitzone(note) and note.state ~= Note.Hit then
			note:setState(Note.Miss)
		end

		note:Update(dt)
	end

	local newNote = NoteGenerator.GetNextNote()
	while newNote do
		table.insert(StateRound._stage.Notes, newNote)
		newNote = NoteGenerator.GetNextNote()
	end

	if StateRound._stage.ScoreLeft >= Settings.ScoreToWin or StateRound._stage.ScoreRight >= Settings.ScoreToWin then
		StateRound._stage.SetState('victory')
	elseif # StateRound._stage.Notes == 0 and NoteGenerator.RemainingNotes() == 0 then
		StateRound._stage.SetState('interlude')
	end
end
