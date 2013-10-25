Note = {}
Note.__index = Note

local _sprites = {}
local _size = 32
local _speed = 100

Note.A = 1
Note.B = 2
Note.X = 3
Note.Y = 4

Note.Left  = -1
Note.Right =  1

Note.Passive = 0
Note.Active  = 1
Note.Hit     = 2
Note.Fail    = 3

function Note.New(value, x, y, dir, state)
	local new = {}

	new.value = value or Note.A
	new.x = x or 0
	new.y = y or 0
	new.dir = dir or Note.Right
	new.state = state or Note.Passive

	setmetatable(new, Note)
	return new
end

function Note.Load()
	_sprites[Note.A] = love.graphics.newImage('assets/sprites/A.png')
	_sprites[Note.B] = love.graphics.newImage('assets/sprites/B.png')
	_sprites[Note.X] = love.graphics.newImage('assets/sprites/X.png')
	_sprites[Note.Y] = love.graphics.newImage('assets/sprites/Y.png')
end

function Note:Draw()
	love.graphics.draw(_sprites[self.value], self.x, self.y, 0, 1, 1, 0, self.state * _size)
end

function Note:Update(dt)
	if self.x <= Settings.ScreenWidth and self.x >= 0 then
		self.x = self.x + dt * self.dir * _speed
	end
end
