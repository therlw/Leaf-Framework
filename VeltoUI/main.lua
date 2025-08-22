-- Velto UI Ultimate Premium Edition
local Velto = {}
Velto.__index = Velto

-- Services
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Premium Theme Configuration
local Theme = {
    Primary = Color3.fromRGB(20, 22, 30),
    Secondary = Color3.fromRGB(30, 33, 43),
    Tertiary = Color3.fromRGB(40, 44, 56),
    Accent = Color3.fromRGB(115, 80, 255),
    AccentSecondary = Color3.fromRGB(0, 200, 255),
    Text = Color3.fromRGB(240, 245, 255),
    TextDim = Color3.fromRGB(170, 180, 200),
    Disabled = Color3.fromRGB(100, 110, 130),
    Success = Color3.fromRGB(80, 220, 120),
    Warning = Color3.fromRGB(255, 180, 70),
    Error = Color3.fromRGB(255, 95, 95),
    Light = Color3.fromRGB(240, 245, 255),
    Dark = Color3.fromRGB(15, 17, 23),
    Overlay = Color3.fromRGB(10, 12, 18)
}

-- Gradient presets
local Gradients = {
    Main = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 22, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 28, 38))
    },
    Accent = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 60, 220))
    },
    Secondary = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 33, 43)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 38, 50))
    },
    Premium = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 70, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(115, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 100, 255))
    }
}

-- Utility functions
local function CreateGradient(parent, gradientType, rotation, transparency)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = rotation or 90
    gradient.Color = Gradients[gradientType] or Gradients.Main
    gradient.Transparency = NumberSequence.new(transparency or 0)
    gradient.Parent = parent
    return gradient
end

local function CreateRoundedFrame(parent, size, position, radius, transparency, color)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(1, 0, 1, 0)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = color or Theme.Primary
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    frame.ZIndex = 2
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = frame
    
    if parent then
        frame.Parent = parent
    end
    
    return frame, corner
end

local function CreateShadow(element, intensity, radius, color)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = color or Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = intensity or 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, radius or 14, 1, radius or 14)
    shadow.Position = UDim2.new(0, -radius/2 or -7, 0, -radius/2 or -7)
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = element.ZIndex - 1
    shadow.Parent = element
    return shadow
end

local function CreateStroke(element, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or Theme.Accent
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = element
    return stroke
end

local function CreateIcon(parent, imageId, size, position, color)
    local icon = Instance.new("ImageLabel")
    icon.Image = "rbxassetid://" .. imageId
    icon.Size = size or UDim2.new(0, 20, 0, 20)
    icon.Position = position or UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.ImageColor3 = color or Theme.Text
    icon.Parent = parent
    return icon
end

-- Animation functions
local function PulseAnimation(element, minSize, maxSize, duration)
    local pulseIn = TweenService:Create(element, TweenInfo.new(
        duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out
    ), {Size = maxSize})
    
    local pulseOut = TweenService:Create(element, TweenInfo.new(
        duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.In
    ), {Size = minSize})
    
    pulseIn:Play()
    pulseIn.Completed:Connect(function()
        pulseOut:Play()
        pulseOut.Completed:Connect(function()
            PulseAnimation(element, minSize, maxSize, duration)
        end)
    end)
end

local function HoverAnimation(element, hoverSize, normalSize, duration)
    element.MouseEnter:Connect(function()
        TweenService:Create(element, TweenInfo.new(
            duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out
        ), {Size = hoverSize}):Play()
    end)
    
    element.MouseLeave:Connect(function()
        TweenService:Create(element, TweenInfo.new(
            duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out
        ), {Size = normalSize}):Play()
    end)
end

-- Water ripple effect
local function CreateRippleEffect(button)
    button.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.ZIndex = 5
        ripple.Parent = button
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        
        TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1
        }):Play()
        
        delay(0.5, function()
            ripple:Destroy()
        end)
    end)
end

