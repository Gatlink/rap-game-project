require 'Settings'
require 'StageState'
require 'Announcement'
require 'Deejay'

StateVictory = {}
setmetatable(StateVictory, StageState)

local _announcementVictory
local _announcementVictoryLeft
local _announcementVictoryRight

function StateVictory:Load(stage)
	StageState.Load(self, stage)

	_announcementVictoryLeft = Announcement.New("assets/sprites/VictoryLeft.png",Settings.ScreenWidth/2,300)
	_announcementVictoryRight = Announcement.New("assets/sprites/VictoryRight.png",Settings.ScreenWidth/2,300)
end

function StateVictory.Enter()
	Deejay.play('cheers')
	Crowds.SetSpeedMultiplier(2)

	if StateVictory._stage.ScoreLeft >= Settings.ScoreToWin then
		StateVictory._stage.PlayerLeft:setState("victory")
		StateVictory._stage.PlayerRight:setState("defeat")
		_announcementVictory = _announcementVictoryLeft
	else
		StateVictory._stage.PlayerLeft:setState("defeat")
		StateVictory._stage.PlayerRight:setState("victory")
		_announcementVictory = _announcementVictoryRight
	end
end

function StateVictory.Update(dt)
	_announcementVictory:Update(dt)
	StateVictory._stage.PlayerLeft:update(dt)
	StateVictory._stage.PlayerRight:update(dt)
	Crowds.Update(dt)
end

function StateVictory.Draw()
	_announcementVictory:Draw()
end

