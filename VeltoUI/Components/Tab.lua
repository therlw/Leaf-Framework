local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Parent.Themes.Default)

local Tab = {}

function Tab.Create(self, tabName)
    local Tab = {}
    Tab.Elements = {}
    Tab.Index = #self.Tabs + 1
    
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -10, 0, 35)
    TabButton.Position = UDim2.new(0, 5, 0, (Tab.Index - 1) * 40)
    TabButton.Text = tabName
    TabButton.BackgroundColor3 = Theme.Secondary
    TabButton.TextColor3 = Theme.Text
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 14
    TabButton.Parent = self.TabContainer
    
    CreateCorner(TabButton, 6)
    CreateStroke(TabButton, 1, Theme.Accent)
    
    -- Highlight for active tab
    local Highlight = Instance.new("Frame")
    Highlight.Size = UDim2.new(0, 3, 1, 0)
    Highlight.Position = UDim2.new(1, -3, 0, 0)
    Highlight.BackgroundColor3 = Theme.Accent
    Highlight.BorderSizePixel = 0
    Highlight.Visible = (#self.Tabs == 0)
    Highlight.Parent = TabButton
    
    -- Content frame
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.Position = UDim2.new(0, 0, 0, 0)
    Content.BackgroundTransparency = 1
    Content.Visible = (#self.Tabs == 0)
    Content.Parent = self.ScrollFrame
    
    Tab.Button = TabButton
    Tab.Highlight = Highlight
    Tab.Content = Content
    
    -- Tab click handler
    TabButton.MouseButton1Click:Connect(function()
        -- Hide all tabs
        for _, t in pairs(self.Tabs) do
            t.Content.Visible = false
            t.Highlight.Visible = false
            TweenService:Create(t.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Secondary
            }):Play()
        end
        
        -- Show selected tab
        Content.Visible = true
        Highlight.Visible = true
        TweenService:Create(TabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        }):Play()
        
        self.CurrentTab = Tab
    end)
    
    table.insert(self.Tabs, Tab)
    return setmetatable(Tab, {__index = self})
end

return Tab