-- Main Window Creation
function Velto:CreateWindow(title, size, accentColor)
    local self = setmetatable({}, Velto)
    self.Tabs = {}
    self.CurrentTab = nil
    self.Elements = {}
    self.Notifications = {}
    self.ConfigPath = "Velto_"..(title:gsub("%s+",""))..".json"
    self.State = { 
        Position = {0.5, -300, 0.5, -200}, 
        Minimized = false, 
        ToggleKey = "RightShift", 
        Size = {0, 600, 0, 500},
        Theme = "Dark"
    }
    
    -- Load saved configuration
    if isfile and readfile and isfile(self.ConfigPath) then
        local raw = readfile(self.ConfigPath)
        if raw then
            local ok, dec = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok and type(dec) == "table" then
                for k,v in pairs(dec) do self.State[k] = v end
            end
        end
    end
    
    -- Create UI container
    local UI = Instance.new("ScreenGui")
    UI.Name = "VeltoUI_"..title:gsub("%s+", "")
    UI.ResetOnSpawn = false
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    UI.Parent = CoreGui

    -- Background overlay for focus effect
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.Position = UDim2.new(0, 0, 0, 0)
    Overlay.BackgroundColor3 = Theme.Overlay
    Overlay.BackgroundTransparency = 0.7
    Overlay.ZIndex = 0
    Overlay.Visible = false
    Overlay.Parent = UI

    -- Main container with smooth rounded corners
    local MainContainer = Instance.new("Frame")
    MainContainer.Size = size or UDim2.new(0, 600, 0, 500)
    MainContainer.Position = UDim2.new(
        self.State.Position[1], self.State.Position[2],
        self.State.Position[3], self.State.Position[4]
    )
    MainContainer.BackgroundColor3 = Theme.Primary
    MainContainer.ClipsDescendants = true
    MainContainer.ZIndex = 2
    MainContainer.Parent = UI
    
    CreateRoundedFrame(MainContainer, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 14)
    CreateShadow(MainContainer, 0.8, 20)
    CreateGradient(MainContainer, "Main")
    
    -- Navigation sidebar
    local NavBar = Instance.new("Frame")
    NavBar.Size = UDim2.new(0, 180, 1, 0)
    NavBar.Position = UDim2.new(0, 0, 0, 0)
    NavBar.BackgroundColor3 = Theme.Secondary
    NavBar.BackgroundTransparency = 0
    NavBar.ZIndex = 3
    NavBar.Parent = MainContainer
    
    CreateRoundedFrame(NavBar, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 14, 0, Theme.Secondary)
    CreateGradient(NavBar, "Secondary")
    
    -- Header with logo and title
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 4
    Header.Parent = NavBar
    
    -- Animated logo
    local Logo = Instance.new("Frame")
    Logo.Size = UDim2.new(0, 36, 0, 36)
    Logo.Position = UDim2.new(0, 15, 0, 12)
    Logo.BackgroundColor3 = Theme.Accent
    Logo.ZIndex = 5
    Logo.Parent = Header
    
    CreateRoundedFrame(Logo, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 10)
    CreateGradient(Logo, "Premium")
    CreateShadow(Logo, 0.5, 10, Theme.Accent)
    
    -- Animate logo
    PulseAnimation(Logo, UDim2.new(0, 36, 0, 36), UDim2.new(0, 40, 0, 40), 3)
    
    -- Title text with glow effect
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 60, 0, 0)
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextColor3 = Theme.Light
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 4
    Title.Parent = Header
    
    -- Add text glow
    local TextGlow = Instance.new("TextLabel")
    TextGlow.Size = Title.Size
    TextGlow.Position = Title.Position
    TextGlow.Text = title
    TextGlow.Font = Enum.Font.GothamBold
    TextGlow.TextSize = 20
    TextGlow.TextColor3 = Theme.Accent
    TextGlow.TextTransparency = 0.8
    TextGlow.BackgroundTransparency = 1
    TextGlow.TextXAlignment = Enum.TextXAlignment.Left
    TextGlow.ZIndex = 3
    TextGlow.Parent = Header
    
    -- Tab container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -120)
    TabContainer.Position = UDim2.new(0, 0, 0, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabContainer.ZIndex = 3
    TabContainer.Parent = NavBar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer
    
    -- Content area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -190, 1, -20)
    ContentArea.Position = UDim2.new(0, 190, 0, 10)
    ContentArea.BackgroundColor3 = Theme.Primary
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 2
    ContentArea.Parent = MainContainer
    
    -- Tab content container
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Position = UDim2.new(0, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ClipsDescendants = true
    TabContent.ZIndex = 2
    TabContent.Parent = ContentArea
    
    -- Window controls
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 80, 0, 30)
    Controls.Position = UDim2.new(1, -90, 0, 15)
    Controls.BackgroundTransparency = 1
    Controls.ZIndex = 5
    Controls.Parent = MainContainer
    
    -- Minimize button
    local MinimizeBtn = Instance.new("ImageButton")
    MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
    MinimizeBtn.Position = UDim2.new(0, 0, 0, 5)
    MinimizeBtn.Image = "rbxassetid://6031094678"
    MinimizeBtn.ImageColor3 = Theme.TextDim
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.ZIndex = 6
    MinimizeBtn.Parent = Controls
    
    -- Close button
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(0, 30, 0, 5)
    CloseBtn.Image = "rbxassetid://6031094678"
    CloseBtn.ImageColor3 = Theme.TextDim
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.ZIndex = 6
    CloseBtn.Parent = Controls
    
    -- Window dragging
    local Dragging, DragInput, DragStart, StartPosition
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPosition = MainContainer.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            MainContainer.Position = UDim2.new(
                StartPosition.X.Scale, 
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale, 
                StartPosition.Y.Offset + Delta.Y
            )
        end
    end)
    
    -- Button hover effects
    MinimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {
            ImageColor3 = Theme.Text
        }):Play()
    end)
    
    MinimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {
            ImageColor3 = Theme.TextDim
        }):Play()
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {
            ImageColor3 = Theme.Error
        }):Play()
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {
            ImageColor3 = Theme.TextDim
        }):Play()
    end)
    
    -- Button functionality
    MinimizeBtn.MouseButton1Click:Connect(function()
        self.State.Minimized = not self.State.Minimized
        
        if self.State.Minimized then
            TweenService:Create(ContentArea, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 0, 1, -20)
            }):Play()
            
            TweenService:Create(NavBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 0, 1, 0)
            }):Play()
        else
            TweenService:Create(ContentArea, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -190, 1, -20)
            }):Play()
            
            TweenService:Create(NavBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 180, 1, 0)
            }):Play()
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        TweenService:Create(Overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
        
        wait(0.3)
        UI:Destroy()
    end)
    
    -- Toggle key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.RightShift then
            UI.Enabled = not UI.Enabled
            
            if UI.Enabled then
                Overlay.Visible = true
                MainContainer.Size = UDim2.new(0, 0, 0, 0)
                MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
                
                TweenService:Create(Overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.7
                }):Play()
                
                TweenService:Create(MainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = size or UDim2.new(0, 600, 0, 500),
                    Position = UDim2.new(
                        self.State.Position[1], self.State.Position[2],
                        self.State.Position[3], self.State.Position[4]
                    )
                }):Play()
            else
                TweenService:Create(Overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                }):Play()
                
                TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }):Play()
                
                wait(0.3)
                Overlay.Visible = false
            end
        end
    end)
    
    -- Store references
    self.UI = UI
    self.Main = MainContainer
    self.NavBar = NavBar
    self.TabContainer = TabContainer
    self.ContentArea = ContentArea
    self.TabContent = TabContent
    self.Overlay = Overlay
    
    return self
