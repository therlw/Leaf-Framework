-- Velto UI Implementation for Pet Simulator 99
local Velto = {}
Velto.__index = Velto

-- Services
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- THEME CONFIGURATION
local Theme = {
    Primary = Color3.fromRGB(20, 22, 28),      -- app background
    Secondary = Color3.fromRGB(35, 38, 46),    -- panels/cards
    Tertiary = Color3.fromRGB(28, 30, 36),     -- rows/controls
    Accent = Color3.fromRGB(70, 150, 255),     -- accent
    Text = Color3.fromRGB(230, 234, 241),
    TextDim = Color3.fromRGB(180, 186, 198),
    Disabled = Color3.fromRGB(110, 115, 125),
    Shadow = Color3.fromRGB(0, 0, 0),
    Success = Color3.fromRGB(70, 200, 140),
    Warning = Color3.fromRGB(255, 180, 90),
    Error = Color3.fromRGB(235, 90, 90)
}

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

-- MAIN WINDOW CREATION
function Velto:CreateWindow(title, size)
    local self = setmetatable({}, Velto)
    self.Tabs = {}
    self.CurrentTab = nil
    self.Elements = {}
    self.ConfigPath = "Velto_"..(title:gsub("%s+",""))..".json"
    self.State = { Position = {0.5,-275,0.5,-200}, Minimized = false, ToggleKey = "RightShift", Size = {0,550,0,400} }
    do
        local raw = TryRead(self.ConfigPath)
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

    -- Main frame
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
    CreateCorner(Frame, 8)
    CreateStroke(Frame, 1, Color3.fromRGB(60, 68, 80))

    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Theme.Secondary
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Frame

    -- Header-only dragging
    do
        local dragging = false
        local dragStart, startPos
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Frame.Position
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
            end
        end)
    end

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

    -- Minimize button
    local MinButton = Instance.new("TextButton")
    MinButton.Size = UDim2.new(0, 30, 1, 0)
    MinButton.Position = UDim2.new(1, -60, 0, 0)
    MinButton.Text = "–"
    MinButton.TextColor3 = Theme.Text
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextSize = 18
    MinButton.BackgroundColor3 = Theme.Secondary
    MinButton.Parent = TitleBar

    -- Tab container (vertical)
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 140, 1, -80)
    TabContainer.Position = UDim2.new(0, 10, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Frame
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Vertical
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 6)
    TabList.Parent = TabContainer

    -- Content container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -170, 1, -80)
    ContentContainer.Position = UDim2.new(0, 160, 0, 40)
    ContentContainer.BackgroundColor3 = Theme.Secondary
    ContentContainer.Name = "ContentContainer"
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = Frame
    CreateCorner(ContentContainer, 8)
    CreateStroke(ContentContainer, 1, Color3.fromRGB(60, 68, 80))

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

    -- padding inside content
    local ContentPad = Instance.new("UIPadding")
    ContentPad.PaddingLeft = UDim.new(0, 12)
    ContentPad.PaddingRight = UDim.new(0, 12)
    ContentPad.PaddingTop = UDim.new(0, 12)
    ContentPad.PaddingBottom = UDim.new(0, 12)
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
        TabContainer.Visible = not minimized
        ContentContainer.Visible = not minimized
        self.State.Minimized = minimized
        TryWrite(self.ConfigPath, HttpService:JSONEncode(self.State))
    end)
    -- apply persisted minimized state
    TabContainer.Visible = not minimized
    ContentContainer.Visible = not minimized

    -- Global toggle key (hide/show entire UI)
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
                UI.Enabled = not UI.Enabled
            end
        end)
    end

    -- Resize handle (bottom-right)
    local ResizeGrip = Instance.new("Frame")
    ResizeGrip.Size = UDim2.new(0, 16, 0, 16)
    ResizeGrip.Position = UDim2.new(1, -16, 1, -16)
    ResizeGrip.BackgroundColor3 = Color3.fromRGB(70, 76, 88)
    ResizeGrip.Active = true
    ResizeGrip.Name = "ResizeGrip"
    ResizeGrip.Parent = Frame
    CreateCorner(ResizeGrip, 3)
    CreateStroke(ResizeGrip, 1, Color3.fromRGB(90, 98, 112))
    local resizing = false
    local startSize, startMouse
    ResizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startSize = Frame.AbsoluteSize
            startMouse = input.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            local newW = math.clamp(startSize.X + delta.X, 480, 900)
            local newH = math.clamp(startSize.Y + delta.Y, 340, 700)
            Frame.Size = UDim2.new(0, newW, 0, newH)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if resizing then
                resizing = false
                self.State.Size = {Frame.Size.X.Scale, Frame.Size.X.Offset, Frame.Size.Y.Scale, Frame.Size.Y.Offset}
                TryWrite(self.ConfigPath, HttpService:JSONEncode(self.State))
            end
        end
    end)

    -- Notifications container
    local NotiHolder = Instance.new("Frame")
    NotiHolder.Name = "Notifications"
    NotiHolder.AnchorPoint = Vector2.new(1, 1)
    NotiHolder.Size = UDim2.new(0, 280, 1, -20)
    NotiHolder.Position = UDim2.new(1, -10, 1, -10)
    NotiHolder.BackgroundTransparency = 1
    NotiHolder.Parent = UI
    local NotiList = Instance.new("UIListLayout")
    NotiList.FillDirection = Enum.FillDirection.Vertical
    NotiList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotiList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotiList.Padding = UDim.new(0, 6)
    NotiList.Parent = NotiHolder

    return self
