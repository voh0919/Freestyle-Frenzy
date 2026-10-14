--[[
	BallView
	========
	Four dots in a row (one per beat) and a ball that hops from dot to dot,
	touching down exactly on each beat. The 4th dot is gold because that
	is where the rhyme word lands.

	It doesn't keep time itself: every frame the game calls
	BallView:Update(beat, fraction) with values from BeatClock.
]]

local UIKit = require(script.Parent.UIKit)

local BallView = {}
BallView.__index = BallView

local DOT_COUNT = 4
local DOT_Y = 0.85 -- vertical position of the dots (0 = top, 1 = bottom)
local DOT_SIZE = 0.07 -- dot width as a fraction of the row width
local BALL_SIZE = 0.06
local GROUND_Y = 0.6 -- ball's center height when touching a dot
local HOP_HEIGHT = 0.5 -- how high the ball hops between beats
local RETURN_HOP_HEIGHT = 0.6 -- slightly bigger hop from beat 4 back to beat 1
local PULSE_AMOUNT = 0.5 -- how much a dot grows when the ball lands on it

export type BallView = typeof(setmetatable(
	{} :: {
		Frame: Frame,
		Ball: Frame,
		Dots: { Frame },
	},
	BallView
))

-- X position (0-1) of each dot inside the row.
local function dotX(index: number): number
	return (index - 0.5) / DOT_COUNT
end

function BallView.new(parent: Instance): BallView
	-- The row is always 4x wider than it is tall, on any screen.
	local frame = UIKit.Create("Frame", {
		Name = "BallRow",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.78),
		Size = UDim2.fromScale(0.7, 0.25),
		Parent = parent,
	}, {
		UIKit.AspectRatio(4),
		UIKit.Create("UISizeConstraint", { MaxSize = Vector2.new(640, 160) }),
	})

	local dots = {}
	for i = 1, DOT_COUNT do
		dots[i] = UIKit.Create("Frame", {
			Name = "Dot" .. i,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(dotX(i), DOT_Y),
			Size = UDim2.fromScale(DOT_SIZE, DOT_SIZE * 4), -- *4 because the row is 4:1
			BackgroundColor3 = if i == DOT_COUNT then UIKit.Colors.Accent else UIKit.Colors.Dot,
			BorderSizePixel = 0,
			Parent = frame,
		}, { UIKit.Corner(0.5) })
	end

	local ball = UIKit.Create("Frame", {
		Name = "Ball",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(dotX(1), GROUND_Y),
		Size = UDim2.fromScale(BALL_SIZE, BALL_SIZE * 4),
		BackgroundColor3 = UIKit.Colors.Ball,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = frame,
	}, { UIKit.Corner(0.5) })

	return setmetatable({
		Frame = frame,
		Ball = ball,
		Dots = dots,
	}, BallView)
end

--[[
	beat:     the beat we just landed on (1-4)
	fraction: 0 to 1, progress toward the next beat

	The ball travels from dot[beat] to the next dot in an arc
	(sin curve), so it touches down exactly when fraction wraps to 0.
]]
function BallView.Update(self: BallView, beat: number, fraction: number)
	local nextBeat = (beat % DOT_COUNT) + 1
	local fromX = dotX(beat)
	local toX = dotX(nextBeat)

	local x = fromX + (toX - fromX) * fraction
	local hop = if beat == DOT_COUNT then RETURN_HOP_HEIGHT else HOP_HEIGHT
	local y = GROUND_Y - math.sin(math.pi * fraction) * hop

	self.Ball.Position = UDim2.fromScale(x, y)

	-- The dot that was just hit swells up and shrinks back during the beat.
	for i, dot in self.Dots do
		local scale = 1
		if i == beat then
			scale = 1 + PULSE_AMOUNT * (1 - fraction) ^ 2
		end
		dot.Size = UDim2.fromScale(DOT_SIZE * scale, DOT_SIZE * 4 * scale)
	end
end

function BallView.SetVisible(self: BallView, visible: boolean)
	self.Frame.Visible = visible
end

return BallView
