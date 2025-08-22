-- Velto UI Premium Implementation for Pet Simulator 99
local Velto = {}
Velto.__index = Velto

-- Services
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- THEME CONFIGURATION - Premium Dark with Neon Accents
local Theme = {
    Primary = Color3.fromRGB(15, 17, 23),          -- Main background
    Secondary = Color3.fromRGB(25, 28, 36),        -- Panels/cards
    Tertiary = Color3.fromRGB(35, 40, 50),         -- Rows/controls
    Accent = Color3.fromRGB(0, 180, 255),          -- Primary accent (cyan)
    AccentSecondary = Color3.fromRGB(150, 70, 255),-- Secondary accent (purple)
    Text = Color3.fromRGB(240, 245, 250),
    TextDim = Color3.fromRGB(160, 170, 190),
    Disabled = Color3.fromRGB(100, 110, 130),
    Shadow = Color3.fromRGB(5, 5, 10),
    Success = Color3.fromRGB(70, 230, 160),
    Warning = Color3.fromRGB(255, 200, 100),
    Error = Color3.fromRGB(255, 100, 100),
    Glow = Color3.fromRGB(0, 180, 255)             -- Glow effect
}

-- Particle effects for premium look
local function CreateParticleEffect(parent)
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Color = ColorSequence.new(Theme.Accent)
    particleEmitter.Size = NumberSequence.new(0.5)
    particleEmitter.Transparency = NumberSequence.new(0.8)
    particleEmitter.Lifetime = NumberRange.new(1, 2)
    particleEmitter.Rate = 5
    particleEmitter.Speed = NumberRange.new(2)
    particleEmitter.VelocitySpread = 180
    particleEmitter.Parent = parent
    return particleEmitter
end

-- Premium glow effect
local function CreateGlowEffect(parent, intensity)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Image = "rbxassetid://5028857084"  -- Circular glow
    glow.ImageColor3 = Theme.Glow
    glow.ImageTransparency = 0.8
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24, 24, 24, 24)
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.ZIndex = 0
    glow.Parent = parent
    
    -- Animate the glow
    local pulseIn = TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        ImageTransparency = 0.7,
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15)
    })
    
    local pulseOut = TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        ImageTransparency = 0.8,
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10)
    })
    
    -- Create looping animation
    pulseIn.Completed:Connect(function()
        pulseOut:Play()
    end)
    
    pulseOut.Completed:Connect(function()
        pulseIn:Play()
    end)
    
    pulseIn:Play()
    
    return glow
end

-- EXPLOIT FILE I/O (feature-detected)
local hasFS = (typeof(isfile) == "function") and (typeof(readfile) == "function") and (typeof(writefile) == "function")

local function TryRead(path)
    if not hasFS then return nil end
    local ok, data = pcall(readfile, path)
    if ok and data then return data end
    return nil
end

local function TryWrite(path, contents)
    if not hasFS then return false end
    pcall(writefile, path, contents)
    return true
end

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
    shadow.ZIndex = -1
    shadow.Parent = parent
    return shadow
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, thickness, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Theme.Accent
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

-- Premium gradient function
local function CreateGradient(parent, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = rotation or 90
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Primary),
        ColorSequenceKeypoint.new(1, Theme.Secondary)
    }
    gradient.Parent = parent
    return gradient
end