end

-- TAB CREATION
function Velto:CreateTab(tabName, iconAssetId)
    local Tab = {}
    Tab.Elements = {}
    Tab.Index = #self.Tabs + 1
    
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -10, 0, 35)
    TabButton.Position = UDim2.new(0, 5, 0, 0)
    TabButton.Text = (iconAssetId and "   " or "") .. tabName
    TabButton.BackgroundColor3 = Theme.Tertiary
    TabButton.TextColor3 = Theme.Text
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 14
    TabButton.Parent = self.TabContainer
    TabButton.LayoutOrder = Tab.Index

    CreateCorner(TabButton, 6)
    CreateStroke(TabButton, 1, Color3.fromRGB(50, 56, 66))

    -- Optional icon
    if iconAssetId then
        local Icon = Instance.new("ImageLabel")
        Icon.BackgroundTransparency = 1
        Icon.Size = UDim2.new(0, 20, 0, 20)
        Icon.Position = UDim2.new(0, 8, 0.5, -10)
        Icon.Image = iconAssetId
        Icon.ImageColor3 = Theme.Text
        Icon.Parent = TabButton
        
        local IconStroke = Instance.new("UIStroke")
        IconStroke.Thickness = 1
        IconStroke.LineJoinMode = Enum.LineJoinMode.Round
        IconStroke.Color = Theme.Accent
        IconStroke.Transparency = 0.2
        IconStroke.Enabled = false
        IconStroke.Parent = Icon

        Tab.Icon = Icon
        Tab.IconStroke = IconStroke
    end

    -- Badge (hidden by default)
    local Badge = Instance.new("TextLabel")
    Badge.BackgroundColor3 = Theme.Accent
    Badge.TextColor3 = Color3.fromRGB(0,0,0)
    Badge.Font = Enum.Font.GothamBold
    Badge.TextSize = 12
    Badge.Text = ""
    Badge.AutoLocalize = false
    Badge.Visible = false
    Badge.AnchorPoint = Vector2.new(1, 0.5)
    Badge.Size = UDim2.new(0, 28, 0, 18)
    Badge.Position = UDim2.new(1, -8, 0.5, 0)
    Badge.Parent = TabButton
    CreateCorner(Badge, 9)

    -- Highlight
    local Highlight = Instance.new("Frame")
    Highlight.Size = UDim2.new(0, 3, 1, 0)
    Highlight.Position = UDim2.new(0, 0, 0, 0)
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
            t.Button.BackgroundColor3 = Theme.Tertiary
            if t.Icon then
                t.Icon.ImageColor3 = Theme.Text
            end
            if t.IconStroke then
                t.IconStroke.Enabled = false
            end
        end
        
        Content.Visible = true
        Highlight.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(54, 58, 70)
        if Tab.Icon then
            Tab.Icon.ImageColor3 = Theme.Accent
        end
        if Tab.IconStroke then
            Tab.IconStroke.Enabled = true
        end
        self.CurrentTab = Tab
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

    table.insert(self.Tabs, Tab)

    -- If this is the first tab, reflect active visual state
    if #self.Tabs == 1 then
        Tab.Button.BackgroundColor3 = Color3.fromRGB(54, 58, 70)
        if Tab.Icon then
            Tab.Icon.ImageColor3 = Theme.Accent
        end
        if Tab.IconStroke then
            Tab.IconStroke.Enabled = true
        end
    end
    return setmetatable(Tab, {__index = self})
