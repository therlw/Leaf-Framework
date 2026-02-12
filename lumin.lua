--[[
    RLWSCRIPTS PREMIUM LIBRARY v1.1
    Design: React/Tailwind Port (1:1 Replica)
    Author: RLW System
    
    HOW TO USE:
    1. Upload this code to a RAW link (GitHub Gist, Pastebin, etc.)
    2. Use loadstring to import it:
       local Library = loadstring(game:HttpGet("YOUR_RAW_LINK_HERE"))()
]]

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
        Muted = Color3.fromRGB(161, 161, 170),       -- Zinc 400
        Success = Color3.fromRGB(74, 222, 128),
        Warning = Color3.fromRGB(251, 146, 60),
        Error = Color3.fromRGB(248, 113, 113)
    },
    Font = Enum.Font.GothamMedium,
    BoldFont = Enum.Font.GothamBold,
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
            ZIndex = 5
        })
        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
        Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), ImageTransparency = 1}, 0.5)
        wait(0.5)
        ripple:Destroy()
    end)
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

--// Main Library Functions
function Library:Init()
    local ScreenGui = Create("ScreenGui", {
        Name = "RLWSCRIPTS_V1",
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
    local UIKey = options.Key or Enum.KeyCode.RightShift
    local UIVisible = true

    -- Main Frame
    local Main = Create("Frame", {
        Parent = GUI,
        Name = "Main",
        BackgroundColor3 = Config.Colors.Background,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 750, 0, 500),
        ClipsDescendants = false
    })
    Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 12)})
    Create("UIStroke", {Parent = Main, Color = Config.Colors.Border, Thickness = 1})

    -- Shadow
    local Shadow = Create("ImageLabel", {
        Parent = Main,
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.4,
        Position = UDim2.new(0, -30, 0, -30),
        Size = UDim2.new(1, 60, 1, 60),
        ZIndex = -1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23,23,277,277)
    })

    -- Header
    local Header = Create("Frame", {
        Parent = Main,
        Name = "Header",
        BackgroundColor3 = Config.Colors.Surface,
        Size = UDim2.new(1, 0, 0, 50)
    })
    Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 12)})
    Create("Frame", { -- Fix bottom corners
        Parent = Header,
        BackgroundColor3 = Config.Colors.Surface,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BorderSizePixel = 0
    })
    Create("Frame", { -- Divider
        Parent = Header,
        BackgroundColor3 = Config.Colors.Border,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0
    })

    MakeDraggable(Header, Main)

    -- Toggle Key Listener
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == UIKey then
            UIVisible = not UIVisible
            GUI.Enabled = UIVisible
        end
    end)

    -- Logo
    local LogoBox = Create("Frame", {
        Parent = Header,
        BackgroundColor3 = Config.Colors.Background,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 16, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5)
    })
    Create("UICorner", {Parent = LogoBox, CornerRadius = UDim.new(0, 8)})
    Create("UIGradient", {Parent = LogoBox, Color = ColorSequence.new(Config.Colors.Primary, Config.Colors.PrimaryDark), Rotation = 45})
    Create("ImageLabel", {
        Parent = LogoBox,
        BackgroundTransparency = 1,
        Image = "rbxassetid://3944693858", -- Terminal Icon
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5)
    })

    -- Title
    Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Text = options.Name or "RLWSCRIPTS",
        TextColor3 = Config.Colors.Text,
        Font = Config.BoldFont,
        TextSize = 16,
        Position = UDim2.new(0, 60, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Text = options.Version or "v1.0 PREMIUM",
        TextColor3 = Config.Colors.Muted,
        Font = Enum.Font.Code,
        TextSize = 11,
        Position = UDim2.new(0, 60, 0, 26),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Close Button
    local CloseBtn = Create("TextButton", {
        Parent = Header,
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5)
    })
    local CloseIcon = Create("ImageLabel", {
        Parent = CloseBtn,
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031094678",
        ImageColor3 = Config.Colors.Muted,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5)
    })
    CloseBtn.MouseEnter:Connect(function() Tween(CloseIcon, {ImageColor3 = Config.Colors.Error}) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseIcon, {ImageColor3 = Config.Colors.Muted}) end)
    CloseBtn.MouseButton1Click:Connect(function() GUI:Destroy() end)

    -- Content Layout
    local Sidebar = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Color3.fromRGB(15, 15, 18),
        Size = UDim2.new(0, 180, 1, -51),
        Position = UDim2.new(0, 0, 0, 51),
        BorderSizePixel = 0
    })
    Create("Frame", { -- Sidebar Border
        Parent = Sidebar,
        BackgroundColor3 = Config.Colors.Border,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BorderSizePixel = 0
    })

    local Content = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Config.Colors.Background,
        Size = UDim2.new(1, -180, 1, -51),
        Position = UDim2.new(0, 180, 0, 51),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    -- Background Decoration (Glow)
    local Glow = Create("ImageLabel", {
        Parent = Content,
        BackgroundTransparency = 1,
        Image = "rbxassetid://13126786847",
        ImageColor3 = Config.Colors.Primary,
        ImageTransparency = 0.92,
        Size = UDim2.new(0, 400, 0, 400),
        Position = UDim2.new(1, 50, 0, -50),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 0
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -60),
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0
    })
    Create("UIListLayout", {
        Parent = TabContainer,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    Create("UIPadding", {Parent = TabContainer, PaddingTop = UDim.new(0, 12)})

    -- User Info (Bottom Sidebar)
    local UserInfo = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Config.Colors.Surface,
        Size = UDim2.new(1, -24, 0, 48),
        Position = UDim2.new(0.5, 0, 1, -12),
        AnchorPoint = Vector2.new(0.5, 1)
    })
    Create("UICorner", {Parent = UserInfo, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = UserInfo, Color = Config.Colors.Border, Thickness = 1})
    Create("ImageLabel", {
        Parent = UserInfo,
        BackgroundColor3 = Config.Colors.SurfaceHighlight,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = Players.LocalPlayer:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    }).CornerRadius = UDim.new(1, 0)
    Create("TextLabel", {
        Parent = UserInfo,
        BackgroundTransparency = 1,
        Text = Players.LocalPlayer.Name,
        TextColor3 = Config.Colors.Text,
        Font = Config.BoldFont,
        TextSize = 12,
        Position = UDim2.new(0, 48, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("TextLabel", {
        Parent = UserInfo,
        BackgroundTransparency = 1,
        Text = "Premium User",
        TextColor3 = Config.Colors.Primary,
        Font = Config.Font,
        TextSize = 10,
        Position = UDim2.new(0, 48, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Notification System
    local NotifyList = Create("Frame", {
        Parent = GUI,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(1, -320, 0, 20),
        ClipsDescendants = false
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
            Size = UDim2.new(1, 0, 0, 0), -- Animated height
            BackgroundTransparency = 0.1,
            ClipsDescendants = true
        })
        Create("UICorner", {Parent = Toast, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {Parent = Toast, Color = Config.Colors.Border, Thickness = 1})
        
        -- Side Bar Color
        Create("Frame", {
            Parent = Toast,
            BackgroundColor3 = color,
            Size = UDim2.new(0, 3, 1, 0)
        })

        local IconImg = Create("ImageLabel", {
            Parent = Toast,
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = color,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 12, 0, 12)
        })

        Create("TextLabel", {
            Parent = Toast,
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Config.Colors.Text,
            Font = Config.BoldFont,
            TextSize = 14,
            Position = UDim2.new(0, 40, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left
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
            TextWrapped = true
        })

        -- Animation In
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
        local Tab = {}
        
        -- Tab Button
        local Btn = Create("TextButton", {
            Parent = TabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            Text = "",
            AutoButtonColor = false
        })
        
        local ActiveIndicator = Create("Frame", {
            Parent = Btn,
            BackgroundColor3 = Config.Colors.Primary,
            Size = UDim2.new(0, 3, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        
        local TabIcon = Create("ImageLabel", {
            Parent = Btn,
            BackgroundTransparency = 1,
            Image = icon or "rbxassetid://4483345998",
            ImageColor3 = Config.Colors.Muted,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 16, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5)
        })

        local TabText = Create("TextLabel", {
            Parent = Btn,
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Config.Colors.Muted,
            Font = Config.Font,
            TextSize = 13,
            Position = UDim2.new(0, 48, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Tab Content Page
        local Page = Create("ScrollingFrame", {
            Parent = Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Config.Colors.Border,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        })
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})
        
        -- Layout (Left & Right columns)
        local LeftCol = Create("Frame", {
            Parent = Page,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UIListLayout", {Parent = LeftCol, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder})
        
        local RightCol = Create("Frame", {
            Parent = Page,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 1, 0),
            Position = UDim2.new(0.5, 6, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UIListLayout", {Parent = RightCol, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder})

        local function Activate()
            -- Reset all tabs
            for _, t in pairs(Tabs) do
                Tween(t.Icon, {ImageColor3 = Config.Colors.Muted}, 0.2)
                Tween(t.Text, {TextColor3 = Config.Colors.Muted}, 0.2)
                Tween(t.Ind, {BackgroundTransparency = 1}, 0.2)
                t.Page.Visible = false
            end
            
            -- Activate active
            Tween(TabIcon, {ImageColor3 = Config.Colors.Primary}, 0.3)
            Tween(TabText, {TextColor3 = Config.Colors.Text}, 0.3)
            Tween(ActiveIndicator, {BackgroundTransparency = 0}, 0.3)
            Page.Visible = true
            
            -- Fade in content
            Page.Position = UDim2.new(0, 10, 0, 0)
            Page.BackgroundTransparency = 1
            Tween(Page, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quad)
        end

        Btn.MouseButton1Click:Connect(Activate)
        table.insert(Tabs, {Icon = TabIcon, Text = TabText, Ind = ActiveIndicator, Page = Page})

        if FirstTab then
            Activate()
            FirstTab = false
        end

        -- Section Handling
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
            Create("UICorner", {Parent = SectionBox, CornerRadius = UDim.new(0, 10)})
            Create("UIStroke", {Parent = SectionBox, Color = Config.Colors.Border, Thickness = 1})

            Create("TextLabel", {
                Parent = SectionBox,
                BackgroundTransparency = 1,
                Text = title:upper(),
                TextColor3 = Config.Colors.Muted,
                Font = Config.BoldFont,
                TextSize = 10,
                Position = UDim2.new(0, 12, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Container = Create("Frame", {
                Parent = SectionBox,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 32),
                Size = UDim2.new(1, -24, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UIListLayout", {Parent = Container, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
            Create("UIPadding", {Parent = SectionBox, PaddingBottom = UDim.new(0, 12)})

            -- ELEMENTS
            local Elements = {}

            -- LABEL
            function Elements:Label(text)
                local LabelFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })
                Create("TextLabel", {
                    Parent = LabelFrame,
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Config.Colors.Text,
                    Font = Config.Font,
                    TextSize = 13,
                    Size = UDim2.new(1, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true
                })
            end

            -- TOGGLE
            function Elements:Toggle(name, default, callback)
                local Toggled = default or false
                local ToggleBtn = Create("TextButton", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.SurfaceHighlight,
                    Size = UDim2.new(1, 0, 0, 36),
                    AutoButtonColor = false,
                    Text = ""
                })
                Create("UICorner", {Parent = ToggleBtn, CornerRadius = Config.CornerRadius})
                local Stroke = Create("UIStroke", {Parent = ToggleBtn, Color = Config.Colors.Border, Thickness = 1})
                
                Create("TextLabel", {
                    Parent = ToggleBtn,
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Muted,
                    Font = Config.Font,
                    TextSize = 13,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Switch = Create("Frame", {
                    Parent = ToggleBtn,
                    BackgroundColor3 = Config.Colors.Surface, -- inactive
                    Size = UDim2.new(0, 36, 0, 20),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5)
                })
                Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1, 0)})
                
                local Dot = Create("Frame", {
                    Parent = Switch,
                    BackgroundColor3 = Color3.new(1,1,1),
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 2, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5)
                })
                Create("UICorner", {Parent = Dot, CornerRadius = UDim.new(1, 0)})

                local function Update()
                    local targetColor = Toggled and Config.Colors.Primary or Config.Colors.Surface
                    local targetPos = Toggled and UDim2.new(0, 18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                    local targetStroke = Toggled and Config.Colors.Primary or Config.Colors.Border
                    
                    Tween(Switch, {BackgroundColor3 = targetColor}, 0.2)
                    Tween(Dot, {Position = targetPos}, 0.3, Enum.EasingStyle.Spring)
                    Tween(Stroke, {Color = targetStroke, Transparency = Toggled and 0.6 or 0}, 0.2)
                end

                ToggleBtn.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Update()
                    callback(Toggled)
                end)
                if Toggled then Update() end
            end

            -- SLIDER
            function Elements:Slider(name, min, max, default, callback)
                local Value = default or min
                local SliderFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.SurfaceHighlight,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                Create("UICorner", {Parent = SliderFrame, CornerRadius = Config.CornerRadius})
                Create("UIStroke", {Parent = SliderFrame, Color = Config.Colors.Border, Thickness = 1})

                Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Muted,
                    Font = Config.Font,
                    TextSize = 13,
                    Position = UDim2.new(0, 12, 0, 10),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Text = tostring(Value),
                    TextColor3 = Config.Colors.Primary,
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    Position = UDim2.new(1, -12, 0, 10),
                    AnchorPoint = Vector2.new(1, 0),
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local Bar = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Config.Colors.Surface,
                    Size = UDim2.new(1, -24, 0, 6),
                    Position = UDim2.new(0, 12, 0, 32)
                })
                Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})

                local Fill = Create("Frame", {
                    Parent = Bar,
                    BackgroundColor3 = Config.Colors.Primary,
                    Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)
                })
                Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
                
                local Knob = Create("Frame", {
                    Parent = Fill,
                    BackgroundColor3 = Color3.new(1,1,1),
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5)
                })
                Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

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

            -- BUTTON
            function Elements:Button(name, callback)
                local Btn = Create("TextButton", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.Primary,
                    Size = UDim2.new(1, 0, 0, 32),
                    Text = "",
                    AutoButtonColor = false,
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = Btn, CornerRadius = Config.CornerRadius})
                
                -- Shimmer
                local Shimmer = Create("Frame", {
                    Parent = Btn,
                    BackgroundColor3 = Color3.new(1,1,1),
                    BackgroundTransparency = 0.9,
                    Size = UDim2.new(0, 0, 1, 0),
                    ZIndex = 2
                })

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

            -- TEXTBOX
            function Elements:Textbox(name, placeholder, callback)
                local BoxFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.SurfaceHighlight,
                    Size = UDim2.new(1, 0, 0, 42)
                })
                Create("UICorner", {Parent = BoxFrame, CornerRadius = Config.CornerRadius})
                local Stroke = Create("UIStroke", {Parent = BoxFrame, Color = Config.Colors.Border, Thickness = 1})

                Create("TextLabel", {
                    Parent = BoxFrame,
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Muted,
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
                    Font = Config.Font,
                    TextSize = 12,
                    Position = UDim2.new(0, 12, 0.5, 0),
                    Size = UDim2.new(1, -24, 0.5, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false
                })

                Input.Focused:Connect(function()
                    Tween(Stroke, {Color = Config.Colors.Primary}, 0.2)
                end)
                
                Input.FocusLost:Connect(function()
                    Tween(Stroke, {Color = Config.Colors.Border}, 0.2)
                    callback(Input.Text)
                end)
            end

            -- KEYBIND
            function Elements:Keybind(name, default, callback)
                local Key = default or Enum.KeyCode.RightShift
                local Waiting = false

                local KeyFrame = Create("TextButton", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.SurfaceHighlight,
                    Size = UDim2.new(1, 0, 0, 36),
                    AutoButtonColor = false,
                    Text = ""
                })
                Create("UICorner", {Parent = KeyFrame, CornerRadius = Config.CornerRadius})
                Create("UIStroke", {Parent = KeyFrame, Color = Config.Colors.Border, Thickness = 1})

                Create("TextLabel", {
                    Parent = KeyFrame,
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Muted,
                    Font = Config.Font,
                    TextSize = 13,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -12, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local BindLabel = Create("TextLabel", {
                    Parent = KeyFrame,
                    BackgroundColor3 = Config.Colors.Surface,
                    Text = Key.Name,
                    TextColor3 = Config.Colors.Text,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Size = UDim2.new(0, 0, 0, 20),
                    AutomaticSize = Enum.AutomaticSize.X
                })
                Create("UICorner", {Parent = BindLabel, CornerRadius = UDim.new(0, 4)})
                Create("UIPadding", {Parent = BindLabel, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

                KeyFrame.MouseButton1Click:Connect(function()
                    Waiting = true
                    BindLabel.Text = "..."
                    BindLabel.TextColor3 = Config.Colors.Primary
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if Waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = input.KeyCode
                        BindLabel.Text = Key.Name
                        BindLabel.TextColor3 = Config.Colors.Text
                        Waiting = false
                        callback(Key)
                    end
                end)
            end

            -- COLOR PICKER (Simple HSV)
            function Elements:ColorPicker(name, default, callback)
                local Color = default or Color3.new(1, 1, 1)
                local Open = false

                local ColorFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.SurfaceHighlight,
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = ColorFrame, CornerRadius = Config.CornerRadius})
                local Stroke = Create("UIStroke", {Parent = ColorFrame, Color = Config.Colors.Border, Thickness = 1})

                local Trigger = Create("TextButton", {
                    Parent = ColorFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    Text = ""
                })

                Create("TextLabel", {
                    Parent = Trigger,
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Muted,
                    Font = Config.Font,
                    TextSize = 13,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -12, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Preview = Create("Frame", {
                    Parent = Trigger,
                    BackgroundColor3 = Color,
                    Size = UDim2.new(0, 24, 0, 14),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5)
                })
                Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 4)})

                -- Pickers
                local PickerArea = Create("Frame", {
                    Parent = ColorFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 40),
                    Size = UDim2.new(1, -24, 0, 60)
                })

                -- RGB sliders logic omitted for brevity in single file, using simple HSV bar
                local HueBar = Create("ImageButton", {
                    Parent = PickerArea,
                    Size = UDim2.new(1, 0, 0, 12),
                    Image = "rbxassetid://6034832530" -- Color Spectrum
                })
                Create("UICorner", {Parent = HueBar, CornerRadius = UDim.new(0, 4)})

                Trigger.MouseButton1Click:Connect(function()
                    Open = not Open
                    Tween(ColorFrame, {Size = UDim2.new(1, 0, 0, Open and 110 or 36)}, 0.2)
                end)
                
                -- Simplified for this file: clicking bar sets random color to demonstrate callback
                HueBar.MouseButton1Click:Connect(function()
                    Color = Color3.fromHSV(math.random(), 1, 1)
                    Preview.BackgroundColor3 = Color
                    callback(Color)
                end)
            end

            -- DROPDOWN
            function Elements:Dropdown(name, options, default, callback)
                local IsOpen = false
                local Selection = default or options[1]
                
                local DropFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = Config.Colors.SurfaceHighlight,
                    Size = UDim2.new(1, 0, 0, 42),
                    ClipsDescendants = true,
                    ZIndex = 2
                })
                Create("UICorner", {Parent = DropFrame, CornerRadius = Config.CornerRadius})
                local Stroke = Create("UIStroke", {Parent = DropFrame, Color = Config.Colors.Border, Thickness = 1})

                local HeaderBtn = Create("TextButton", {
                    Parent = DropFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 42),
                    Text = "",
                    ZIndex = 2
                })

                Create("TextLabel", {
                    Parent = HeaderBtn,
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Config.Colors.Muted,
                    Font = Config.Font,
                    TextSize = 11,
                    Position = UDim2.new(0, 12, 0, 6),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2
                })

                local SelLabel = Create("TextLabel", {
                    Parent = HeaderBtn,
                    BackgroundTransparency = 1,
                    Text = Selection,
                    TextColor3 = Config.Colors.Text,
                    Font = Config.Font,
                    TextSize = 13,
                    Position = UDim2.new(0, 12, 0, 22),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2
                })

                local Arrow = Create("ImageLabel", {
                    Parent = HeaderBtn,
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6034818372",
                    ImageColor3 = Config.Colors.Muted,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    ZIndex = 2
                })

                local List = Create("ScrollingFrame", {
                    Parent = DropFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 42),
                    Size = UDim2.new(1, 0, 1, -42),
                    CanvasSize = UDim2.new(0,0,0,0),
                    ScrollBarThickness = 2,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 3
                })
                Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})

                local function RenderOptions()
                    for _, c in pairs(List:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    
                    for _, opt in pairs(options) do
                        local OptBtn = Create("TextButton", {
                            Parent = List,
                            BackgroundColor3 = Config.Colors.Surface,
                            BackgroundTransparency = 0.5,
                            Size = UDim2.new(1, 0, 0, 32),
                            Text = "  " .. opt,
                            TextColor3 = opt == Selection and Config.Colors.Primary or Config.Colors.Muted,
                            Font = Config.Font,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 3
                        })
                        OptBtn.MouseButton1Click:Connect(function()
                            Selection = opt
                            SelLabel.Text = Selection
                            callback(Selection)
                            IsOpen = false
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.2)
                            Tween(Arrow, {Rotation = 0}, 0.2)
                            RenderOptions()
                        end)
                    end
                end
                RenderOptions()

                HeaderBtn.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    local targetHeight = IsOpen and math.min(180, 42 + (#options * 32)) or 42
                    Tween(DropFrame, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                    Tween(Arrow, {Rotation = IsOpen and 180 or 0}, 0.2)
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
