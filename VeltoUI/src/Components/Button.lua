local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.Themes.Default)

local Button = {}

function Button.Add(self, name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 30)
    Button.Position = UDim2.new(0, 10, 0, #self.Elements * 40)
    Button.Text = name
    Button.TextColor3 = Theme.Text
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.BackgroundColor3 = Theme.Accent
    Button.Parent = self.Content
    
    CreateCorner(Button, 6)
    CreateStroke(Button, 1, Theme.Secondary)
    
    -- Click animation
    Button.MouseButton1Down:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -25, 0, 25),
            Position = UDim2.new(0, 12.5, 0, (#self.Elements * 40) + 2.5)
        }):Play()
    end)
    
    Button.MouseButton1Up:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, #self.Elements * 40)
        }):Play()
        
        if callback then
            pcall(callback)
        end
    end)
    
    -- Hover effect
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 190, 255)
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Accent
        }):Play()
    end)
    
    table.insert(self.Elements, Button)
    return Button
end

return Button