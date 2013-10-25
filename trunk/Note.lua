Note = {}
Note.__index = Note

Note.A = 1
Note.B = 2
Note.X = 3
Note.Y = 4

function Note.New(value)
	local new

	x = x or 0
	y = y or 0
	new = {x = x, y = y}

	setmetatable(new, Note)
	return new
end
