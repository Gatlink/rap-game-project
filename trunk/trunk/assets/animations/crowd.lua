return {
	imageSrc = "assets/sprites/public_00_spritesheet.png",
	defaultState = "bouncing",
	states = {
		bouncing = {
			frameCount = 3,
			offsetY = 0,
			frameW = 700,
			frameH = 395,
			nextState = "bouncing",
			switchDelay = 0.15
		}
	}
}
