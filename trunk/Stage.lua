require 'Settings'
require 'Note'
require 'NoteGenerator'
require 'loveanimation'
require 'Announcement'
require 'Crowds'

Stage = {}

-- Sprites
local _timeline
local _streetCred
local _hitzoneLeft
local _hitzoneRight
local _announcementReady
local _announcementGo
local _announcementVictoryLeft
local _announcementVictoryRight

-- Players
local _playerLeft = nil
local _playerRight = nil
local _scoreLeft = 0
local _scoreRight = 0


local _notes = {}
local _hitCount = 0
local _hitzoneWidth = Settings.ScreenWidth * Settings.HitzoneWidthRatio
local _leftHitzoneBorder = Settings.ScreenWidth / 2 - _hitzoneWidth / 2
local _rightHitzoneBorder = Settings.ScreenWidth / 2 + _hitzoneWidth / 2


local _notesPerRound = Settings.DefaultNotesPerRound
local _roundCount = 0
local _interludeTimeout = 3

local _inRound = true
local _deejay = {
	backgroundBeat = nil,
	voices = {
		[Note.Left] = {},
		[Note.Right] = {}
	}
}
local _lastWord

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

		if note.state == Note.Hit then
			_hitCount= _hitCount + 1
		elseif not hasLeftHitzone(note) and note.state ~= Note.Hit and note.state ~= Note.Miss and note.value == key then
			note:setState(Note.Hit)

			_deejay.yo:stop()
			_deejay.yo:setPitch(0.90 + note.value * 0.05)
			_deejay.yo:play()

			if note.direction == Note.Right then
				_playerLeft:setState('attack')
			else
				_playerRight:setState('attack')
			end

			if _hitCount >= 3 and math.random(0, 10) > 8 then
				_deejay['oooh' .. math.random(1, 2)]:play()
				_hitCount = 0
			end
			return
		end
	end

	-- If the player hits a button that does not correspond to
	-- any note in the hitzone, play damage anim and miss the first note.
	if NoteGenerator.GetDirection() == Note.Right then
		_playerLeft:setState('dammage')
		_scoreLeft = math.max(_scoreLeft - 0.25, 0)
	else
		_playerRight:setState('dammage')
		_scoreRight = math.max(_scoreRight - 0.25, 0)
	end

	for _, note in ipairs(_notes) do
		if note.state == Note.Active or note.state == Note.Passive then
			note:setState(Note.Miss)
			_hitCount = 0
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

	-- Crowd
	Crowds.Load()

	-- Announcement
	_announcementReady = Announcement.New("assets/sprites/Ready.png",Settings.ScreenWidth/2,200)
	_announcementGo = Announcement.New("assets/sprites/Go.png",Settings.ScreenWidth/2,200)
	_announcementVictoryLeft = Announcement.New("assets/sprites/VictoryLeft.png",Settings.ScreenWidth/2,300)
	_announcementVictoryRight = Announcement.New("assets/sprites/VictoryRight.png",Settings.ScreenWidth/2,300)

	Note.Load()
	GamePad:RegisterEvent(GamePad.A, onA)
	GamePad:RegisterEvent(GamePad.B, onB)
	GamePad:RegisterEvent(GamePad.X, onX)
	GamePad:RegisterEvent(GamePad.Y, onY)

	_deejay.background = love.audio.newSource("assets/music/beat" ..
		math.random(1,Settings.BeatFilesAvailable) .. ".ogg", "static")
	_deejay.background:setLooping(true)
	_deejay.cheers = love.audio.newSource("assets/music/cheers.ogg", "static")
	_deejay.cheers:setLooping(true)
	_deejay.cheers:play()
	_deejay.scratch = love.audio.newSource("assets/music/scratch.ogg", "static")
	_deejay.scratch:setLooping(false)
	_deejay.oooh1 = love.audio.newSource("assets/music/Oooh1.ogg", "static")
	_deejay.oooh1:setLooping(false)
 	_deejay.oooh2 = love.audio.newSource("assets/music/Oooh2.ogg", "static")
	_deejay.yeah = love.audio.newSource("assets/music/Yeah.ogg", "static")
	_deejay.yeah:setLooping(false)
	_deejay.ready = love.audio.newSource("assets/music/Ready.ogg", "static")
	_deejay.go = love.audio.newSource("assets/music/Go.ogg", "static")
	_deejay.yo = love.audio.newSource("assets/music/Yo.ogg", "static")
	for i=1,Settings.WordCount do
		table.insert(_deejay.voices[Note.Left], love.audio.newSource("assets/music/word" .. i .. ".ogg"))
		table.insert(_deejay.voices[Note.Right], love.audio.newSource("assets/music/word" .. Settings.WordCount + i .. ".ogg"))
	end

	_playerLeft = LoveAnimation.new("assets/animations/rapper1.lua")
	_playerRight = LoveAnimation.new("assets/animations/rapper1.lua","assets/sprites/rapper2_spritesheet.png")


	_playerRight:setRelativeOrigin(0.5,0.5)
	_playerLeft:setRelativeOrigin(0.5,0.5)
	_playerLeft:flipHorizontal()

	_playerRight:setPosition(7*Settings.ScreenWidth/8, Settings.ScreenHeight/2)
	_playerRight:setCurrentFrame(1)
	_playerLeft:setPosition(Settings.ScreenWidth/8, Settings.ScreenHeight/2)

	NoteGenerator.ToggleDirection()
