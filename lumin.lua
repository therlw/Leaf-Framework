--[[
    RLWSCRIPTS UI LIBRARY v1.0
    Premium Roblox GUI Library
    Design: 1:1 Port from React/Tailwind Design
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Library = {}
local UIConfig = {
    Colors = {
        Background = Color3.fromRGB(9, 9, 11),      -- Zinc 950
        Surface = Color3.fromRGB(24, 24, 27),       -- Zinc 900
        SurfaceHighlight = Color3.fromRGB(39, 39, 42), -- Zinc 800
        Border = Color3.fromRGB(39, 39, 42),        -- Zinc 800
        Primary = Color3.fromRGB(139, 92, 246),     -- Violet 500
        Text = Color3.fromRGB(244, 244, 245),       -- Zinc 100
        Muted = Color3.fromRGB(113, 113, 122),      -- Zinc 500
        Success = Color3.fromRGB(74, 222, 128),
        Error = Color3.fromRGB(248, 113, 113)
    },
    Font = Enum.Font.GothamMedium,
    BoldFont = Enum.Font.GothamBold
}

-- Utility Functions
local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function Tween(instance, info, properties)
    TweenService:Create(instance, info, properties):Play()
end

local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        Tween(object, TweenInfo.new(0.15), {Position = pos})
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

-- Main Library
function Library:Init()
    -- Protect GUI (Synapse/Standard Exploit protection)
    local ScreenGui = Create("ScreenGui", {
        Name = "RLWSCRIPTS",
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

function Library:CreateWindow(Config)
    local ScreenGui = Library:Init()
    local ActiveTab = nil
    
    -- Main Window Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = UIConfig.Colors.Background,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(750, 500),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 12)})
    Create("UIStroke", {Parent = MainFrame, Color = UIConfig.Colors.Border, Thickness = 1})
    
    -- Shadow
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = 0,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0,0,0),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23,23,277,277)
    })

    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Parent = MainFrame,
        BackgroundColor3 = UIConfig.Colors.Surface,
        Size = UDim2.new(1, 0, 0, 48),
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 12)})
    -- Fix bottom corners of header to be square
    local HeaderFix = Create("Frame", {
        Parent = Header,
        BackgroundColor3 = UIConfig.Colors.Surface,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BorderSizePixel = 0
    })
    Create("Frame", { -- Divider
        Parent = Header,
        BackgroundColor3 = UIConfig.Colors.Border,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0
    })

    MakeDraggable(Header, MainFrame)

    -- Logo & Title
    local LogoContainer = Create("Frame", {
        Parent = Header,
        BackgroundColor3 = UIConfig.Colors.Background,
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(0, 16, 0.5, -16),
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = LogoContainer, CornerRadius = UDim.new(0, 8)})
    Create("UIGradient", {Parent = LogoContainer, Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, UIConfig.Colors.Primary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(167, 139, 250))
    }, Rotation = 45})
    
    -- Icon (Terminalish)
    Create("ImageLabel", {
        Parent = LogoContainer,
        BackgroundTransparency = 1,
        Image = "rbxassetid://3944693858", -- Generic code/terminal icon
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = Color3.new(1,1,1)
    })

    local Title = Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 8),
        Size = UDim2.new(0, 200, 0, 20),
        Font = UIConfig.BoldFont,
        Text = "RLWSCRIPTS",
        TextColor3 = Color3.new(1,1,1),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 26),
        Size = UDim2.new(0, 200, 0, 12),
        Font = Enum.Font.Code,
        Text = "v1.0 PREMIUM",
        TextColor3 = UIConfig.Colors.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Inject Button (Visual)
    local InjectBtn = Create("Frame", {
        Parent = Header,
        BackgroundColor3 = UIConfig.Colors.SurfaceHighlight,
        Size = UDim2.fromOffset(70, 24),
        Position = UDim2.new(1, -50, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5)
    })
    Create("UICorner", {Parent = InjectBtn, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = InjectBtn, Color = UIConfig.Colors.Border, Thickness = 1})
    
    local InjectText = Create("TextLabel", {
        Parent = InjectBtn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Code,
        Text = "Inject",
        TextColor3 = UIConfig.Colors.Success,
        TextSize = 11
    })
    
    local PulseDot = Create("Frame", {
        Parent = InjectBtn,
        BackgroundColor3 = UIConfig.Colors.Success,
        Size = UDim2.fromOffset(4, 4),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5)
    })
    Create("UICorner", {Parent = PulseDot, CornerRadius = UDim.new(1, 0)})
    
    -- Pulse Animation
    task.spawn(function()
        while MainFrame.Parent do
            Tween(PulseDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.5})
            task.wait(1.6)
        end
    end)

    -- Close Button
    local CloseBtn = Create("TextButton", {
        Parent = Header,
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(1, -12, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5)
    })
    local CloseIcon = Create("ImageLabel", {
        Parent = CloseBtn,
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904", -- X icon
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = UIConfig.Colors.Muted,
        ImageRectOffset = Vector2.new(284, 4),
        ImageRectSize = Vector2.new(24, 24)
    })
    
    CloseBtn.MouseEnter:Connect(function() Tween(CloseIcon, TweenInfo.new(0.2), {ImageColor3 = UIConfig.Colors.Error}) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseIcon, TweenInfo.new(0.2), {ImageColor3 = UIConfig.Colors.Muted}) end)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Container Layout
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundColor3 = UIConfig.Colors.Background,
        Position = UDim2.new(0, 180, 0, 49),
        Size = UDim2.new(1, -180, 1, -49),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    -- Background Decoration (Blurred Glow)
    local GlowDeco = Create("ImageLabel", {
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Image = "rbxassetid://13126786847", -- Soft glow blob
        ImageColor3 = UIConfig.Colors.Primary,
        ImageTransparency = 0.9,
        Size = UDim2.fromOffset(400, 400),
        Position = UDim2.new(1, -100, 0, -100),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 0
    })

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(17, 17, 19),
        Position = UDim2.new(0, 0, 0, 49),
        Size = UDim2.new(0, 180, 1, -49),
        BorderSizePixel = 0
    })
    Create("UIStroke", {
        Parent = Sidebar,
        Color = UIConfig.Colors.Border,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }).Enabled = false -- Only need right border which isn't natively supported easily, using frame line

    local SidebarBorder = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = UIConfig.Colors.Border,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BorderSizePixel = 0
    })
    
    local SidebarList = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -60),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Create("UIListLayout", {Parent = SidebarList, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
    Create("UIPadding", {Parent = SidebarList, PaddingTop = UDim.new(0, 12)})

    -- User Profile
    local UserProfile = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Color3.fromRGB(24, 24, 27),
        Size = UDim2.new(1, -24, 0, 50),
        Position = UDim2.new(0.5, 0, 1, -12),
        AnchorPoint = Vector2.new(0.5, 1)
    })
    Create("UICorner", {Parent = UserProfile, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = UserProfile, Color = UIConfig.Colors.Border, Thickness = 1})
    
    Create("ImageLabel", {
        Parent = UserProfile,
        BackgroundColor3 = UIConfig.Colors.SurfaceHighlight,
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(0, 9, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = Players.LocalPlayer and Players.LocalPlayer:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) or ""
    }).CornerRadius = UDim.new(1,0)
    
    Create("TextLabel", {
        Parent = UserProfile,
        BackgroundTransparency = 1,
        Text = Players.LocalPlayer.Name,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 12,
        Font = UIConfig.BoldFont,
        Position = UDim2.new(0, 50, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("TextLabel", {
        Parent = UserProfile,
        BackgroundTransparency = 1,
        Text = "Lifetime",
        TextColor3 = UIConfig.Colors.Primary,
        TextSize = 10,
        Font = UIConfig.Font,
        Position = UDim2.new(0, 50, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- NOTIFICATIONS
    local NotifyContainer = Create("Frame", {
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -320, 0, 0),
        ClipsDescendants = false
    })
    Create("UIListLayout", {
        Parent = NotifyContainer,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 10)
    })
    Create("UIPadding", {Parent = NotifyContainer, PaddingBottom = UDim.new(0, 20)})

    function Library:Notification(Title, Msg, Type)
        local NFrame = Create("Frame", {
            Parent = NotifyContainer,
            BackgroundColor3 = Color3.fromRGB(18, 18, 21),
            Size = UDim2.new(1, 0, 0, 70),
            Position = UDim2.new(1, 300, 0, 0), -- Start off screen
            BorderSizePixel = 0
        })
        Create("UICorner", {Parent = NFrame, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {Parent = NFrame, Color = UIConfig.Colors.Border, Thickness = 1})
        
        -- Type Line
        local TypeColor = Type == "success" and UIConfig.Colors.Success or (Type == "error" and UIConfig.Colors.Error or UIConfig.Colors.Primary)
        local Bar = Create("Frame", {
            Parent = NFrame,
            BackgroundColor3 = TypeColor,
            Size = UDim2.new(0, 2, 1, -16),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5)
        })
        
        Create("TextLabel", {
            Parent = NFrame,
            BackgroundTransparency = 1,
            Text = Title,
            TextColor3 = Color3.new(1,1,1),
            Font = UIConfig.BoldFont,
            TextSize = 14,
            Position = UDim2.new(0, 12, 0, 10),
            TextXAlignment = Enum.TextXAlignment.Left
        })
        Create("TextLabel", {
            Parent = NFrame,
            BackgroundTransparency = 1,
            Text = Msg,
            TextColor3 = UIConfig.Colors.Muted,
            Font = UIConfig.Font,
            TextSize = 12,
            Position = UDim2.new(0, 12, 0, 30),
            Size = UDim2.new(1, -20, 0, 30),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })

        -- Animate In
        Tween(NFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Position = UDim2.new(0,0,0,0)})
        
        task.delay(4, function()
            Tween(NFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
            task.wait(0.5)
            NFrame:Destroy()
        end)
    end

    -- TAB HANDLING
    local WindowFuncs = {}

    function WindowFuncs:Tab(Name, IconId)
        local TabButton = Create("TextButton", {
            Parent = SidebarList,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 42),
            Text = "",
            AutoButtonColor = false
        })
        
        local ActiveLine = Create("Frame", {
            Parent = TabButton,
            BackgroundColor3 = UIConfig.Colors.Primary,
            Size = UDim2.new(0, 2, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        
        local TabIcon = Create("ImageLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Image = IconId or "rbxassetid://4483345998", -- Fallback
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(0, 16, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ImageColor3 = UIConfig.Colors.Muted
        })
        
        local TabLabel = Create("TextLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Text = Name,
            TextColor3 = UIConfig.Colors.Muted,
            Font = UIConfig.Font,
            TextSize = 13,
            Position = UDim2.new(0, 48, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Tab Content Container
        local TabPage = Create("ScrollingFrame", {
            Name = Name .. "_Page",
            Parent = ContentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = UIConfig.Colors.Border,
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        Create("UIPadding", {Parent = TabPage, PaddingTop = UDim.new(0, 16), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingBottom = UDim.new(0,16)})
        
        -- Two Column Layout logic using a simple grid emulator
        local LeftCol = Create("Frame", {
            Parent = TabPage,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UIListLayout", {Parent = LeftCol, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder})
        
        local RightCol = Create("Frame", {
            Parent = TabPage,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 1, 0),
            Position = UDim2.new(0.5, 6, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        Create("UIListLayout", {Parent = RightCol, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder})

        local function Activate()
            if ActiveTab then
                Tween(ActiveTab.Btn.Icon, TweenInfo.new(0.3), {ImageColor3 = UIConfig.Colors.Muted})
                Tween(ActiveTab.Btn.Label, TweenInfo.new(0.3), {TextColor3 = UIConfig.Colors.Muted, Position = UDim2.new(0, 48, 0.5, 0)})
                Tween(ActiveTab.Btn.Line, TweenInfo.new(0.3), {BackgroundTransparency = 1})
                ActiveTab.Page.Visible = false
            end
            
            ActiveTab = {Btn = {Icon = TabIcon, Label = TabLabel, Line = ActiveLine}, Page = TabPage}
            
            Tween(TabIcon, TweenInfo.new(0.3), {ImageColor3 = UIConfig.Colors.Primary})
            Tween(TabLabel, TweenInfo.new(0.3), {TextColor3 = Color3.new(1,1,1), Position = UDim2.new(0, 54, 0.5, 0)})
            Tween(ActiveLine, TweenInfo.new(0.3), {BackgroundTransparency = 0})
            TabPage.Visible = true
            TabPage.CanvasPosition = Vector2.new(0,0)
            
            -- Fade In effect
            TabPage.Position = UDim2.new(0, 10, 0, 0)
            TabPage.BackgroundTransparency = 1
            Tween(TabPage, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)})
        end

        TabButton.MouseButton1Click:Connect(Activate)
        
        -- Select first tab automatically
        if ActiveTab == nil then Activate() end

        local TabFuncs = {}
        local LeftColCount = 0
        local RightColCount = 0

        function TabFuncs:Section(Title)
            -- Auto balance columns
            local ParentCol = LeftCol
            if RightColCount < LeftColCount then
                ParentCol = RightCol
                RightColCount = RightColCount + 1
            else
                LeftColCount = LeftColCount + 1
            end

            local SectionFrame = Create("Frame", {
                Parent = ParentCol,
                BackgroundColor3 = Color3.fromRGB(24, 24, 27), -- Surface
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 0), -- Auto scaled
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0
            })
            Create("UICorner", {Parent = SectionFrame, CornerRadius = UDim.new(0, 10)})
            Create("UIStroke", {Parent = SectionFrame, Color = Color3.fromRGB(255,255,255), Transparency = 0.95, Thickness = 1})
            
            Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Text = Title:upper(),
                Font = UIConfig.BoldFont,
                TextSize = 10,
                TextColor3 = UIConfig.Colors.Muted,
                Position = UDim2.new(0, 12, 0, 10),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Container = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 30),
                Size = UDim2.new(1, -24, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UIListLayout", {Parent = Container, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
            Create("UIPadding", {Parent = SectionFrame, PaddingBottom = UDim.new(0, 12)})

            local SectionFuncs = {}

            -- TOGGLE
            function SectionFuncs:Toggle(Name, Default, Callback)
                Default = Default or false
                local Toggled = Default
                
                local ToggleFrame = Create("TextButton", {
                    Parent = Container,
                    BackgroundColor3 = UIConfig.Colors.SurfaceHighlight,
                    BackgroundTransparency = 0.7,
                    Size = UDim2.new(1, 0, 0, 36),
                    AutoButtonColor = false,
                    Text = ""
                })
                Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 6)})
                local Stroke = Create("UIStroke", {Parent = ToggleFrame, Color = UIConfig.Colors.Border, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
                
                local Label = Create("TextLabel", {
                    Parent = ToggleFrame,
                    Text = Name,
                    Font = UIConfig.Font,
                    TextSize = 13,
                    TextColor3 = UIConfig.Colors.Muted,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Switch = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = UIConfig.Colors.SurfaceHighlight,
                    Size = UDim2.fromOffset(40, 20),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5)
                })
                Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1, 0)})
                
                local Knob = Create("Frame", {
                    Parent = Switch,
                    BackgroundColor3 = Color3.new(1,1,1),
                    Size = UDim2.fromOffset(16, 16),
                    Position = UDim2.new(0, 2, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5)
                })
                Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

                local function UpdateState()
                    Tween(Label, TweenInfo.new(0.2), {TextColor3 = Toggled and Color3.new(1,1,1) or UIConfig.Colors.Muted})
                    Tween(Switch, TweenInfo.new(0.3), {BackgroundColor3 = Toggled and UIConfig.Colors.Primary or UIConfig.Colors.SurfaceHighlight})
                    Tween(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Spring), {Position = UDim2.new(0, Toggled and 22 or 2, 0.5, 0)})
                    if Toggled then
                        Tween(Stroke, TweenInfo.new(0.2), {Color = UIConfig.Colors.Primary, Transparency = 0.5})
                    else
                        Tween(Stroke, TweenInfo.new(0.2), {Color = UIConfig.Colors.Border, Transparency = 0})
                    end
                end

                ToggleFrame.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    UpdateState()
                    Callback(Toggled)
                end)
                
                if Default then UpdateState() end
            end

            -- BUTTON
            function SectionFuncs:Button(Name, Callback)
                local Btn = Create("TextButton", {
                    Parent = Container,
                    BackgroundColor3 = UIConfig.Colors.Primary,
                    Size = UDim2.new(1, 0, 0, 32),
                    Text = "",
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
                
                local BtnLabel = Create("TextLabel", {
                    Parent = Btn,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = Name,
                    Font = UIConfig.BoldFont,
                    TextSize = 13,
                    TextColor3 = Color3.new(1,1,1),
                    ZIndex = 2
                })
                
                -- Shimmer Effect Overlay
                local Shimmer = Create("Frame", {
                    Parent = Btn,
                    BackgroundColor3 = Color3.new(1,1,1),
                    BackgroundTransparency = 0.8,
                    Size = UDim2.new(0, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    ZIndex = 1
                })
                Create("UICorner", {Parent = Shimmer, CornerRadius = UDim.new(0, 6)})

                Btn.MouseEnter:Connect(function()
                    Tween(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(150, 110, 250)}) -- Lighter
                end)
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, TweenInfo.new(0.2), {BackgroundColor3 = UIConfig.Colors.Primary})
                end)
                Btn.MouseButton1Click:Connect(function()
                    -- Click Ripple
                    local Ripple = Create("Frame", {
                        Parent = Btn,
                        BackgroundColor3 = Color3.new(1,1,1),
                        BackgroundTransparency = 0.6,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Size = UDim2.new(0,0,0,0),
                        ZIndex = 0
                    })
                    Create("UICorner", {Parent = Ripple, CornerRadius = UDim.new(1,0)})
                    Tween(Ripple, TweenInfo.new(0.4), {Size = UDim2.new(1, 50, 2, 0), BackgroundTransparency = 1})
                    game.Debris:AddItem(Ripple, 0.45)
                    Callback()
                end)
            end

            -- SLIDER
            function SectionFuncs:Slider(Name, Min, Max, Default, Callback)
                Default = math.clamp(Default or Min, Min, Max)
                local Value = Default

                local SliderFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = UIConfig.Colors.SurfaceHighlight,
                    BackgroundTransparency = 0.7,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                Create("UICorner", {Parent = SliderFrame, CornerRadius = UDim.new(0, 6)})
                local Stroke = Create("UIStroke", {Parent = SliderFrame, Color = UIConfig.Colors.Border, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})

                Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Text = Name,
                    Font = UIConfig.Font,
                    TextSize = 13,
                    TextColor3 = UIConfig.Colors.Muted,
                    Position = UDim2.new(0, 12, 0, 8),
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Text = tostring(Value),
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    TextColor3 = UIConfig.Colors.Primary,
                    Position = UDim2.new(1, -12, 0, 8),
                    AnchorPoint = Vector2.new(1, 0),
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local Track = Create("TextButton", {
                    Parent = SliderFrame,
                    BackgroundColor3 = UIConfig.Colors.SurfaceHighlight,
                    Size = UDim2.new(1, -24, 0, 6),
                    Position = UDim2.new(0, 12, 0, 32),
                    Text = "",
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = Track, CornerRadius = UDim.new(1, 0)})
                
                local Fill = Create("Frame", {
                    Parent = Track,
                    BackgroundColor3 = UIConfig.Colors.Primary,
                    Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
                })
                Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})

                -- Drag Logic
                local Dragging = false
                
                local function UpdateSlide(input)
                    local SizeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local NewValue = math.floor(Min + ((Max - Min) * SizeX))
                    Value = NewValue
                    ValueLabel.Text = tostring(Value)
                    Tween(Fill, TweenInfo.new(0.05), {Size = UDim2.new(SizeX, 0, 1, 0)})
                    Callback(Value)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        Tween(Stroke, TweenInfo.new(0.2), {Color = UIConfig.Colors.Primary, Transparency = 0.5})
                        UpdateSlide(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlide(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                        Tween(Stroke, TweenInfo.new(0.2), {Color = UIConfig.Colors.Border, Transparency = 0})
                    end
                end)
            end

            -- DROPDOWN
            function SectionFuncs:Dropdown(Name, Options, Default, Callback)
                local IsOpen = false
                local Selected = Default or Options[1]
                
                local DropFrame = Create("Frame", {
                    Parent = Container,
                    BackgroundColor3 = UIConfig.Colors.SurfaceHighlight,
                    BackgroundTransparency = 0.7,
                    Size = UDim2.new(1, 0, 0, 42),
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = DropFrame, CornerRadius = UDim.new(0, 6)})
                local Stroke = Create("UIStroke", {Parent = DropFrame, Color = UIConfig.Colors.Border, Thickness = 1})

                local HeaderBtn = Create("TextButton", {
                    Parent = DropFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 42),
                    Text = ""
                })

                local Label = Create("TextLabel", {
                    Parent = HeaderBtn,
                    Text = Name,
                    Font = UIConfig.Font,
                    TextSize = 11,
                    TextColor3 = UIConfig.Colors.Muted,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 6),
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Current = Create("TextLabel", {
                    Parent = HeaderBtn,
                    Text = Selected,
                    Font = UIConfig.Font,
                    TextSize = 13,
                    TextColor3 = Color3.new(1,1,1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 22),
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Arrow = Create("ImageLabel", {
                    Parent = HeaderBtn,
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6034818372", -- Chevron Down
                    Size = UDim2.fromOffset(16, 16),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    ImageColor3 = UIConfig.Colors.Muted
                })

                local OptionsContainer = Create("Frame", {
                    Parent = DropFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 42),
                    Size = UDim2.new(1, 0, 0, 0) -- Auto
                })
                Create("UIListLayout", {Parent = OptionsContainer, SortOrder = Enum.SortOrder.LayoutOrder})

                local function RefreshOptions()
                    for _, v in pairs(OptionsContainer:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    
                    for _, opt in pairs(Options) do
                        local OptBtn = Create("TextButton", {
                            Parent = OptionsContainer,
                            BackgroundColor3 = Color3.new(1,1,1),
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 30),
                            Text = "  " .. opt,
                            TextColor3 = (opt == Selected) and UIConfig.Colors.Primary or UIConfig.Colors.Muted,
                            Font = UIConfig.Font,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })
                        
                        OptBtn.MouseButton1Click:Connect(function()
                            Selected = opt
                            Current.Text = Selected
                            Callback(Selected)
                            -- Close
                            IsOpen = false
                            Tween(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 42)})
                            Tween(Arrow, TweenInfo.new(0.3), {Rotation = 0})
                            RefreshOptions() -- Refresh colors
                        end)
                    end
                end
                
                RefreshOptions()

                HeaderBtn.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    local ContentSize = #Options * 30 + 48
                    Tween(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, IsOpen and ContentSize or 42)})
                    Tween(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 180 or 0})
                    Tween(Stroke, TweenInfo.new(0.3), {Color = IsOpen and UIConfig.Colors.Primary or UIConfig.Colors.Border})
                end)
            end

            return SectionFuncs
        end

        return TabFuncs
    end
    
    return WindowFuncs
