require 'loveanimation'

Crowds = {}

function Crowds.Load()
	-- Left
	Crowds[1] = LoveAnimation.new("assets/animations/crowd.lua")
	Crowds[1]:setPosition(-50, 350)

	-- Right
	Crowds[2] = LoveAnimation.new("assets/animations/crowd.lua","assets/sprites/public_01_spritesheet.png")
	Crowds[2]:setPosition(Settings.ScreenWidth - Crowds[2]:getFrameWidth() + 50, 360)
	Crowds[2]:setCurrentFrame(1)

	-- Center
	Crowds[3] = LoveAnimation.new("assets/animations/crowd.lua","assets/sprites/public_02_spritesheet.png")
	Crowds[3]:setPosition(Settings.ScreenWidth / 2 - Crowds[3]:getFrameWidth() / 2, 380)
	Crowds[3]:setCurrentFrame(2)

	-- Front Left
	Crowds[4] = Crowds[2]:clone()
	Crowds[4]:setPosition(Crowds[3].x - Crowds[4]:getFrameWidth(), 390)
	Crowds[4]:setCurrentFrame(1)

	-- Front Right
	Crowds[5] = Crowds[1]:clone()
	Crowds[5]:setPosition(Crowds[3].x + Crowds[3]:getFrameWidth(), 385)
end

function Crowds.Update(dt)
	for _, crowd in ipairs(Crowds) do
		crowd:update(dt)
	end
end

function Crowds.Draw()
	for _, crowd in ipairs(Crowds) do
		crowd:draw()
	end
end

function Crowds.SetSpeedMultiplier(mult)
	for _, crowd in ipairs(Crowds) do
		crowd:setSpeedMultiplier(mult)
	end
end