-- MAIN WINDOW CREATION
function Velto:CreateWindow(title, size)
    local self = setmetatable({}, Velto)
    self.Tabs = {}
    self.CurrentTab = nil
    self.Elements = {}
    self.ConfigPath = "Velto_"..(title:gsub("%s+",""))..".json"
    self.State = { Position = {0.5,-275,0.5,-200}, Minimized = false, ToggleKey = "RightShift", Size = {0,550,0,400} }
    self.Animations = {}
    
    -- Load saved configuration
    do
        local raw = TryRead(self.ConfigPath)
        if raw then
            local ok, dec = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok and type(dec) == "table" then
                for k,v in pairs(dec) do self.State[k] = v end
            end
        end
    end
    
    -- Create UI container with premium effects
    local UI = Instance.new("ScreenGui")
    UI.Name = "VeltoUI_"..title:gsub("%s+", "")
    UI.ResetOnSpawn = false
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    UI.Parent = CoreGui

    -- Main frame with premium styling
    local Frame = Instance.new("Frame")
    local defaultSize = size or UDim2.new(self.State.Size[1], self.State.Size[2], self.State.Size[3], self.State.Size[4])
    Frame.Size = defaultSize
    Frame.Position = UDim2.new(self.State.Position[1], self.State.Position[2], self.State.Position[3], self.State.Position[4])
    Frame.BackgroundColor3 = Theme.Primary
    Frame.Active = true
    Frame.Draggable = false -- header-only dragging implemented below
    Frame.Name = "Main"
    Frame.Parent = UI

    CreateShadow(Frame)
    CreateCorner(Frame, 10)
    CreateStroke(Frame, 2, Theme.Accent, 0.5)
    CreateGradient(Frame)
    CreateGlowEffect(Frame)

    -- Title bar with premium styling
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 36)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Theme.Secondary
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Frame
    CreateCorner(TitleBar, 10, 10, 0, 0)
    CreateStroke(TitleBar, 1, Theme.Accent, 0.3)

    -- Header-only dragging with smooth animation
    do
        local dragging = false
        local dragStart, startPos
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Frame.Position
                
                -- Animate on drag start
                TweenService:Create(Frame, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(20, 22, 28)
                }):Play()
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                self.State.Position = {Frame.Position.X.Scale, Frame.Position.X.Offset, Frame.Position.Y.Scale, Frame.Position.Y.Offset}
                TryWrite(self.ConfigPath, HttpService:JSONEncode(self.State))
                
                -- Animate on drag end
                TweenService:Create(Frame, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.Primary
                }):Play()
            end
        end)
    end

    -- Premium title label with glow
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = TitleBar
    
    -- Add text glow effect
    local textGlow = Instance.new("TextLabel")
    textGlow.Size = TitleLabel.Size
    textGlow.Position = TitleLabel.Position
    textGlow.Text = title
    textGlow.TextColor3 = Theme.Accent
    textGlow.Font = Enum.Font.GothamBold
    textGlow.TextSize = 16
    textGlow.TextXAlignment = Enum.TextXAlignment.Left
    textGlow.BackgroundTransparency = 1
    textGlow.TextTransparency = 0.8
    textGlow.ZIndex = TitleLabel.ZIndex - 1
    textGlow.Parent = TitleBar

    -- Close button with hover animation
    local CloseButton = Instance.new("ImageButton")
    CloseButton.Size = UDim2.new(0, 28, 0, 28)
    CloseButton.Position = UDim2.new(1, -34, 0.5, -14)
    CloseButton.Image = "rbxassetid://3926305904"
    CloseButton.ImageRectOffset = Vector2.new(924, 724)
    CloseButton.ImageRectSize = Vector2.new(36, 36)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Parent = TitleBar
    
    -- Hover effects for close button
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            ImageColor3 = Color3.fromRGB(255, 80, 80),
            Rotation = 90
        }):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            Rotation = 0
        }):Play()
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        -- Animate out before closing
        local tween = TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 1.5, 0),
            Rotation = math.rad(10)
        })
        tween:Play()
        tween.Completed:Connect(function()
            UI:Destroy()
        end)
    end)

    -- Minimize button with animation
    local MinButton = Instance.new("ImageButton")
    MinButton.Size = UDim2.new(0, 28, 0, 28)
    MinButton.Position = UDim2.new(1, -68, 0.5, -14)
    MinButton.Image = "rbxassetid://3926305904"
    MinButton.ImageRectOffset = Vector2.new(964, 324)
    MinButton.ImageRectSize = Vector2.new(36, 36)
    MinButton.BackgroundTransparency = 1
    MinButton.Parent = TitleBar
    
    -- Hover effects for minimize button
    MinButton.MouseEnter:Connect(function()
        TweenService:Create(MinButton, TweenInfo.new(0.2), {
            ImageColor3 = Theme.Accent
        }):Play()
    end)
    
    MinButton.MouseLeave:Connect(function()
        TweenService:Create(MinButton, TweenInfo.new(0.2), {
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)

    -- Tab container (vertical) with premium styling
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 150, 1, -90)
    TabContainer.Position = UDim2.new(0, 10, 0, 45)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Frame
    
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Vertical
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 8)
    TabList.Parent = TabContainer

    -- Content container with premium styling
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -180, 1, -90)
    ContentContainer.Position = UDim2.new(0, 170, 0, 45)
    ContentContainer.BackgroundColor3 = Theme.Secondary
    ContentContainer.Name = "ContentContainer"
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = Frame
    CreateCorner(ContentContainer, 10)
    CreateStroke(ContentContainer, 1, Theme.Accent, 0.3)

    -- Scroll frame with custom scrollbar
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollFrame.Position = UDim2.new(0, 0, 0, 0)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.ScrollBarImageColor3 = Theme.Accent
    ScrollFrame.ScrollBarImageTransparency = 0.7
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Parent = ContentContainer

    -- padding inside content
    local ContentPad = Instance.new("UIPadding")
    ContentPad.PaddingLeft = UDim.new(0, 15)
    ContentPad.PaddingRight = UDim.new(0, 15)
    ContentPad.PaddingTop = UDim.new(0, 15)
    ContentPad.PaddingBottom = UDim.new(0, 15)
    ContentPad.Parent = ContentContainer

    self.UI = UI
    self.Main = Frame
    self.ScrollFrame = ScrollFrame
    self.TabContainer = TabContainer
    self.ContentContainer = ContentContainer

    -- wire minimize after containers exist
    local minimized = self.State.Minimized or false
    MinButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            -- Animate minimize
            TweenService:Create(ContentContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            
            TweenService:Create(TabContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            
            wait(0.3)
            ContentContainer.Visible = false
            TabContainer.Visible = false
        else
            -- Animate restore
            ContentContainer.Visible = true
            TabContainer.Visible = true
            
            TweenService:Create(ContentContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -180, 1, -90),
                Position = UDim2.new(0, 170, 0, 45)
            }):Play()
            
            TweenService:Create(TabContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 150, 1, -90),
                Position = UDim2.new(0, 10, 0, 45)
            }):Play()
        end
        
        self.State.Minimized = minimized
        TryWrite(self.ConfigPath, HttpService:JSONEncode(self.State))
    end)
    
    -- apply persisted minimized state
    if minimized then
        ContentContainer.Visible = false
        TabContainer.Visible = false
        ContentContainer.Size = UDim2.new(0, 0, 0, 0)
        ContentContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
        TabContainer.Size = UDim2.new(0, 0, 0, 0)
        TabContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    end

    -- Global toggle key (hide/show entire UI) with animation
    do
        local keyName = self.State.ToggleKey or "RightShift"
        local function toKeyCode(name)
            for _, kc in pairs(Enum.KeyCode:GetEnumItems()) do if kc.Name == name then return kc end end
            return Enum.KeyCode.RightShift
        end
        local toggleKey = toKeyCode(keyName)
        self.ToggleKey = toggleKey
        
        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == self.ToggleKey then
                if UI.Enabled then
                    -- Animate out
                    local tween = TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        Position = UDim2.new(0.5, 0, 1.5, 0),
                        Rotation = math.rad(10)
                    })
                    tween:Play()
                    tween.Completed:Connect(function()
                        UI.Enabled = false
                    end)
                else
                    -- Animate in
                    UI.Enabled = true
                    Frame.Position = UDim2.new(0.5, 0, 1.5, 0)
                    Frame.Rotation = math.rad(10)
                    
                    local tween = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(self.State.Position[1], self.State.Position[2], self.State.Position[3], self.State.Position[4]),
                        Rotation = 0
                    })
                    tween:Play()
                end
            end
        end)
    end

    -- Resize handle (bottom-right) with premium styling
    local ResizeGrip = Instance.new("Frame")
    ResizeGrip.Size = UDim2.new(0, 20, 0, 20)
    ResizeGrip.Position = UDim2.new(1, -20, 1, -20)
    ResizeGrip.BackgroundColor3 = Theme.Accent
    ResizeGrip.BackgroundTransparency = 0.7
    ResizeGrip.Active = true
    ResizeGrip.Name = "ResizeGrip"
    ResizeGrip.Parent = Frame
    CreateCorner(ResizeGrip, 4)
    
    local gripIcon = Instance.new("ImageLabel")
    gripIcon.Size = UDim2.new(0, 12, 0, 12)
    gripIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
    gripIcon.Image = "rbxassetid://3926305904"
    gripIcon.ImageRectOffset = Vector2.new(964, 444)
    gripIcon.ImageRectSize = Vector2.new(36, 36)
    gripIcon.BackgroundTransparency = 1
    gripIcon.Parent = ResizeGrip
    
    local resizing = false
    local startSize, startMouse
    ResizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startSize = Frame.AbsoluteSize
            startMouse = input.Position
            
            TweenService:Create(ResizeGrip, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.3
            }):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            local newW = math.clamp(startSize.X + delta.X, 500, 1000)
            local newH = math.clamp(startSize.Y + delta.Y, 350, 800)
            Frame.Size = UDim2.new(0, newW, 0, newH)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if resizing then
                resizing = false
                self.State.Size = {Frame.Size.X.Scale, Frame.Size.X.Offset, Frame.Size.Y.Scale, Frame.Size.Y.Offset}
                TryWrite(self.ConfigPath, HttpService:JSONEncode(self.State))
                
                TweenService:Create(ResizeGrip, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.7
                }):Play()
            end
        end
    end)

    -- Notifications container with premium styling
    local NotiHolder = Instance.new("Frame")
    NotiHolder.Name = "Notifications"
    NotiHolder.AnchorPoint = Vector2.new(1, 1)
    NotiHolder.Size = UDim2.new(0, 300, 1, -20)
    NotiHolder.Position = UDim2.new(1, -10, 1, -10)
    NotiHolder.BackgroundTransparency = 1
    NotiHolder.Parent = UI
    
    local NotiList = Instance.new("UIListLayout")
    NotiList.FillDirection = Enum.FillDirection.Vertical
    NotiList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotiList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotiList.Padding = UDim.new(0, 10)
    NotiList.Parent = NotiHolder

    -- Animate window entrance
    Frame.Position = UDim2.new(0.5, 0, -0.5, 0)
    Frame.Rotation = math.rad(-5)
    
    local entranceTween = TweenService:Create(Frame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(self.State.Position[1], self.State.Position[2], self.State.Position[3], self.State.Position[4]),
        Rotation = 0
    })
    entranceTween:Play()

    return self
