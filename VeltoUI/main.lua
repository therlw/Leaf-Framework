-- Velto UI Library (Single File)
-- GitHub: https://github.com/therlw/Velto-Framework

local Velto = {}
Velto.__index = Velto

-- Services
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- THEME CONFIGURATION
local Theme = {
    Primary = Color3.fromRGB(30, 30, 40),
    Secondary = Color3.fromRGB(45, 45, 55),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Disabled = Color3.fromRGB(100, 100, 100),
    Shadow = Color3.fromRGB(0, 0, 0, 0.5),
    Success = Color3.fromRGB(0, 200, 0),
    Warning = Color3.fromRGB(255, 150, 0),
    Error = Color3.fromRGB(200, 0, 0)
}

-- UTILITY FUNCTIONS
local function CreateShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Theme.Shadow
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Parent = parent
    return shadow
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Theme.Secondary
    stroke.Parent = parent
    return stroke
end

-- INTRO ANIMATION
local function PlayIntroAnimation(UI, callback)
    local IntroConfig = {
        Duration = 3,
        Text = "Made By RLW",
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSize = 24,
        Font = Enum.Font.GothamBold
    }

    local IntroLabel = Instance.new("TextLabel")
    IntroLabel.Size = UDim2.new(0, 0, 0, 40)
    IntroLabel.Position = UDim2.new(0.5, 0, 0.5, -20)
    IntroLabel.Text = IntroConfig.Text
    IntroLabel.TextColor3 = IntroConfig.TextColor
    IntroLabel.Font = IntroConfig.Font
    IntroLabel.TextSize = IntroConfig.TextSize
    IntroLabel.BackgroundTransparency = 1
    IntroLabel.TextTransparency = 1
    IntroLabel.ZIndex = 100
    IntroLabel.Parent = UI

    local tweenIn = TweenService:Create(IntroLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 200, 0, 40),
        Position = UDim2.new(0.5, -100, 0.5, -20),
        TextTransparency = 0
    })

    local tweenOut = TweenService:Create(IntroLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    })

    tweenIn:Play()
    tweenIn.Completed:Connect(function()
        task.wait(IntroConfig.Duration)
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            IntroLabel:Destroy()
            if callback then callback() end -- Animasyon bittiğinde çağır
        end)
    end)
end


-- MAIN WINDOW CREATION
function Velto:CreateWindow(title, size)
    local self = setmetatable({}, Velto)
    self.Tabs = {}
    self.CurrentTab = nil
    self.Elements = {}
    
    -- Create UI container
    local UI = Instance.new("ScreenGui")
    UI.Name = "VeltoUI_"..title:gsub("%s+", "")
    UI.ResetOnSpawn = false
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    UI.Parent = CoreGui

    -- Main frame
    local Frame = Instance.new("Frame")
    Frame.Size = size or UDim2.new(0, 550, 0, 400)
    Frame.Position = UDim2.new(0.5, -275, 0.5, -200)
    Frame.BackgroundColor3 = Theme.Primary
    Frame.Active = true
    Frame.Draggable = true
    Frame.Name = "Main"
    Frame.Parent = UI

    CreateShadow(Frame)
    CreateCorner(Frame, 8)
    CreateStroke(Frame, 2, Theme.Accent)

    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Theme.Secondary
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Frame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = TitleBar

    -- Close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Theme.Text
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.BackgroundColor3 = Theme.Secondary
    CloseButton.Parent = TitleBar

    CloseButton.MouseButton1Click:Connect(function()
        UI:Destroy()
    end)

    -- Tab container (vertical)
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 120, 1, -80)
    TabContainer.Position = UDim2.new(0, 10, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Frame

    -- Content container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -140, 1, -80)
    ContentContainer.Position = UDim2.new(0, 130, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Name = "ContentContainer"
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = Frame

    -- Scroll frame
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollFrame.Position = UDim2.new(0, 0, 0, 0)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.ScrollBarImageColor3 = Theme.Accent
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Parent = ContentContainer

    CreateStroke(ContentContainer, 1, Theme.Secondary)
    CreateCorner(ContentContainer, 6)

    self.UI = UI
    self.Main = Frame
    self.ScrollFrame = ScrollFrame
    self.TabContainer = TabContainer
    self.ContentContainer = ContentContainer

    PlayIntroAnimation(UI)
    return self
end

-- TAB CREATION
function Velto:CreateTab(tabName)
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

    -- Highlight
    local Highlight = Instance.new("Frame")
    Highlight.Size = UDim2.new(0, 3, 1, 0)
    Highlight.Position = UDim2.new(1, -3, 0, 0)
    Highlight.BackgroundColor3 = Theme.Accent
    Highlight.Visible = (#self.Tabs == 0)
    Highlight.Parent = TabButton

    -- Content frame
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.Position = UDim2.new(0, 0, 0, 0)
    Content.BackgroundTransparency = 1
    Content.Visible = (#self.Tabs == 0)
    Content.Parent = self.ScrollFrame

    -- Tab click handler
    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Content.Visible = false
            t.Highlight.Visible = false
            t.Button.BackgroundColor3 = Theme.Secondary
        end
        
        Content.Visible = true
        Highlight.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        self.CurrentTab = Tab
    end)

    Tab.Button = TabButton
    Tab.Highlight = Highlight
    Tab.Content = Content

    table.insert(self.Tabs, Tab)
    return setmetatable(Tab, {__index = self})
end

-- BUTTON COMPONENT
function Velto:AddButton(name, callback)
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

    Button.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)

    -- Hover effects
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

-- TOGGLE COMPONENT
function Velto:AddToggle(name, defaultValue, callback)
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
        ToggleButton.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(70, 70, 70)
        ToggleDot.Position = UDim2.new(0, state and 27 or 2, 0.5, -10.5)
        if callback then pcall(callback, state) end
    end)

    table.insert(self.Elements, ToggleFrame)
    return ToggleFrame
end

-- LABEL COMPONENT
function Velto:AddLabel(text)
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

-- AUTO RUN: Play intro and create window after animation
local IntroGui = Instance.new("ScreenGui")
IntroGui.Name = "VeltoIntro"
IntroGui.ResetOnSpawn = false
IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
IntroGui.IgnoreGuiInset = true
IntroGui.Parent = CoreGui

PlayIntroAnimation(IntroGui, function()
    local window = Velto:CreateWindow("RLW Hub", UDim2.new(0, 600, 0, 400))
    -- örnek ekleme yapılabilir
end)

return Velto
