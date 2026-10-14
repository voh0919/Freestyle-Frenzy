--[[
	UIKit
	=====
	Small helpers for building UI in code, plus the shared colors and
	fonts. Every size uses Scale (a fraction of the screen) so the same
	layout works on phones and computers.
]]

local UIKit = {}

-- Shared look for all screens.
UIKit.Colors = {
	Background = Color3.fromRGB(20, 18, 32),
	Panel = Color3.fromRGB(38, 34, 60),
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(170, 165, 200),
	Accent = Color3.fromRGB(255, 196, 0), -- beat 4 / rhyme highlight
	Dot = Color3.fromRGB(90, 84, 130),
	Ball = Color3.fromRGB(255, 255, 255),
	Button = Color3.fromRGB(70, 62, 120),
	ButtonSelected = Color3.fromRGB(255, 196, 0),
}

UIKit.Font = Enum.Font.FredokaOne

--[[
	Create an Instance, set its properties, and parent children to it.

		UIKit.Create("TextLabel", { Text = "Hi" }, { UIKit.Corner(0.2) })

	"Parent" is applied last so the object is fully set up before it
	appears on screen.
]]
function UIKit.Create(className: string, properties: { [string]: any }?, children: { Instance }?): any
	local instance = Instance.new(className)
	local parent = nil

	if properties then
		for key, value in properties do
			if key == "Parent" then
				parent = value
			else
				(instance :: any)[key] = value
			end
		end
	end

	if children then
		for _, child in children do
			child.Parent = instance
		end
	end

	instance.Parent = parent
	return instance
end

-- Rounded corners. 0.5 makes a circle on a square frame.
function UIKit.Corner(scale: number): UICorner
	return UIKit.Create("UICorner", { CornerRadius = UDim.new(scale, 0) })
end

-- Keeps width:height locked so things stay the right shape on any screen.
function UIKit.AspectRatio(ratio: number): UIAspectRatioConstraint
	return UIKit.Create("UIAspectRatioConstraint", { AspectRatio = ratio })
end

-- Stops scaled text from getting too tiny or too huge.
function UIKit.TextSize(minSize: number, maxSize: number): UITextSizeConstraint
	return UIKit.Create("UITextSizeConstraint", { MinTextSize = minSize, MaxTextSize = maxSize })
end

-- A text label with scaled text, transparent background, centered.
function UIKit.Label(properties: { [string]: any }, maxTextSize: number?): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		Font = UIKit.Font,
		TextColor3 = UIKit.Colors.Text,
		TextScaled = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
	}
	for key, value in properties do
		defaults[key] = value
	end
	return UIKit.Create("TextLabel", defaults, { UIKit.TextSize(10, maxTextSize or 60) })
end

-- The ScreenGui that holds every screen of the game for this player.
function UIKit.CreateScreenGui(playerGui: PlayerGui): ScreenGui
	return UIKit.Create("ScreenGui", {
		Name = "FreestyleFrenzyGui",
		ResetOnSpawn = false, -- keep the UI if the character respawns
		IgnoreGuiInset = true, -- use the full screen, including the top bar
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = playerGui,
	})
end

return UIKit
