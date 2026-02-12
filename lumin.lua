--[[
    LUMIN UI FRAMEWORK - FINAL FIXED VERSION
    Aesthetic: Modern Emerald & Deep Navy
    Developer: RLWGG / Leaf Framework
]]

local Lumin = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Yardımcı Fonksiyon: Animasyonlar
local function ApplyTween(obj, properties, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad), properties):Play()
end

function Lumin:CreateWindow(arg)
    -- HATA DÜZELTME: İlk parametrenin tipini kontrol et
    local config = {}
    if type(arg) == "table" then
        config = arg
    elseif type(arg) == "string" then
        config.Name = arg
    else
        config.Name = "LUMIN HUB"
    end

    local hubName = tostring(config.Name or "LUMIN HUB")
    local accentColor = Color3.fromRGB(0, 184, 148) -- Emerald Green
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Lumin_" .. tostring(math.random(1000, 9999))
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false

    -- Ana Çerçeve
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 520, 0, 360)
    main.Position = UDim2.new(0.5, -260, 0.5, -180)
    main.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    main.BorderSizePixel = 0
    main.Parent = screenGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    -- Sol Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 150, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

    -- Başlık
    local title = Instance.new("TextLabel")
    title.Text = hubName
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.TextColor3 = accentColor
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = sidebar

    -- Tab Konteynırı
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Size = UDim2.new(1, 0, 1, -65)
    tabContainer.Position = UDim2.new(0, 0, 0, 60)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 0
    tabContainer.Parent = sidebar
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = tabContainer

    -- İçerik Alanı
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -165, 1, -20)
    contentArea.Position = UDim2.new(0, 160, 0, 10)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    -- Sürükleme Özelliği
    local dragging, dragInput, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    local tabs = {}
    local firstTab = true

    function tabs:CreateTab(name)
        name = tostring(name or "Tab")
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = accentColor
        page.Parent = contentArea
        Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(25, 32, 45)
        tabBtn.Text = name
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 14
        tabBtn.Parent = tabContainer
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

        if firstTab then 
            page.Visible = true
            tabBtn.TextColor3 = accentColor
            firstTab = false 
        end

        tabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(contentArea:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, b in pairs(tabContainer:GetChildren()) do if b:IsA("TextButton") then ApplyTween(b, {TextColor3 = Color3.fromRGB(200, 200, 200)}) end end
            page.Visible = true
            ApplyTween(tabBtn, {TextColor3 = accentColor})
        end)

        local elements = {}

        -- BUTTON
        function elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.96, 0, 0, 38)
            btn.BackgroundColor3 = Color3.fromRGB(30, 38, 52)
            btn.Text = "   " .. tostring(text)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.Gotham
            btn.Parent = page
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(callback)
        end

        -- TOGGLE
        function elements:Toggle(text, callback)
            local state = false
            local tFrame = Instance.new("TextButton")
            tFrame.Size = UDim2.new(0.96, 0, 0, 38)
            tFrame.BackgroundColor3 = Color3.fromRGB(30, 38, 52)
            tFrame.Text = "   " .. tostring(text)
            tFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
            tFrame.TextXAlignment = Enum.TextXAlignment.Left
            tFrame.Font = Enum.Font.Gotham
            tFrame.Parent = page
            Instance.new("UICorner", tFrame).CornerRadius = UDim.new(0, 6)

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 20, 0, 20)
            box.Position = UDim2.new(1, -30, 0.5, -10)
            box.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
            box.Parent = tFrame
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

            tFrame.MouseButton1Click:Connect(function()
                state = not state
                ApplyTween(box, {BackgroundColor3 = state and accentColor or Color3.fromRGB(50, 60, 80)})
                callback(state)
            end)
        end

        return elements
    end
    return tabs
end

return Lumin
