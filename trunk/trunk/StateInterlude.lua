require 'Settings'
require 'Crowds'
require 'Deejay'
require 'Announcement'

StateInterlude = {}

local _stage
local _announcementReady
local _announcementGo
local _interludeTimeout = Settings.InterludeTimeout

function StateInterlude.Load(stage)
	_stage = stage

	_announcementReady = Announcement.New("assets/sprites/Ready.png",Settings.ScreenWidth/2,200)
	_announcementGo = Announcement.New("assets/sprites/Go.png",Settings.ScreenWidth/2,200)
end

function StateInterlude.Enter()
	Deejay.play('cheers')
	Deejay.play('ready')
	Crowds.SetSpeedMultiplier(2)
end

function StateInterlude.Leave()
	Deejay.stop('cheers')
	_interludeTimeout = Settings.InterludeTimeout
	_announcementGo:Reset()
	_announcementReady:Reset()
	Stage.RoundCount = Stage.RoundCount + 1
	Crowds.SetSpeedMultiplier(1)

	if Stage.RoundCount % 2 == 1 then
		NoteGenerator.SetTimeInterval(NoteGenerator.GetTimeInterval() + 1)
		NoteGenerator.SetNotesPerInterval(NoteGenerator.GetNotesPerInterval() + 4)
	end
end

function StateInterlude.Update(dt)
	_interludeTimeout = _interludeTimeout - dt

	_stage.PlayerLeft:update(dt)
	_stage.PlayerRight:update(dt)
	Crowds.Update(dt)

	if _interludeTimeout <= 0 then
		_stage.SetState('round')
	elseif _interludeTimeout <= 0.3 then
		_announcementGo:Update(dt)
		Deejay.play('go')
	elseif _interludeTimeout <= 2.5 then
		_announcementReady:Update(dt)
	end
end

function StateInterlude.Draw()
	if _interludeTimeout <= 0.3 then
		_announcementGo:Draw()
	elseif _interludeTimeout <= 2.5 then
		_announcementReady:Draw()
	end
end
