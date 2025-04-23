local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.Themes.Default)

local Textbox = {}

function Textbox.Add(self, name, placeholder, callback)
    local TextboxFrame = Instance.new("Frame")
    TextboxFrame.Size = UDim2.new(1, -20, 0, 60)
    TextboxFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 40)
    TextboxFrame.BackgroundTransparency = 1
    TextboxFrame.Parent = self.Content
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Text = name
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TextboxFrame
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, 0, 0, 30)
    Box.Position = UDim2.new(0, 0, 0, 25)
    Box.Text = ""
    Box.PlaceholderText = placeholder or "Type here..."
    Box.TextColor3 = Theme.Text
    Box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    Box.BackgroundColor3 = Theme.Secondary
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Box.ClearTextOnFocus = false
    Box.Parent = TextboxFrame
    
    CreateCorner(Box, 6)
    CreateStroke(Box, 1, Theme.Accent)
    
    -- Focus effects
    Box.Focused:Connect(function()
        TweenService:Create(Box, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(55, 55, 65)
        }):Play()
        
        TweenService:Create(Box.UIStroke, TweenInfo.new(0.2), {
            Color = Theme.Accent,
            Thickness = 2
        }):Play()
    end)
    
    Box.FocusLost:Connect(function(enterPressed)
        TweenService:Create(Box, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Secondary
        }):Play()
        
        TweenService:Create(Box.UIStroke, TweenInfo.new(0.2), {
            Color = Theme.Accent,
            Thickness = 1
        }):Play()
        
        if callback and (enterPressed or not Box:IsFocused()) then
            pcall(callback, Box.Text)
        end
    end)
    
    table.insert(self.Elements, TextboxFrame)
    return {
        Frame = TextboxFrame,
        Label = Label,
        Box = Box
    }
end

return Textbox