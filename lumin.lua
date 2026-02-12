local LuminLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function LuminLib:CreateWindow(hubName)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = hubName .. "_UI"
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    -- Ana Çerçeve
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 550, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    -- Sol Sidebar (Tablar için)
    local sideBar = Instance.new("Frame")
    sideBar.Size = UDim2.new(0, 150, 1, 0)
    sideBar.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    sideBar.BorderSizePixel = 0
    sideBar.Parent = mainFrame
    
    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 12)
    sideCorner.Parent = sideBar

    -- Hub Başlığı
    local title = Instance.new("TextLabel")
    title.Text = hubName
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = sideBar

    -- Tab Konteynırı
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Size = UDim2.new(1, 0, 1, -70)
    tabContainer.Position = UDim2.new(0, 0, 0, 60)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 0
    tabContainer.Parent = sideBar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = tabContainer

    -- İçerik Alanı (Sayfalar)
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -160, 1, -20)
    contentFrame.Position = UDim2.new(0, 160, 0, 10)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    local pages = {}

    function LuminLib:CreateTab(tabName)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0.9, 0, 0, 35)
        tabButton.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.TextSize = 14
        tabButton.Parent = tabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = tabButton

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Color3.fromRGB(0, 184, 148)
        page.Parent = contentFrame
        
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.Parent = page

        tabButton.MouseButton1Click:Connect(function()
            for _, p in pairs(contentFrame:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            for _, b in pairs(tabContainer:GetChildren()) do
                if b:IsA("TextButton") then 
                    TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 35, 50), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
                end
            end
            page.Visible = true
            TweenService:Create(tabButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 184, 148), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)

        local elements = {}

        -- Buton Oluşturma
        function elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.95, 0, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(30, 38, 55)
            btn.Text = "  " .. text
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.GothamMedium
            btn.Parent = page
            
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(callback)
        end

        -- Toggle Oluşturma
        function elements:Toggle(text, callback)
            local toggled = false
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0.95, 0, 0, 40)
            toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 38, 55)
            toggleBtn.Text = "  " .. text
            toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
            toggleBtn.Font = Enum.Font.GothamMedium
            toggleBtn.Parent = page
            
            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 20, 0, 20)
            indicator.Position = UDim2.new(1, -30, 0.5, -10)
            indicator.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
            indicator.Parent = toggleBtn
            Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 4)

            toggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                local color = toggled and Color3.fromRGB(0, 184, 148) or Color3.fromRGB(50, 60, 80)
                TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
                callback(toggled)
            end)
        end

        return elements
    end
    
    -- Draggable (Sürüklenebilir) yapma özelliği
    local dragging, dragInput, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return LuminLib
end

return LuminLib