end

function Stage.Update(dt)
	-- Vicotry
	if _scoreLeft >= 100 or _scoreRight >= 100 then
		if _scoreLeft >= 100 then
			if _inRound then
				_deejay.yeah:play()
				_playerLeft:setState("victory")
				_playerRight:setState("defeat")
				_inRound = false
			end
			_announcementVictoryLeft:Update(dt)
		else
			if _inRound then
				_deejay.yeah:play()
				_playerLeft:setState("defeat")
				_playerRight:setState("victory")
				_inRound = false
			end
			_announcementVictoryRight:Update(dt)
		end
		_deejay.background:stop()
		Crowds.SetSpeedMultiplier(2)
	end

	NoteGenerator.Update(dt)

	_playerLeft:update(dt)
	_playerRight:update(dt)
	Crowds.Update(dt)

	if _scoreLeft >= 100 or _scoreRight >= 100 then
		return
	end

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

	if _inRound and _deejay.cheers:getVolume() > 0.2 then
		_deejay.cheers:setVolume(_deejay.cheers:getVolume() - 0.005)
	end

	if #_notes == 0 and NoteGenerator.RemainingNotes() == 0 then
		_interludeTimeout = _interludeTimeout - dt
		_deejay.background:stop()
		if _inRound then
			_deejay.cheers:setVolume(1)
			_deejay.cheers:stop()
			_deejay.cheers:play()
		end
		if _inRound then
			_deejay.scratch:play()
		end

		Crowds.SetSpeedMultiplier(2)

		-- Announcement
		if _interludeTimeout <= 0.3 then
			_announcementGo:Update(dt)
			_deejay.go:play()
		elseif _interludeTimeout <= 2.5 then
			_announcementReady:Update(dt)
			if _inRound then _deejay.ready:play() end
		end

		_inRound = false

		-- we wait for the interlude to finish
		if _interludeTimeout <= 0 then

			if _roundCount % 2 == 1 then
				NoteGenerator.SetTimeInterval(NoteGenerator.GetTimeInterval() + 1)
				NoteGenerator.SetNotesPerInterval(NoteGenerator.GetNotesPerInterval() + 4)
			end
			-- we start the next round
			NoteGenerator.Generate(_roundCount == 0 and _notesPerRound/2 or _notesPerRound)
			_roundCount = _roundCount + 1
			NoteGenerator.ToggleDirection()
			_deejay.background:play()
			_interludeTimeout = 3

			_announcementGo:Reset()
			_announcementReady:Reset()
		end
	else
		Crowds.SetSpeedMultiplier(1)
		_inRound = true
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
	Crowds.Draw()

	-- Announcement
	if #_notes == 0 and NoteGenerator.RemainingNotes() == 0 then
		if _interludeTimeout <= 0.5 then
			_announcementGo:Draw()
		elseif _interludeTimeout <= 2.5 then
			_announcementReady:Draw()
		end
	end

	-- Victory
	if _scoreLeft >= 100 then
		_announcementVictoryLeft:Draw(dt)
	elseif _scoreRight >= 100 then
		_announcementVictoryRight:Draw(dt)
	end
end