end

-- TAB CREATION with premium styling
function Velto:CreateTab(tabName, iconAssetId)
    local Tab = {}
    Tab.Elements = {}
    Tab.Index = #self.Tabs + 1
    
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -10, 0, 40)
    TabButton.Position = UDim2.new(0, 5, 0, 0)
    TabButton.Text = (iconAssetId and "   " or "") .. tabName
    TabButton.BackgroundColor3 = Theme.Tertiary
    TabButton.TextColor3 = Theme.TextDim
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 14
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = self.TabContainer
    TabButton.LayoutOrder = Tab.Index

    CreateCorner(TabButton, 6)
    CreateStroke(TabButton, 1, Theme.Accent, 0.7)

    -- Optional icon with premium styling
    if iconAssetId then
        local Icon = Instance.new("ImageLabel")
        Icon.BackgroundTransparency = 1
        Icon.Size = UDim2.new(0, 22, 0, 22)
        Icon.Position = UDim2.new(0, 12, 0.5, -11)
        Icon.Image = iconAssetId
        Icon.ImageColor3 = Theme.TextDim
        Icon.Parent = TabButton
        
        Tab.Icon = Icon
    end

    -- Badge (hidden by default) with premium styling
    local Badge = Instance.new("Frame")
    Badge.BackgroundColor3 = Theme.Accent
    Badge.Size = UDim2.new(0, 8, 0, 8)
    Badge.Position = UDim2.new(1, -14, 0.5, -4)
    Badge.Visible = false
    Badge.Parent = TabButton
    CreateCorner(Badge, 4)
    CreateGlowEffect(Badge)

    -- Highlight with animation
    local Highlight = Instance.new("Frame")
    Highlight.Size = UDim2.new(0, 4, 0.7, 0)
    Highlight.Position = UDim2.new(0, -2, 0.15, 0)
    Highlight.BackgroundColor3 = Theme.Accent
    Highlight.Visible = (#self.Tabs == 0)
    Highlight.Parent = TabButton
    CreateCorner(Highlight, 2)
    CreateGlowEffect(Highlight)

    -- Content frame
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.Position = UDim2.new(0, 0, 0, 0)
    Content.BackgroundTransparency = 1
    Content.Visible = (#self.Tabs == 0)
    Content.Parent = self.ScrollFrame

    -- Tab click handler with animation
    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Content.Visible = false
            t.Highlight.Visible = false
            TweenService:Create(t.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Tertiary,
                TextColor3 = Theme.TextDim
            }):Play()
            
            if t.Icon then
                TweenService:Create(t.Icon, TweenInfo.new(0.2), {
                    ImageColor3 = Theme.TextDim
                }):Play()
            end
        end
        
        Content.Visible = true
        Highlight.Visible = true
        
        TweenService:Create(TabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 45, 55),
            TextColor3 = Theme.Text
        }):Play()
        
        if Tab.Icon then
            TweenService:Create(Tab.Icon, TweenInfo.new(0.2), {
                ImageColor3 = Theme.Accent
            }):Play()
        end
        
        self.CurrentTab = Tab
        
        -- Animate content entrance
        for _, element in pairs(Content:GetChildren()) do
            if element:IsA("Frame") then
                element.Position = UDim2.new(0, 20, element.Position.Y.Scale, element.Position.Y.Offset)
                element.BackgroundTransparency = 1
                
                TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, element.Position.Y.Scale, element.Position.Y.Offset),
                    BackgroundTransparency = 0
                }):Play()
            end
        end
    end)

    Tab.Button = TabButton
    Tab.Highlight = Highlight
    Tab.Content = Content
    Tab.Elements = {}
    Tab.Badge = Badge

    -- Allow building controls onto this tab directly using Velto methods
    Tab.AddButton = self.AddButton
    Tab.AddToggle = self.AddToggle
    Tab.AddLabel = self.AddLabel
    Tab.AddSlider = self.AddSlider
    Tab.AddDropdown = self.AddDropdown
    Tab.AddSection = self.AddSection
    Tab.AddTextbox = self.AddTextbox
    Tab.AddKeybind = self.AddKeybind
    Tab.AddColorPicker = self.AddColorPicker

    table.insert(self.Tabs, Tab)

    -- If this is the first tab, reflect active visual state
    if #self.Tabs == 1 then
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
        TabButton.TextColor3 = Theme.Text
        
        if Tab.Icon then
            Tab.Icon.ImageColor3 = Theme.Accent
        end
    end
    
    return setmetatable(Tab, {__index = self})
