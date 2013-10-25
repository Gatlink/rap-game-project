require 'GamePad'

Note = {}
Note.__index = Note

local _sprites = {}
local _size = 32
local _speed = 100

Note.Left  = -1
Note.Right =  1

Note.Passive = 0
Note.Active  = 1
Note.Hit     = 2
Note.Fail    = 3

function Note.New(value, x, y, dir, state)
	local new = {}

	new.value = value or GamePad.A
	new.x = x or 0
	new.y = y or 0
	new.dir = dir or Note.Right
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
	love.graphics.setScissor(self.x, self.y, _size, _size)
	love.graphics.draw(_sprites[self.value], self.x, self.y, 0, 1, 1, 0, self.state * _size)
	love.graphics.setScissor()
end

function Note:Update(dt)
	if self.x <= Settings.ScreenWidth and self.x >= -_size then
		self.x = self.x + dt * self.dir * _speed
	end
end