end

--[[ 
    -----------------------------------------
    USAGE EXAMPLE
    -----------------------------------------
]]

local Window = Library:CreateWindow()

-- GENERAL TAB
local MainTab = Window:Tab("General", "rbxassetid://6034502861") -- Box Icon

local CharSection = MainTab:Section("Character Modification")
CharSection:Slider("WalkSpeed", 16, 500, 16, function(v)
    if Players.LocalPlayer.Character then
        Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)
CharSection:Slider("JumpPower", 50, 500, 50, function(v)
    if Players.LocalPlayer.Character then
        Players.LocalPlayer.Character.Humanoid.JumpPower = v
    end
end)
CharSection:Toggle("Infinite Jump", false, function(v)
    Library:Notification("Module Toggled", "Infinite Jump is now " .. (v and "Enabled" or "Disabled"), "info")
end)

local AutoSection = MainTab:Section("Automation")
AutoSection:Toggle("Auto Farm", false, function(v) end)
AutoSection:Dropdown("Farm Method", {"Tween", "Teleport", "Walk"}, "Tween", function(v)
    print("Method:", v)
end)

-- VISUALS TAB
local VisualsTab = Window:Tab("Visuals", "rbxassetid://6034156557") -- Palette Icon

local EspSection = VisualsTab:Section("ESP Settings")
EspSection:Toggle("Enable ESP", true, function(v) end)
EspSection:Toggle("Box ESP", true, function(v) end)
EspSection:Toggle("Tracers", false, function(v) end)