end

-- SECTION CARD with premium styling
function Velto:AddSection(title)
    local container = self.Content
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -6, 0, 0)
    Section.Position = UDim2.new(0, 3, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Theme.Tertiary
    Section.BackgroundTransparency = 0.5
    Section.Parent = container
    CreateCorner(Section, 8)
    CreateStroke(Section, 1, Theme.Accent, 0.3)
    CreateGlowEffect(Section, 0.8)

    -- Header (collapsible) with premium styling
    local Header = Instance.new("TextButton")
    Header.BackgroundTransparency = 1
    Header.Text = (title and #title > 0) and ("  "..title) or "  Section"
    Header.TextColor3 = Theme.Text
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 15
    Header.Size = UDim2.new(1, -8, 0, 28)
    Header.Position = UDim2.new(0, 4, 0, 6)
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Section

    local Chevron = Instance.new("ImageLabel")
    Chevron.BackgroundTransparency = 1
    Chevron.Size = UDim2.new(0, 16, 0, 16)
    Chevron.Position = UDim2.new(0, -2, 0.5, -8)
    Chevron.Image = "rbxassetid://3926305904"
    Chevron.ImageRectOffset = Vector2.new(964, 204)
    Chevron.ImageRectSize = Vector2.new(36, 36)
    Chevron.ImageColor3 = Theme.Accent
    Chevron.Parent = Header

    local Inner = Instance.new("Frame")
    Inner.Name = "Inner"
    Inner.Size = UDim2.new(1, -16, 0, 0)
    Inner.Position = UDim2.new(0, 8, 0, 34)
    Inner.AutomaticSize = Enum.AutomaticSize.Y
    Inner.BackgroundTransparency = 1
    Inner.Parent = Section

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = Inner

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = Inner

    local collapsed = false
    Header.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        Inner.Visible = not collapsed
        
        if collapsed then
            TweenService:Create(Chevron, TweenInfo.new(0.2), {
                Rotation = -90
            }):Play()
            
            TweenService:Create(Section, TweenInfo.new(0.2), {
                Size = UDim2.new(1, -6, 0, 34)
            }):Play()
        else
            TweenService:Create(Chevron, TweenInfo.new(0.2), {
                Rotation = 0
            }):Play()
            
            TweenService:Create(Section, TweenInfo.new(0.2), {
                Size = UDim2.new(1, -6, 0, 0)
            }):Play()
        end
    end)

    local sec = { Content = Inner, Elements = {}, __SectionFrame = Section }
    sec.AddButton = self.AddButton
    sec.AddToggle = self.AddToggle
    sec.AddLabel = self.AddLabel
    sec.AddSlider = self.AddSlider
    sec.AddDropdown = self.AddDropdown
    sec.AddTextbox = self.AddTextbox
    sec.AddKeybind = self.AddKeybind
    sec.AddColorPicker = self.AddColorPicker
    return setmetatable(sec, {__index = self})
end

-- BUTTON COMPONENT with premium styling
function Velto:AddButton(name, callback)
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local Button = Instance.new("TextButton")
    
    if inSection then
        Button.Size = UDim2.new(1, 0, 0, 36)
        Button.Position = UDim2.new(0, 0, 0, 0)
    else
        Button.Size = UDim2.new(1, -20, 0, 34)
        Button.Position = UDim2.new(0, 10, 0, #self.Elements * 44)
    end
    
    Button.Text = name
    Button.TextColor3 = Theme.Text
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.BackgroundColor3 = Theme.Accent
    Button.Parent = parent

    CreateCorner(Button, 6)
    CreateStroke(Button, 1, Theme.Secondary, 0.5)
    CreateGlowEffect(Button, 0.7)

    Button.MouseButton1Click:Connect(function()
        -- Animate click
        TweenService:Create(Button, TweenInfo.new(0.1), {
            Size = UDim2.new(Button.Size.X.Scale, Button.Size.X.Offset - 4, 0, Button.Size.Y.Offset - 4),
            Position = UDim2.new(Button.Position.X.Scale, Button.Position.X.Offset + 2, Button.Position.Y.Scale, Button.Position.Y.Offset + 2)
        }):Play()
        
        wait(0.1)
        
        TweenService:Create(Button, TweenInfo.new(0.1), {
            Size = UDim2.new(Button.Size.X.Scale, Button.Size.X.Offset + 4, 0, Button.Size.Y.Offset + 4),
            Position = UDim2.new(Button.Position.X.Scale, Button.Position.X.Offset - 2, Button.Position.Y.Scale, Button.Position.Y.Offset - 2)
        }):Play()
        
        if callback then 
            task.spawn(function()
                pcall(callback) 
            end)
        end
    end)

    -- Hover effects with animation
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 200, 255),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Accent,
            TextColor3 = Theme.Text
        }):Play()
    end)

    table.insert(self.Elements, Button)
    return Button
