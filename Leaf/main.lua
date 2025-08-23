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
    Text = Color3.fromRGB(230, 255, 255),
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
    Success = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 200, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 230, 140))
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
    corner.CornerRadius = UDim.new(0, radius or 12)
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
    icon.Size = size or UDim2.new(0, 30, 0, 30)
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
function Velto:CreateWindow(title, size, accentColor, tabs)
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
    Overlay.BackgroundColor3 = Theme.Dark
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
    
    -- Round the actual outer container corners so the very edge is soft
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 22)
    MainCorner.Parent = MainContainer

    CreateRoundedFrame(MainContainer, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 18)
    CreateShadow(MainContainer, 0.8, 20)
    CreateGradient(MainContainer, "Main")
    CreateStroke(MainContainer, Color3.fromRGB(255,255,255), 1, 0.92)
    
    -- Navigation sidebar
    local NavBar = Instance.new("Frame")
    NavBar.Size = UDim2.new(0, 180, 1, 0)
    NavBar.Position = UDim2.new(0, 0, 0, 0)
    NavBar.BackgroundColor3 = Theme.Secondary
    NavBar.BackgroundTransparency = 0.7
    NavBar.ClipsDescendants = true
    NavBar.ZIndex = 3
    NavBar.Parent = MainContainer
    local NavBarCorner = Instance.new("UICorner")
    NavBarCorner.CornerRadius = UDim.new(0, 22)
    NavBarCorner.Parent = NavBar
    
    CreateRoundedFrame(NavBar, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 18, 0, Theme.Secondary)
    CreateGradient(NavBar, "Secondary")
    CreateStroke(NavBar, Color3.fromRGB(255,255,255), 1, 0.94)
    
    -- Top-right PNG/Image placeholder on NavBar
    local NavIcon = Instance.new("ImageLabel")
    NavIcon.Name = "NavIcon"
    NavIcon.Size = UDim2.new(0, 90, 0, 90)
    NavIcon.AnchorPoint = Vector2.new(1, 0)
    NavIcon.Position = UDim2.new(1, -1, 0, 0)
    NavIcon.BackgroundTransparency = 1
    NavIcon.Image = "rbxassetid://73659725499742" -- TODO: replace with your PNG asset id
    NavIcon.ImageColor3 = Theme.Text
    NavIcon.ZIndex = 5
    NavIcon.Parent = NavBar
    
    -- Second icon placed directly left of the right icon (X axis)
    local NavIconLeft = Instance.new("ImageLabel")
    NavIconLeft.Name = "NavIconLeft"
    NavIconLeft.Size = NavIcon.Size
    NavIconLeft.AnchorPoint = Vector2.new(1, 0)
    do
        -- Align exactly left of the right icon using its -1px offset (no extra gap)
        local leftX = -1 - NavIcon.Size.X.Offset
        NavIconLeft.Position = UDim2.new(1, leftX, 0, 0)
    end
    NavIconLeft.BackgroundTransparency = 1
    NavIconLeft.Image = "rbxassetid://79100459650541"
    NavIconLeft.ImageColor3 = NavIcon.ImageColor3
    NavIconLeft.Rotation = -360
    NavIconLeft.ZIndex = 5
    NavIconLeft.Parent = NavBar
    
    -- Header with logo and title
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 4
    Header.Parent = NavBar
    
    -- Animated logo
    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 36, 0, 36)
    Logo.Image = "rbxassetid://84415711490874"
    Logo.Position = UDim2.new(0, 35, 0, 23)
    Logo.BackgroundColor3 = Theme.Primary
    Logo.BackgroundTransparency = 1
    Logo.ZIndex = 5
    Logo.Parent = Header
    
       
    
    -- Title text with glow effect
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 75, 0, 10)
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
    local TabContainerCorner = Instance.new("UICorner")
    TabContainerCorner.CornerRadius = UDim.new(0, 22)
    TabContainerCorner.Parent = TabContainer
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 5)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    TabPadding.Parent = TabContainer
    
    -- Content area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -190, 1, -20)
    ContentArea.Position = UDim2.new(0, 190, 0, 10)
    ContentArea.BackgroundColor3 = Theme.Primary
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 2
    ContentArea.Parent = MainContainer
    local ContentAreaCorner = Instance.new("UICorner")
    ContentAreaCorner.CornerRadius = UDim.new(0, 22)
    ContentAreaCorner.Parent = ContentArea
    
    -- Tab content container
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Position = UDim2.new(0, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ClipsDescendants = true
    TabContent.ZIndex = 2
    TabContent.Parent = ContentArea
    local TabContentCorner = Instance.new("UICorner")
    TabContentCorner.CornerRadius = UDim.new(0, 22)
    TabContentCorner.Parent = TabContent
    
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
    MinimizeBtn.Image = "rbxassetid://4991505231"
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
    
    -- Window dragging (smoothed)
    local Dragging, DragInput, DragStart, StartPosition
    local dragTween
    
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
            local target = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
            if dragTween then dragTween:Cancel() end
            dragTween = TweenService:Create(MainContainer, TweenInfo.new(0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = target
            })
            dragTween:Play()
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
    -- Ensure tabs table exists before any auto-creation
    if not self.Tabs then self.Tabs = {} end

    -- Optional: auto-create tabs passed to CreateWindow
    -- Accept formats: { {"Main", 6031265977}, {name="Settings", icon=6031280882} }
    if tabs and type(tabs) == "table" then
        for _, def in ipairs(tabs) do
            local name = (type(def) == "table" and (def.name or def[1])) or tostring(def)
            local icon = (type(def) == "table" and (def.icon or def[2])) or nil
            if name then
                self:CreateTab(name, icon)
            end
        end
    end
    
    return self
end

-- Tab Creation
function Velto:CreateTab(name, icon)
    local Tab = {}
    Tab.Name = name
    Tab.Buttons = {}
    Tab.Content = Instance.new("ScrollingFrame")
    Tab.Content.Size = UDim2.new(1, 0, 1, 0)
    Tab.Content.Position = UDim2.new(0, 0, 0.03, 12) -- start slightly below for slide-in animation (softer)
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
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.Text = ""
    TabButton.BackgroundColor3 = Theme.Tertiary
    TabButton.BackgroundTransparency = 0.7
    TabButton.AutoButtonColor = false
    TabButton.ZIndex = 3
    TabButton.Parent = self.TabContainer
    TabButton.LayoutOrder = #self.Tabs
    
    CreateRoundedFrame(TabButton, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 12)
    CreateGradient(TabButton, "Secondary")
    CreateStroke(TabButton, Color3.fromRGB(255,255,255), 1, 0.9)
    CreateRippleEffect(TabButton)
    
    -- Tab icon
    if icon then
        local TabIcon = CreateIcon(TabButton, icon, UDim2.new(0, 25, 0, 25), UDim2.new(0, 15, 0.5, -10))
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
    TabText.TextTruncate = Enum.TextTruncate.AtEnd
    TabText.BackgroundTransparency = 1
    TabText.ZIndex = 4
    TabText.Parent = TabButton
    
    -- Tab indicator (single per tab) using image asset
    local TabIndicator = Instance.new("ImageLabel")
    TabIndicator.Size = UDim2.new(0, 3, 0, 0)
    TabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
    TabIndicator.AnchorPoint = Vector2.new(0, 0.5)
    TabIndicator.BackgroundTransparency = 0.5
    TabIndicator.Image = "rbxassetid://88861960253549"
    TabIndicator.ImageTransparency = 0.2
    TabIndicator.ScaleType = Enum.ScaleType.Stretch
    TabIndicator.Visible = false
    TabIndicator.ZIndex = 5
    TabIndicator.Parent = TabButton
    
    -- Helper: tween all child transparencies to simulate soft blur/fade
    local function tweenContentTransparency(container, target, duration)
        -- Only fade visible content (text/images/strokes). Do NOT touch backgrounds to preserve colors.
        duration = duration or 0.35
        local tweens = {}
        for _, d in ipairs(container:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                table.insert(tweens, TweenService:Create(d, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = target}))
            elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
                table.insert(tweens, TweenService:Create(d, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageTransparency = target}))
            elseif d:IsA("UIStroke") then
                table.insert(tweens, TweenService:Create(d, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = target}))
            end
        end
        for _, t in ipairs(tweens) do t:Play() end
    end

    -- Tab activation function (used by click and initial select)
    local function ActivateTab()
        -- ignore if already current
        if self.CurrentTab == Tab then return end
        
        -- if a transition is already happening, instantly hide the previous to prevent ghosting
        if self.IsSwitching and self.CurrentTab and self.CurrentTab.Content then
            local prev = self.CurrentTab.Content
            prev.Visible = false
            prev.Position = UDim2.new(0, 0, 0.03, 12)
            tweenContentTransparency(prev, 0, 0.01)
        end
        self.IsSwitching = true
        local function showNewTab()
            -- Prepare and show new tab (start faded and slightly below)
            Tab.Content.Visible = true
            Tab.Content.Position = UDim2.new(0, 0, 0.03, 12)
            tweenContentTransparency(Tab.Content, 1, 0.01) -- set to fully faded
            TweenService:Create(Tab.Content, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            tweenContentTransparency(Tab.Content, 0, 0.3) -- fade in contents softly

            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
            
            TweenService:Create(TabText, TweenInfo.new(0.2), {
                TextColor3 = Theme.Text
            }):Play()
            
            -- Animate per-tab indicator: expand vertically with slight bounce
            TabIndicator.Visible = true
            TabIndicator.Size = UDim2.new(0, 3, 0, 0)
            TweenService:Create(TabIndicator, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 3, 0, 20)
            }):Play()
            
            self.CurrentTab = Tab
        end

        if self.CurrentTab then
            -- Animate current tab out (slide up slightly + fade), then hide BEFORE showing new
            local oldContent = self.CurrentTab.Content
            if oldContent.Visible then
                if self.IsSwitching and oldContent.Visible then
                    -- normal path: animate out then show new
                    tweenContentTransparency(oldContent, 1, 0.25)
                    local tw = TweenService:Create(oldContent, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                        Position = UDim2.new(0, 0, -0.03, -12)
                    })
                    tw:Play()
                    tw.Completed:Connect(function()
                        oldContent.Visible = false
                        oldContent.Position = UDim2.new(0, 0, 0.03, 12) -- reset
                        tweenContentTransparency(oldContent, 0, 0.01) -- reset
                        showNewTab()
                        self.IsSwitching = false
                    end)
                else
                    -- fallback: if something odd, hide immediately
                    oldContent.Visible = false
                    oldContent.Position = UDim2.new(0, 0, 0.03, 12)
                    tweenContentTransparency(oldContent, 0, 0.01)
                    showNewTab()
                    self.IsSwitching = false
                end
            else
                showNewTab()
                self.IsSwitching = false
            end

            TweenService:Create(self.CurrentTab.Button, TweenInfo.new(0.18), {
                BackgroundTransparency = 0.7
            }):Play()
            
            TweenService:Create(self.CurrentTab.Text, TweenInfo.new(0.18), {
                TextColor3 = Theme.TextDim
            }):Play()
            
            self.CurrentTab.Indicator.Visible = false
        else
            showNewTab()
            self.IsSwitching = false
        end
    end

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
    
    TabButton.MouseButton1Click:Connect(ActivateTab)
    
    -- Store tab references
    Tab.Button = TabButton
    Tab.Text = TabText
    Tab.Indicator = TabIndicator
    Tab.ContentFrame = Tab.Content
    
    table.insert(self.Tabs, Tab)
    
    -- Select first tab without firing RBXScriptSignal
    if #self.Tabs == 1 then
        ActivateTab()
    end
    
    return setmetatable(Tab, {__index = self})
