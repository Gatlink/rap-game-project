Deejay = {}

local _defaultExt = "ogg"
local _playin = {}
local _soundsToLoad = {
	background = { filename="beat",suffix = math.random(1,Settings.BeatFilesAvailable),loop= true },
	cheers = {loop=true},
	scratch = {},
	oooh1 = { filename="Oooh1" },
	oooh2 = { filename="Oooh2" },
	oooh3 = { filename="Oooh3" },
	ready = {filename="Ready"},
	go = {filename="Go"},
	yo = {filename="Yo", ext="ogg"}
}

function Deejay.play(name)
	Deejay[name]:play()
	table.insert(_playin, name)
end

function Deejay.stop(name)
	Deejay[name]:stop()
	for i, sound in ipairs(_playin) do
		if sound == name then
			table.remove(_playin, i)
			break
		end
	end
end

function Deejay.replay(name)
	Deejay[name]:stop()
	Deejay[name]:play()
end

function Deejay.pauseAll()
	for _, sound in ipairs(_playin) do
		Deejay[sound]:pause()
	end
end

function Deejay.resumeAll()
	for _, sound in ipairs(_playin) do
		Deejay[sound]:play()
	end
end

function Deejay.Load(dir)
	dir = dir or Settings.DefaultMusicDirectory
	for name, descriptor in pairs(_soundsToLoad) do

		local ext = descriptor.ext or _defaultExt
		local filename = descriptor.filename or name
		local suffix =  descriptor.suffix or ""

		Deejay[name] = love.audio.newSource(dir .. "/" .. filename .. suffix .. "." .. ext, "static")
		Deejay[name]:setLooping(descriptor.loop)

	end
end

function Deejay.Update(dt)
	local stillPlayin = {}
	for _, sound in ipairs(_playin) do
		if not Deejay[sound]:isStopped() then
			table.insert(stillPlayin, sound)
		end
	end
	_playin = stillPlayin
end