end

-- TOGGLE COMPONENT with premium styling
function Velto:AddToggle(name, defaultValue, callback)
    local state = defaultValue or false
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local ToggleFrame = Instance.new("Frame")
    
    if inSection then
        ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
        ToggleFrame.BackgroundColor3 = Theme.Tertiary
        ToggleFrame.BackgroundTransparency = 0.5
    else
        ToggleFrame.Size = UDim2.new(1, -20, 0, 34)
        ToggleFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 44)
        ToggleFrame.BackgroundTransparency = 1
    end
    
    ToggleFrame.Parent = parent
    
    if inSection then
        CreateCorner(ToggleFrame, 6)
        CreateStroke(ToggleFrame, 1, Color3.fromRGB(50, 56, 66), 0.5)
    end
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.Text = name
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 14
    ToggleLabel.TextColor3 = Theme.Text
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 50, 0, 24)
    ToggleButton.Position = UDim2.new(1, -60, 0.5, -12)
    ToggleButton.Text = ""
    ToggleButton.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 64, 74)
    ToggleButton.Parent = ToggleFrame
    
    CreateCorner(ToggleButton, 12)
    CreateStroke(ToggleButton, 1, Theme.Secondary, 0.5)
    CreateGlowEffect(ToggleButton, state and 0.7 or 0)
    
    local ToggleDot = Instance.new("Frame")
    ToggleDot.Size = UDim2.new(0, 18, 0, 18)
    ToggleDot.Position = UDim2.new(0, state and 28 or 2, 0.5, -9)
    ToggleDot.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    ToggleDot.Parent = ToggleButton
    
    CreateCorner(ToggleDot, 12)
    
    -- Click handler with animation
    ToggleButton.MouseButton1Click:Connect(function()
        state = not state
        
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 64, 74)
        }):Play()
        
        TweenService:Create(ToggleDot, TweenInfo.new(0.2), {
            Position = UDim2.new(0, state and 28 or 2, 0.5, -9)
        }):Play()
        
        -- Toggle glow effect
        if state then
            CreateGlowEffect(ToggleButton, 0.7)
        else
            if ToggleButton:FindFirstChild("Glow") then
                ToggleButton.Glow:Destroy()
            end
        end
        
        if callback then 
            task.spawn(function()
                pcall(callback, state) 
            end)
        end
    end)

    table.insert(self.Elements, ToggleFrame)
    return ToggleFrame
end

