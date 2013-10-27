require 'Announcement'
require 'Deejay'

StateVictory = {}

local _stage
local _announcementVictory
local _announcementVictoryLeft
local _announcementVictoryRight

function StateVictory.Load(stage)
	_stage = stage
	_announcementVictoryLeft = Announcement.New("assets/sprites/VictoryLeft.png",Settings.ScreenWidth/2,300)
	_announcementVictoryRight = Announcement.New("assets/sprites/VictoryRight.png",Settings.ScreenWidth/2,300)
end

function StateVictory.Enter()
	Deejay.play('cheers')
	Crowds.SetSpeedMultiplier(2)

	if _stage.ScoreLeft >= Settings.ScoreToWin then
		_stage.PlayerLeft:setState("victory")
		_stage.PlayerRight:setState("defeat")
		_announcementVictory = _announcementVictoryLeft
	else
		_stage.PlayerLeft:setState("defeat")
		_stage.PlayerRight:setState("victory")
		_announcementVictory = _announcementVictoryRight
	end
end

function StateVictory.Leave()

end

function StateVictory.Update(dt)
	_announcementVictory:Update(dt)
	_stage.PlayerLeft:update(dt)
	_stage.PlayerRight:update(dt)
	Crowds.Update(dt)
end

function StateVictory.Draw()
	_announcementVictory:Draw()
end