end

-- Batch create tabs helper
function Velto:CreateTabs(tabDefs)
    if not self.Tabs then self.Tabs = {} end
    if not tabDefs or type(tabDefs) ~= "table" then return end
    for _, def in ipairs(tabDefs) do
        local name = (type(def) == "table" and (def.name or def[1])) or tostring(def)
        local icon = (type(def) == "table" and (def.icon or def[2])) or nil
        if name then
            self:CreateTab(name, icon)
        end
    end
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
    -- Make section elements denser ve ortalı hizalı
    ContentLayout.Padding = UDim.new(0, 6)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.Parent = Section.Content
    
    Section.Elements = {}
    
    -- Add element methods
    Section.AddButton = function(_, text, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 0, 0, 28) -- kompakt yükseklik
        Button.AutomaticSize = Enum.AutomaticSize.X -- metne göre genişlik
        Button.Text = text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextXAlignment = Enum.TextXAlignment.Center
        Button.TextTruncate = Enum.TextTruncate.AtEnd
        Button.BackgroundColor3 = Theme.Primary
        Button.AutoButtonColor = false
        Button.ZIndex = 3
        Button.Parent = Section.Content

        -- Subtle scale for hover/press without affecting layout too much
        local Scale = Instance.new("UIScale")
        Scale.Scale = 1
        Scale.Parent = Button
        
        -- İç boşluk: metin etrafında yatay padding
        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 12)
        Padding.PaddingRight = UDim.new(0, 12)
        Padding.Parent = Button

        -- Orantılı maksimum genişlik: satır genişliğinin %60'ı
        local SizeConstraint = Instance.new("UISizeConstraint")
        SizeConstraint.MinSize = Vector2.new(80, 28)
        SizeConstraint.MaxSize = Vector2.new(200, 28) -- başlangıç, sonra dinamik güncellenecek
        SizeConstraint.Parent = Button

        local function updateMax()
            local parentWidth = Button.Parent and Button.Parent.AbsoluteSize.X or 0
            if parentWidth > 0 then
                SizeConstraint.MaxSize = Vector2.new(math.floor(parentWidth * 0.5), 28)
            end
        end
        updateMax()
        if Button.Parent then
            Button.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateMax)
        end

        CreateRoundedFrame(Button, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 10)
        CreateShadow(Button, 0.35, 8)
        CreateRippleEffect(Button)
        
        -- Hover effects (slight lift and tint)
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.18), {
                BackgroundTransparency = 0.45
            }):Play()
            TweenService:Create(Scale, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Scale = 1.02
            }):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.18), {
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(Scale, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Scale = 1
            }):Play()
        end)
        
        -- Press feedback
        Button.MouseButton1Down:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.08), {
                BackgroundTransparency = 0.55
            }):Play()
            TweenService:Create(Scale, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Scale = 0.98
            }):Play()
        end)
        Button.MouseButton1Up:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.45
            }):Play()
            TweenService:Create(Scale, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Scale = 1.02
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
        Label.TextTruncate = Enum.TextTruncate.AtEnd
        Label.BackgroundTransparency = 1
        Label.ZIndex = 3
        Label.Parent = Toggle
        
        local ToggleButton = Instance.new("ImageButton")
        ToggleButton.Size = UDim2.new(0, 64, 0, 32)
        ToggleButton.Position = UDim2.new(1, -64, 0.5, -16)
        ToggleButton.Image = ""
        ToggleButton.BackgroundTransparency = 1
        ToggleButton.AutoButtonColor = false
        ToggleButton.ScaleType = Enum.ScaleType.Fit
        ToggleButton.ZIndex = 3
        ToggleButton.Parent = Toggle
        
        -- keep aspect of typical toggle ~2:1
        local AR = Instance.new("UIAspectRatioConstraint")
        AR.AspectRatio = 2
        AR.DominantAxis = Enum.DominantAxis.Width
        AR.Parent = ToggleButton
        
        local state = default or false
        -- two layers for realistic transition (crossfade)
        local OffImg = Instance.new("ImageLabel")
        OffImg.Size = UDim2.new(1, 0, 1, 0)
        OffImg.Position = UDim2.new(0, 0, 0, 0)
        OffImg.BackgroundTransparency = 1
        OffImg.Image = "rbxassetid://124898666728649"
        OffImg.ScaleType = Enum.ScaleType.Fit
        OffImg.ZIndex = 4
        OffImg.Parent = ToggleButton
        
        local OnImg = Instance.new("ImageLabel")
        OnImg.Size = UDim2.new(1, 0, 1, 0)
        OnImg.Position = UDim2.new(0, 0, 0, 0)
        OnImg.BackgroundTransparency = 1
        OnImg.Image = "rbxassetid://84415711490874"
        OnImg.ScaleType = Enum.ScaleType.Fit
        OnImg.ZIndex = 6
        OnImg.Parent = ToggleButton
        
        -- subtle neon glow when ON (slightly larger, tinted, and semi-transparent)
        local OnGlow = Instance.new("ImageLabel")
        OnGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        OnGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        OnGlow.Size = UDim2.new(1.06, 0, 1.06, 0)
        OnGlow.BackgroundTransparency = 1
        OnGlow.Image = OnImg.Image
        OnGlow.ScaleType = Enum.ScaleType.Fit
        OnGlow.ZIndex = 5
        OnGlow.ImageColor3 = Theme and Theme.Accent or Color3.fromRGB(0, 255, 200)
        OnGlow.ImageTransparency = 0.50 -- hidden by default, will drop when ON
        OnGlow.Parent = ToggleButton
        
        local function applyVisual()
            OnImg.ImageTransparency = state and 0 or 1
            OffImg.ImageTransparency = state and 1 or 0
            OnGlow.ImageTransparency = state and 0.9 or 1 -- show very faint glow only when ON
            -- keep only active layers visible to prevent stacking when switching tabs
            OnImg.Visible = state
            OffImg.Visible = not state
            OnGlow.Visible = state
        end
        applyVisual()
        
        -- Re-apply visuals when hierarchy or visibility changes (e.g., tab switch)
        ToggleButton:GetPropertyChangedSignal("Visible"):Connect(function()
            if ToggleButton.Visible then
                state = false -- default to OFF when shown
            end
            applyVisual()
        end)
        Toggle:GetPropertyChangedSignal("Visible"):Connect(function()
            if Toggle.Visible then
                state = false -- default to OFF when shown
            end
            applyVisual()
        end)
        Toggle.AncestryChanged:Connect(function()
            applyVisual()
        end)
        
        ToggleButton.MouseButton1Click:Connect(function()
            state = not state
            
            local toOn = state and 0 or 1
            local toOff = state and 1 or 0
            local toGlow = state and 0.9 or 1
            -- show all during crossfade, then re-hide the inactive layer
            OnImg.Visible = true
            OffImg.Visible = true
            OnGlow.Visible = true
            TweenService:Create(OnImg, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { ImageTransparency = toOn }):Play()
            TweenService:Create(OffImg, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { ImageTransparency = toOff }):Play()
            TweenService:Create(OnGlow, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { ImageTransparency = toGlow }):Play()
            if task and task.delay then
                task.delay(0.22, applyVisual)
            else
                delay(0.22, applyVisual)
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
        Label.TextTruncate = Enum.TextTruncate.AtEnd
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
        
        -- smoother corners and subtle stroke
        CreateRoundedFrame(Track, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 6)
        CreateGradient(Track, "Secondary")
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.Position = UDim2.new(0, 0, 0, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.ZIndex = 4
        Fill.Parent = Track
        
        CreateRoundedFrame(Fill, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 6)
        CreateGradient(Fill, "Success")
        
        -- Image-based knob (match toggle OnImg style)
        local knobImageId = "rbxassetid://84415711490874"
        local Knob = Instance.new("ImageButton")
        Knob.Size = UDim2.new(0, 18, 0, 18)
        Knob.Position = UDim2.new(0, -1, 0.5, -9)
        Knob.Image = knobImageId
        Knob.BackgroundTransparency = 1
        Knob.AutoButtonColor = false
        Knob.ScaleType = Enum.ScaleType.Fit
        Knob.ZIndex = 5
        Knob.Parent = Track
        local KnobScale = Instance.new("UIScale")
        KnobScale.Scale = 1
        KnobScale.Parent = Knob

        -- removed floating value bubble; right-side value label is sufficient

        local value = default or min
        local dragging = false
        local fillTween, knobTween
        
        local function updateValue(newValue, animate)
            value = math.clamp(newValue, min, max)
            Value.Text = tostring(math.floor(value))
            -- floating value bubble removed
            
            local percentage = (value - min) / (max - min)
            local targetSize = UDim2.new(percentage, 0, 1, 0)
            local targetPos = UDim2.new(percentage, -9, 0.5, -9)
            if fillTween then fillTween:Cancel() end
            if knobTween then knobTween:Cancel() end
            if animate ~= false then
                fillTween = TweenService:Create(Fill, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = targetSize })
                knobTween = TweenService:Create(Knob, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Position = targetPos })
                fillTween:Play()
                knobTween:Play()
            else
                Fill.Size = targetSize
                Knob.Position = targetPos
            end
            
            if callback then
                callback(value)
            end
        end
        
        Knob.MouseButton1Down:Connect(function()
            dragging = true
            
            TweenService:Create(Knob, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 20, 0, 20)
            }):Play()
            TweenService:Create(KnobScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Scale = 1.05
            }):Play()
            -- floating value bubble removed
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if dragging then
                    dragging = false
                    
                    TweenService:Create(Knob, TweenInfo.new(0.1), {
                        Size = UDim2.new(0, 18, 0, 18)
                    }):Play()
                    TweenService:Create(KnobScale, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                        Scale = 1
                    }):Play()
                    -- floating value bubble removed
                end
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = input.Position
                local relativeX = pos.X - Track.AbsolutePosition.X
                local percentage = math.clamp(relativeX / Track.AbsoluteSize.X, 0, 1)
                updateValue(min + (max - min) * percentage, true)
            end
        end)
        
        -- Allow clicking the track to jump value (use InputBegan on Frame)
        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = input.Position
                local relativeX = pos.X - Track.AbsolutePosition.X
                local percentage = math.clamp(relativeX / Track.AbsoluteSize.X, 0, 1)
                updateValue(min + (max - min) * percentage, true)
                dragging = true
            end
        end)
        
        updateValue(default or min, false)
        
        table.insert(Section.Elements, Slider)
        return Slider
    end
    
    Section.AddDropdown = function(_, text, options, default, callback)
        local Dropdown = Instance.new("Frame")
        Dropdown.Size = UDim2.new(1, 0, 0, 55)
        Dropdown.AutomaticSize = Enum.AutomaticSize.None
        Dropdown.BackgroundTransparency = 1
        Dropdown.ClipsDescendants = false
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
        Label.TextTruncate = Enum.TextTruncate.AtEnd
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
        Button.TextTruncate = Enum.TextTruncate.AtEnd
        Button.BackgroundColor3 = Theme.Tertiary
        Button.AutoButtonColor = false
        Button.ZIndex = 3
        Button.Parent = Dropdown
        
        CreateRoundedFrame(Button, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 6)
        
        local ButtonPadding = Instance.new("UIPadding")
        ButtonPadding.PaddingLeft = UDim.new(0, 8)
        ButtonPadding.PaddingRight = UDim.new(0, 28)
        ButtonPadding.Parent = Button
        
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
        Options.ScrollingDirection = Enum.ScrollingDirection.Y
        Options.ScrollingEnabled = true
        Options.CanvasSize = UDim2.new(0, 0, 0, 0)
        Options.AutomaticCanvasSize = Enum.AutomaticSize.None
        Options.Visible = false
        Options.ZIndex = 100
        Options.Parent = Dropdown
        
        CreateRoundedFrame(Options, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 6)
        CreateGradient(Options, "Secondary")
        
        -- Inner content container so gradient/background siblings don't affect layout
        local OptionsContent = Instance.new("Frame")
        OptionsContent.BackgroundTransparency = 1
        OptionsContent.Size = UDim2.new(1, -8, 0, 0)
        OptionsContent.Position = UDim2.new(0, 4, 0, 4)
        OptionsContent.AutomaticSize = Enum.AutomaticSize.Y
        OptionsContent.ZIndex = 101
        OptionsContent.Name = "OptionsContent"
        OptionsContent.Parent = Options
        
        local OptionsLayout = Instance.new("UIListLayout")
        OptionsLayout.Padding = UDim.new(0, 1)
        OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        OptionsLayout.Parent = OptionsContent
        
        -- keep canvas sized to content to avoid opening with blank space
        local function refreshOptionsCanvas()
            local contentY = OptionsLayout.AbsoluteContentSize.Y
            -- include the 8px vertical margins (top 4 + bottom 4)
            Options.CanvasSize = UDim2.new(0, 0, 0, contentY + 8)
            -- keep view anchored to top whenever open so first items are visible
            if open then
                Options.CanvasPosition = Vector2.new(0, 0)
            end
        end
        
        OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshOptionsCanvas)
        
        -- initial refresh (in case options already exist)
        task.defer(refreshOptionsCanvas)
        
        local open = false
        
        local function toggleDropdown()
            open = not open
            
            if open then
                -- compute exact content height and size viewport accordingly
                refreshOptionsCanvas()
                local contentH = OptionsLayout.AbsoluteContentSize.Y + 8 -- include top/bottom margins
                local targetH = math.min(contentH, 155)
                Options.Visible = true
                Options.Size = UDim2.new(1, 0, 0, targetH)
                -- disable scrolling if everything fits; enable if overflow
                local overflow = contentH > targetH
                Options.ScrollingEnabled = overflow
                Options.ScrollBarThickness = overflow and 3 or 0
                Options.CanvasPosition = Vector2.new(0, 0)
                -- ensure after children/layout finish, still at top
                task.delay(0.05, function()
                    if open then
                        Options.CanvasPosition = Vector2.new(0, 0)
                    end
                end)
                
                TweenService:Create(Arrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Rotation = 180
                }):Play()
                
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.2
                }):Play()
            else
                Options.Size = UDim2.new(1, 0, 0, 0)
                
                TweenService:Create(Arrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Rotation = 0
                }):Play()
                
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0
                }):Play()
                
                task.delay(0.05, function()
                    if not open then Options.Visible = false end
                end)
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
            OptionButton.ZIndex = 102
            OptionButton.Parent = OptionsContent
            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
            OptionButton.TextTruncate = Enum.TextTruncate.AtEnd
            
            local OBPad = Instance.new("UIPadding")
            OBPad.PaddingLeft = UDim.new(0, 8)
            OBPad.PaddingRight = UDim.new(0, 8)
            OBPad.Parent = OptionButton
            
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
        
        -- ensure canvas reflects populated items before first open
        refreshOptionsCanvas()
        Options.CanvasPosition = Vector2.new(0, 0)
        
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
        Label.TextTruncate = Enum.TextTruncate.AtEnd
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
        Label.TextTruncate = Enum.TextTruncate.AtEnd
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
        
        local BoxPadding = Instance.new("UIPadding")
        BoxPadding.PaddingLeft = UDim.new(0, 8)
        BoxPadding.PaddingRight = UDim.new(0, 8)
        BoxPadding.Parent = Box
        
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
        Label.TextTruncate = Enum.TextTruncate.AtEnd
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
        
        local KeyPad = Instance.new("UIPadding")
        KeyPad.PaddingLeft = UDim.new(0, 6)
        KeyPad.PaddingRight = UDim.new(0, 6)
        KeyPad.Parent = KeyButton
        
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