-- LABEL COMPONENT with premium styling
function Velto:AddLabel(text)
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local Label = Instance.new("TextLabel")
    
    if inSection then
        Label.Size = UDim2.new(1, 0, 0, 24)
        Label.Position = UDim2.new(0, 0, 0, 0)
    else
        Label.Size = UDim2.new(1, -20, 0, 24)
        Label.Position = UDim2.new(0, 10, 0, #self.Elements * 44)
    end
    
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = parent
    
    table.insert(self.Elements, Label)
    return Label
end

-- SLIDER COMPONENT with premium styling
function Velto:AddSlider(name, minValue, maxValue, defaultValue, callback)
    local value = defaultValue or minValue
    local sliding = false
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local SliderFrame = Instance.new("Frame")
    
    if inSection then
        SliderFrame.Size = UDim2.new(1, 0, 0, 64)
        SliderFrame.BackgroundTransparency = 1
    else
        SliderFrame.Size = UDim2.new(1, -20, 0, 64)
        SliderFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 44)
        SliderFrame.BackgroundTransparency = 1
    end
    
    SliderFrame.Parent = parent
    
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
    SliderTrack.Size = UDim2.new(1, 0, 0, 6)
    SliderTrack.Position = UDim2.new(0, 0, 0, 30)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 64, 74)
    SliderTrack.Parent = SliderFrame
    
    CreateCorner(SliderTrack, 3)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    SliderFill.BackgroundColor3 = Theme.Accent
    SliderFill.Parent = SliderTrack
    
    CreateCorner(SliderFill, 3)
    CreateGlowEffect(SliderFill, 0.5)
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 18, 0, 18)
    SliderButton.Position = UDim2.new(0, -9, 0.5, -9)
    SliderButton.Text = ""
    SliderButton.BackgroundColor3 = Theme.Text
    SliderButton.Parent = SliderTrack
    
    CreateCorner(SliderButton, 9)
    CreateStroke(SliderButton, 1, Theme.Accent)
    CreateGlowEffect(SliderButton, 0.7)
    
    -- Initialize slider position
    local function UpdateSlider(pos)
        local relativeX = math.clamp(pos.X - SliderTrack.AbsolutePosition.X, 0, SliderTrack.AbsoluteSize.X)
        local percentage = relativeX / SliderTrack.AbsoluteSize.X
        value = math.floor(minValue + (maxValue - minValue) * percentage)
        
        TweenService:Create(SliderFill, TweenInfo.new(0.1), {
            Size = UDim2.new(percentage, 0, 1, 0)
        }):Play()
        
        TweenService:Create(SliderButton, TweenInfo.new(0.1), {
            Position = UDim2.new(percentage, -9, 0.5, -9)
        }):Play()
        
        Label.Text = name .. ": " .. value
        
        if callback then
            task.spawn(function()
                pcall(callback, value)
            end)
        end
    end
    
    -- Set initial value
    if defaultValue then
        local percentage = (defaultValue - minValue) / (maxValue - minValue)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderButton.Position = UDim2.new(percentage, -9, 0.5, -9)
    end
    
    -- Mouse interactions
    SliderButton.MouseButton1Down:Connect(function()
        sliding = true
        TweenService:Create(SliderButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 22, 0, 22)
        }):Play()
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if sliding then
                sliding = false
                TweenService:Create(SliderButton, TweenInfo.new(0.1), {
                    Size = UDim2.new(0, 18, 0, 18)
                }):Play()
            end
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

-- DROPDOWN COMPONENT with premium styling
function Velto:AddDropdown(name, options, defaultOption, callback)
    local selected = defaultOption or options[1]
    local open = false
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local DropdownFrame = Instance.new("Frame")
    
    if inSection then
        DropdownFrame.Size = UDim2.new(1, 0, 0, 64)
        DropdownFrame.BackgroundTransparency = 1
    else
        DropdownFrame.Size = UDim2.new(1, -20, 0, 64)
        DropdownFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 44)
        DropdownFrame.BackgroundTransparency = 1
    end
    
    DropdownFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Text = name
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 0, 34)
    DropdownButton.Position = UDim2.new(0, 0, 0, 25)
    DropdownButton.Text = selected
    DropdownButton.TextColor3 = Theme.Text
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextSize = 14
    DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    DropdownButton.BackgroundColor3 = Theme.Tertiary
    DropdownButton.Parent = DropdownFrame
    
    CreateCorner(DropdownButton, 6)
    CreateStroke(DropdownButton, 1, Color3.fromRGB(50, 56, 66), 0.5)
    
    local DropdownIcon = Instance.new("ImageLabel")
    DropdownIcon.Size = UDim2.new(0, 20, 0, 20)
    DropdownIcon.Position = UDim2.new(1, -25, 0.5, -10)
    DropdownIcon.Image = "rbxassetid://3926305904"
    DropdownIcon.ImageRectOffset = Vector2.new(964, 124)
    DropdownIcon.ImageRectSize = Vector2.new(36, 36)
    DropdownIcon.BackgroundTransparency = 1
    DropdownIcon.Parent = DropdownButton
    
    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, 0, 0, 0)
    DropdownList.Position = UDim2.new(0, 0, 0, 59)
    DropdownList.BackgroundColor3 = Theme.Tertiary
    DropdownList.ClipsDescendants = true
    DropdownList.Visible = false
    DropdownList.Parent = DropdownFrame
    
    CreateCorner(DropdownList, 6)
    CreateStroke(DropdownList, 1, Theme.Accent, 0.3)
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 1)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = DropdownList
    
    -- Forward declare for closures
    local ToggleDropdown

    -- Create options
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 32)
        OptionButton.Text = "  " .. option
        OptionButton.TextColor3 = Theme.Text
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.BackgroundColor3 = Theme.Tertiary
        OptionButton.BackgroundTransparency = 0.5
        OptionButton.LayoutOrder = i
        OptionButton.Parent = DropdownList
        
        OptionButton.MouseButton1Click:Connect(function()
            selected = option
            DropdownButton.Text = option
            ToggleDropdown()
            
            if callback then
                task.spawn(function()
                    pcall(callback, option)
                end)
            end
        end)
        
        -- Hover effect
        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.2), { 
                BackgroundColor3 = Color3.fromRGB(48, 52, 62),
                BackgroundTransparency = 0
            }):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.2), { 
                BackgroundColor3 = Theme.Tertiary,
                BackgroundTransparency = 0.5
            }):Play()
        end)
    end
    
    -- Update dropdown list size
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        DropdownList.Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end)
    
    ToggleDropdown = function()
        open = not open
        
        if open then
            DropdownList.Visible = true
            TweenService:Create(DropdownIcon, TweenInfo.new(0.2), {
                Rotation = 180
            }):Play()
            
            TweenService:Create(DropdownList, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y)
            }):Play()
        else
            TweenService:Create(DropdownIcon, TweenInfo.new(0.2), {
                Rotation = 0
            }):Play()
            
            TweenService:Create(DropdownList, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            
            wait(0.2)
            DropdownList.Visible = false
        end
    end
    
    -- Dropdown button click
    DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
    
    -- Close dropdown when clicking outside
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and open then
            local mousePos = input.Position
            local absolutePos = DropdownList.AbsolutePosition
            local absoluteSize = DropdownList.AbsoluteSize
            
            if not (mousePos.X >= absolutePos.X and mousePos.X <= absolutePos.X + absoluteSize.X and
                   mousePos.Y >= absolutePos.Y and mousePos.Y <= absolutePos.Y + absoluteSize.Y) then
                ToggleDropdown()
            end
        end
    end
    
    UserInputService.InputBegan:Connect(onInputBegan)
    
    table.insert(self.Elements, DropdownFrame)
    return DropdownFrame
end

-- TEXTBOX COMPONENT with premium styling
function Velto:AddTextbox(labelText, defaultValue, placeholder, onCommit)
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local Row = Instance.new("Frame")
    
    if inSection then
        Row.Size = UDim2.new(1, 0, 0, 60)
        Row.Position = UDim2.new(0, 0, 0, 0)
    else
        Row.Size = UDim2.new(1, -20, 0, 60)
        Row.Position = UDim2.new(0, 10, 0, #self.Elements * 44)
    end
    
    Row.BackgroundTransparency = 1
    Row.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Text = labelText or ""
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, 0, 0, 34)
    Box.Position = UDim2.new(0, 0, 0, 24)
    Box.Text = tostring(defaultValue or "")
    Box.PlaceholderText = placeholder or ""
    Box.TextColor3 = Theme.Text
    Box.PlaceholderColor3 = Color3.fromRGB(170,170,170)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Box.BackgroundColor3 = Theme.Tertiary
    Box.BackgroundTransparency = 0.5
    Box.ClearTextOnFocus = false
    Box.Parent = Row

    CreateCorner(Box, 6)
    CreateStroke(Box, 1, Theme.Accent, 0.3)

    Box.Focused:Connect(function()
        TweenService:Create(Box, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(45, 50, 60)
        }):Play()
        
        CreateGlowEffect(Box, 0.7)
    end)
    
    Box.FocusLost:Connect(function(enter)
        if Box:FindFirstChild("Glow") then
            Box.Glow:Destroy()
        end
        
        TweenService:Create(Box, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.5,
            BackgroundColor3 = Theme.Tertiary
        }):Play()
        
        if onCommit then 
            task.spawn(function()
                pcall(onCommit, Box.Text, enter) 
            end)
        end
    end)

    table.insert(self.Elements, Row)
    return Row
