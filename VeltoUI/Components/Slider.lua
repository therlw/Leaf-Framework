local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.Themes.Default)

local Slider = {}

function Slider.Add(self, name, minValue, maxValue, defaultValue, callback)
    local value = defaultValue or minValue
    local sliding = false
    
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 60)
    SliderFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 40)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = self.Content
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Text = name .. ": " .. value
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, 0, 0, 5)
    SliderTrack.Position = UDim2.new(0, 0, 0, 30)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SliderTrack.Parent = SliderFrame
    
    CreateCorner(SliderTrack, 3)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    SliderFill.BackgroundColor3 = Theme.Accent
    SliderFill.Parent = SliderTrack
    
    CreateCorner(SliderFill, 3)
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 15, 0, 15)
    SliderButton.Position = UDim2.new(0, -7.5, 0.5, -7.5)
    SliderButton.Text = ""
    SliderButton.BackgroundColor3 = Theme.Text
    SliderButton.Parent = SliderTrack
    
    CreateCorner(SliderButton, 7)
    CreateStroke(SliderButton, 1, Theme.Accent)
    
    -- Initialize slider position
    local function UpdateSlider(pos)
        local relativeX = math.clamp(pos.X - SliderTrack.AbsolutePosition.X, 0, SliderTrack.AbsoluteSize.X)
        local percentage = relativeX / SliderTrack.AbsoluteSize.X
        value = math.floor(minValue + (maxValue - minValue) * percentage)
        
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderButton.Position = UDim2.new(percentage, -7.5, 0.5, -7.5)
        Label.Text = name .. ": " .. value
        
        if callback then
            pcall(callback, value)
        end
    end
    
    -- Set initial value
    if defaultValue then
        local percentage = (defaultValue - minValue) / (maxValue - minValue)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderButton.Position = UDim2.new(percentage, -7.5, 0.5, -7.5)
    end
    
    -- Mouse interactions
    SliderButton.MouseButton1Down:Connect(function()
        sliding = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input.Position)
        end
    end)
    
    SliderTrack.MouseButton1Down:Connect(function(x, y)
        UpdateSlider(Vector2.new(x, y))
    end)
    
    table.insert(self.Elements, SliderFrame)
    return SliderFrame
end

return Slider