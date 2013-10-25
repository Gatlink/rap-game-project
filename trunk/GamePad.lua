GamePad = {
	isKeyboard = false,
}
GamePad.__index = GamePad

GamePad.A = 1
GamePad.B = 2
GamePad.X = 3
GamePad.Y = 4

local __keyboardUsed = false
local __events = {}

local inTable = function(table, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end

function GamePad:OnPress(pad, button)
	table.insert(__events, button)
end

function GamePad:GetNextPress()
	if #__events == 0 then
		return -1
	end
	return table.remove(__events, 1)
end