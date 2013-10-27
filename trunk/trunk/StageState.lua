StageState = {}
StageState.__index = StageState

function StageState:Load(stage)
	self._stage = stage
end

function StageState.Enter() end
function StageState.Leave() end
function StageState.Update(dt) end
function StageState.Draw() end
