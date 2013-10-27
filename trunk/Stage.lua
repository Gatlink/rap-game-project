require 'Settings'
require 'Note'
require 'NoteGenerator'
require 'loveanimation'
require 'Announcement'
require 'Crowds'
require 'StateRound'
require 'StateInterlude'
require 'StateVictory'

Stage = {}

-- Sprites
local _timeline
local _streetCred
local _hitzoneLeft
local _hitzoneRight

local _hitzoneWidth = Settings.ScreenWidth * Settings.HitzoneWidthRatio
local _leftHitzoneBorder = Settings.ScreenWidth / 2 - _hitzoneWidth / 2
local _rightHitzoneBorder = Settings.ScreenWidth / 2 + _hitzoneWidth / 2

local _currentState
local _states = {
	round = StateRound,
	interlude = StateInterlude,
	victory = StateVictory
}

Stage.PlayerLeft = nil
Stage.PlayerRight = nil
Stage.ScoreLeft = 0
Stage.ScoreRight = 0

Stage.RoundCount = 0
Stage.NotesPerRound = Settings.DefaultNotesPerRound

Stage.Notes = {}
Stage.HitCount = 0

function Stage.SetState(state)
	if _currentState ~= nil then
		_states[_currentState].Leave()
	end
	_currentState = state
	_states[_currentState].Enter()
end

-- HIT TESTS
function Stage.IsInsideHitzone(note)
	return note.x > _leftHitzoneBorder and note.x < _rightHitzoneBorder
end

function Stage.HasLeftHitzone(note)
	return (note.direction == Note.Left and note.x < _leftHitzoneBorder)
		or (note.direction == Note.Right and note.x > _rightHitzoneBorder)
end

function Stage.Load()
	_timeline = love.graphics.newImage("assets/sprites/Timeline.png")
	_streetCred = love.graphics.newImage("assets/sprites/StreetCred_Remplissage_00.png")
	_hitzoneLeft = love.graphics.newImage("assets/sprites/Hitzone_gauche.png")
	_hitzoneRight = love.graphics.newImage("assets/sprites/Hitzone_droite.png")

	Crowds.Load()
	Note.Load()

	Stage.PlayerLeft = LoveAnimation.new("assets/animations/rapper1.lua")
	Stage.PlayerRight = LoveAnimation.new("assets/animations/rapper1.lua","assets/sprites/rapper2_spritesheet.png")

	Stage.PlayerRight:setRelativeOrigin(0.5,0.5)
	Stage.PlayerLeft:setRelativeOrigin(0.5,0.5)
	Stage.PlayerLeft:flipHorizontal()

	Stage.PlayerRight:setPosition(7*Settings.ScreenWidth/8, Settings.ScreenHeight/2)
	Stage.PlayerRight:setCurrentFrame(1)
	Stage.PlayerLeft:setPosition(Settings.ScreenWidth/8, Settings.ScreenHeight/2)

	NoteGenerator.ToggleDirection()

	for _, state in pairs(_states) do
		state.Load(Stage)
	end

	Stage.SetState('interlude')
end

function Stage.Update(dt)
	_states[_currentState].Update(dt)

	local i = 1
	while i <= # Stage.Notes do
		if not Stage.Notes[i]:IsAlive() then
			table.remove(Stage.Notes, i)
			i = i - 1
		end
		i = i + 1
	end
end

function Stage.Draw()
	-- Street Cred bars
	local quad = love.graphics.newQuad(0,0,Stage.ScoreLeft/Settings.ScoreToWin*Settings.StreetCredWidth + 1,Settings.StreetCredHeight,Settings.StreetCredWidth,Settings.StreetCredHeight)
	love.graphics.drawq(_streetCred, quad, 3, 50)

	local actualWidth = Stage.ScoreRight/Settings.ScoreToWin*Settings.StreetCredWidth + 1
	local halfWidth, halfHeight = 0.5*_streetCred:getWidth(), 0.5*_streetCred:getHeight()
	quad = love.graphics.newQuad(0,0,actualWidth,Settings.StreetCredHeight,Settings.StreetCredWidth,Settings.StreetCredHeight)
	love.graphics.drawq(_streetCred,quad,Settings.ScreenWidth - halfWidth - 3,50 + halfHeight,0,-1,1,halfWidth,halfHeight)

	-- Timeline
	love.graphics.draw(_timeline, 0, 42)

	-- Hitzone
	local hitzoneX = Settings.ScreenWidth / 2 - _hitzoneWidth / 2
	love.graphics.setColor(0, 76, 255, 85)
	love.graphics.rectangle('fill', hitzoneX + Settings.HitzoneBorderWidth, Settings.HitzoneYOffset, _hitzoneWidth - 2 * Settings.HitzoneBorderWidth, Settings.HitzoneHeight)
	love.graphics.setColor(255, 255, 255, 85)
	love.graphics.draw(_hitzoneLeft, hitzoneX, Settings.HitzoneYOffset)
	love.graphics.draw(_hitzoneRight, hitzoneX + _hitzoneWidth - Settings.HitzoneBorderWidth, Settings.HitzoneYOffset)
	love.graphics.setColor(255, 255, 255)

	-- Notes
	for _, note in ipairs(Stage.Notes) do
		note:Draw()
	end

	-- Players
	Stage.PlayerLeft:draw()
	Stage.PlayerRight:draw()

	-- crowd
	Crowds.Draw()

	_states[_currentState].Draw()
end
