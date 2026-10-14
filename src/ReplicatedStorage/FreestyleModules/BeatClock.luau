--[[
	BeatClock
	=========
	Turns a playing Sound into "where are we in the music?" answers:
	which bar, which beat (1-4), and how far we are between beats.

	All timing comes from Sound.TimePosition (the audio's real playhead),
	never from wait() or task.wait(). If the game lags for a moment, the
	next frame reads the playhead again and everything snaps back on beat.

	Usage:
		local clock = BeatClock.new(sound, 90, 0.25)
		-- every frame:
		clock:Update(deltaTime)
		local info = clock:GetBeatInfo()
		print(info.Bar, info.Beat, info.Fraction)
]]

local BeatClock = {}
BeatClock.__index = BeatClock

-- Sound.TimePosition can update a little unevenly from frame to frame,
-- which would make the ball stutter. We keep our own smooth copy of the
-- time and gently pull it toward TimePosition every frame.
-- If they ever differ by more than MAX_DRIFT seconds (a lag spike, a
-- loop, a seek), we jump straight to the real TimePosition.
local MAX_DRIFT = 0.08
local CORRECTION = 0.15

export type BeatInfo = {
	BeatPosition: number, -- total beats since bar 1 beat 1 (negative before it)
	Bar: number, -- 1-based bar number (0 or less during the intro)
	Beat: number, -- 1, 2, 3 or 4 inside the bar
	Fraction: number, -- 0 to 1, how far we are toward the next beat
}

export type BeatClock = typeof(setmetatable(
	{} :: {
		Sound: Sound,
		SecondsPerBeat: number,
		FirstBeatOffset: number,
		_loops: number,
		_lastTimePosition: number,
		_smoothTime: number,
	},
	BeatClock
))

function BeatClock.new(sound: Sound, bpm: number, firstBeatOffset: number): BeatClock
	local self = setmetatable({
		Sound = sound,
		SecondsPerBeat = 60 / bpm,
		FirstBeatOffset = firstBeatOffset,
		_loops = 0, -- how many times a looping Sound has wrapped around
		_lastTimePosition = sound.TimePosition,
		_smoothTime = sound.TimePosition,
	}, BeatClock)
	return self
end

-- Call once per frame (from RenderStepped) with the frame's delta time.
function BeatClock.Update(self: BeatClock, deltaTime: number)
	local sound = self.Sound
	local timePosition = sound.TimePosition
	local length = sound.TimeLength

	-- If the Sound is Looped, TimePosition jumps back to 0 at the end.
	-- Count those wraps so our song time keeps going up.
	if length > 0 and timePosition + length * 0.5 < self._lastTimePosition then
		self._loops += 1
	end
	self._lastTimePosition = timePosition

	local realTime = self._loops * length + timePosition

	if sound.IsPlaying then
		-- Predict where the playhead should be now, then nudge toward
		-- the real value so we stay locked to the audio.
		local predicted = self._smoothTime + deltaTime * sound.PlaybackSpeed
		local drift = realTime - predicted
		if math.abs(drift) > MAX_DRIFT then
			self._smoothTime = realTime
		else
			self._smoothTime = predicted + drift * CORRECTION
		end
	else
		self._smoothTime = realTime
	end
end

-- Seconds since the audio started (keeps counting across loops).
function BeatClock.GetSongTime(self: BeatClock): number
	return self._smoothTime
end

-- Works out bar / beat / fraction from the current song time.
function BeatClock.GetBeatInfo(self: BeatClock): BeatInfo
	local beatPosition = (self._smoothTime - self.FirstBeatOffset) / self.SecondsPerBeat
	local wholeBeats = math.floor(beatPosition)

	return {
		BeatPosition = beatPosition,
		Bar = math.floor(wholeBeats / 4) + 1,
		Beat = (wholeBeats % 4) + 1,
		Fraction = beatPosition - wholeBeats,
	}
end

return BeatClock
