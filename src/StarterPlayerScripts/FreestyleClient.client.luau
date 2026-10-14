--[[
	FreestyleClient
	===============
	The main script for Freestyle Frenzy. Runs on each player's own
	device, so every player gets their own beat and their own screen.

	STEP (a) - TEST BUILD: the beat starts right away and the ball
	bounces on every beat. Press 1, 2 or 3 to switch beats.
	(The start menu replaces this in a later step.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Beats = require(ReplicatedStorage:WaitForChild("Beats"))
local Modules = ReplicatedStorage:WaitForChild("FreestyleModules")
local BeatClock = require(Modules:WaitForChild("BeatClock"))
local BeatPlayer = require(Modules:WaitForChild("BeatPlayer"))
local BallView = require(Modules:WaitForChild("BallView"))
local UIKit = require(Modules:WaitForChild("UIKit"))

local player = Players.LocalPlayer

------------------------------------------------------------------------
-- UI setup
------------------------------------------------------------------------

local screenGui = UIKit.CreateScreenGui(player:WaitForChild("PlayerGui") :: PlayerGui)

-- Full-screen dark background for the play screen.
local playScreen = UIKit.Create("Frame", {
	Name = "PlayScreen",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = UIKit.Colors.Background,
	BorderSizePixel = 0,
	Parent = screenGui,
})

-- Top line: beat name, bar and beat counter.
local infoLabel = UIKit.Label({
	Name = "Info",
	Position = UDim2.fromScale(0.5, 0.08),
	Size = UDim2.fromScale(0.9, 0.06),
	TextColor3 = UIKit.Colors.SubText,
	Text = "Loading beat...",
	Parent = playScreen,
}, 28)

local ballView = BallView.new(playScreen)

------------------------------------------------------------------------
-- Beat playback
------------------------------------------------------------------------

local currentSound: Sound? = nil
local currentClock: BeatClock.BeatClock? = nil
local currentBeat: Beats.Beat? = nil
local loadingToken = 0 -- ignores old loads if the player switches beats quickly

local function stopBeat()
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
	end
	currentSound = nil
	currentClock = nil
	currentBeat = nil
end

local function startBeat(index: number)
	local beat = Beats[index]
	if not beat then
		return
	end

	stopBeat()
	loadingToken += 1
	local myToken = loadingToken
	infoLabel.Text = `Loading "{beat.Name}"...`

	local sound, err = BeatPlayer.Load(beat)
	if myToken ~= loadingToken then
		-- Player picked another beat while this one was loading.
		if sound then
			sound:Destroy()
		end
		return
	end
	if not sound then
		warn(err)
		infoLabel.Text = err or "Couldn't load beat"
		return
	end

	currentSound = sound
	currentBeat = beat
	currentClock = BeatClock.new(sound, beat.BPM, beat.FirstBeatOffset)
	sound:Play()
end

------------------------------------------------------------------------
-- Every frame: read the music's position and move the ball
------------------------------------------------------------------------

RunService.RenderStepped:Connect(function(deltaTime)
	local clock = currentClock
	local beat = currentBeat
	if not clock or not beat then
		return
	end

	clock:Update(deltaTime)
	local info = clock:GetBeatInfo()
	ballView:Update(info.Beat, info.Fraction)

	infoLabel.Text = string.format(
		"%s  |  %d BPM  |  Bar %d  Beat %d  |  %.2fs   (press 1/2/3 to switch)",
		beat.Name,
		beat.BPM,
		info.Bar,
		info.Beat,
		clock:GetSongTime()
	)
end)

------------------------------------------------------------------------
-- Test controls (temporary, for step a)
------------------------------------------------------------------------

local NUMBER_KEYS = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	local index = NUMBER_KEYS[input.KeyCode]
	if index then
		task.spawn(startBeat, index)
	end
end)

startBeat(1)
