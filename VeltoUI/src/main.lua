local Velto = {}
Velto.__index = Velto

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Import modules
local Theme = require(script.Parent.Themes.Default)
local IntroAnimation = require(script.Parent.IntroAnimation)
local Tab = require(script.Parent.Components.Tab)
local Button = require(script.Parent.Components.Button)
local Toggle = require(script.Parent.Components.Toggle)
local Textbox = require(script.Parent.Components.Textbox)
local Slider = require(script.Parent.Components.Slider)
local Dropdown = require(script.Parent.Components.Dropdown)
local Label = require(script.Parent.Components.Label)

-- Utility functions
local CreateShadow = require(script.Parent.Utilities.Shadow)
local CreateCorner = require(script.Parent.Utilities.Corner)
local CreateStroke = require(script.Parent.Utilities.Stroke)

function Velto:CreateWindow(title, size)
    local self = setmetatable({}, Velto)
    self.Tabs = {}
    self.CurrentTab = nil
    self.Elements = {}
    self.TabCount = 0
    
    -- Create main UI container
    local UI = Instance.new("ScreenGui")
    UI.Name = "VeltoUI_" .. title:gsub("%s+", "")
    UI.ResetOnSpawn = false
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    UI.Parent = CoreGui
    
    -- Main window frame
    local Frame = Instance.new("Frame")
    Frame.Size = size or UDim2.new(0, 550, 0, 400)
    Frame.Position = UDim2.new(0.5, -300, 0.5, -225)
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
    
    CreateCorner(TitleBar, 0)
    
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
    
    CreateCorner(CloseButton, 0)
    
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Error
        }):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Secondary
        }):Play()
    end)
    
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
    
    -- Scroll frame for content
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollFrame.Position = UDim2.new(0, 0, 0, 0)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.ScrollBarImageColor3 = Theme.Accent
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Parent = ContentContainer
    
    -- UI Stroke for content area
    local ContentStroke = Instance.new("UIStroke")
    ContentStroke.Thickness = 1
    ContentStroke.Color = Theme.Secondary
    ContentStroke.Parent = ContentContainer
    
    CreateCorner(ContentContainer, 6)
    
    self.UI = UI
    self.Main = Frame
    self.TitleBar = TitleBar
    self.TabContainer = TabContainer
    self.ContentContainer = ContentContainer
    self.ScrollFrame = ScrollFrame
    
    -- Play intro animation
    IntroAnimation:Play(UI)
    
    return self
end

-- Attach component methods
Velto.CreateTab = Tab.Create
Velto.AddButton = Button.Add
Velto.AddToggle = Toggle.Add
Velto.AddTextbox = Textbox.Add
Velto.AddSlider = Slider.Add
Velto.AddDropdown = Dropdown.Add
Velto.AddLabel = Label.Add

return Velto