GamePad = {
	isKeyboard = false,
}
GamePad.__index = GamePad

GamePad.A = 1
GamePad.B = 2
GamePad.X = 3
GamePad.Y = 4
GamePad.Start = 8

local __keyboardUsed = false
local __events = {}
local __callbacks = {}

function love.keypressed(key)
	if key == 'escape' then
		love.event.push('quit')
	elseif key == "1" then
		GamePad:OnPress(0, GamePad.A)
	elseif key == "2" then
		GamePad:OnPress(0, GamePad.B)
	elseif key == "3" then
		GamePad:OnPress(0, GamePad.X)
	elseif key == "4" then
		GamePad:OnPress(0, GamePad.Y)
	end
end

function love.joystickpressed(joystick, key)
	if key == 1 then
		GamePad:OnPress(0, GamePad.A)
	elseif key == 2 then
		GamePad:OnPress(0, GamePad.B)
	elseif key == 3 then
		GamePad:OnPress(0, GamePad.X)
	elseif key == 4 then
		GamePad:OnPress(0, GamePad.Y)
	elseif key == 8 then
		GamePad:OnPress(0, GamePad.Start)
	end
end

local inTable = function(tab, item)
    for key, value in pairs(tab) do
        if value == item then return key end
    end
    return false
end

function GamePad:OnPress(pad, button)
	if # __callbacks > 0 then
		for i,cb in ipairs(__callbacks) do
			cb(button)
		end
	end

	table.insert(__events, button)
end

function GamePad:GetNextPress()
	if #__events == 0 then
		return -1
	end
	return table.remove(__events, 1)
end


function GamePad:RegisterEvent(callback)
	table.insert(__callbacks, callback)
end

function GamePad:UnregisterEvent(callback)
	local key = inTable(__callbacks, callback)
	if key ~= nil then
		table.remove(__callbacks, key)
	end
end
