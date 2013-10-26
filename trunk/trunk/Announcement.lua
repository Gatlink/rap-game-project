Announcement = {}
Announcement.__index = Announcement

Announcement.Grow = 0
Announcement.Shrink = 1
Announcement.Shiver = 2

function Announcement.New(imagePath, x, y)
	local new = {}

	new.sprite = love.graphics.newImage(imagePath)
	new.x = x or 0
	new.y = y or 0
	new.angle = 0
	new.scale = 0.1
	new.state = Announcement.Growth

	setmetatable(new, Announcement)
	return new
end

function Announcement:Update(dt)
	if self.state == Announcement.Growth then
		if self.scale >= 1.1 then
			self.state = Announcement.Shrink
		else
			self.scale = self.scale + 2 * dt
		end
	elseif self.state == Announcement.Shrink then
		if self.scale <= 1.0 then
			self.state = Announcement.Shiver
		else
			self.scale = self.scale - 2 * dt
		end
	else
		-- self.angle = (self.angle+math.pi/16*dt) % (math.pi/2) - math.pi/4
	end
end

function Announcement:Draw()
	love.graphics.draw(self.sprite,self.x,self.y,self.angle,self.scale,self.scale,0.5*self.sprite:getWidth(),0.5*self.sprite:getHeight())
end