end

-- Tab Creation
function Velto:CreateTab(name, icon)
    local Tab = {}
    Tab.Name = name
    Tab.Buttons = {}
    Tab.Content = Instance.new("ScrollingFrame")
    Tab.Content.Size = UDim2.new(1, 0, 1, 0)
    Tab.Content.Position = UDim2.new(0, 0, 0, 0)
    Tab.Content.BackgroundTransparency = 1
    Tab.Content.ScrollBarThickness = 3
    Tab.Content.ScrollBarImageColor3 = Theme.Accent
    Tab.Content.ScrollBarImageTransparency = 0.7
    Tab.Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Tab.Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Tab.Content.Visible = false
    Tab.Content.ZIndex = 2
    Tab.Content.Parent = self.TabContent
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 10)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = Tab.Content
    
    -- Tab button
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -20, 0, 40)
    TabButton.Position = UDim2.new(0, 10, 0, #self.Tabs * 45)
    TabButton.Text = ""
    TabButton.BackgroundColor3 = Theme.Tertiary
    TabButton.BackgroundTransparency = 0.7
    TabButton.AutoButtonColor = false
    TabButton.ZIndex = 3
    TabButton.Parent = self.TabContainer
    
    CreateRoundedFrame(TabButton, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 8)
    CreateGradient(TabButton, "Secondary")
    CreateRippleEffect(TabButton)
    
    -- Tab icon
    if icon then
        local TabIcon = CreateIcon(TabButton, icon, UDim2.new(0, 20, 0, 20), UDim2.new(0, 15, 0.5, -10))
        TabIcon.ZIndex = 4
    end
    
    -- Tab text
    local TabText = Instance.new("TextLabel")
    TabText.Size = UDim2.new(1, -50, 1, 0)
    TabText.Position = UDim2.new(0, 45, 0, 0)
    TabText.Text = name
    TabText.Font = Enum.Font.Gotham
    TabText.TextSize = 14
    TabText.TextColor3 = Theme.TextDim
    TabText.TextXAlignment = Enum.TextXAlignment.Left
    TabText.BackgroundTransparency = 1
    TabText.ZIndex = 4
    TabText.Parent = TabButton
    
    -- Tab indicator
    local TabIndicator = Instance.new("Frame")
    TabIndicator.Size = UDim2.new(0, 3, 0, 0)
    TabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
    TabIndicator.BackgroundColor3 = Theme.Accent
    TabIndicator.Visible = false
    TabIndicator.ZIndex = 5
    TabIndicator.Parent = TabButton
    
    CreateRoundedFrame(TabIndicator, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 2)
    CreateGradient(TabIndicator, "Premium")
    
    -- Tab button events
    TabButton.MouseEnter:Connect(function()
        if Tab ~= self.CurrentTab then
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.5
            }):Play()
            
            TweenService:Create(TabText, TweenInfo.new(0.2), {
                TextColor3 = Theme.Text
            }):Play()
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if Tab ~= self.CurrentTab then
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.7
            }):Play()
            
            TweenService:Create(TabText, TweenInfo.new(0.2), {
                TextColor3 = Theme.TextDim
            }):Play()
        end
    end)
    
    TabButton.MouseButton1Click:Connect(function()
        if self.CurrentTab then
            -- Hide current tab
            self.CurrentTab.Content.Visible = false
            
            TweenService:Create(self.CurrentTab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.7
            }):Play()
            
            TweenService:Create(self.CurrentTab.Text, TweenInfo.new(0.2), {
                TextColor3 = Theme.TextDim
            }):Play()
            
            self.CurrentTab.Indicator.Visible = false
        end
        
        -- Show new tab
        Tab.Content.Visible = true
        
        TweenService:Create(TabButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3
        }):Play()
        
        TweenService:Create(TabText, TweenInfo.new(0.2), {
            TextColor3 = Theme.Text
        }):Play()
        
        TabIndicator.Visible = true
        TweenService:Create(TabIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 3, 0, 20)
        }):Play()
        
        self.CurrentTab = Tab
    end)
    
    -- Store tab references
    Tab.Button = TabButton
    Tab.Text = TabText
    Tab.Indicator = TabIndicator
    Tab.ContentFrame = Tab.Content
    
    table.insert(self.Tabs, Tab)
    
    -- Select first tab
    if #self.Tabs == 1 then
        TabButton.MouseButton1Click:Fire()
    end
    
    return setmetatable(Tab, {__index = self})
