--[[
	Beats
	=====
	The list of instrumentals the player can pick from on the start menu.

	Each entry has:
	  Name            - Text shown on the menu button.
	  AssetId         - The Roblox audio asset ID (just the number).
	  BPM             - Beats per minute of the instrumental.
	  FirstBeatOffset - Seconds from the very start of the audio file to
	                    beat 1 of the first bar you want to rap over.
	                    If the ball feels EARLY, make this number bigger.
	                    If the ball feels LATE, make this number smaller.
	  Volume          - 0 to 1 (optional, defaults to 0.8).

	All three tracks below are APM Music tracks that Roblox licensed and
	made free to use in Roblox experiences. The BPM values come from each
	track's Creator Store description. The FirstBeatOffset values are a
	starting guess; tune them by ear in a playtest.

	To add a beat: copy one entry, paste it at the end, change the values.
]]

export type Beat = {
	Name: string,
	AssetId: number,
	BPM: number,
	FirstBeatOffset: number,
	Volume: number?,
}

local Beats: { Beat } = {
	{
		-- "Beach Cushions" (APM, album: Lofi Hip Hop) - listed at 90 bpm
		Name = "Beach Cushions",
		AssetId = 9047104411,
		BPM = 90,
		FirstBeatOffset = 0,
		Volume = 0.8,
	},
	{
		-- "Dusk To Dawn" (APM, album: Lofi Hip Hop) - listed at 80 bpm
		Name = "Dusk To Dawn",
		AssetId = 9047105308,
		BPM = 80,
		FirstBeatOffset = 0,
		Volume = 0.8,
	},
	{
		-- "Lo-fi Chill A" (APM, Hip Hop Shop library) - listed at 100 bpm.
		-- A little faster than the 80-95 target; swap it out if you find
		-- a better one in the Creator Store.
		Name = "Lo-fi Chill",
		AssetId = 9043887091,
		BPM = 100,
		FirstBeatOffset = 0,
		Volume = 0.8,
	},
}

return Beats