end

-- SECTION CARD
function Velto:AddSection(title)
    local container = self.Content
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -6, 0, 0)
    Section.Position = UDim2.new(0, 3, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Theme.Tertiary
    Section.Parent = container
    CreateCorner(Section, 8)
    CreateStroke(Section, 1, Color3.fromRGB(50, 56, 66))

    -- Header (collapsible)
    local Header = Instance.new("TextButton")
    Header.BackgroundTransparency = 1
    Header.Text = (title and #title > 0) and ("  "..title) or "  Section"
    Header.TextColor3 = Theme.Text
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 15
    Header.Size = UDim2.new(1, -8, 0, 24)
    Header.Position = UDim2.new(0, 4, 0, 6)
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Section

    local Chevron = Instance.new("TextLabel")
    Chevron.BackgroundTransparency = 1
    Chevron.Size = UDim2.new(0, 18, 0, 18)
    Chevron.Position = UDim2.new(0, -2, 0.5, -9)
    Chevron.Text = "▼"
    Chevron.TextColor3 = Theme.Text
    Chevron.Font = Enum.Font.GothamBold
    Chevron.TextSize = 14
    Chevron.Parent = Header

    local Inner = Instance.new("Frame")
    Inner.Name = "Inner"
    Inner.Size = UDim2.new(1, -16, 0, 0)
    Inner.Position = UDim2.new(0, 8, 0, 34)
    Inner.AutomaticSize = Enum.AutomaticSize.Y
    Inner.BackgroundTransparency = 1
    Inner.Parent = Section

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 2)
    pad.PaddingRight = UDim.new(0, 2)
    pad.PaddingTop = UDim.new(0, 2)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = Inner

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = Inner

    local collapsed = false
    Header.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        Inner.Visible = not collapsed
        TweenService:Create(Chevron, TweenInfo.new(0.2), { Rotation = collapsed and -90 or 0 }):Play()
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

-- BUTTON COMPONENT
function Velto:AddButton(name, callback)
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local Button = Instance.new("TextButton")
    if inSection then
        Button.Size = UDim2.new(1, 0, 0, 32)
        Button.Position = UDim2.new(0, 0, 0, 0)
    else
        Button.Size = UDim2.new(1, -20, 0, 30)
        Button.Position = UDim2.new(0, 10, 0, #self.Elements * 40)
    end
    Button.Text = name
    Button.TextColor3 = Theme.Text
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.BackgroundColor3 = Theme.Accent
    Button.Parent = parent

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
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local ToggleFrame = Instance.new("Frame")
    if inSection then
        ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
        ToggleFrame.BackgroundColor3 = Theme.Tertiary
    else
        ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
        ToggleFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 40)
        ToggleFrame.BackgroundTransparency = 1
    end
    ToggleFrame.Parent = parent
    if inSection then
        CreateCorner(ToggleFrame, 6)
        CreateStroke(ToggleFrame, 1, Color3.fromRGB(50, 56, 66))
    end
    
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
    ToggleButton.Size = UDim2.new(0, 50, 0, 22)
    ToggleButton.Position = UDim2.new(1, -58, 0.5, -11)
    ToggleButton.Text = ""
    ToggleButton.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 64, 74)
    ToggleButton.Parent = ToggleFrame
    
    CreateCorner(ToggleButton, 12)
    CreateStroke(ToggleButton, 1, Theme.Secondary)
    
    local ToggleDot = Instance.new("Frame")
    ToggleDot.Size = UDim2.new(0, 18, 0, 18)
    ToggleDot.Position = UDim2.new(0, state and 28 or 2, 0.5, -9)
    ToggleDot.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    ToggleDot.Parent = ToggleButton
    
    CreateCorner(ToggleDot, 12)
    
    -- Click handler
    ToggleButton.MouseButton1Click:Connect(function()
        state = not state
        ToggleButton.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 64, 74)
        ToggleDot.Position = UDim2.new(0, state and 28 or 2, 0.5, -9)
        if callback then pcall(callback, state) end
    end)

    table.insert(self.Elements, ToggleFrame)
    return ToggleFrame
