require 'Settings'
require 'Note'
require 'NoteGenerator'
require 'loveanimation'

Stage = {}

-- Sprites
local _timeline
local _streetCred
local _hitzoneLeft
local _hitzoneRight
local _crowdLeft
local _crowdCenter
local _crowdRight

-- Players
local _playerLeft = nil
local _playerRight = nil
local _scoreLeft = 0
local _scoreRight = 0


local _notes = {}
local _hitzoneWidth = Settings.ScreenWidth * Settings.HitzoneWidthRatio
local _leftHitzoneBorder = Settings.ScreenWidth / 2 - _hitzoneWidth / 2
local _rightHitzoneBorder = Settings.ScreenWidth / 2 + _hitzoneWidth / 2


local _interludeTimeout = 5

local _deejay = {
	backgroundBeat = nil
}

-- HIT TESTS
local function isInsideHitzone(note)
	return note.x > _leftHitzoneBorder and note.x < _rightHitzoneBorder
end

local function hasLeftHitzone(note)
	return (note.direction == Note.Left and note.x < _leftHitzoneBorder)
		or (note.direction == Note.Right and note.x > _rightHitzoneBorder)
end

-- BUTTON CALLBACKS
function ValidOneKey(key)
	for _, note in ipairs(_notes) do
		-- if one note isn't in the zone yet, any of the following ones will be
		if not (isInsideHitzone(note) or hasLeftHitzone(note)) then
			break
		end

		if not hasLeftHitzone(note) and note.state ~= Note.Hit and note.value == key then
			note:setState(Note.Hit)

			if note.direction == Note.Right then
				_playerLeft:setState('attack')
			else
				_playerRight:setState('attack')
			end

			break
		end
	end
end

function onA()
	ValidOneKey(GamePad.A)
end

function onB()
	ValidOneKey(GamePad.B)
end

function onX()
	ValidOneKey(GamePad.X)
end

function onY()
	ValidOneKey(GamePad.Y)
end


function Stage.Load()
	_timeline = love.graphics.newImage("assets/sprites/Timeline.png")
	_streetCred = love.graphics.newImage("assets/sprites/StreetCred_Remplissage_00.png")
	_hitzoneLeft = love.graphics.newImage("assets/sprites/Hitzone_gauche.png")
	_hitzoneRight = love.graphics.newImage("assets/sprites/Hitzone_droite.png")

	_crowdLeft = LoveAnimation.new("assets/animations/crowd.lua")
	_crowdLeft:setPosition(-35, 350)

	_crowdCenter = LoveAnimation.new("assets/animations/crowd.lua","assets/sprites/public_02_spritesheet.png")
	_crowdCenter:setPosition(Settings.ScreenWidth / 2 - _crowdCenter:getFrameWidth(0) / 2, 380)
	_crowdCenter:setCurrentFrame(2)

	_crowdRight = LoveAnimation.new("assets/animations/crowd.lua","assets/sprites/public_01_spritesheet.png")
	_crowdRight:setPosition(Settings.ScreenWidth - _crowdRight:getFrameWidth() + 35, 360)
	_crowdRight:setCurrentFrame(1)

	Note.Load()
	GamePad:RegisterEvent(GamePad.A, onA)
	GamePad:RegisterEvent(GamePad.B, onB)
	GamePad:RegisterEvent(GamePad.X, onX)
	GamePad:RegisterEvent(GamePad.Y, onY)

	_deejay.background = love.audio.newSource("assets/music/beat2.ogg", "static")
	_deejay.background:setLooping(true)
	_deejay.background:play()

	_playerLeft = LoveAnimation.new("assets/animations/rapper1.lua")
	_playerRight = _playerLeft:clone()


	_playerRight:setRelativeOrigin(0.5,0.5)
	_playerLeft:setRelativeOrigin(0.5,0.5)
	_playerLeft:flipHorizontal()

	_playerRight:setPosition(7*Settings.ScreenWidth/8, Settings.ScreenHeight/2)
	_playerLeft:setPosition(Settings.ScreenWidth/8, Settings.ScreenHeight/2)

	NoteGenerator.Generate(15)

end

function Stage.Update(dt)

	NoteGenerator.Update(dt)

	_playerLeft:update(dt)
	_playerRight:update(dt)
	_crowdLeft:update(dt)
	_crowdCenter:update(dt)
	_crowdRight:update(dt)

	for i, note in ipairs(_notes) do
		-- Is player right hit
		if note.direction == Note.Right
		and note.state == Note.Hit
		and _playerRight:intersects(note.x, note.y) then
			_playerRight:setState('dammage')
			_scoreLeft = _scoreLeft + 1
			note:SetAlive(false)
		-- Is player left hit
		elseif note.direction == Note.Left
		and note.state == Note.Hit
		and _playerLeft:intersects(note.x, note.y) then
			_playerLeft:setState('dammage')
			_scoreRight = _scoreRight + 1
			note:SetAlive(false)
		elseif note.x > Settings.ScreenWidth + Settings.NoteSize
			or note.x < -Settings.NoteSize then
			note:SetAlive(false)
		end

		if isInsideHitzone(note) and note.state == Note.Passive then
			note:setState(Note.Active)
		end

		if hasLeftHitzone(note) and note.state ~= Note.Hit then
			note:setState(Note.Miss)
		end

		note:Update(dt)
	end

	local i = 1
	while i <= #_notes do
		if not _notes[i]:IsAlive() then
			table.remove(_notes, i)
			i = i - 1
		end
		i = i + 1
	end

	local newNote = NoteGenerator.GetNextNote()
	while newNote do
		table.insert(_notes, newNote)
		newNote = NoteGenerator.GetNextNote()
	end


	if #_notes == 0 and NoteGenerator.RemainingNotes() == 0 then
		_interludeTimeout = _interludeTimeout - dt
		_deejay.background:pause()
		-- we wait for the interlude to finish
		if _interludeTimeout <= 0 then
			-- we start the next round
			NoteGenerator.Generate(30)
			NoteGenerator.ToggleDirection()
			_deejay.background:play()
			_interludeTimeout = 5
		end
	end

end

function Stage.Draw()
	-- Street Cred bars
	local quad = love.graphics.newQuad(0,0,_scoreLeft/100*Settings.StreetCredWidth + 1,Settings.StreetCredHeight,Settings.StreetCredWidth,Settings.StreetCredHeight)
	love.graphics.drawq(_streetCred, quad, 3, 50)

	local actualWidth = _scoreRight/100*Settings.StreetCredWidth + 1
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
	for _, note in ipairs(_notes) do
		note:Draw()
	end

	-- Players
	_playerLeft:draw()
	_playerRight:draw()

	-- crowd
	_crowdRight:draw()
	_crowdLeft:draw()
	_crowdCenter:draw()
end
