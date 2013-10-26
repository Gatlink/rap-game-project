require 'Settings'
require 'Note'
require 'NoteGenerator'
require 'loveanimation'

Stage = {}

local _playerLeft = nil
local _playerRight = nil

local _notes = {}
local _hitzoneWidth = Settings.ScreenWidth * Settings.HitzoneWidthRatio
local _leftHitzoneBorder = Settings.ScreenWidth / 2 - _hitzoneWidth / 2
local _rightHitzoneBorder = Settings.ScreenWidth / 2 + _hitzoneWidth / 2


local _interludeTimeout = 5
local _timeLeftInRound = 15

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
			local player = note.direction == Note.Right and _playerLeft or _playerRight
			player:setState('attack')
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

end

function Stage.Update(dt)

	NoteGenerator.Update(dt)

	_playerLeft:update(dt)
	_playerRight:update(dt)

	--local toDestroy = {}
	for i, note in ipairs(_notes) do
		-- Is player right hit
		if note.direction == Note.Right
		and note.state == Note.Hit
		and _playerRight:intersects(note.x, note.y) then
			_playerRight:setState('dammage')
			note:SetAlive(false)
			--table.insert(toDestroy, i)
		-- Is player left hit
		elseif note.direction == Note.Left
			and note.state == Note.Hit
			and _playerLeft:intersects(note.x, note.y) then
				_playerLeft:setState('dammage')
				note:SetAlive(false)
				--table.insert(toDestroy, i)
		elseif note.x > Settings.ScreenWidth + Settings.NoteSize
			or note.x < -Settings.NoteSize then
			note:SetAlive(false)
			--table.insert(toDestroy, i)
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

	_timeLeftInRound = _timeLeftInRound - dt
	-- timeout
	if _timeLeftInRound < 0 then
		-- we stop the note generator
		NoteGenerator.Stop()
		-- we wait for the current notes to finish
		if #_notes == 0 then
			_interludeTimeout = _interludeTimeout - dt
			-- we wait for the interlude to finish
			if _interludeTimeout <= 0 then
				-- we start the next round
				NoteGenerator.Start()
				NoteGenerator.ToggleDirection()
				_timeLeftInRound = 30
				_interludeTimeout = 5
			end
		end
	end

end

function Stage.Draw()
	love.graphics.setColor(223, 223, 223)
	love.graphics.rectangle('fill', _leftHitzoneBorder, 0, _hitzoneWidth, Settings.ScreenHeight)
	love.graphics.setColor(255, 255, 255)

	_playerLeft:draw()
	_playerRight:draw()

	for _, note in ipairs(_notes) do
		note:Draw()
	end
end