end

-- Section Creation
function Velto:AddSection(title)
    local Section = {}
    Section.Frame = Instance.new("Frame")
    Section.Frame.Size = UDim2.new(1, -20, 0, 0)
    Section.Frame.Position = UDim2.new(0, 10, 0, 0)
    Section.Frame.BackgroundTransparency = 1
    Section.Frame.AutomaticSize = Enum.AutomaticSize.Y
    Section.Frame.ZIndex = 2
    Section.Frame.Parent = self.ContentFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Section.Frame
    
    -- Section header
    if title then
        local Header = Instance.new("Frame")
        Header.Size = UDim2.new(1, 0, 0, 30)
        Header.Position = UDim2.new(0, 0, 0, 0)
        Header.BackgroundTransparency = 1
        Header.ZIndex = 3
        Header.Parent = Section.Frame
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 1, 0)
        Title.Position = UDim2.new(0, 0, 0, 0)
        Title.Text = title
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 16
        Title.TextColor3 = Theme.Text
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.BackgroundTransparency = 1
        Title.ZIndex = 3
        Title.Parent = Header
        
        local Divider = Instance.new("Frame")
        Divider.Size = UDim2.new(1, 0, 0, 1)
        Divider.Position = UDim2.new(0, 0, 1, -1)
        Divider.BackgroundColor3 = Theme.Tertiary
        Divider.BackgroundTransparency = 0.8
        Divider.ZIndex = 3
        Divider.Parent = Header
    end
    
    Section.Content = Instance.new("Frame")
    Section.Content.Size = UDim2.new(1, 0, 0, 0)
    Section.Content.Position = UDim2.new(0, 0, 0, title and 40 or 0)
    Section.Content.BackgroundTransparency = 1
    Section.Content.AutomaticSize = Enum.AutomaticSize.Y
    Section.Content.ZIndex = 2
    Section.Content.Parent = Section.Frame
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = Section.Content
    
    Section.Elements = {}
    
    -- Add element methods
    Section.AddButton = function(_, text, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.Text = text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14
        Button.TextColor3 = Theme.Text
        Button.BackgroundColor3 = Theme.Tertiary
        Button.AutoButtonColor = false
        Button.ZIndex = 3
        Button.Parent = Section.Content
        
        CreateRoundedFrame(Button, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 8)
        CreateGradient(Button, "Secondary")
        CreateRippleEffect(Button)
        
        -- Hover effects
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.5
            }):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0
            }):Play()
        end)
        
        -- Click effect
        Button.MouseButton1Down:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {
                Size = UDim2.new(0.98, 0, 0, 38)
            }):Play()
        end)
        
        Button.MouseButton1Up:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {
                Size = UDim2.new(1, 0, 0, 40)
            }):Play()
        end)
        
        Button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
        
        table.insert(Section.Elements, Button)
        return Button
    end
    
    Section.AddToggle = function(_, text, default, callback)
        local Toggle = Instance.new("Frame")
        Toggle.Size = UDim2.new(1, 0, 0, 30)
        Toggle.BackgroundTransparency = 1
        Toggle.ZIndex = 2
        Toggle.Parent = Section.Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextColor3 = Theme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.ZIndex = 3
        Label.Parent = Toggle
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 50, 0, 24)
        ToggleButton.Position = UDim2.new(1, -50, 0.5, -12)
        ToggleButton.Text = ""
        ToggleButton.BackgroundColor3 = default and Theme.Accent or Theme.Tertiary
        ToggleButton.AutoButtonColor = false
        ToggleButton.ZIndex = 3
        ToggleButton.Parent = Toggle
        
        CreateRoundedFrame(ToggleButton, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 12)
        
        if default then
            CreateGradient(ToggleButton, "Accent")
        else
            CreateGradient(ToggleButton, "Secondary")
        end
        
        local ToggleKnob = Instance.new("Frame")
        ToggleKnob.Size = UDim2.new(0, 18, 0, 18)
        ToggleKnob.Position = UDim2.new(0, default and 28 or 2, 0.5, -9)
        ToggleKnob.BackgroundColor3 = Theme.Light
        ToggleKnob.ZIndex = 4
        ToggleKnob.Parent = ToggleButton
        
        CreateRoundedFrame(ToggleKnob, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 9)
        
        local state = default or false
        
        ToggleButton.MouseButton1Click:Connect(function()
            state = not state
            
            if state then
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.Accent
                }):Play()
                
                TweenService:Create(ToggleKnob, TweenInfo.new(0.2), {
                    Position = UDim2.new(0, 28, 0.5, -9)
                }):Play()
                
                CreateGradient(ToggleButton, "Accent")
            else
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.Tertiary
                }):Play()
                
                TweenService:Create(ToggleKnob, TweenInfo.new(0.2), {
                    Position = UDim2.new(0, 2, 0.5, -9)
                }):Play()
                
                CreateGradient(ToggleButton, "Secondary")
            end
            
            if callback then
                callback(state)
            end
        end)
        
        table.insert(Section.Elements, Toggle)
        return Toggle
    end
    
    Section.AddSlider = function(_, text, min, max, default, callback)
        local Slider = Instance.new("Frame")
        Slider.Size = UDim2.new(1, 0, 0, 60)
        Slider.BackgroundTransparency = 1
        Slider.ZIndex = 2
        Slider.Parent = Section.Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextColor3 = Theme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.ZIndex = 3
        Label.Parent = Slider
        
        local Value = Instance.new("TextLabel")
        Value.Size = UDim2.new(0, 50, 0, 20)
        Value.Position = UDim2.new(1, -50, 0, 0)
        Value.Text = tostring(default or min)
        Value.Font = Enum.Font.Gotham
        Value.TextSize = 14
        Value.TextColor3 = Theme.TextDim
        Value.TextXAlignment = Enum.TextXAlignment.Right
        Value.BackgroundTransparency = 1
        Value.ZIndex = 3
        Value.Parent = Slider
        
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, 0, 0, 5)
        Track.Position = UDim2.new(0, 0, 0, 35)
        Track.BackgroundColor3 = Theme.Tertiary
        Track.ZIndex = 3
        Track.Parent = Slider
        
        CreateRoundedFrame(Track, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 3)
        CreateGradient(Track, "Secondary")
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.Position = UDim2.new(0, 0, 0, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.ZIndex = 4
        Fill.Parent = Track
        
        CreateRoundedFrame(Fill, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 3)
        CreateGradient(Fill, "Accent")
        
        local Knob = Instance.new("TextButton")
        Knob.Size = UDim2.new(0, 15, 0, 15)
        Knob.Position = UDim2.new(0, 0, 0.5, -7.5)
        Knob.Text = ""
        Knob.BackgroundColor3 = Theme.Light
        Knob.AutoButtonColor = false
        Knob.ZIndex = 5
        Knob.Parent = Track
        
        CreateRoundedFrame(Knob, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 8)
        CreateShadow(Knob, 0.5, 10)
        
        local value = default or min
        local dragging = false
        
        local function updateValue(newValue)
            value = math.clamp(newValue, min, max)
            Value.Text = tostring(math.floor(value))
            
            local percentage = (value - min) / (max - min)
            Fill.Size = UDim2.new(percentage, 0, 1, 0)
            Knob.Position = UDim2.new(percentage, -7.5, 0.5, -7.5)
            
            if callback then
                callback(value)
            end
        end
        
        Knob.MouseButton1Down:Connect(function()
            dragging = true
            
            TweenService:Create(Knob, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 18, 0, 18)
            }):Play()
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if dragging then
                    dragging = false
                    
                    TweenService:Create(Knob, TweenInfo.new(0.1), {
                        Size = UDim2.new(0, 15, 0, 15)
                    }):Play()
                end
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = input.Position
                local relativeX = pos.X - Track.AbsolutePosition.X
                local percentage = math.clamp(relativeX / Track.AbsoluteSize.X, 0, 1)
                updateValue(min + (max - min) * percentage)
            end
        end)
        
        Track.MouseButton1Down:Connect(function(x, y)
            local relativeX = x - Track.AbsolutePosition.X
            local percentage = math.clamp(relativeX / Track.AbsoluteSize.X, 0, 1)
            updateValue(min + (max - min) * percentage)
        end)
        
        updateValue(default or min)
        
        table.insert(Section.Elements, Slider)
        return Slider
    end
    
    Section.AddDropdown = function(_, text, options, default, callback)
        local Dropdown = Instance.new("Frame")
        Dropdown.Size = UDim2.new(1, 0, 0, 40)
        Dropdown.BackgroundTransparency = 1
        Dropdown.ClipsDescendants = true
        Dropdown.ZIndex = 2
        Dropdown.Parent = Section.Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextColor3 = Theme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.ZIndex = 3
        Label.Parent = Dropdown
        
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 30)
        Button.Position = UDim2.new(0, 0, 0, 25)
        Button.Text = default or options[1] or "Select..."
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14
        Button.TextColor3 = Theme.Text
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.BackgroundColor3 = Theme.Tertiary
        Button.AutoButtonColor = false
        Button.ZIndex = 3
        Button.Parent = Dropdown
        
        CreateRoundedFrame(Button, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 6)
        CreateGradient(Button, "Secondary")
        
        local Arrow = Instance.new("ImageLabel")
        Arrow.Size = UDim2.new(0, 16, 0, 16)
        Arrow.Position = UDim2.new(1, -25, 0.5, -8)
        Arrow.Image = "rbxassetid://6031090990"
        Arrow.ImageColor3 = Theme.TextDim
        Arrow.BackgroundTransparency = 1
        Arrow.Rotation = 0
        Arrow.ZIndex = 4
        Arrow.Parent = Button
        
        local Options = Instance.new("ScrollingFrame")
        Options.Size = UDim2.new(1, 0, 0, 0)
        Options.Position = UDim2.new(0, 0, 1, 5)
        Options.BackgroundColor3 = Theme.Tertiary
        Options.ScrollBarThickness = 3
        Options.ScrollBarImageColor3 = Theme.Accent
        Options.ScrollBarImageTransparency = 0.7
        Options.CanvasSize = UDim2.new(0, 0, 0, 0)
        Options.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Options.Visible = false
        Options.ZIndex = 5
        Options.Parent = Dropdown
        
        CreateRoundedFrame(Options, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 6)
        CreateGradient(Options, "Secondary")
        
        local OptionsLayout = Instance.new("UIListLayout")
        OptionsLayout.Padding = UDim.new(0, 1)
        OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        OptionsLayout.Parent = Options
        
        local open = false
        
        local function toggleDropdown()
            open = not open
            
            if open then
                Options.Visible = true
                TweenService:Create(Options, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, math.min(#options * 31, 155))
                }):Play()
                
                TweenService:Create(Arrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Rotation = 180
                }):Play()
                
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.2
                }):Play()
            else
                TweenService:Create(Options, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, 0)
                }):Play()
                
                TweenService:Create(Arrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Rotation = 0
                }):Play()
                
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0
                }):Play()
                
                wait(0.3)
                Options.Visible = false
            end
        end
        
        Button.MouseButton1Click:Connect(toggleDropdown)
        
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Size = UDim2.new(1, 0, 0, 30)
            OptionButton.Text = option
            OptionButton.Font = Enum.Font.Gotham
            OptionButton.TextSize = 14
            OptionButton.TextColor3 = Theme.Text
            OptionButton.BackgroundColor3 = Theme.Tertiary
            OptionButton.BackgroundTransparency = 0.7
            OptionButton.AutoButtonColor = false
            OptionButton.LayoutOrder = i
            OptionButton.ZIndex = 6
            OptionButton.Parent = Options
            
            OptionButton.MouseEnter:Connect(function()
                TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.5
                }):Play()
            end)
            
            OptionButton.MouseLeave:Connect(function()
                TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.7
                }):Play()
            end)
            
            OptionButton.MouseButton1Click:Connect(function()
                Button.Text = option
                toggleDropdown()
                
                if callback then
                    callback(option)
                end
            end)
        end
        
        -- Close dropdown when clicking outside
        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and open then
                local mousePos = input.Position
                local absolutePos = Dropdown.AbsolutePosition
                local absoluteSize = Dropdown.AbsoluteSize
                
                if not (mousePos.X >= absolutePos.X and mousePos.X <= absolutePos.X + absoluteSize.X and
                       mousePos.Y >= absolutePos.Y and mousePos.Y <= absolutePos.Y + absoluteSize.Y + (open and Options.AbsoluteSize.Y or 0)) then
                    toggleDropdown()
                end
            end
        end
        
        UserInputService.InputBegan:Connect(onInputBegan)
        
        table.insert(Section.Elements, Dropdown)
        return Dropdown
    end
    
    Section.AddLabel = function(_, text)
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextColor3 = Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.ZIndex = 2
        Label.Parent = Section.Content
        
        table.insert(Section.Elements, Label)
        return Label
    end
    
    Section.AddTextbox = function(_, text, placeholder, callback)
        local Textbox = Instance.new("Frame")
        Textbox.Size = UDim2.new(1, 0, 0, 60)
        Textbox.BackgroundTransparency = 1
        Textbox.ZIndex = 2
        Textbox.Parent = Section.Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextColor3 = Theme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.ZIndex = 3
        Label.Parent = Textbox
        
        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1, 0, 0, 30)
        Box.Position = UDim2.new(0, 0, 0, 25)
        Box.Text = ""
        Box.PlaceholderText = placeholder or ""
        Box.Font = Enum.Font.Gotham
        Box.TextSize = 14
        Box.TextColor3 = Theme.Text
        Box.PlaceholderColor3 = Theme.TextDim
        Box.BackgroundColor3 = Theme.Tertiary
        Box.ZIndex = 3
        Box.Parent = Textbox
        
        CreateRoundedFrame(Box, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 6)
        CreateGradient(Box, "Secondary")
        
        Box.Focused:Connect(function()
            TweenService:Create(Box, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        
        Box.FocusLost:Connect(function(enterPressed)
            TweenService:Create(Box, TweenInfo.new(0.2), {
                BackgroundTransparency = 0
            }):Play()
            
            if enterPressed and callback then
                callback(Box.Text)
            end
        end)
        
        table.insert(Section.Elements, Textbox)
        return Textbox
    end
    
    Section.AddKeybind = function(_, text, defaultKey, callback)
        local Keybind = Instance.new("Frame")
        Keybind.Size = UDim2.new(1, 0, 0, 40)
        Keybind.BackgroundTransparency = 1
        Keybind.ZIndex = 2
        Keybind.Parent = Section.Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextColor3 = Theme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.ZIndex = 3
        Label.Parent = Keybind
        
        local KeyButton = Instance.new("TextButton")
        KeyButton.Size = UDim2.new(0, 80, 0, 25)
        KeyButton.Position = UDim2.new(1, -80, 0.5, -12.5)
        KeyButton.Text = defaultKey and defaultKey.Name or "None"
        KeyButton.Font = Enum.Font.Gotham
        KeyButton.TextSize = 12
        KeyButton.TextColor3 = Theme.Text
        KeyButton.BackgroundColor3 = Theme.Tertiary
        KeyButton.AutoButtonColor = false
        KeyButton.ZIndex = 3
        KeyButton.Parent = Keybind
        
        CreateRoundedFrame(KeyButton, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 6)
        CreateGradient(KeyButton, "Secondary")
        
        local listening = false
        local currentKey = defaultKey
        
        KeyButton.MouseButton1Click:Connect(function()
            listening = not listening
            
            if listening then
                KeyButton.Text = "..."
                TweenService:Create(KeyButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.2
                }):Play()
            else
                KeyButton.Text = currentKey and currentKey.Name or "None"
                TweenService:Create(KeyButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0
                }):Play()
            end
        end)
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    KeyButton.Text = currentKey.Name
                    listening = false
                    
                    TweenService:Create(KeyButton, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0
                    }):Play()
                    
                    if callback then
                        callback(currentKey)
                    end
                end
            end
        end)
        
        table.insert(Section.Elements, Keybind)
        return Keybind
    end
    
    Section.AddColorPicker = function(_, text, defaultColor, callback)
        local ColorPicker = Instance.new("Frame")
        ColorPicker.Size = UDim2.new(1, 0, 0, 40)
        ColorPicker.BackgroundTransparency = 1
        ColorPicker.ZIndex = 2
        ColorPicker.Parent = Section.Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextColor3 = Theme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.ZIndex = 3
        Label.Parent = ColorPicker
        
        local ColorButton = Instance.new("TextButton")
        ColorButton.Size = UDim2.new(0, 25, 0, 25)
        ColorButton.Position = UDim2.new(1, -30, 0.5, -12.5)
        ColorButton.Text = ""
        ColorButton.BackgroundColor3 = defaultColor or Theme.Accent
        ColorButton.AutoButtonColor = false
        ColorButton.ZIndex = 3
        ColorButton.Parent = ColorPicker
        
        CreateRoundedFrame(ColorButton, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 6)
        CreateShadow(ColorButton, 0.5, 5)
        
        ColorButton.MouseButton1Click:Connect(function()
            if callback then
                callback(ColorButton.BackgroundColor3)
            end
        end)
        
        table.insert(Section.Elements, ColorPicker)
        return ColorPicker
    end
    
    return Section
