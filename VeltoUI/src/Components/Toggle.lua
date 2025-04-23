local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.Themes.Default)

local Toggle = {}

function Toggle.Add(self, name, defaultValue, callback)
    local state = defaultValue or false
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
    ToggleFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 40)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = self.Content
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
    ToggleLabel.Text = name
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 14
    ToggleLabel.TextColor3 = Theme.Text
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 50, 0, 25)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -12.5)
    ToggleButton.Text = ""
    ToggleButton.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(70, 70, 70)
    ToggleButton.Parent = ToggleFrame
    
    CreateCorner(ToggleButton, 12)
    CreateStroke(ToggleButton, 1, Theme.Secondary)
    
    local ToggleDot = Instance.new("Frame")
    ToggleDot.Size = UDim2.new(0, 21, 0, 21)
    ToggleDot.Position = UDim2.new(0, state and 27 or 2, 0.5, -10.5)
    ToggleDot.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    ToggleDot.Parent = ToggleButton
    
    CreateCorner(ToggleDot, 12)
    
    -- Click handler
    ToggleButton.MouseButton1Click:Connect(function()
        state = not state
        
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Theme.Success or Color3.fromRGB(70, 70, 70)
        }):Play()
        
        TweenService:Create(ToggleDot, TweenInfo.new(0.2), {
            Position = UDim2.new(0, state and 27 or 2, 0.5, -10.5)
        }):Play()
        
        if callback then
            pcall(callback, state)
        end
    end)
    
    -- Hover effect
    ToggleButton.MouseEnter:Connect(function()
        TweenService:Create(ToggleDot, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 23, 0, 23),
            Position = UDim2.new(0, state and 26 or 1, 0.5, -11.5)
        }):Play()
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        TweenService:Create(ToggleDot, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 21, 0, 21),
            Position = UDim2.new(0, state and 27 or 2, 0.5, -10.5)
        }):Play()
    end)
    
    table.insert(self.Elements, ToggleFrame)
    return ToggleFrame
end

return Toggle