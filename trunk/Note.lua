require 'Settings'
require 'loveanimation'
require 'GamePad'

Note = {}
Note.__index = Note

local _sprites = {}

Note.Left  = -1
Note.Right =  1

Note.Passive = 1
Note.Active  = 2
Note.Hit     = 3
Note.Miss    = 4

Note.Alive = true

function Note.New(value, x, y, dir, state)
	local new = {}

	new.value = value or GamePad.A
	new.x = x or 0
	new.y = y or 0
	new.direction = dir or Note.Right
	new.state = state or Note.Passive
	new.sprite = _sprites[new.value]:clone()
	new.sprite:setRelativeOrigin(0.5, 0.5)

	setmetatable(new, Note)
	return new
end

function Note.Load()
	_sprites[GamePad.A] = LoveAnimation.new('assets/animations/note.lua')
	_sprites[GamePad.B] = LoveAnimation.new('assets/animations/note.lua','assets/sprites/B.png')
	_sprites[GamePad.X] = LoveAnimation.new('assets/animations/note.lua','assets/sprites/X.png')
	_sprites[GamePad.Y] = LoveAnimation.new('assets/animations/note.lua','assets/sprites/Y.png')
end

function Note:setState(state)
	self.state = state
	self.sprite:setState(tostring(state))
end

function Note:Draw()
	self.sprite:draw()
end

function Note:Update(dt)

	self.x = self.x + dt * self.direction * Settings.NoteSpeed

	self.sprite:update(dt)
	self.sprite:setPosition(self.x, self.y)
end

function Note:SetAlive(a)
	self.Alive = a
end

function Note:IsAlive()
	return self.Alive
end
