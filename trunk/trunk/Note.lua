require 'Settings'
require 'GamePad'

Note = {}
Note.__index = Note

local _sprites = {}
local _speed = 100

Note.Left  = -1
Note.Right =  1

Note.Passive = 0
Note.Active  = 1
Note.Hit     = 2
Note.Miss    = 3

function Note.New(value, x, y, dir, state)
	local new = {}

	new.value = value or GamePad.A
	new.x = x or 0
	new.y = y or 0
	new.direction = dir or Note.Right
	new.state = state or Note.Passive

	setmetatable(new, Note)
	return new
end

function Note.Load()
	_sprites[GamePad.A] = love.graphics.newImage('assets/sprites/A.png')
	_sprites[GamePad.B] = love.graphics.newImage('assets/sprites/B.png')
	_sprites[GamePad.X] = love.graphics.newImage('assets/sprites/X.png')
	_sprites[GamePad.Y] = love.graphics.newImage('assets/sprites/Y.png')
end

function Note:Draw()
	love.graphics.setScissor(self.x - Settings.NoteSize / 2 , self.y - Settings.NoteSize / 2, Settings.NoteSize, Settings.NoteSize)
	love.graphics.push()
	love.graphics.translate(-Settings.NoteSize / 2, -Settings.NoteSize / 2)
	love.graphics.draw(_sprites[self.value], self.x, self.y, 0, 1, 1, 0, self.state * Settings.NoteSize)
	love.graphics.pop()
	love.graphics.setScissor()
end

function Note:Update(dt)
	if self.x <= Settings.ScreenWidth and self.x >= -Settings.NoteSize then
		self.x = self.x + dt * self.direction * _speed
	end
end
