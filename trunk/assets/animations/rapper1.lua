return {
	imageSrc = "assets/sprites/rapper1_spritesheet.png",
	defaultState = "idle",
	states = {
		idle = {
			frameCount = 3,
			offsetY = 0,
			frameW = 512,
			frameH = 512,
			nextState = "idle",
			switchDelay = 0.15
		},
		dammage = {
			frameCount = 3,
			offsetY = 512,
			frameW = 512,
			frameH = 512,
			nextState = "idle",
			switchDelay = 0.2
		},
		attack = {
			frameCount = 3,
			offsetY = 1024,
			frameW = 512,
			frameH = 512,
			nextState = "idle",
			switchDelay = 0.2
		}
	}
}
