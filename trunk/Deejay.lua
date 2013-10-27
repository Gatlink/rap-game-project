Deejay = {}

local _defaultExt = "ogg"
local _soundsToLoad = {

	background = { filename = "beat",
		suffix = math.random(1,Settings.BeatFilesAvailable), loop= true},
	cheers = {loop=true},
	scratch = {},
	oooh1 = { filename="Oooh1" },
	oooh2 = { filename="Oooh2" },
	oooh3 = { filename="Oooh3" },
	ready = {filename="Ready"},
	go = {filename="Go"},
	yo = {filename="Yo", ext="ogg"}
}



-- Background
-- Deejay.background = love.audio.newSource("assets/music/beat" ..
-- 		math.random(1,Settings.BeatFilesAvailable) .. ".ogg", "static")
-- -- Deejay.background:setLooping(true)
-- -- Cheers
-- Deejay.cheers = love.audio.newSource("assets/music/cheers.ogg", "static")
-- -- Deejay.cheers:setLooping(true)

-- -- Scratch
-- Deejay.scratch = love.audio.newSource("assets/music/scratch.ogg", "static")


-- Deejay.oooh1 = love.audio.newSource("assets/music/Oooh1.ogg", "static")
-- Deejay.oooh2 = love.audio.newSource("assets/music/Oooh2.ogg", "static")
-- Deejay.yeah = love.audio.newSource("assets/music/Yeah.ogg", "static")
-- Deejay.ready = love.audio.newSource("assets/music/Ready.ogg", "static")
-- Deejay.go = love.audio.newSource("assets/music/Go.ogg", "static")
-- Deejay.yo = love.audio.newSource("assets/music/Yo.ogg", "static")


function Deejay.play(name)
	Deejay[name]:play()
end

function Deejay.stop(name)
	Deejay[name]:stop()
end

function Deejay.replay(name)
	Deejay[name]:stop()
	Deejay[name]:play()
end

function Deejay.random(name)

end


function Deejay.Load(dir)
	dir = dir or Settings.DefaultMusicDirectory
	for name, descriptor in pairs(_soundsToLoad) do

		local ext = descriptor.ext or _defaultExt
		local filename = descriptor.filename or name
		local suffix =  descriptor.suffix or ""

		print("loading sound " .. dir .. "/" .. filename .. suffix .. "." .. ext)
		Deejay[name] = love.audio.newSource(
			dir .. "/" .. filename .. suffix .. "." .. ext, "static")

		Deejay[name]:setLooping(descriptor.loop or false)

	end

	-- local files = love.filesystem.enumerate(dir)
	-- for k, file in ipairs(files) dof
 --    	if love.filesystem.isFile(dir .. "/" .. file ) then
 --    		if string.match(file, "[^/]*.ogg") then
	-- 			local name = string.sub(file, 0 , #file - #(".ogg"))
	-- 			-- LOAD FILE HERE
	-- 		end
 --    	end
	-- end



end

function Deejay.update(dt)
	-- body
end