end

-- KEYBIND COMPONENT with premium styling
function Velto:AddKeybind(name, defaultKey, callback)
    local listening = false
    local key = defaultKey or Enum.KeyCode.Unknown
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local KeybindFrame = Instance.new("Frame")
    
    if inSection then
        KeybindFrame.Size = UDim2.new(1, 0, 0, 40)
        KeybindFrame.BackgroundColor3 = Theme.Tertiary
        KeybindFrame.BackgroundTransparency = 0.5
    else
        KeybindFrame.Size = UDim2.new(1, -20, 0, 34)
        KeybindFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 44)
        KeybindFrame.BackgroundTransparency = 1
    end
    
    KeybindFrame.Parent = parent
    
    if inSection then
        CreateCorner(KeybindFrame, 6)
        CreateStroke(KeybindFrame, 1, Color3.fromRGB(50, 56, 66), 0.5)
    end
    
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Size = UDim2.new(0.7, 0, 1, 0)
    KeybindLabel.Position = UDim2.new(0, 10, 0, 0)
    KeybindLabel.Text = name
    KeybindLabel.Font = Enum.Font.Gotham
    KeybindLabel.TextSize = 14
    KeybindLabel.TextColor3 = Theme.Text
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Parent = KeybindFrame
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Size = UDim2.new(0, 80, 0, 24)
    KeybindButton.Position = UDim2.new(1, -90, 0.5, -12)
    KeybindButton.Text = tostring(key.Name):gsub("^%l", string.upper)
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.TextSize = 12
    KeybindButton.TextColor3 = Theme.Text
    KeybindButton.BackgroundColor3 = Theme.Tertiary
    KeybindButton.Parent = KeybindFrame
    
    CreateCorner(KeybindButton, 4)
    CreateStroke(KeybindButton, 1, Theme.Accent, 0.5)
    
    KeybindButton.MouseButton1Click:Connect(function()
        listening = not listening
        
        if listening then
            KeybindButton.Text = "..."
            TweenService:Create(KeybindButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Accent,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            
            CreateGlowEffect(KeybindButton, 0.7)
        else
            KeybindButton.Text = tostring(key.Name):gsub("^%l", string.upper)
            TweenService:Create(KeybindButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Tertiary,
                TextColor3 = Theme.Text
            }):Play()
            
            if KeybindButton:FindFirstChild("Glow") then
                KeybindButton.Glow:Destroy()
            end
        end
    end)
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                KeybindButton.Text = tostring(key.Name):gsub("^%l", string.upper)
                listening = false
                
                TweenService:Create(KeybindButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.Tertiary,
                    TextColor3 = Theme.Text
                }):Play()
                
                if KeybindButton:FindFirstChild("Glow") then
                    KeybindButton.Glow:Destroy()
                end
                
                if callback then 
                    task.spawn(function()
                        pcall(callback, key) 
                    end)
                end
            end
        end
    end)

    table.insert(self.Elements, KeybindFrame)
    return KeybindFrame
end