local WorldSection = VisualsTab:Section("World Visuals")
WorldSection:Slider("FOV", 70, 120, 90, function(v)
    workspace.CurrentCamera.FieldOfView = v
end)
WorldSection:Toggle("Fullbright", false, function(v) end)

-- COMBAT TAB
local CombatTab = Window:Tab("Combat", "rbxassetid://6031265976") -- Lightning Icon

local AimSection = CombatTab:Section("Aimbot")
AimSection:Toggle("Silent Aim", false, function(v) end)
AimSection:Slider("FOV Radius", 0, 800, 150, function(v) end)
AimSection:Dropdown("Aim Part", {"Head", "Torso", "Random"}, "Head", function(v) end)

local GunSection = CombatTab:Section("Gun Mods")
GunSection:Toggle("No Recoil", false, function(v) end)
GunSection:Button("Force Reload", function()
    Library:Notification("Success", "Weapon reloaded!", "success")
end)

-- SETTINGS TAB
local SettingsTab = Window:Tab("Settings", "rbxassetid://6031280882") -- Cog Icon

local ConfSection = SettingsTab:Section("Library Configuration")
ConfSection:Button("Unload Library", function()
    game.CoreGui.RLWSCRIPTS:Destroy()
end)
ConfSection:Toggle("Watermark", true, function(v) end)

-- Initial Notification
Library:Notification("Welcome", "RLWSCRIPTS loaded successfully.", "success")