end

-- Notification system
function Velto:Notify(title, message, duration, notiType)
    duration = duration or 5
    notiType = notiType or "Info"
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 300, 0, 0)
    Notification.Position = UDim2.new(1, -320, 1, -80)
    Notification.BackgroundColor3 = Theme.Tertiary
    Notification.ClipsDescendants = true
    Notification.ZIndex = 10
    Notification.Parent = self.UI
    
    CreateRoundedFrame(Notification, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 8)
    CreateShadow(Notification, 0.8, 15)
    CreateGradient(Notification, "Secondary")
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.ZIndex = 11
    Title.Parent = Notification
    
    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(1, -20, 0, 40)
    Message.Position = UDim2.new(0, 10, 0, 35)
    Message.Text = message
    Message.Font = Enum.Font.Gotham
    Message.TextSize = 14
    Message.TextColor3 = Theme.TextDim
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextWrapped = true
    Message.BackgroundTransparency = 1
    Message.ZIndex = 11
    Message.Parent = Notification
    
    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 20, 0, 20)
    Icon.Position = UDim2.new(1, -30, 0, 10)
    Icon.BackgroundTransparency = 1
    Icon.ZIndex = 11
    Icon.Parent = Notification
    
    -- Set icon based on notification type
    if notiType == "Success" then
        Icon.Image = "rbxassetid://6031094678"
        Icon.ImageColor3 = Theme.Success
    elseif notiType == "Warning" then
        Icon.Image = "rbxassetid://6031094667"
        Icon.ImageColor3 = Theme.Warning
    elseif notiType == "Error" then
        Icon.Image = "rbxassetid://6031094652"
        Icon.ImageColor3 = Theme.Error
    else
        Icon.Image = "rbxassetid://6031094643"
        Icon.ImageColor3 = Theme.Accent
    end
    
    -- Animate in
    TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 80)
    }):Play()
    
    -- Auto remove after duration
    task.spawn(function()
        wait(duration)
        
        -- Animate out
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 300, 0, 0)
        }):Play()
        
        wait(0.3)
        Notification:Destroy()
    end)
    
    return Notification
