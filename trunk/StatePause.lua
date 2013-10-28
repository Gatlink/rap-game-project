require 'Settings'
require 'StageState'
require 'Deejay'
require 'Announcement'

StatePause = {}
setmetatable(StatePause, StageState)

local _announcementPause
local _previousState

local function OnPausePressed(button)
	if button == GamePad.Start then
		if StatePause._stage.CurrentState == 'pause' then
			StatePause.Leave()
		else
			StatePause.Enter()
		end
	end
end

function StatePause:Load(stage)
	StageState.Load(self, stage)

	_announcementPause = Announcement.New("assets/sprites/Pause.png",Settings.ScreenWidth/2,300)
	GamePad:RegisterEvent(OnPausePressed)
end

function StatePause.Enter()
	_previousState = StatePause._stage.CurrentState
	StatePause._stage.CurrentState = 'pause'
	Deejay.pauseAll()
end

function StatePause.Leave()
	_announcementPause:Reset()
	Deejay.resumeAll()
	StatePause._stage.CurrentState = _previousState
end

function StatePause.Update(dt)
	_announcementPause:Update(dt)
end

function StatePause:Draw()
	love.graphics.setColor(0,0,0,85)
	love.graphics.rectangle('fill',0,0,Settings.ScreenWidth,Settings.ScreenHeight)
	love.graphics.setColor(255,255,255)

	_announcementPause:Draw()
end
