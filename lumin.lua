--[[
    RLWSCRIPTS PREMIUM LIBRARY v2.3 (Shadow Removed & Perfect Corners)
    Design: React/Tailwind Port (1:1 Replica)
    Author: RLW System
]]

print("[RLW LIB] Initializing Library v2.3...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

--// Library Configuration & Colors
local Library = {}
local Config = {
    Colors = {
        Background = Color3.fromRGB(9, 9, 11),       -- Zinc 950
        Surface = Color3.fromRGB(24, 24, 27),        -- Zinc 900
        SurfaceHighlight = Color3.fromRGB(39, 39, 42), -- Zinc 800
        Border = Color3.fromRGB(39, 39, 42),         -- Zinc 800
        Primary = Color3.fromRGB(139, 92, 246),      -- Violet 500
        PrimaryDark = Color3.fromRGB(124, 58, 237),
        Text = Color3.fromRGB(244, 244, 245),        -- Zinc 100
        Muted = Color3.fromRGB(113, 113, 122),       -- Zinc 500
        Success = Color3.fromRGB(74, 222, 128),
        Warning = Color3.fromRGB(251, 146, 60),
        Error = Color3.fromRGB(248, 113, 113)
    },
    Font = Enum.Font.Gotham,          -- Thin/Regular
    BoldFont = Enum.Font.GothamBold,  -- Thick
    CornerRadius = UDim.new(0, 8),
    Duration = 0.25
}

--// Utility Functions
local function Create(class, props)
    local instance = Instance.new(class)
    for k, v in pairs(props) do
        instance[k] = v
    end
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(duration or Config.Duration, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
    TweenService:Create(instance, info, properties):Play()
end

local function TruncateText(text, maxLength)
    if #text > maxLength then
        return string.sub(text, 1, maxLength) .. "..."
    end
    return text
end

local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05, Enum.EasingStyle.Linear)
        end
    end)
end

local function Ripple(button)
    spawn(function()
        local ripple = Create("ImageLabel", {
            Parent = button,
            BackgroundTransparency = 1,
            Image = "rbxassetid://2708891598",
            ImageColor3 = Color3.new(1, 1, 1),
            ImageTransparency = 0.6,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = 15
        })
        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
        Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), ImageTransparency = 1}, 0.5)
        wait(0.5)
        ripple:Destroy()
    end)
end

