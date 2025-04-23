local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.Themes.Default)

local Dropdown = {}

function Dropdown.Add(self, name, options, defaultOption, callback)
    local selected = defaultOption or options[1]
    local open = false
    
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -20, 0, 60)
    DropdownFrame.Position = UDim2.new(0, 10, 0, #self.Elements * 40)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = self.Content
    
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
    DropdownButton.BackgroundColor3 = Theme.Secondary
    DropdownButton.Parent = DropdownFrame
    
    CreateCorner(DropdownButton, 6)
    CreateStroke(DropdownButton, 1, Theme.Accent)
    
    local DropdownIcon = Instance.new("ImageLabel")
    DropdownIcon.Size = UDim2.new(0, 20, 0, 20)
    DropdownIcon.Position = UDim2.new(1, -25, 0.5, -10)
    DropdownIcon.Image = "rbxassetid://6031090990" -- Down arrow icon
    DropdownIcon.BackgroundTransparency = 1
    DropdownIcon.Parent = DropdownButton
    
    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, 0, 0, 0)
    DropdownList.Position = UDim2.new(0, 0, 0, 55)
    DropdownList.BackgroundColor3 = Theme.Secondary
    DropdownList.ClipsDescendants = true
    DropdownList.Visible = false
    DropdownList.Parent = DropdownFrame
    
    CreateCorner(DropdownList, 6)
    CreateStroke(DropdownList, 1, Theme.Accent)
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 1)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = DropdownList
    
    -- Create options
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.Text = option
        OptionButton.TextColor3 = Theme.Text
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.BackgroundColor3 = Theme.Secondary
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
            TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            }):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Secondary
            }):Play()
        end)
    end
    
    -- Update dropdown list size
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        DropdownList.Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end)
    
    local function ToggleDropdown()
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

return Dropdown