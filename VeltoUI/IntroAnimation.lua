local TweenService = game:GetService("TweenService")

local IntroAnimation = {}

-- Configuration
IntroAnimation.Config = {
    Duration = 1.5, -- Duration of the intro animation in seconds
    Text = "Made By RLW",
    TextColor = Color3.fromRGB(255, 255, 255),
    BackgroundColor = Color3.fromRGB(0, 0, 0),
    TextSize = 24,
    Font = Enum.Font.GothamBold
}

function IntroAnimation:Play(UI)
    -- Create intro screen
    local IntroFrame = Instance.new("Frame")
    IntroFrame.Size = UDim2.new(1, 0, 1, 0)
    IntroFrame.Position = UDim2.new(0, 0, 0, 0)
    IntroFrame.BackgroundColor3 = self.Config.BackgroundColor
    IntroFrame.ZIndex = 100
    IntroFrame.Parent = UI

    local IntroLabel = Instance.new("TextLabel")
    IntroLabel.Size = UDim2.new(0, 0, 0, 40)
    IntroLabel.Position = UDim2.new(0.5, 0, 0.5, -20)
    IntroLabel.Text = self.Config.Text
    IntroLabel.TextColor3 = self.Config.TextColor
    IntroLabel.Font = self.Config.Font
    IntroLabel.TextSize = self.Config.TextSize
    IntroLabel.BackgroundTransparency = 1
    IntroLabel.Parent = IntroFrame

    -- Animate intro in
    local introTweenIn = TweenService:Create(IntroLabel, TweenInfo.new(self.Config.Duration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 200, 0, 40),
        Position = UDim2.new(0.5, -100, 0.5, -20)
    })

    -- Animate intro out
    local introTweenOut = TweenService:Create(IntroFrame, TweenInfo.new(self.Config.Duration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    })

    introTweenIn:Play()
    introTweenIn.Completed:Connect(function()
        introTweenOut:Play()
        introTweenOut.Completed:Connect(function()
            IntroFrame:Destroy()
        end)
    end)
end

return IntroAnimation
