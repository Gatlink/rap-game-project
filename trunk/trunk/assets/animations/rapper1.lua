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
		},
		victory = {
			frameCount = 3,
			offsetY = 1536,
			frameW = 512,
			frameH = 512,
			nextState = "victory",
			switchDelay = 0.2
		},
		defeat = {
			frameCount = 3,
			offsetY = 2048,
			frameW = 512,
			frameH = 512,
			nextState = "defeat",
			switchDelay = 0.2
		}
	}
}