--// Main Library Functions
function Library:Init()
    local ScreenGui = Create("ScreenGui", {
        Name = "RLWSCRIPTS_V2",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end

    return ScreenGui
end

function Library:Window(options)
    local GUI = Library:Init()
    local Tabs = {}
    local FirstTab = true
    local TabCount = 0
    local UIKey = options.Key or Enum.KeyCode.RightShift
    local UIVisible = true
    local CurrentTabName = nil

    -- Main Frame (Directly on GUI, no Canvas/Shadow wrapper)
    local Main = Create("Frame", {
        Parent = GUI,
        Name = "Main",
        BackgroundColor3 = Config.Colors.Background,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 750, 0, 500),
        ClipsDescendants = true, -- Clips bottom corners mostly
        ZIndex = 1
    })
    Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 16)})
    Create("UIStroke", {Parent = Main, Color = Config.Colors.Border, Thickness = 1})

    -- Header
    local Header = Create("Frame", {
        Parent = Main,
        Name = "Header",
        BackgroundColor3 = Config.Colors.Surface,
        Size = UDim2.new(1, 0, 0, 54),
        BorderSizePixel = 0,
        ZIndex = 2
    })
    -- Header Corner Logic: 
    -- 1. Apply UICorner to round ALL corners of the header.
    -- 2. Add a Filler Frame at the bottom half to make the bottom corners square again (connecting to body).
    Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 16)})
    
    local HeaderFiller = Create("Frame", {
        Parent = Header,
        BackgroundColor3 = Config.Colors.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0.5, 0), -- Covers bottom half
        Position = UDim2.new(0, 0, 0.5, 0),
        ZIndex = 2
    })

    Create("Frame", { -- Divider Line
        Parent = Header,
        BackgroundColor3 = Config.Colors.Border,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 3
    })

    MakeDraggable(Header, Main)

    -- Toggle Key Listener
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == UIKey then
            UIVisible = not UIVisible
            GUI.Enabled = UIVisible
        end
    end)

    -- Logo Area
    local LogoContainer = Create("Frame", {
        Parent = Header,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        ZIndex = 5
    })

    local LogoBox = Create("Frame", {
        Parent = LogoContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 5
    })
    
    -- Main Icon (Terminal/Code) - Box removed, just icon
    Create("ImageLabel", {
        Parent = LogoBox,
        BackgroundTransparency = 1,
        Image = "rbxassetid://79185829747284", -- Terminal Icon
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 6
    })

    -- Title Text
    local TitleFrame = Create("Frame", {
        Parent = LogoContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 100, 0, 32),
        ZIndex = 5
    })
    
    Create("TextLabel", {
        Parent = TitleFrame,
        BackgroundTransparency = 1,
        Text = options.Name or "RLWSCRIPTS",
        TextColor3 = Config.Colors.Text,
        Font = Config.BoldFont,
        TextSize = 15,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(1, 0, 0.5, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    })
    Create("TextLabel", {
        Parent = TitleFrame,
        BackgroundTransparency = 1,
        Text = options.Version or "v1.0 PREMIUM",
        TextColor3 = Config.Colors.Muted,
        Font = Enum.Font.Code,
        TextSize = 10,
        Position = UDim2.new(0, 0, 0.5, 2),
        Size = UDim2.new(1, 0, 0.5, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5
    })

    -- Header Actions
    local Actions = Create("Frame", {
        Parent = Header,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(1, -20, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        ZIndex = 5
    })
    Create("UIListLayout", {
        Parent = Actions,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12)
    })

    -- Close Button
    local CloseBtn = Create("TextButton", {
        Parent = Actions,
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(0, 24, 0, 24),
        LayoutOrder = 2,
        ZIndex = 5
    })
    local CloseIcon = Create("ImageLabel", {
        Parent = CloseBtn,
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031094678",
        ImageColor3 = Config.Colors.Muted,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 6
    })
    CloseBtn.MouseEnter:Connect(function() Tween(CloseIcon, {ImageColor3 = Config.Colors.Error}) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseIcon, {ImageColor3 = Config.Colors.Muted}) end)
    CloseBtn.MouseButton1Click:Connect(function() GUI:Destroy() end)

    -- Status Badge
    local StatusBadge = Create("Frame", {
        Parent = Actions,
        BackgroundColor3 = Config.Colors.SurfaceHighlight,
        Size = UDim2.new(0, 0, 0, 24),
        LayoutOrder = 1,
        ZIndex = 5
    })
    Create("UICorner", {Parent = StatusBadge, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = StatusBadge, Color = Config.Colors.Border, Thickness = 1})
    
    local StatusLayout = Create("UIListLayout", {
        Parent = StatusBadge,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    Create("UIPadding", {Parent = StatusBadge, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

    local PulseDot = Create("Frame", {
        Parent = StatusBadge,
        BackgroundColor3 = Config.Colors.Success,
        Size = UDim2.new(0, 6, 0, 6)
    })
    Create("UICorner", {Parent = PulseDot, CornerRadius = UDim.new(1, 0)})
    
    spawn(function()
        while PulseDot.Parent do
            Tween(PulseDot, {BackgroundTransparency = 0.6}, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(0.8)
            Tween(PulseDot, {BackgroundTransparency = 0}, 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(0.8)
        end
    end)

    Create("TextLabel", {
        Parent = StatusBadge,
        BackgroundTransparency = 1,
        Text = options.Updated or "Updated: 2 days ago",
        TextColor3 = Config.Colors.Success,
        Font = Enum.Font.Code,
        TextSize = 11,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0)
    })
    StatusBadge.AutomaticSize = Enum.AutomaticSize.X

    -- Sidebar
    local Sidebar = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Color3.fromRGB(17, 17, 20),
        Size = UDim2.new(0, 200, 1, -54),
        Position = UDim2.new(0, 0, 0, 54),
        BorderSizePixel = 0,
        ZIndex = 5
    })
    Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Config.Colors.Border,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 6
    })

    -- Content Area
    local Content = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Config.Colors.Background,
        Size = UDim2.new(1, -200, 1, -54),
        Position = UDim2.new(0, 200, 0, 54),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 1
    })

    -- Background Decoration
    Create("ImageLabel", {
        Parent = Content,
        BackgroundTransparency = 1,
        Image = "rbxassetid://13126786847",
        ImageColor3 = Config.Colors.Primary,
        ImageTransparency = 0.94,
        Size = UDim2.new(0, 600, 0, 600),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 0
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -70), -- Space for user profile
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ZIndex = 6
    })
    
    local TabList = Create("UIListLayout", {
        Parent = TabContainer,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 20)
    end)
    
    Create("UIPadding", {Parent = TabContainer, PaddingTop = UDim.new(0, 16)})

    -- User Profile
    local UserContainer = Create("Frame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 70),
        Position = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        ZIndex = 6
    })
    
    Create("UIPadding", {
        Parent = UserContainer, 
        PaddingTop = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16)
    })

    local UserPanel = Create("Frame", {
        Parent = UserContainer,
        BackgroundColor3 = Config.Colors.Surface,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 7
    })
    Create("UICorner", {Parent = UserPanel, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = UserPanel, Color = Config.Colors.Border, Thickness = 1})

    local success, headshot = pcall(function()
        return Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    
    local UserImgContainer = Create("Frame", {
        Parent = UserPanel,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 8
    })
    local UserImg = Create("ImageLabel", {
        Parent = UserImgContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = success and headshot or "rbxassetid://4483345998",
        ZIndex = 8
    })
    Create("UICorner", {Parent = UserImg, CornerRadius = UDim.new(1, 0)})

    Create("TextLabel", {
        Parent = UserPanel,
        BackgroundTransparency = 1,
        Text = TruncateText(Players.LocalPlayer.Name, 12),
        TextColor3 = Config.Colors.Text,
        Font = Config.BoldFont,
        TextSize = 12,
        Position = UDim2.new(0, 42, 0, 6),
        Size = UDim2.new(1, -44, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8
    })
    Create("TextLabel", {
        Parent = UserPanel,
        BackgroundTransparency = 1,
        Text = "Lifetime",
        TextColor3 = Config.Colors.Primary,
        Font = Config.Font,
        TextSize = 10,
        Position = UDim2.new(0, 42, 0, 20),
        Size = UDim2.new(1, -44, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8
    })

    -- Notification System
    local NotifyList = Create("Frame", {
        Parent = GUI,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(1, -320, 0, 20),
        ClipsDescendants = false,
        ZIndex = 100
    })
    Create("UIListLayout", {
        Parent = NotifyList,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 10)
    })

    function Library:Notify(title, msg, type)
        local color = type == "success" and Config.Colors.Success or (type == "error" and Config.Colors.Error or Config.Colors.Primary)
        local icon = type == "success" and "rbxassetid://6031094667" or (type == "error" and "rbxassetid://6031094678" or "rbxassetid://6031091224")

        local Toast = Create("Frame", {
            Parent = NotifyList,
            BackgroundColor3 = Config.Colors.Surface,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 0.1,
            ClipsDescendants = true,
            ZIndex = 101
        })
        Create("UICorner", {Parent = Toast, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {Parent = Toast, Color = Config.Colors.Border, Thickness = 1})
        
        Create("Frame", {
            Parent = Toast,
            BackgroundColor3 = color,
            Size = UDim2.new(0, 3, 1, 0),
            ZIndex = 102
        })

        Create("ImageLabel", {
            Parent = Toast,
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = color,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 12, 0, 12),
            ZIndex = 102
        })

        Create("TextLabel", {
            Parent = Toast,
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Config.Colors.Text,
            Font = Config.BoldFont,
            TextSize = 14,
            Position = UDim2.new(0, 40, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 102
        })

        Create("TextLabel", {
            Parent = Toast,
            BackgroundTransparency = 1,
            Text = msg,
            TextColor3 = Config.Colors.Muted,
            Font = Config.Font,
            TextSize = 12,
            Position = UDim2.new(0, 40, 0, 30),
            Size = UDim2.new(1, -50, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 102
        })

        Tween(Toast, {Size = UDim2.new(1, 0, 0, 65)}, 0.4, Enum.EasingStyle.Back)
        
        task.delay(4, function()
            Tween(Toast, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quart)
            wait(0.5)
            Toast:Destroy()
        end)
    end

    -- Window Functions
    local WindowFunctions = {}

    function WindowFunctions:Tab(name, icon)
        TabCount = TabCount + 1
        local Tab = {}
        
        -- Tab Button
        local Btn = Create("TextButton", {
            Name = name .. "_Tab",
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 46),
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = TabCount,
            ZIndex = 7
        })

        -- Hover Background
        local Hover = Create("Frame", {
            Parent = Btn,
            BackgroundColor3 = Config.Colors.Text,
            BackgroundTransparency = 1, -- Invisible by default
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 7
        })
        Create("UIGradient", {
            Parent = Hover,
            Color = ColorSequence.new(Config.Colors.Primary, Config.Colors.Primary),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.95),
                NumberSequenceKeypoint.new(1, 1)
            }),
            Rotation = 0
        })

        -- Active Indicator (Fixed: Clean 4px solid vertical line)
        local ActiveIndicator = Create("Frame", {
            Parent = Btn,
            BackgroundColor3 = Config.Colors.Primary,
            Size = UDim2.new(0, 4, 1, 0), -- 4px wide, full height
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 9
        })

        local TabIcon = Create("ImageLabel", {
            Parent = Btn,
            BackgroundTransparency = 1,
            Image = icon or "rbxassetid://4483345998",
            ImageColor3 = Config.Colors.Muted,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 24, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex = 8
        })

        local TabText = Create("TextLabel", {
            Parent = Btn,
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Config.Colors.Muted,
            Font = Config.Font,
            TextSize = 14,
            Position = UDim2.new(0, 56, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 8
        })
        
        -- Hover Events (Smooth Animation)
        Btn.MouseEnter:Connect(function()
            if CurrentTabName ~= name then
                Tween(Hover, {BackgroundTransparency = 0.96}, 0.2) -- Very subtle hover
                Tween(TabText, {TextColor3 = Config.Colors.Text}, 0.2)
                Tween(TabIcon, {ImageColor3 = Config.Colors.Text}, 0.2)
            end
        end)
        
        Btn.MouseLeave:Connect(function()
            if CurrentTabName ~= name then
                Tween(Hover, {BackgroundTransparency = 1}, 0.2)
                Tween(TabText, {TextColor3 = Config.Colors.Muted}, 0.2)
                Tween(TabIcon, {ImageColor3 = Config.Colors.Muted}, 0.2)
            end
        end)

        -- Page
        local Page = Create("ScrollingFrame", {
            Parent = Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Config.Colors.Border,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 5
        })
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 24), PaddingLeft = UDim.new(0, 24), PaddingRight = UDim.new(0, 24), PaddingBottom = UDim.new(0, 24)})
        
        local LeftCol = Create("Frame", {
            Parent = Page,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -8, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UIListLayout", {Parent = LeftCol, Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder})
        
        local RightCol = Create("Frame", {
            Parent = Page,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -8, 1, 0),
            Position = UDim2.new(0.5, 8, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UIListLayout", {Parent = RightCol, Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder})

        local function Activate()
            CurrentTabName = name
            
            for _, t in pairs(Tabs) do
                Tween(t.Icon, {ImageColor3 = Config.Colors.Muted}, 0.2)
                Tween(t.Text, {TextColor3 = Config.Colors.Muted}, 0.2)
                Tween(t.Ind, {BackgroundTransparency = 1}, 0.2)
                Tween(t.Hover, {BackgroundTransparency = 1}, 0.2)
                t.Page.Visible = false
            end
            
            Tween(TabIcon, {ImageColor3 = Config.Colors.Primary}, 0.3)
            Tween(TabText, {TextColor3 = Config.Colors.Text}, 0.3)
            Tween(ActiveIndicator, {BackgroundTransparency = 0}, 0.3)
            Tween(Hover, {BackgroundTransparency = 0.9}, 0.3)
            Page.Visible = true
            
            Page.Position = UDim2.new(0, 10, 0, 0)
            Page.BackgroundTransparency = 1
            Tween(Page, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quad)
        end

        Btn.MouseButton1Click:Connect(Activate)
        table.insert(Tabs, {Icon = TabIcon, Text = TabText, Ind = ActiveIndicator, Hover = Hover, Page = Page})

        if FirstTab then
            FirstTab = false
            task.spawn(function()
                task.wait()
                Activate()
            end)
        end

        local TabFunctions = {}
        local LeftCount, RightCount = 0, 0

        function TabFunctions:Section(title)
            local Parent = LeftCol
            if RightCount < LeftCount then
                Parent = RightCol
                RightCount = RightCount + 1
            else
                LeftCount = LeftCount + 1
            end

            local SectionBox = Create("Frame", {
                Parent = Parent,
                BackgroundColor3 = Config.Colors.Surface,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UICorner", {Parent = SectionBox, CornerRadius = UDim.new(0, 12)})
            Create("UIStroke", {Parent = SectionBox, Color = Color3.fromRGB(255,255,255), Transparency = 0.92, Thickness = 1})

            Create("TextLabel", {
                Parent = SectionBox,
                BackgroundTransparency = 1,
                Text = title:upper(),
                TextColor3 = Config.Colors.Muted,
                Font = Config.BoldFont,
                TextSize = 11,
                Position = UDim2.new(0, 16, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Container = Create("Frame", {
                Parent = SectionBox,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 40),
                Size = UDim2.new(1, -32, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UIListLayout", {Parent = Container, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
            Create("UIPadding", {Parent = SectionBox, PaddingBottom = UDim.new(0, 16)})

            local Elements = {}

            function Elements:Toggle(name, default, callback)
                local Toggled = default or false
                local ToggleBtn = Create("TextButton", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.SurfaceHighlight,
                    BackgroundTransparency = 0.7,
                    Size = UDim2.new(1, 0, 0, 40),
                    AutoButtonColor = false,
                    Text = ""
                })
                Create("UICorner", {Parent = ToggleBtn, CornerRadius = Config.CornerRadius})
                local Stroke = Create("UIStroke", {Parent = ToggleBtn, Color = Config.Colors.Border, Thickness = 1})
                
                Create("TextLabel", {
                    Parent = ToggleBtn,
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    Font = Config.Font,
                    TextSize = 13,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Switch = Create("Frame", {
                    Parent = ToggleBtn,
                    BackgroundColor3 = Config.Colors.Surface,
                    Size = UDim2.new(0, 40, 0, 22),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5)
                })
                Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1, 0)})
                
                local Dot = Create("Frame", {
                    Parent = Switch,
                    BackgroundColor3 = Color3.new(1,1,1),
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 2, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5)
                })
                Create("UICorner", {Parent = Dot, CornerRadius = UDim.new(1, 0)})

                local function Update()
                    local targetColor = Toggled and Config.Colors.Primary or Config.Colors.SurfaceHighlight
                    local targetPos = Toggled and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                    local targetStroke = Toggled and Config.Colors.Primary or Config.Colors.Border
                    
                    Tween(Switch, {BackgroundColor3 = targetColor}, 0.2)
                    Tween(Dot, {Position = targetPos}, 0.3, Enum.EasingStyle.Back)
                    Tween(Stroke, {Color = targetStroke, Transparency = Toggled and 0.5 or 0}, 0.2)
                end

                ToggleBtn.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Update()
                    callback(Toggled)
                end)
                if Toggled then Update() end
            end

            function Elements:Slider(name, min, max, default, callback)
                local Value = default or min
                local SliderFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.SurfaceHighlight,
                    BackgroundTransparency = 0.7,
                    Size = UDim2.new(1, 0, 0, 54)
                })
                Create("UICorner", {Parent = SliderFrame, CornerRadius = Config.CornerRadius})
                Create("UIStroke", {Parent = SliderFrame, Color = Config.Colors.Border, Thickness = 1})

                Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    Font = Config.Font,
                    TextSize = 13,
                    Position = UDim2.new(0, 12, 0, 12),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Text = tostring(Value),
                    TextColor3 = Config.Colors.Primary,
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    Position = UDim2.new(1, -12, 0, 12),
                    AnchorPoint = Vector2.new(1, 0),
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local Bar = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Config.Colors.Surface,
                    Size = UDim2.new(1, -24, 0, 6),
                    Position = UDim2.new(0, 12, 0, 36)
                })
                Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})

                local Fill = Create("Frame", {
                    Parent = Bar,
                    BackgroundColor3 = Config.Colors.Primary,
                    Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)
                })
                Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
                
                local dragging = false
                local function Update(input)
                    local percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    Value = math.floor(min + (max - min) * percent)
                    ValLabel.Text = tostring(Value)
                    Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05)
                    callback(Value)
                end

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        Update(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
            end
            
            function Elements:Button(name, callback)
                local Btn = Create("TextButton", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.Primary,
                    Size = UDim2.new(1, 0, 0, 36),
                    Text = "",
                    AutoButtonColor = false,
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = Btn, CornerRadius = Config.CornerRadius})
                
                Create("TextLabel", {
                    Parent = Btn,
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Color3.new(1,1,1),
                    Font = Config.BoldFont,
                    TextSize = 13,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 3
                })

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Config.Colors.PrimaryDark}, 0.2)
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Config.Colors.Primary}, 0.2)
                end)
                Btn.MouseButton1Click:Connect(function()
                    Ripple(Btn)
                    callback()
                end)
            end

            function Elements:Textbox(name, placeholder, callback)
                local BoxFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.SurfaceHighlight,
                    BackgroundTransparency = 0.7,
                    Size = UDim2.new(1, 0, 0, 46)
                })
                Create("UICorner", {Parent = BoxFrame, CornerRadius = Config.CornerRadius})
                local Stroke = Create("UIStroke", {Parent = BoxFrame, Color = Config.Colors.Border, Thickness = 1})

                Create("TextLabel", {
                    Parent = BoxFrame,
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    Font = Config.Font,
                    TextSize = 13,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -24, 0.5, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Input = Create("TextBox", {
                    Parent = BoxFrame,
                    BackgroundTransparency = 1,
                    Text = "",
                    PlaceholderText = placeholder or "...",
                    PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
                    TextColor3 = Config.Colors.Text,
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    Position = UDim2.new(0, 12, 0.5, 0),
                    Size = UDim2.new(1, -24, 0.5, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false
                })

                Input.Focused:Connect(function()
                    Tween(Stroke, {Color = Config.Colors.Primary}, 0.2)
                    Tween(BoxFrame, {BackgroundTransparency = 0.5}, 0.2)
                end)
                
                Input.FocusLost:Connect(function()
                    Tween(Stroke, {Color = Config.Colors.Border}, 0.2)
                    Tween(BoxFrame, {BackgroundTransparency = 0.7}, 0.2)
                    callback(Input.Text)
                end)
            end
            
            function Elements:Dropdown(name, options, default, callback)
                local IsOpen = false
                local Selection = default or options[1]
                
                local DropFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.SurfaceHighlight,
                    BackgroundTransparency = 0.7,
                    Size = UDim2.new(1, 0, 0, 46),
                    ClipsDescendants = true,
                    ZIndex = 20
                })
                Create("UICorner", {Parent = DropFrame, CornerRadius = Config.CornerRadius})
                local Stroke = Create("UIStroke", {Parent = DropFrame, Color = Config.Colors.Border, Thickness = 1})

                local HeaderBtn = Create("TextButton", {
                    Parent = DropFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 46),
                    Text = "",
                    ZIndex = 20
                })

                Create("TextLabel", {
                    Parent = HeaderBtn,
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Text,
                    Font = Config.Font,
                    TextSize = 13,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 20
                })

                local SelLabel = Create("TextLabel", {
                    Parent = HeaderBtn,
                    BackgroundTransparency = 1,
                    Text = Selection,
                    TextColor3 = Config.Colors.Primary,
                    Font = Config.Font,
                    TextSize = 13,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -36, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 20
                })

                local List = Create("ScrollingFrame", {
                    Parent = DropFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 46),
                    Size = UDim2.new(1, 0, 1, -46),
                    CanvasSize = UDim2.new(0,0,0,0),
                    ScrollBarThickness = 2,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 21
                })
                Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})

                local function RenderOptions()
                    for _, c in pairs(List:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    for _, opt in pairs(options) do
                        local OptBtn = Create("TextButton", {
                            Parent = List,
                            BackgroundColor3 = Config.Colors.Surface,
                            BackgroundTransparency = 0.2,
                            Size = UDim2.new(1, 0, 0, 32),
                            Text = "  " .. opt,
                            TextColor3 = opt == Selection and Config.Colors.Primary or Config.Colors.Muted,
                            Font = Config.Font,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 22
                        })
                        OptBtn.MouseButton1Click:Connect(function()
                            Selection = opt
                            SelLabel.Text = Selection
                            callback(Selection)
                            IsOpen = false
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 46)}, 0.2)
                            RenderOptions()
                        end)
                    end
                end
                RenderOptions()

                HeaderBtn.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    local targetHeight = IsOpen and math.min(180, 46 + (#options * 32)) or 46
                    Tween(DropFrame, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                    Tween(Stroke, {Color = IsOpen and Config.Colors.Primary or Config.Colors.Border}, 0.2)
                end)
            end

            return Elements
        end

        return TabFunctions
    end
    return WindowFunctions
end

return Library
