local Theme = require(script.Parent.Parent.Themes.Default)

local Label = {}

function Label.Add(self, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, #self.Elements * 40)
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = self.Content
    
    table.insert(self.Elements, Label)
    return Label
end

return Label