--[[
	BeatPlayer
	==========
	Creates the Sound for a beat and waits for it to load.

	The Sound is created by a LocalScript and parented to SoundService,
	so only this player hears it. Every player gets their own beat.
]]

local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")

local Beats = require(script.Parent.Parent:WaitForChild("Beats"))

local BeatPlayer = {}

-- Makes a Sound for the beat and waits until the audio is ready.
-- Returns the Sound, or nil plus an error message if it can't load
-- (wrong ID, audio is private, no permission, etc).
function BeatPlayer.Load(beat: Beats.Beat): (Sound?, string?)
	local sound = Instance.new("Sound")
	sound.Name = "FreestyleBeat"
	sound.SoundId = "rbxassetid://" .. tostring(beat.AssetId)
	sound.Volume = beat.Volume or 0.8
	-- Loop so short instrumentals still last a full 32-bar session.
	sound.Looped = true
	sound.Parent = SoundService

	-- PreloadAsync waits until the audio is downloaded (or fails).
	local ok, err = pcall(function()
		ContentProvider:PreloadAsync({ sound })
	end)

	if not ok or not sound.IsLoaded or sound.TimeLength <= 0 then
		sound:Destroy()
		local reason = if ok then "audio did not load" else tostring(err)
		return nil, `Couldn't load beat "{beat.Name}" (ID {beat.AssetId}): {reason}`
	end

	return sound, nil
end

return BeatPlayer