end

-- LABEL COMPONENT
function Velto:AddLabel(text)
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local Label = Instance.new("TextLabel")
    if inSection then
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Position = UDim2.new(0, 0, 0, 0)
    else
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Position = UDim2.new(0, 10, 0, #self.Elements * 40)
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

-- SLIDER COMPONENT
function Velto:AddSlider(name, minValue, maxValue, defaultValue, callback)
    local value = defaultValue or minValue
    local sliding = false
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local SliderFrame = Instance.new("Frame")
    if inSection then
        SliderFrame.Size = UDim2.new(1, 0, 0, 60)
        SliderFrame.BackgroundTransparency = 1
    else
        SliderFrame.Size = UDim2.new(1, -20, 0, 60)
        SliderFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 40)
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
    SliderTrack.Size = UDim2.new(1, 0, 0, 5)
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
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 15, 0, 15)
    SliderButton.Position = UDim2.new(0, -7.5, 0.5, -7.5)
    SliderButton.Text = ""
    SliderButton.BackgroundColor3 = Theme.Text
    SliderButton.Parent = SliderTrack
    
    CreateCorner(SliderButton, 7)
    CreateStroke(SliderButton, 1, Theme.Accent)
    
    -- Initialize slider position
    local function UpdateSlider(pos)
        local relativeX = math.clamp(pos.X - SliderTrack.AbsolutePosition.X, 0, SliderTrack.AbsoluteSize.X)
        local percentage = relativeX / SliderTrack.AbsoluteSize.X
        value = math.floor(minValue + (maxValue - minValue) * percentage)
        
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderButton.Position = UDim2.new(percentage, -7.5, 0.5, -7.5)
        Label.Text = name .. ": " .. value
        
        if callback then
            pcall(callback, value)
        end
    end
    
    -- Set initial value
    if defaultValue then
        local percentage = (defaultValue - minValue) / (maxValue - minValue)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderButton.Position = UDim2.new(percentage, -7.5, 0.5, -7.5)
    end
    
    -- Mouse interactions
    SliderButton.MouseButton1Down:Connect(function()
        sliding = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
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

-- DROPDOWN COMPONENT
function Velto:AddDropdown(name, options, defaultOption, callback)
    local selected = defaultOption or options[1]
    local open = false
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local DropdownFrame = Instance.new("Frame")
    if inSection then
        DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
        DropdownFrame.BackgroundTransparency = 1
    else
        DropdownFrame.Size = UDim2.new(1, -20, 0, 60)
        DropdownFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 40)
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
    DropdownButton.Size = UDim2.new(1, 0, 0, 30)
    DropdownButton.Position = UDim2.new(0, 0, 0, 25)
    DropdownButton.Text = selected
    DropdownButton.TextColor3 = Theme.Text
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextSize = 14
    DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    DropdownButton.BackgroundColor3 = Theme.Tertiary
    DropdownButton.Parent = DropdownFrame
    
    CreateCorner(DropdownButton, 6)
    CreateStroke(DropdownButton, 1, Color3.fromRGB(50, 56, 66))
    
    local DropdownIcon = Instance.new("ImageLabel")
    DropdownIcon.Size = UDim2.new(0, 20, 0, 20)
    DropdownIcon.Position = UDim2.new(1, -25, 0.5, -10)
    DropdownIcon.Image = "rbxassetid://6031090990" -- Down arrow icon
    DropdownIcon.BackgroundTransparency = 1
    DropdownIcon.Parent = DropdownButton
    
    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, 0, 0, 0)
    DropdownList.Position = UDim2.new(0, 0, 0, 55)
    DropdownList.BackgroundColor3 = Theme.Tertiary
    DropdownList.ClipsDescendants = true
    DropdownList.Visible = false
    DropdownList.Parent = DropdownFrame
    
    CreateCorner(DropdownList, 6)
    CreateStroke(DropdownList, 1, Theme.Accent)
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 1)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = DropdownList
    
    -- Forward declare for closures
    local ToggleDropdown

    -- Create options
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.Text = option
        OptionButton.TextColor3 = Theme.Text
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.BackgroundColor3 = Theme.Tertiary
        OptionButton.LayoutOrder = i
        OptionButton.Parent = DropdownList
        
        OptionButton.MouseButton1Click:Connect(function()
            selected = option
            DropdownButton.Text = option
            ToggleDropdown()
            
            if callback then
                pcall(callback, option)
            end
        end)
        
        -- Hover effect
        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(48, 52, 62) }):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Tertiary }):Play()
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