-- COLOR PICKER COMPONENT with premium styling
function Velto:AddColorPicker(name, defaultColor, callback)
    local color = defaultColor or Color3.fromRGB(255, 255, 255)
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local ColorFrame = Instance.new("Frame")
    
    if inSection then
        ColorFrame.Size = UDim2.new(1, 0, 0, 40)
        ColorFrame.BackgroundColor3 = Theme.Tertiary
        ColorFrame.BackgroundTransparency = 0.5
    else
        ColorFrame.Size = UDim2.new(1, -20, 0, 34)
        ColorFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 44)
        ColorFrame.BackgroundTransparency = 1
    end
    
    ColorFrame.Parent = parent
    
    if inSection then
        CreateCorner(ColorFrame, 6)
        CreateStroke(ColorFrame, 1, Color3.fromRGB(50, 56, 66), 0.5)
    end
    
    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ColorLabel.Position = UDim2.new(0, 10, 0, 0)
    ColorLabel.Text = name
    ColorLabel.Font = Enum.Font.Gotham
    ColorLabel.TextSize = 14
    ColorLabel.TextColor3 = Theme.Text
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Parent = ColorFrame
    
    local ColorButton = Instance.new("TextButton")
    ColorButton.Size = UDim2.new(0, 24, 0, 24)
    ColorButton.Position = UDim2.new(1, -34, 0.5, -12)
    ColorButton.Text = ""
    ColorButton.BackgroundColor3 = color
    ColorButton.Parent = ColorFrame
    
    CreateCorner(ColorButton, 4)
    CreateStroke(ColorButton, 1, Theme.Accent, 0.5)
    CreateGlowEffect(ColorButton, 0.7)

    table.insert(self.Elements, ColorFrame)
    return ColorFrame
end

-- NOTIFICATION SYSTEM with premium styling
function Velto:Notify(title, message, duration, notiType)
    duration = duration or 5
    notiType = notiType or "Info"
    
    local notiHolder = self.UI:FindFirstChild("Notifications")
    if not notiHolder then return end
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(1, 0, 0, 0)
    Notification.BackgroundColor3 = Theme.Secondary
    Notification.ClipsDescendants = true
    Notification.Parent = notiHolder
    
    CreateCorner(Notification, 8)
    CreateStroke(Notification, 1, Theme.Accent, 0.3)
    CreateGlowEffect(Notification, 0.7)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Text = title
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Notification
    
    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(1, -20, 0, 0)
    Message.Position = UDim2.new(0, 10, 0, 30)
    Message.Text = message
    Message.TextColor3 = Theme.TextDim
    Message.Font = Enum.Font.Gotham
    Message.TextSize = 12
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextWrapped = true
    Message.AutomaticSize = Enum.AutomaticSize.Y
    Message.BackgroundTransparency = 1
    Message.Parent = Notification
    
    -- Set notification color based on type
    local accentColor = Theme.Accent
    if notiType == "Success" then
        accentColor = Theme.Success
    elseif notiType == "Warning" then
        accentColor = Theme.Warning
    elseif notiType == "Error" then
        accentColor = Theme.Error
    end
    
    Notification.UIStroke.Color = accentColor
    if Notification:FindFirstChild("Glow") then
        Notification.Glow.ImageColor3 = accentColor
    end
    
    -- Calculate notification height
    local textHeight = Message.TextBounds.Y
    local notiHeight = math.clamp(40 + textHeight, 60, 150)
    
    -- Animate in
    TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, notiHeight)
    }):Play()
    
    -- Auto-remove after duration
    task.spawn(function()
        wait(duration)
        
        -- Animate out
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(1, 0, 0, 0)
        }):Play()
        
        wait(0.3)
        Notification:Destroy()
    end)
    
    return Notification
end

-- MAIN MODULE RETURN
local VeltoUI = {}

function VeltoUI.Init()
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "VeltoIntro"
    IntroGui.ResetOnSpawn = false
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    IntroGui.IgnoreGuiInset = true
    IntroGui.Parent = CoreGui

    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    Background.Parent = IntroGui
    
    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 0, 0, 0)
    Logo.Position = UDim2.new(0.5, 0, 0.5, 0)
    Logo.Image = "rbxassetid://0" -- Replace with your logo asset ID
    Logo.BackgroundTransparency = 1
    Logo.Parent = Background
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 0, 0, 0)
    Title.Position = UDim2.new(0.5, 0, 0.6, 0)
    Title.Text = "VELTO UI"
    Title.TextColor3 = Theme.Accent
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 0
    Title.BackgroundTransparency = 1
    Title.Parent = Background
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0, 0, 0, 0)
    Subtitle.Position = UDim2.new(0.5, 0, 0.65, 0)
    Subtitle.Text = "Premium Interface System"
    Subtitle.TextColor3 = Theme.TextDim
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 0
    Subtitle.BackgroundTransparency = 1
    Subtitle.Parent = Background
    
    -- Animate intro sequence
    local logoAnim = TweenService:Create(Logo, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 120, 0, 120),
        Position = UDim2.new(0.5, -60, 0.4, -60)
    })
    
    local titleAnim = TweenService:Create(Title, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextSize = 32,
        Size = UDim2.new(0, 200, 0, 40),
        Position = UDim2.new(0.5, -100, 0.55, -20)
    })
    
    local subtitleAnim = TweenService:Create(Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextSize = 16,
        Size = UDim2.new(0, 250, 0, 20),
        Position = UDim2.new(0.5, -125, 0.62, -10)
    })
    
    local fadeOut = TweenService:Create(Background, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    })
    
    logoAnim:Play()
    logoAnim.Completed:Wait()
    
    titleAnim:Play()
    subtitleAnim:Play()
    
    wait(2)
    
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        IntroGui:Destroy()
    end)
end

function VeltoUI.CreateWindow(title, size)
    return Velto:CreateWindow(title, size)
end

return VeltoUI
