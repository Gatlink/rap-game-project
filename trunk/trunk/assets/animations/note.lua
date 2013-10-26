-- state 1 = Passive
-- state 2 = Active
-- state 3 = Hit
-- state 4 = Miss

return {
	imageSrc = "assets/sprites/A.png",
	defaultState = "1",
	states = {
		["1"] = {
			frameCount = 1,
			offsetY = 0,
			frameW = 32,
			frameH = 32,
			nextState = "1",
			switchDelay = 0.1
		},
		["2"] = {
			frameCount = 1,
			offsetY = 32,
			frameW = 32,
			frameH = 32,
			nextState = "2",
			switchDelay = 0.1
		},
		["3"] = {
			frameCount = 1,
			offsetY = 64,
			frameW = 32,
			frameH = 32,
			nextState = "3",
			switchDelay = 0.1
		},
		["4"] = {
			frameCount = 1,
			offsetY = 96,
			frameW = 32,
			frameH = 32,
			nextState = "4",
			switchDelay = 0.1
		}
	}
}