-- TEXTBOX COMPONENT
function Velto:AddTextbox(labelText, defaultValue, placeholder, onCommit)
    local parent = rawget(self, "Content")
    local inSection = parent and parent ~= self.ScrollFrame
    local Row = Instance.new("Frame")
    if inSection then
        Row.Size = UDim2.new(1, 0, 0, 56)
        Row.Position = UDim2.new(0, 0, 0, 0)
    else
        Row.Size = UDim2.new(1, -20, 0, 56)
        Row.Position = UDim2.new(0, 10, 0, #self.Elements * 60)
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
    Box.Size = UDim2.new(1, 0, 0, 30)
    Box.Position = UDim2.new(0, 0, 0, 24)
    Box.Text = tostring(defaultValue or "")
    Box.PlaceholderText = placeholder or ""
    Box.TextColor3 = Theme.Text
    Box.PlaceholderColor3 = Color3.fromRGB(170,170,170)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Box.BackgroundColor3 = Theme.Secondary
    Box.ClearTextOnFocus = false
    Box.Parent = Row

    CreateCorner(Box, 6)
    CreateStroke(Box, 1, Theme.Accent)

    Box.FocusLost:Connect(function(enter)
        if onCommit then pcall(onCommit, Box.Text, enter) end
    end)

    table.insert(self.Elements, Row)
    return Row
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

    local IntroLabel = Instance.new("TextLabel")
    IntroLabel.Size = UDim2.new(0, 0, 0, 40)
    IntroLabel.Position = UDim2.new(0.5, 0, 0.5, -20)
    IntroLabel.Text = "Made By RLW"
    IntroLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IntroLabel.Font = Enum.Font.GothamBold
    IntroLabel.TextSize = 24
    IntroLabel.BackgroundTransparency = 1
    IntroLabel.TextTransparency = 1
    IntroLabel.ZIndex = 100
    IntroLabel.Parent = IntroGui

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
        task.wait(3)
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            IntroLabel:Destroy()
            IntroGui:Destroy()
        end)
    end)
end

function VeltoUI.CreateWindow(title, size)
    return Velto:CreateWindow(title, size)
end

return VeltoUI