end

-- Watermark system
function Velto:CreateWatermark(text)
    local Watermark = Instance.new("Frame")
    Watermark.Size = UDim2.new(0, 200, 0, 30)
    Watermark.Position = UDim2.new(0, 10, 0, 10)
    Watermark.BackgroundColor3 = Theme.Tertiary
    Watermark.BackgroundTransparency = 0.7
    Watermark.ZIndex = 1
    Watermark.Parent = self.UI
    
    CreateRoundedFrame(Watermark, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 6)
    CreateGradient(Watermark, "Secondary", 0, 0.7)
    
    local WatermarkText = Instance.new("TextLabel")
    WatermarkText.Size = UDim2.new(1, -10, 1, 0)
    WatermarkText.Position = UDim2.new(0, 5, 0, 0)
    WatermarkText.Text = text
    WatermarkText.Font = Enum.Font.Gotham
    WatermarkText.TextSize = 12
    WatermarkText.TextColor3 = Theme.TextDim
    WatermarkText.TextXAlignment = Enum.TextXAlignment.Left
    WatermarkText.BackgroundTransparency = 1
    WatermarkText.ZIndex = 2
    WatermarkText.Parent = Watermark
    
    -- Make watermark draggable
    local Dragging, DragInput, DragStart, StartPosition
    
    Watermark.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPosition = Watermark.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    Watermark.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            Watermark.Position = UDim2.new(
                StartPosition.X.Scale, 
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale, 
                StartPosition.Y.Offset + Delta.Y
            )
        end
    end)
    
    return Watermark
end

-- Theme system
function Velto:SetTheme(themeName)
    -- This would change the entire UI theme
    -- Implementation would go here
end

-- Main module return
local VeltoUI = {}

function VeltoUI.Init()
    -- Optional initialization function
    print("Velto UI Ultimate Premium Edition Initialized")
end

function VeltoUI.CreateWindow(title, size, accentColor)
    return Velto:CreateWindow(title, size, accentColor)
end

return VeltoUI
