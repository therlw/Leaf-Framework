-- Leaf UI
local Leaf = {}

-- Premium Theme Configuration (Futuristic Dark - Neon Cyan)
local Theme = {
    -- Base and layers
    Primary = Color3.fromRGB(14, 15, 18),   -- #0E0F12 deep charcoal
    Secondary = Color3.fromRGB(18, 20, 24), -- slightly lighter panel
    Tertiary = Color3.fromRGB(22, 24, 28),  -- inner sections
    Overlay = Color3.fromRGB(8, 10, 14),
    Dark = Color3.fromRGB(10, 11, 14),

    -- Accents
    Accent = Color3.fromRGB(0, 194, 255),       -- primary neon cyan
    AccentSecondary = Color3.fromRGB(0, 140, 255), -- deeper cyan for strokes
    SpringGreen = Color3.fromRGB(0, 194, 255),  -- align with Accent (visual parity)

    -- Text
    Text = Color3.fromRGB(240, 245, 255),      -- #F0F5FF soft white glow
    TextDim = Color3.fromRGB(160, 170, 185),
    Disabled = Color3.fromRGB(95, 105, 120),

    -- Status
    Success = Color3.fromRGB(0, 225, 255),
    Warning = Color3.fromRGB(255, 180, 70),
    Error = Color3.fromRGB(255, 95, 95),
    Light = Color3.fromRGB(240, 245, 255)
}

Leaf.__index = Leaf

-- Services
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Theme already defined above

-- (Removed) MainConfig and SectionConfig: all main window and section visuals are hardcoded in code paths now.

-- Content (right-side section) configuration
local ContentConfig = {
    Margin = { Left = 0, Right = 10, Top = 10, Bottom = 10 },
    Background = {
        Enabled = true,
        Color = Theme.Secondary,
        Transparency = 0.06,
        CornerRadius = 16,
        Stroke = { Enabled = true, Color = Theme.AccentSecondary, Thickness = 1, Transparency = 0.82 },
        Gradient = { Enabled = true, Preset = "Secondary" },
        GlassOverlay = true,
        -- Default background image (main content area)
        Image = { Enabled = true, ImageId = 82773849228613, Transparency = 0.92, ScaleType = Enum.ScaleType.Stretch, TileSize = UDim2.new(0,128,0,128) },
        SyncWithNav = true, -- NavBar temasıyla otomatik eşitle
    },
    Padding = { Left = 14, Right = 14, Top = 12, Bottom = 12 },
}

-- Expose ContentConfig
Leaf.ContentConfig = ContentConfig

-- small utilities
local function _deepCopy(t)
    if type(t) ~= "table" then return t end
    local r = {}
    for k, v in pairs(t) do r[k] = _deepCopy(v) end
    return r
end

local function _deepMerge(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" and type(dst[k]) == "table" then
            _deepMerge(dst[k], v)
        else
            dst[k] = v
        end
    end
end

-- Gradient presets
local Gradients = {
    -- subtle top->bottom darkening
    Main = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 17, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 13, 16))
    },
    Secondary = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 22, 26)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 18, 22))
    },
    Accent = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 230, 255))
    },
    Success = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 160, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 220, 255))
    },
    Premium = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 136)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 229, 255))
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
    frame.Size = size or UDim2.new(0, 100, 0, 100)
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
    shadow.ImageTransparency = intensity or 0.85
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, radius or 18, 1, radius or 18)
    shadow.Position = UDim2.new(0, -(radius or 18)/2, 0, -(radius or 18)/2)
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = element.ZIndex - 1
    shadow.Parent = element
    -- mirror corner radius from parent to avoid sharp edges on shadow
    local parentCorner = element:FindFirstChildOfClass("UICorner")
    if parentCorner then
        local sc = Instance.new("UICorner")
        sc.CornerRadius = parentCorner.CornerRadius
        sc.Parent = shadow
    end
    return shadow
end

local function CreateStroke(element, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or Theme.Accent
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.65
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = element
    return stroke
end

-- Glass reflection overlay (non-blocking, under content z-order)
local function AddGlassOverlay(parent)
    if not parent then return end
    local glass = Instance.new("Frame")
    glass.Name = "GlassOverlay"
    glass.Size = UDim2.fromScale(1,1)
    glass.BackgroundTransparency = 1
    glass.ZIndex = 1 -- keep beneath main content
    glass.Parent = parent
    -- top light sweep
    local sweep = Instance.new("Frame")
    sweep.Name = "Sweep"
    sweep.Size = UDim2.new(1, 0, 0, math.max(6, math.floor((parent.AbsoluteSize and parent.AbsoluteSize.Y or 100) * 0.08)))
    sweep.Position = UDim2.new(0, 0, 0, 0)
    sweep.BackgroundTransparency = 1
    sweep.ZIndex = glass.ZIndex
    sweep.Parent = glass
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.3, Theme.Light),
        ColorSequenceKeypoint.new(1, Theme.Primary)
    }
    grad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.92),
        NumberSequenceKeypoint.new(0.4, 0.96),
        NumberSequenceKeypoint.new(1, 1)
    }
    grad.Rotation = 90
    grad.Parent = sweep
    -- corner rounding follow
    local c = parent:FindFirstChildOfClass("UICorner")
    if c then
        local cc = Instance.new("UICorner")
        cc.CornerRadius = c.CornerRadius
        cc.Parent = glass
    end
    return glass
end

-- Hover + Press glow/scale utilities
local function ApplyHoverPressEffects(btn, opts)
    if not btn then return end
    opts = opts or {}
    local hoverScale = opts.hoverScale or 1.05
    local pressScale = opts.pressScale or 0.96
    local glowColor = opts.glowColor or Theme.Accent
    local dur = opts.duration or 0.16

    local scale = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
    scale.Scale = 1
    scale.Parent = btn

    -- Check if button has a stroke for hover effects
    local stroke = btn:FindFirstChildOfClass("UIStroke")
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(scale, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = hoverScale }):Play()
        if stroke then
            TweenService:Create(stroke, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 0.35 }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(scale, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
        if stroke then
            TweenService:Create(stroke, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 0.85 }):Play()
        end
    end)
    if btn:IsA("GuiButton") then
        btn.MouseButton1Down:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.10, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = pressScale }):Play()
        end)
        btn.MouseButton1Up:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Scale = hoverScale }):Play()
        end)
    end
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

-- Reusable cyan keycap styling (rounded pill with neon stroke)
local function StyleKeycap(label, opts)
    if not label or not label.Parent then return end
    opts = opts or {}
    local baseTrans = opts.baseTransparency or 0.7
    local hoverTrans = opts.hoverTransparency or 0.6
    local activeTrans = opts.activeTransparency or 0.35

    label.BackgroundColor3 = opts.bgColor or Theme.Tertiary
    label.BackgroundTransparency = opts.bgTransparency or 0
    label.TextColor3 = opts.textColor or Theme.Text
    label.ZIndex = math.max(label.ZIndex or 1, (label.Parent.ZIndex or 1) + 1)

    local c = label:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    c.CornerRadius = UDim.new(1,0)
    c.Parent = label

    local s = label:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = Theme.Accent
    s.Thickness = 1
    s.Transparency = baseTrans
    s.LineJoinMode = Enum.LineJoinMode.Round
    s.Parent = label

    local hoverTarget = label.Parent:IsA("GuiButton") and label.Parent or label
    if hoverTarget then
        hoverTarget.MouseEnter:Connect(function()
            TweenService:Create(s, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = hoverTrans }):Play()
        end)
        hoverTarget.MouseLeave:Connect(function()
            TweenService:Create(s, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = baseTrans }):Play()
        end)
        if hoverTarget:IsA("GuiButton") then
            hoverTarget.MouseButton1Down:Connect(function()
                TweenService:Create(s, TweenInfo.new(0.10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = activeTrans }):Play()
            end)
            hoverTarget.MouseButton1Up:Connect(function()
                TweenService:Create(s, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = hoverTrans }):Play()
            end)
        end
    end
    return s
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

-- Water ripple effect (works for both GuiButton and Frame/GuiObject)
local function CreateRippleEffect(target)
    if not target or not target:IsA("GuiObject") then return end

    local function spawnRipple(container)
        -- core ripple fill
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Theme.Accent
        ripple.BackgroundTransparency = 0.7
        ripple.ZIndex = (container.ZIndex or 5) + 1
        ripple.Parent = container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple

        TweenService:Create(ripple, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 8, 1, 8),
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.36, function() if ripple then ripple:Destroy() end end)

        -- glow shockwave outline
        local ring = Instance.new("Frame")
        ring.Size = UDim2.fromOffset(0,0)
        ring.Position = UDim2.new(0.5,0,0.5,0)
        ring.AnchorPoint = Vector2.new(0.5,0.5)
        ring.BackgroundTransparency = 1
        ring.ZIndex = (container.ZIndex or 5) + 2
        ring.Parent = container
        local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(1,0); rc.Parent = ring
        local rs = Instance.new("UIStroke"); rs.Thickness = 2; rs.Color = Theme.AccentSecondary; rs.Transparency = 0.2; rs.Parent = ring
        TweenService:Create(ring, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 16, 1, 16) }):Play()
        TweenService:Create(rs, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
        task.delay(0.48, function() if ring then ring:Destroy() end end)
    end

    if target:IsA("GuiButton") then
        target.MouseButton1Click:Connect(function()
            spawnRipple(target)
        end)
    else
        -- For non-button frames, use InputBegan with mouse left click
        target.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                spawnRipple(target)
            end
        end)
    end
end

-- NAVBAR AYAR BLOĞU (Türkçe)
-- Bu tablo üzerinden NavBar (sol yan menü) ile ilgili tüm görsel ayarları tek noktadan düzenleyebilirsiniz.
-- Değişiklik yapmanız yeterlidir; alttaki NavBar oluşturma kısmında bu değerler uygulanır.
local NavConfig = {
    -- Genel boyutlar
    Width = 180,                                   -- NavBar genişliği (px)
    BackgroundColor = Theme.Dark,                  -- Arkaplan rengi (Theme.Secondary / Theme.Dark vb.)
    BackgroundTransparency = 0,                    -- Arkaplan saydamlığı (0 = opak, 1 = tamamen saydam)
    CornerRadius = 7,                              -- Köşe yuvarlama yarıçapı (px)

    -- Kenarlık (UIStroke) ayarları
    Stroke = {
        Enabled = false,                            -- Kenarlık açık/kapat
        Color = Theme.Accent,                      -- Kenarlık rengi
        Thickness = 1,                             -- Kenarlık kalınlığı (px)
        Transparency = 0.45,                       -- Kenarlık saydamlığı (0 net, 1 görünmez)
    },

    -- İç neon parıltısı (NeonGlow) ayarları
    InnerGlowEnabled = true,                       -- İç neon parıltısı açık/kapat
    InnerGlowImageId = 107914684814320,            -- Parıltı için kullanılan dilimlenebilir görsel asset id
    InnerGlowTransparency = 0.8,                   -- Parıltı saydamlığı (daha küçük = daha belirgin)

    -- Gradient ve cam efekti (glass overlay) ayarları
    GradientEnabled = false,                        -- NavBar üstünde hafif degrade kullan
    GradientPreset = "Secondary",                  -- Gradients tablosundan bir anahtar: "Main", "Secondary" vb.
    GlassOverlayEnabled = true,                    -- Cam/ışık süpürme efekti açık/kapat

    -- İkon ve partikül ayarları
    IconsEnabled = true,                              -- Sağ/sol üst köşe ikonlarını göster
    RightIconId = 73659725499742,                     -- Sağ üst ikon asset id
    LeftIconId = 79100459650541,                      -- Sol (sağdaki ikonun hemen solu) ikon asset id
    IconColor = Theme.Text,                           -- İkon rengi (Theme.Text önerilir)
    ParticlesEnabled = true,                          -- İkonların etrafında süzülen partiküller
    ParticlesPerIcon = 7,                             -- Her ikon için partikül sayısı

    -- İçerik alanı ile ilgili ofsetler (NavBar genişliği değişince içerik otomatik kayar)
    ContentGap = 20,                               -- NavBar ile içerik alanı arasındaki yatay boşluk (px)

    -- Profil kartı ayarları
    Profile = {
        Enabled = true,                                 -- Profil bölümü açık/kapat
        Size = UDim2.new(1, -16, 0, 84),                -- Genişlik/yükseklik
        Position = UDim2.new(0, 8, 0, 64),              -- Konum
        BackgroundColor = Theme.Tertiary,               -- Arkaplan rengi
        UsernameText = nil,                             -- Varsayılan: oyuncu adını gösterir (nil)
        UsernameTextColor = Theme.Text,                 -- Kullanıcı adı rengi
        SubInfoText = "Premium Member",                -- Alt bilgi metni
        SubInfoTextColor = Theme.TextDim,               -- Alt bilgi rengi
        ProgressEnabled = true,                         -- İlerleme barı açık/kapat
        InitialProgressScale = 0.62,                    -- İlerleme barı başlangıç oranı (0-1)
    },

    -- Arama satırı ayarları
    Search = {
        Enabled = true,                                 -- Arama satırı açık/kapat
        Size = UDim2.new(0.95, -16, 0, 32),
        Position = UDim2.new(0, 8, 0, 156),
        BackgroundColor = Theme.Tertiary,
        IconId = 6031154877,                            -- Büyüteç ikon id
        LabelText = "Search",                          -- Etiket metni
        LabelTextColor = Theme.Text,
        KeycapText = "Tab",                             -- Sağdaki kısayol yazısı
        HoverEffects = true,                            -- Hover/press efektleri aktif mi
        Ripple = true,                                  -- Su dalgası efekti
    },

    -- Sekme listesi (sol menü) ayarları
    Tabs = {
        ListPadding = 10,                                -- Tab butonları arası boşluk (px)
        PaddingTop = 8,                                 -- Üst iç boşluk
        PaddingLeft = 10,                               -- Sol iç boşluk
        PaddingRight = 10,                              -- Sağ iç boşluk
        ScrollBarThickness = 0,                         -- Kaydırma çubuğu kalınlığı (0 = gizle)
    },

    -- Tek tek Tab butonlarının varsayılan stil/anim ayarları
    TabButton = {
        Height = 25,                                    -- Buton yüksekliği (px)
        TextSize = 14,                                  -- Etiket yazı boyutu
        InactiveBgTransparency = 0.7,                   -- Pasif arkaplan saydamlığı
        HoverBgTransparency = 0,                      -- Hover arkaplan saydamlığı
        ActiveBgTransparency = 0.55,                    -- Aktif arkaplan saydamlığı
        TextColor = Theme.Text,                         -- Hover/aktif yazı rengi
        TextDimColor = Theme.TextDim,                   -- Pasif yazı rengi
        SelectionStrokeVisibleAlpha = 0.35,             -- Aktif seçim çerçevesi saydamlığı
        SelectionStrokeHoverAlpha = 0.6,                -- Hover seçim çerçevesi saydamlığı
        SelectionStrokeHiddenAlpha = 0.92,              -- Pasif seçim çerçevesi saydamlığı
        NeonImageTransparencyActive = 0.6,              -- Aktif neon arkaplan saydamlığı
        NeonImageTransparencyIdle = 0.88,               -- Pasif neon arkaplan saydamlığı
        SlideInOffset = UDim2.new(0, 0, 0.03, 12),      -- İçerik ilk gösterimde kayma ofseti
        SlideOutOffset = UDim2.new(0, 0, -0.03, -12),   -- İçerik kapanırken kayma ofseti
        SlideDurIn = 0.35,                              -- İçeriğin giriş animasyon süresi
        SlideDurOut = 0.25,                             -- İçeriğin çıkış animasyon süresi
        IconActiveColor = Theme.Text,                   -- Aktif sekmede ikon rengi
        IconInactiveColor = Theme.TextDim,              -- Pasif sekmede ikon rengi
        -- İsteğe bağlı ikon görsel değiştirme: IconActiveId, IconInactiveId
    },

    -- Tab göstergesi (sol ince çubuk) ayarları
    Indicator = {
        -- Modlar: "Bar" (ince çizgi) | "Image" (ikon/nokta)
        Mode = "Image",
        Width = 3,                                      -- Bar modunda genişlik (px)
        TargetHeight = 20,                              -- Bar modunda yükseklik hedefi (px)
        ExpandDur = 0.18,                               -- Açılma animasyon süresi (Bar)
        ImageId = 4726772330,                       -- Varsayılan görsel asset id (Bar için doku; Image modunda pasif ikon)
        ActiveImageId = nil,                            -- Image modunda aktif ikon id (nil = ImageId kullan)
        Size = UDim2.fromOffset(12, 12),                -- Image modunda ikon boyutu
        Color = Theme.Light,                  -- Görsel renk (aktif)
        InactiveColor = Theme.TextDim,                  -- Image modunda pasif renk
        Transparency = 0.2,                             -- Görsel saydamlık
        Visible = true,                                 -- Göster/gizle
    },

    -- Alt kısımdaki Ayarlar (Settings) butonu ayarları
    Settings = {
        DividerEnabled = true,                          -- Üstünde ince ayırıcı çizgi olsun mu
        DividerTransparency = 0.88,                     -- Ayırıcı saydamlığı (0-1)
        StrokeEnabled = false,                          -- Settings ikonuna stroke uygula (varsayılan kapalı)
    },
}

-- Main Window Creation
function Leaf:CreateWindow(options, size, accentColor, tabs)
    -- Handle both old style (title, size, color, tabs) and new style (options table)
    local title
    local customUsername = nil
    
    print("[LeafUI DEBUG] options type: " .. type(options))
    print("[LeafUI DEBUG] options value: " .. tostring(options))
    
    if type(options) == "table" then
        -- New style: options is a table
        print("[LeafUI DEBUG] Table detected!")
        title = tostring(options.title) or "Leaf UI"
        size = options.size or UDim2.new(0, 650, 0, 450)
        accentColor = options.accentColor or Color3.fromRGB(0, 194, 255)
        tabs = options.tabs
        customUsername = options.username
        
        print("[LeafUI DEBUG] options.title: " .. tostring(options.title))
        print("[LeafUI DEBUG] options.tabs: " .. tostring(options.tabs))
        print("[LeafUI DEBUG] type(options.tabs): " .. tostring(type(options.tabs)))
        if type(options.tabs) == "table" then
            print("[LeafUI DEBUG] #options.tabs: " .. #options.tabs)
        end
    else
        -- Old style: options is the title string
        title = tostring(options) or "Leaf UI"
        print("[LeafUI DEBUG] String detected (old style)")
    end
    
    -- Set custom username in NavConfig if provided
    if customUsername then
        NavConfig.Profile.UsernameText = customUsername
    else
        NavConfig.Profile.UsernameText = nil  -- Will use actual player name
    end
    
    local self = setmetatable({}, Leaf)
    self.Tabs = {}
    self.CurrentTab = nil
    self.Elements = {}
    self.Notifications = {}
    
    -- Safe config path (handle nil title)
    local safeTitle = tostring(title) or "Default"
    self.ConfigPath = "Leaf_"..safeTitle:gsub("%s+",""):gsub("[^%w_]","_")..".json"
    self.State = { 
        Position = {0.5, -300, 0.5, -200}, 
        Minimized = false, 
        ToggleKey = "RightShift", 
        Size = {0, 600, 0, 500},
        Theme = "Dark"
    }
    
    -- Load saved configuration (with executor compatibility check)
    local useFileSystem = pcall(function() return isfile and readfile and writefile end) and isfile and readfile
    
    if useFileSystem then
        local ok, raw = pcall(readfile, self.ConfigPath)
        if ok and raw then
            local ok2, dec = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok2 and type(dec) == "table" then
                for k,v in pairs(dec) do self.State[k] = v end
            end
        end
    end
    
    -- Create UI container
    local UI = Instance.new("ScreenGui")
    UI.Name = "LeafUI_"..title:gsub("%s+", ""):gsub("[^%w_]", "_")
    UI.ResetOnSpawn = false
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    UI.Parent = CoreGui

    -- Background overlay for focus effect (hardcoded)
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.Position = UDim2.new(0, 0, 0, 0)
    Overlay.BackgroundColor3 = Theme.Dark
    Overlay.BackgroundTransparency = 0.75
    Overlay.ZIndex = 0
    Overlay.Visible = true
    Overlay.Parent = UI

    -- Ambient background particles (soft glow dots) (hardcoded)
    do
        local AmbientLayer = Instance.new("Frame")
        AmbientLayer.Name = "AmbientParticles"
        AmbientLayer.Size = UDim2.fromScale(1,1)
        AmbientLayer.BackgroundTransparency = 1
        AmbientLayer.ZIndex = 1
        AmbientLayer.Parent = UI
        coroutine.wrap(function()
            for i=1, 24 do
                local d = Instance.new("Frame")
                d.Size = UDim2.fromOffset(math.random(2,4), math.random(2,4))
                d.AnchorPoint = Vector2.new(0.5,0.5)
                d.Position = UDim2.fromScale(math.random(), math.random())
                d.BackgroundColor3 = (math.random() < 0.5) and Theme.Accent or Theme.AccentSecondary
                d.BackgroundTransparency = 0.75
                d.BorderSizePixel = 0
                d.ZIndex = 1
                d.Parent = AmbientLayer
                local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1,0); dc.Parent = d
                local drift = TweenService:Create(d, TweenInfo.new(math.random(10,16), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    Position = UDim2.fromScale(math.clamp(d.Position.X.Scale + (math.random(-10,10)/200), 0,1), math.clamp(d.Position.Y.Scale + (math.random(-10,10)/200), 0,1)),
                    BackgroundTransparency = 0.9
                })
                drift:Play()
            end
        end)()
    end

    -- Main container with smooth rounded corners (hardcoded Neon Glass)
    local MainContainer = Instance.new("Frame")
    MainContainer.Size = size or UDim2.new(0, 600, 0, 400)
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
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainContainer

    CreateRoundedFrame(MainContainer, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 16, 0, Theme.Primary)
    -- Shadow
    CreateShadow(MainContainer, 0.88, 22)
    -- Gradient
    CreateGradient(MainContainer, "Main")
    -- Outer neon hairline to match reference (hardcoded outline/glow)
    do
        local mcStroke = MainContainer:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        mcStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        mcStroke.Color = Theme.Accent
        mcStroke.Thickness = 1
        mcStroke.Transparency = 0.55
        mcStroke.LineJoinMode = Enum.LineJoinMode.Round
        mcStroke.Parent = MainContainer
        mcStroke.Enabled = true
        -- soft cyan glow hugging the border (masked to rounded corners)
        do
            local glowMask = Instance.new("Frame")
            glowMask.Name = "NeonGlowMask"
            glowMask.BackgroundTransparency = 1
            glowMask.Size = UDim2.new(1, 0, 1, 0)
            glowMask.Position = UDim2.new(0, 0, 0, 0)
            glowMask.ZIndex = 1
            glowMask.ClipsDescendants = true
            glowMask.Parent = MainContainer
            do
                local mcCorner = MainContainer:FindFirstChildOfClass("UICorner")
                if mcCorner then
                    local mk = Instance.new("UICorner")
                    mk.CornerRadius = mcCorner.CornerRadius
                    mk.Parent = glowMask
                end
            end
            local glow = Instance.new("ImageLabel")
            glow.Name = "NeonGlow"
            glow.BackgroundTransparency = 1
            glow.Image = "rbxassetid://5554236805"
            glow.ImageColor3 = Theme.Accent
            glow.ImageTransparency = 0.9
            glow.ScaleType = Enum.ScaleType.Slice
            glow.SliceCenter = Rect.new(10, 10, 118, 118)
            local inset = 9
            glow.Size = UDim2.new(1, inset*2, 1, inset*2)
            glow.Position = UDim2.new(0, -inset, 0, -inset)
            glow.ZIndex = 1
            glow.Parent = glowMask
        end
    end
    AddGlassOverlay(MainContainer)
    
    -- Navigation sidebar
    local NavBar = Instance.new("Frame")
    NavBar.Size = UDim2.new(0, NavConfig.Width, 1, 0)
    NavBar.Position = UDim2.new(0, 0, 0, 0)
    NavBar.BackgroundColor3 = NavConfig.BackgroundColor
    NavBar.BackgroundTransparency = NavConfig.BackgroundTransparency
    NavBar.ClipsDescendants = true
    NavBar.ZIndex = 3
    NavBar.Parent = MainContainer
    local NavBarCorner = Instance.new("UICorner")
    NavBarCorner.CornerRadius = UDim.new(0, NavConfig.CornerRadius)
    NavBarCorner.Parent = NavBar
    
    -- Neon hairline outline to match reference
    do
        local nbStroke = NavBar:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        nbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        nbStroke.Color = NavConfig.Stroke.Color
        nbStroke.Thickness = NavConfig.Stroke.Thickness
        nbStroke.Transparency = NavConfig.Stroke.Transparency
        nbStroke.LineJoinMode = Enum.LineJoinMode.Round
        nbStroke.Parent = NavBar
        -- Kenarlık kapatılmak istenirse
        if not NavConfig.Stroke.Enabled then
            nbStroke.Enabled = false
        end
        -- soft inner cyan glow on NavBar panel
        local existing = NavBar:FindFirstChild("NeonGlow")
        if not existing then
            -- masked neon glow inside a rounded container to avoid sharp edges
            local glowMask = Instance.new("Frame")
            glowMask.Name = "NeonGlowMask"
            glowMask.BackgroundTransparency = 1
            glowMask.Size = UDim2.new(1, 0, 1, 0)
            glowMask.Position = UDim2.new(0, 0, 0, 0)
            glowMask.ZIndex = 3
            glowMask.ClipsDescendants = true
            glowMask.Parent = NavBar
            do
                local nbCorner = NavBar:FindFirstChildOfClass("UICorner")
                if nbCorner then
                    local mk = Instance.new("UICorner")
                    mk.CornerRadius = nbCorner.CornerRadius
                    mk.Parent = glowMask
                end
            end
            local glow = Instance.new("ImageLabel")
            glow.Name = "NeonGlow"
            glow.BackgroundTransparency = 1
            -- İç parıltı görseli ve görünürlüğü NavConfig'ten
            glow.Image = "rbxassetid://" .. tostring(NavConfig.InnerGlowImageId)
            glow.ImageColor3 = Theme.Accent
            glow.ImageTransparency = NavConfig.InnerGlowTransparency
            glow.ScaleType = Enum.ScaleType.Slice
            glow.SliceCenter = Rect.new(10, 10, 118, 118)
            glow.Size = UDim2.new(1, 16, 1, 16)
            glow.Position = UDim2.new(0, -8, 0, -8)
            glow.ZIndex = 3
            glow.Parent = glowMask
        end
        -- İç parıltı tamamen kapatılmak istenirse (varsa kaldır)
        if not NavConfig.InnerGlowEnabled then
            local glowMask = NavBar:FindFirstChild("NeonGlowMask")
            if glowMask then glowMask:Destroy() end
        end
    end
    
    -- Aşağıdaki üç efekt isteğe bağlıdır. NavConfig ile kolayca aç/kapat yapabilirsiniz.
    -- 1) İç dolgu için ekstra bir yuvarlatılmış Frame (hafif katman etkisi)
    do
        local innerLayer = CreateRoundedFrame(NavBar, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 16, 0, Theme.Secondary)
        -- Not: innerLayer opsiyonel bırakmak isterseniz, bu bloğu bir ayar ile sarmalayabilirsiniz.
    end
    -- 2) Gradient (degrade) katmanı
    do
        if NavConfig.GradientEnabled then
            CreateGradient(NavBar, NavConfig.GradientPreset)
        else
            -- Eğer yukarıda otomatik bir gradient oluşturulmuşsa, kapatmak için bulunup yok edilebilir.
            local g = NavBar:FindFirstChildOfClass("UIGradient")
            if g then g:Destroy() end
        end
    end
    -- 3) Cam/ışık süpürme efekti (glass overlay)
    do
        if NavConfig.GlassOverlayEnabled then
            AddGlassOverlay(NavBar)
        else
            local glass = NavBar:FindFirstChild("GlassOverlay")
            if glass then glass:Destroy() end
        end
    end
    -- subtle inner hairline kept via UIStroke above
    
    -- Helper: attach small snowfall-like particles around a given icon on the NavBar
    local function AttachParticlesAround(icon, navFrame, count)
        if not icon or not navFrame then return end
        count = count or 6
        local basePos = icon.Position
        local baseAnchor = icon.AnchorPoint
        
        local function spawnOne()
            if not icon or not icon.Parent or not navFrame or not navFrame.Parent then return end
            local p = Instance.new("ImageLabel")
            p.Name = "Particle"
            p.Image = "rbxassetid://84415711490874"
            p.BackgroundTransparency = 1
            p.ImageColor3 = Theme.Light
            p.ImageTransparency = 0.35
            p.Size = UDim2.new(0, math.random(6, 10), 0, math.random(6, 10))
            p.AnchorPoint = baseAnchor
            -- start slightly above the icon with random horizontal offset
            local startX = math.random(-20, 20)
            local startY = math.random(-22, -8)
            local curX, curY = startX, startY
            p.Position = UDim2.new(basePos.X.Scale, basePos.X.Offset + curX, basePos.Y.Scale, basePos.Y.Offset + curY)
            p.ZIndex = icon.ZIndex
            p.Parent = navFrame

            coroutine.wrap(function()
                while p.Parent do
                    -- compute dynamic fall limit: to bottom of nav (and some go much further)
                    local navHeight = navFrame.AbsoluteSize.Y
                    if navHeight == 0 then navHeight = 260 end -- fallback if not measured yet
                    local fallLimit = navHeight + math.random(20, 80)
                    if math.random() < 0.35 then
                        fallLimit = math.floor(navHeight * 1.8) + math.random(60, 180) -- some flakes travel much further
                    end
                    -- fall step
                    local yStep = math.random(26, 44)
                    local xDrift = math.random(-10, 10)
                    local dur = math.random(60, 100) / 100 -- 0.60s - 1.00s
                    curX = curX + xDrift
                    curY = curY + yStep
                    TweenService:Create(p, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        Position = UDim2.new(basePos.X.Scale, basePos.X.Offset + curX, basePos.Y.Scale, basePos.Y.Offset + curY),
                        ImageTransparency = math.clamp(p.ImageTransparency + (math.random(-8, 8) / 100), 0.2, 0.6)
                    }):Play()
                    task.wait(dur)
                    -- if too far below, fade out then reset above and fade back in
                    if curY > fallLimit then
                        local fadeOutDur = math.random(20, 35) / 100 -- 0.20s - 0.35s
                        TweenService:Create(p, TweenInfo.new(fadeOutDur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                            ImageTransparency = 1
                        }):Play()
                        task.wait(fadeOutDur)

                        -- reset new spawn params above
                        curX = math.random(-20, 20)
                        curY = math.random(-22, -8)
                        p.Size = UDim2.new(0, math.random(6, 10), 0, math.random(6, 10))
                        p.Position = UDim2.new(basePos.X.Scale, basePos.X.Offset + curX, basePos.Y.Scale, basePos.Y.Offset + curY)

                        -- fade back in to a random target alpha
                        local targetAlpha = math.random(25, 55) / 100
                        p.ImageTransparency = 1
                        local fadeInDur = math.random(18, 32) / 100 -- 0.18s - 0.32s
                        TweenService:Create(p, TweenInfo.new(fadeInDur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                            ImageTransparency = targetAlpha
                        }):Play()
                        task.wait(fadeInDur)
                    end
                end
            end)()
        end

        -- staggered spawn: one-by-one with wider random delays and initial jitter
        coroutine.wrap(function()
            local spawned = 0
            -- initial jitter to avoid both icons starting at the same moment
            task.wait(math.random(20, 100) / 100) -- 0.20s - 1.00s
            while spawned < count and icon.Parent and navFrame.Parent do
                task.wait(math.random(35, 120) / 100) -- 0.35s - 1.20s between spawns
                spawnOne()
                spawned += 1
            end
        end)()
    end
    
    -- Sağ üst ikon (NavConfig üzerinden yönetilir)
    local NavIcon = Instance.new("ImageLabel")
    NavIcon.Name = "NavIcon"
    NavIcon.Size = UDim2.new(0, 90, 0, 90)
    NavIcon.AnchorPoint = Vector2.new(1, 0)
    NavIcon.Position = UDim2.new(1, -1, 0, 0)
    NavIcon.BackgroundTransparency = 1
    NavIcon.Image = "rbxassetid://" .. tostring(NavConfig.RightIconId)
    NavIcon.ImageColor3 = NavConfig.IconColor
    NavIcon.ZIndex = 5
    NavIcon.Visible = NavConfig.IconsEnabled
    NavIcon.Parent = NavBar
    
    -- Sol ikon (sağdakinin hemen solu) - NavConfig'ten yönetilir
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
    NavIconLeft.Image = "rbxassetid://" .. tostring(NavConfig.LeftIconId)
    NavIconLeft.ImageColor3 = NavConfig.IconColor
    NavIconLeft.Rotation = -360
    NavIconLeft.ZIndex = 5
    NavIconLeft.Visible = NavConfig.IconsEnabled
    NavIconLeft.Parent = NavBar
    
    -- İkon partikülleri (NavConfig.ParticlesEnabled ile kontrol edilir)
    if NavConfig.ParticlesEnabled and NavConfig.IconsEnabled then
        AttachParticlesAround(NavIcon, NavBar, NavConfig.ParticlesPerIcon)
        AttachParticlesAround(NavIconLeft, NavBar, NavConfig.ParticlesPerIcon)
    end
    
    -- Header with logo and title
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 4
    Header.Parent = NavBar
    -- Minimal runtime config toggle button (overlay visibility)
    do
        local CfgBtn = Instance.new("TextButton")
        CfgBtn.Name = "CfgBtn"
        CfgBtn.Text = "CFG"
        CfgBtn.Size = UDim2.fromOffset(36, 22)
        CfgBtn.Position = UDim2.new(1, -44, 0, 10)
        CfgBtn.BackgroundColor3 = Theme.Tertiary
        CfgBtn.TextColor3 = Theme.Text
        CfgBtn.BackgroundTransparency = 0.2
        CfgBtn.AutoButtonColor = false
        CfgBtn.ZIndex = math.max(Header.ZIndex or 4, 4) + 1
        CfgBtn.Parent = Header
        local c1 = Instance.new("UICorner"); c1.CornerRadius = UDim.new(0, 8); c1.Parent = CfgBtn
        CreateStroke(CfgBtn, Theme.AccentSecondary, 1, 0.8)
        CfgBtn.MouseButton1Click:Connect(function()
            Overlay.Visible = not Overlay.Visible
        end)
    end
    -- subtle cyan border helping separation from profile and content
    do
        local hStroke = Header:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        hStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        hStroke.Color = Theme.AccentSecondary
        hStroke.Thickness = 1
        hStroke.Transparency = 0.92
        hStroke.LineJoinMode = Enum.LineJoinMode.Round
        hStroke.Parent = Header
    end
    
    -- Animated logo
    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 50, 0, 50)
    Logo.Image = "rbxassetid://95636565011705"
    Logo.AnchorPoint = Vector2.new(0.5,0.5)
    Logo.Position = UDim2.new(0.5, 0, 0.5, 15) -- 10 px aşağı
    Logo.BackgroundColor3 = Theme.Primary
    Logo.BackgroundTransparency = 1
    Logo.ImageTransparency = 0.5
    Logo.ZIndex = 5
    Logo.Parent = Header
    -- do -- holographic shimmer intro
    --     local g = Instance.new("UIGradient")
    --     g.Color = Gradients.Accent
    --     g.Rotation = 0
    --     g.Offset = Vector2.new(-1,0)
    --     g.Parent = Logo
    --     TweenService:Create(g, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Offset = Vector2.new(1,0) }):Play()
    --     Logo.ImageTransparency = 1
    --     TweenService:Create(Logo, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
    -- end
    -- Lens flare + depth parallax
    local Flare = Instance.new("Frame")
    Flare.Name = "LensFlare"
    Flare.Size = UDim2.fromOffset(12,12)
    Flare.AnchorPoint = Vector2.new(0.5,0.5)
    Flare.Position = UDim2.new(0, 53, 0, 41)
    Flare.BackgroundTransparency = 1
    Flare.Visible = false
    Flare.ZIndex = 4
    Flare.Parent = Header
    local flareStroke = Instance.new("UIStroke"); flareStroke.Color = Theme.AccentSecondary; flareStroke.Thickness = 2; flareStroke.Transparency = 0.4; flareStroke.Parent = Flare
    local flareCorner = Instance.new("UICorner"); flareCorner.CornerRadius = UDim.new(1,0); flareCorner.Parent = Flare
    
       
    
    -- Title removed per request; keep a hidden placeholder to avoid breaking any references
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0,0,0,0)
    Title.Visible = false
    Title.Parent = Header
    do -- remove previous underline if present
        local old = Header:FindFirstChild("Underline") or nil
        if old then old:Destroy() end
    end
    
    -- Remove text glow branding
    local TextGlow = Instance.new("TextLabel")
    TextGlow.Visible = false
    TextGlow.Parent = Header

    -- Profil bölümü (NavConfig.Profile ile yönetilir)
    local Profile = Instance.new("Frame")
    Profile.Name = "ProfileSection"
    Profile.Size = NavConfig.Profile.Size
    Profile.Position = NavConfig.Profile.Position
    Profile.BackgroundColor3 = NavConfig.Profile.BackgroundColor
    Profile.BackgroundTransparency = 0
    Profile.ZIndex = 4
    Profile.Parent = NavBar
    local pCorner = Instance.new("UICorner"); pCorner.CornerRadius = UDim.new(0, 16); pCorner.Parent = Profile
    do -- subtle neon stroke to match nav style
        local pStroke = Profile:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        pStroke.Color = Theme.AccentSecondary
        pStroke.Thickness = 1
        pStroke.Transparency = 0.9
        pStroke.LineJoinMode = Enum.LineJoinMode.Round
        pStroke.Parent = Profile
    end
    CreateShadow(Profile, 0.9, 16)
    AddGlassOverlay(Profile)
    local Avatar = Instance.new("ImageLabel")
    Avatar.Name = "Avatar"
    Avatar.Size = UDim2.fromOffset(44,44)
    Avatar.Position = UDim2.new(0, 10, 0, 12)
    Avatar.BackgroundTransparency = 1
    Avatar.ZIndex = 5
    Avatar.Parent = Profile
    
    -- Get actual player avatar
    local playerId = 0
    pcall(function()
        if game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.UserId then
            playerId = game.Players.LocalPlayer.UserId
        end
    end)
    -- Try to get avatar image, fallback to placeholder
    local avatarUrl = "rbxassetid://114947819863912"  -- default placeholder
    if playerId > 0 then
        avatarUrl = "rbxassetid://" .. tostring(playerId)
    end
    Avatar.Image = avatarUrl
    
    local aCorner = Instance.new("UICorner"); aCorner.CornerRadius = UDim.new(1,0); aCorner.Parent = Avatar
    
    local Username = Instance.new("TextLabel")
    Username.Size = UDim2.new(1, -68, 0, 22)
    Username.Position = UDim2.new(0, 64, 0, 10)
    Username.BackgroundTransparency = 1
    Username.Font = Enum.Font.GothamBold
    
    -- Get actual player name with truncation for long names
    local playerName = "Player"
    pcall(function()
        if game.Players and game.Players.LocalPlayer then
            playerName = game.Players.LocalPlayer.Name or game.Players.LocalPlayer.DisplayName or "Player"
        end
    end)
    -- Truncate long names
    if #playerName > 15 then
        playerName = playerName:sub(1, 12) .. "..."
    end
    
    Username.Text = NavConfig.Profile.UsernameText or playerName
    Username.TextSize = 16
    Username.TextColor3 = NavConfig.Profile.UsernameTextColor
    Username.TextXAlignment = Enum.TextXAlignment.Left
    Username.TextTruncate = Enum.TextTruncate.AtEnd
    Username.ZIndex = 5
    Username.Parent = Profile
    local SubInfo = Instance.new("TextLabel")
    SubInfo.Size = UDim2.new(1, -68, 0, 16)
    SubInfo.Position = UDim2.new(0, 64, 0, 30)
    SubInfo.BackgroundTransparency = 1
    SubInfo.Font = Enum.Font.Gotham
    SubInfo.Text = NavConfig.Profile.SubInfoText
    SubInfo.TextSize = 12
    SubInfo.TextColor3 = NavConfig.Profile.SubInfoTextColor
    SubInfo.TextXAlignment = Enum.TextXAlignment.Left
    SubInfo.ZIndex = 5
    SubInfo.Parent = Profile
    -- progress bar
    local Progress = Instance.new("Frame")
    Progress.Size = UDim2.new(1, -20, 0, 8)
    Progress.Position = UDim2.new(0, 10, 1, -18)
    Progress.BackgroundColor3 = Theme.Secondary
    Progress.BorderSizePixel = 0
    Progress.ZIndex = 4
    Progress.Parent = Profile
    local prCorner = Instance.new("UICorner"); prCorner.CornerRadius = UDim.new(0, 6); prCorner.Parent = Progress
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 5
    Fill.Parent = Progress
    local fCorner = Instance.new("UICorner"); fCorner.CornerRadius = UDim.new(0, 6); fCorner.Parent = Fill
    local fg = Instance.new("UIGradient"); fg.Color = Gradients.Accent; fg.Rotation = 0; fg.Parent = Fill
    -- İlerleme barı: başlangıç oranı NavConfig.Profile.InitialProgressScale
    TweenService:Create(Fill, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(NavConfig.Profile.InitialProgressScale, 0, 1, 0)
    }):Play()
    -- Profil/Progress görünürlük kontrolü
    Profile.Visible = NavConfig.Profile.Enabled
    Progress.Visible = NavConfig.Profile.ProgressEnabled

    -- Arama satırı (NavConfig.Search ile yönetilir)
    local SearchRow = Instance.new("Frame")
    SearchRow.Name = "SearchRow"
    SearchRow.Size = NavConfig.Search.Size
    SearchRow.Position = NavConfig.Search.Position
    SearchRow.BackgroundColor3 = NavConfig.Search.BackgroundColor
    SearchRow.BackgroundTransparency = 0
    SearchRow.ZIndex = 4
    SearchRow.Parent = NavBar
    local srCorner = Instance.new("UICorner"); srCorner.CornerRadius = UDim.new(0, 16); srCorner.Parent = SearchRow
    local srStroke = Instance.new("UIStroke"); srStroke.Color = Theme.AccentSecondary; srStroke.Thickness = 1; srStroke.Transparency = 0.9; srStroke.Parent = SearchRow
    AddGlassOverlay(SearchRow)
    -- search icon
    do
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.fromOffset(18,18)
        icon.Position = UDim2.new(0, 10, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0,0.5)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://"..tostring(NavConfig.Search.IconId)
        icon.ImageColor3 = NavConfig.Search.LabelTextColor
        icon.ZIndex = 5
        icon.Parent = SearchRow
    end
    do
        local keycap = Instance.new("TextLabel")
        keycap.Name = "SearchKeycap"
        keycap.Text = NavConfig.Search.KeycapText
        keycap.Font = Enum.Font.Gotham
        keycap.TextSize = 12
        keycap.TextColor3 = Theme.Text
        keycap.BackgroundColor3 = Theme.Tertiary
        keycap.BackgroundTransparency = 0
        keycap.AnchorPoint = Vector2.new(1,0.5)
        keycap.Position = UDim2.new(1, -10, 0.5, 0)
        keycap.Size = UDim2.fromOffset(34,20)
        keycap.ZIndex = 6
        keycap.Parent = SearchRow
        local kcCorner = Instance.new("UICorner"); kcCorner.CornerRadius = UDim.new(1,0); kcCorner.Parent = keycap
        local kcStroke = Instance.new("UIStroke"); kcStroke.Color = Theme.Accent; kcStroke.Thickness = 1; kcStroke.Transparency = 0.7; kcStroke.Parent = keycap
        -- unify keycap styling
        if StyleKeycap then StyleKeycap(keycap) end
    end
    -- Hover ve ripple efektleri NavConfig.Search ile kontrol edilir
    if NavConfig.Search.HoverEffects then
        ApplyHoverPressEffects(SearchRow, { hoverScale = 1.02, pressScale = 0.98 })
    end
    if NavConfig.Search.Ripple then
        CreateRippleEffect(SearchRow)
    end
    
    -- Tab container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -120)
    TabContainer.Position = UDim2.new(0, 0, 0, 200)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = NavConfig.Tabs.ScrollBarThickness
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabContainer.ZIndex = 3
    TabContainer.Parent = NavBar
    local TabContainerCorner = Instance.new("UICorner")
    TabContainerCorner.CornerRadius = UDim.new(0, 16)
    TabContainerCorner.Parent = TabContainer
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, NavConfig.Tabs.ListPadding)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, NavConfig.Tabs.PaddingTop)
    TabPadding.PaddingLeft = UDim.new(0, NavConfig.Tabs.PaddingLeft)
    TabPadding.PaddingRight = UDim.new(0, NavConfig.Tabs.PaddingRight)
    TabPadding.Parent = TabContainer

    -- Style future-added menu items inside TabContainer
    local function StyleMenuItem(item)
        if not item or not item:IsA("Frame") and not item:IsA("TextButton") and not item:IsA("ImageButton") then return end
        -- base rounded button style
        item.BackgroundTransparency = 0
        item.BackgroundColor3 = Theme.Tertiary
        local c = item:FindFirstChildOfClass("UICorner") or Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 14); c.Parent = item
        local st = item:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke"); st.Color = Theme.AccentSecondary; st.Transparency = 0.8; st.Thickness = 1; st.Parent = item
        -- icon left, label center heuristic
        for _, ch in ipairs(item:GetChildren()) do
            if ch:IsA("ImageLabel") or ch:IsA("ImageButton") then
                ch.ImageColor3 = Theme.Text
            elseif ch:IsA("TextLabel") or ch:IsA("TextButton") then
                ch.TextColor3 = Theme.Text
                ch.Font = Enum.Font.Gotham
            end
        end
        ApplyHoverPressEffects(item, { hoverScale = 1.05, pressScale = 0.97 })
        -- cyan pill-outline interaction to match reference
        if item:IsA("GuiObject") then
            item.MouseEnter:Connect(function()
                TweenService:Create(st, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 0.55 }):Play()
            end)
            item.MouseLeave:Connect(function()
                TweenService:Create(st, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 0.8 }):Play()
            end)
            if item:IsA("GuiButton") then
                item.MouseButton1Down:Connect(function()
                    TweenService:Create(st, TweenInfo.new(0.1), { Transparency = 0.35 }):Play()
                end)
                item.MouseButton1Up:Connect(function()
                    TweenService:Create(st, TweenInfo.new(0.16), { Transparency = 0.55 }):Play()
                end)
            end
        end
        if item:IsA("GuiButton") then CreateRippleEffect(item) end
        AddGlassOverlay(item)
    end
    TabContainer.ChildAdded:Connect(StyleMenuItem)
    
    -- İçerik alanı (NavBar genişliği değişince otomatik uyum sağlar)
    -- NavConfig.Width + NavConfig.ContentGap kadar sola ofset verilir.
    local ContentArea = Instance.new("Frame")
    local _cm = ContentConfig.Margin or {Left=0,Right=10,Top=10,Bottom=10}
    local _bg = ContentConfig.Background or {}
    -- Sync with NavBar theme if requested
    if _bg.SyncWithNav then
        -- inherit color/transparency from Nav
        _bg.Color = NavConfig.BackgroundColor or _bg.Color
        local navBT = (NavConfig.BackgroundTransparency ~= nil) and NavConfig.BackgroundTransparency or 0
        _bg.Transparency = (_bg.Enabled == true) and (_bg.Transparency or 0) or navBT
        -- inherit gradient/glass
        _bg.Gradient = _bg.Gradient or {}
        _bg.Gradient.Enabled = (_bg.Gradient.Enabled == true) or (NavConfig.GradientEnabled == true)
        _bg.Gradient.Preset = _bg.Gradient.Preset or NavConfig.GradientPreset or "Main"
        if NavConfig.GlassOverlayEnabled == true then _bg.GlassOverlay = true end
        -- if Nav indicator uses image, mirror it as subtle tiled background unless overridden
        local ind = NavConfig.Indicator or {}
        if (not _bg.Image or _bg.Image.Enabled ~= true) and ind.Mode == "Image" and ind.ImageId then
            _bg.Image = _bg.Image or {}
            _bg.Image.Enabled = true
            _bg.Image.ImageId = ind.ImageId
            _bg.Image.Transparency = _bg.Image.Transparency or 0.92
            _bg.Image.ScaleType = _bg.Image.ScaleType or Enum.ScaleType.Tile
            _bg.Image.TileSize = _bg.Image.TileSize or UDim2.new(0, 96, 0, 96)
        end
    end
    local posX = (NavConfig.Width + NavConfig.ContentGap) + (_cm.Left or 0)
    local posY = (_cm.Top or 0)
    local sizeOffsetX = -(NavConfig.Width + NavConfig.ContentGap) - (_cm.Left or 0) - (_cm.Right or 0)
    local sizeOffsetY = -((_cm.Top or 0) + (_cm.Bottom or 0))
    ContentArea.Size = UDim2.new(1, sizeOffsetX, 1, sizeOffsetY)
    ContentArea.Position = UDim2.new(0, posX, 0, posY)
    ContentArea.BackgroundColor3 = (_bg.Color or Theme.Primary)
    -- Always keep ContentArea fully transparent so custom background can be seen
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 2
    ContentArea.Parent = MainContainer
    local ContentAreaCorner = Instance.new("UICorner")
    ContentAreaCorner.CornerRadius = UDim.new(0, (_bg.CornerRadius or 16))
    ContentAreaCorner.Parent = ContentArea
    -- Background image under ContentArea is handled later via helper under TabContent. Skip legacy image creation.
    -- Optional stroke
    do
        local s = _bg.Stroke or {}
        if s.Enabled then
            local st = ContentArea:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
            st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            st.Color = s.Color or Theme.Accent
            st.Thickness = s.Thickness or 1
            st.Transparency = s.Transparency or 0.75
            st.LineJoinMode = Enum.LineJoinMode.Round
            st.Parent = ContentArea
        end
    end
    -- Suppress gradient / glass overlay to avoid dimming the background image
    -- (No-op: do not add any overlay on ContentArea)
    
    -- Tab content container
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Position = UDim2.new(0, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ClipsDescendants = true
    TabContent.ZIndex = 11
    TabContent.Parent = ContentArea
    local TabContentCorner = Instance.new("UICorner")
    TabContentCorner.CornerRadius = UDim.new(0, (_bg.CornerRadius or 16))
    TabContentCorner.Parent = TabContent
    -- Expose ContentArea for helpers
    self.MainContent = ContentArea
    -- Ensure base fill doesn't hide bg image
    ContentArea.BackgroundTransparency = 1
    -- Expose TabContent for helpers
    self.TabContent = TabContent
    -- Helper: set background image on the main content area (behind sections)
    function self:SetBackgroundImage(imageId, transparency, scaleType, tileSize)
        local parent = self.MainContent or self.TabContent
        if not parent then return end
        -- clean up if there is a previous BG under TabContent
        do
            local oldTC = self.TabContent and self.TabContent:FindFirstChild("BackgroundImage")
            if oldTC then oldTC:Destroy() end
        end
        local bg = parent:FindFirstChild("BackgroundImage")
        if not bg then
            bg = Instance.new("ImageLabel")
            bg.Name = "BackgroundImage"
            bg.BackgroundTransparency = 1
            bg.Size = UDim2.new(1,0,1,0)
            bg.Position = UDim2.new(0,0,0,0)
            -- Use high global ZIndex to stay above MainContainer overlays but below content
            bg.ZIndex = 10
            bg.Parent = parent
            local c = parent:FindFirstChildOfClass("UICorner")
            if c then local cc = Instance.new("UICorner"); cc.CornerRadius = c.CornerRadius; cc.Parent = bg end
        end
        if imageId and imageId ~= 0 then
            bg.Image = "rbxassetid://"..tostring(imageId)
            bg.ImageTransparency = (transparency ~= nil) and transparency or 0
            bg.ScaleType = scaleType or Enum.ScaleType.Stretch
            if bg.ScaleType == Enum.ScaleType.Tile then
                bg.TileSize = tileSize or UDim2.new(0,128,0,128)
            end
            bg.Visible = true
            -- If ContentArea has a GlassOverlay, hide it to avoid dimming the image
            local ca = self.MainContent
            if ca then
                local glass = ca:FindFirstChild("GlassOverlay")
                if glass then glass.Visible = false end
                -- Ensure base fill is transparent
                ca.BackgroundTransparency = 1
            end
        else
            bg.Visible = false
            -- Re-enable GlassOverlay if it exists
            local ca = self.MainContent
            if ca then
                local glass = ca:FindFirstChild("GlassOverlay")
                if glass then glass.Visible = true end
            end
        end
        -- ensure content sits above
        TabContent.ZIndex = math.max(TabContent.ZIndex or 2, (bg.ZIndex or 1) + 1)
    end
    -- If config requests an image, apply it now
    do
        local cfg = ContentConfig and ContentConfig.Background and ContentConfig.Background.Image
        if cfg and cfg.Enabled then
            self:SetBackgroundImage(cfg.ImageId, cfg.Transparency, cfg.ScaleType, cfg.TileSize)
        end
    end
    -- Safety: ensure no stray fills under ContentArea hide the background
    do
        for _, ch in ipairs(ContentArea:GetChildren()) do
            if (ch:IsA("Frame") or ch:IsA("ImageLabel")) and ch ~= TabContent and ch.Name ~= "BackgroundImage" then
                if ch:IsA("Frame") then
                    ch.BackgroundTransparency = 1
                elseif ch:IsA("ImageLabel") then
                    -- leave images as-is unless they are obvious overlays
                    if ch.Name:lower():find("overlay") or ch.Name:lower():find("glass") then
                        ch.Visible = false
                    end
                end
            end
        end
    end
    -- Inner padding for content area
    do
        local pad = ContentConfig.Padding or {Left=8,Right=8,Top=8,Bottom=8}
        local uiPad = Instance.new("UIPadding")
        uiPad.PaddingLeft = UDim.new(0, pad.Left or 0)
        uiPad.PaddingRight = UDim.new(0, pad.Right or 0)
        uiPad.PaddingTop = UDim.new(0, pad.Top or 0)
        uiPad.PaddingBottom = UDim.new(0, pad.Bottom or 0)
        uiPad.Parent = TabContent
    end
    -- initial menu open animation: fade + slide with overshoot
    TabContent.Position = UDim2.new(0, 20, 0, 20)
    TabContent.BackgroundTransparency = 1
    TweenService:Create(TabContent, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0,0,0,0) }):Play()
    TweenService:Create(TabContent, TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
    
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
    ApplyHoverPressEffects(MinimizeBtn)
    CreateRippleEffect(MinimizeBtn)
    
    -- Close button
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(0, 30, 0, 5)
    CloseBtn.Image = "rbxassetid://6031094678"
    CloseBtn.ImageColor3 = Theme.TextDim
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.ZIndex = 6
    CloseBtn.Parent = Controls
    ApplyHoverPressEffects(CloseBtn, { glowColor = Theme.AccentSecondary })
    CreateRippleEffect(CloseBtn)

    -- Settings button (Bottom of NavBar) - NavConfig.Settings ile yönetilir
local SettingsBtn = Instance.new("ImageButton")
SettingsBtn.Name = "SettingsBtn"
SettingsBtn.Size = UDim2.fromOffset(28,28)
SettingsBtn.AnchorPoint = Vector2.new(0.5,1)
SettingsBtn.Position = UDim2.new(0.5, 0, 1, -12)
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.BorderSizePixel = 0 -- kenarlık tamamen kapalı
SettingsBtn.Image = "rbxassetid://6031280882" -- gear
SettingsBtn.ImageColor3 = Theme.TextDim
SettingsBtn.ZIndex = 6
SettingsBtn.Parent = NavBar
-- if NavConfig.Settings.StrokeEnabled then
--     local sStroke = Instance.new("UIStroke")
--     sStroke.Color = Theme.Accent
--     sStroke.Thickness = 1
--     sStroke.Transparency = 0.65
--     sStroke.Parent = SettingsBtn
-- end

-- divider above settings
-- do
--     local divider = Instance.new("Frame")
--     divider.Name = "BottomDivider"
--     divider.Size = UDim2.new(1, -16, 0, 1)
--     divider.Position = UDim2.new(0, 8, 1, -52)
--     divider.BackgroundColor3 = Theme.Accent
--     divider.BackgroundTransparency = NavConfig.Settings.DividerTransparency
--     divider.Visible = NavConfig.Settings.DividerEnabled
--     divider.ZIndex = 5
--     divider.Parent = NavBar
-- end

-- UIStroke kaldırıldı 👇
--local sStroke = Instance.new("UIStroke")

ApplyHoverPressEffects(SettingsBtn)

SettingsBtn.MouseEnter:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Rotation = 15, ImageColor3 = Theme.Text
    }):Play()
end)

SettingsBtn.MouseLeave:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Rotation = 0, ImageColor3 = Theme.TextDim
    }):Play()
end)




    -- ESC hint badge (bottom-right)
    local EscBadge = Instance.new("TextLabel")
    EscBadge.Text = "Shift"
    EscBadge.Font = Enum.Font.Gotham
    EscBadge.TextSize = 12
    EscBadge.TextColor3 = Theme.Text
    EscBadge.BackgroundColor3 = Theme.Tertiary
    EscBadge.BackgroundTransparency = 0
    EscBadge.AnchorPoint = Vector2.new(1,1)
    EscBadge.Position = UDim2.new(1, -10, 1, -10)
    EscBadge.Size = UDim2.fromOffset(36,20)
    EscBadge.ZIndex = 6
    EscBadge.Parent = MainContainer
    local escC = Instance.new("UICorner"); escC.CornerRadius = UDim.new(1,0); escC.Parent = EscBadge
    local escS = Instance.new("UIStroke"); escS.Color = Theme.Accent; escS.Transparency = 0.7; escS.Thickness = 1; escS.Parent = EscBadge
    -- Unify badge visuals with cyan keycap style
    StyleKeycap(EscBadge, { baseTransparency = 0.7, hoverTransparency = 0.6, activeTransparency = 0.35 })

    -- Try to auto-style Search keycap if present elsewhere (named 'SearchKeycap' or text 'Tab')
    do
        for _, d in ipairs(MainContainer:GetDescendants()) do
            if d:IsA("TextLabel") and (d.Name == "SearchKeycap" or d.Text == "Tab") then
                StyleKeycap(d)
            end
        end
    end

    -- ESC pulse
    local escScale = Instance.new("UIScale"); escScale.Scale = 1; escScale.Parent = EscBadge
    
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
    
    -- Button hover effects (icons glow)
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
            ImageColor3 = Theme.Accent
        }):Play()
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {
            ImageColor3 = Theme.TextDim
        }):Play()
    end)
    
    -- Optional ambient hum loop
    pcall(function()
        local humId = UI:GetAttribute("AmbientHumSoundId")
        if humId then
            local hum = Instance.new("Sound")
            hum.SoundId = (typeof(humId) == "string" and humId) or ("rbxassetid://"..tostring(humId))
            hum.Volume = 0.08
            hum.Looped = true
            hum.Parent = UI
            hum:Play()
        end
    end)

    -- Cursor parallax (subtle)
    -- do
    --     local strength = 8
    --     local basePos = MainContainer.Position
    --     UserInputService.InputChanged:Connect(function(input)
    --         if input.UserInputType == Enum.UserInputType.MouseMovement then
    --             local v = input.Position
    --             local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
    --             local dx = ((v.X / viewport.X) - 0.5) * strength
    --             local dy = ((v.Y / viewport.Y) - 0.5) * strength
    --             TweenService:Create(MainContainer, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Position = UDim2.new(basePos.X.Scale, basePos.X.Offset + dx, basePos.Y.Scale, basePos.Y.Offset + dy) }):Play()
    --         end
    --     end)
    -- end

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
        -- Guard to avoid re-entry
        if self.State._closing then return end
        self.State._closing = true
        -- Disable interactions immediately
        pcall(function()
            MinimizeBtn.Active = false; MinimizeBtn.AutoButtonColor = false
            CloseBtn.Active = false; CloseBtn.AutoButtonColor = false
        end)
        -- Hide section buttons (TabContainer) instantly to avoid late disappearance
        pcall(function()
            if TabContainer then TabContainer.Visible = false end
        end)
        -- Hide main content region and active tab content instantly
        pcall(function()
            if TabContent then TabContent.Visible = false end
            if ContentArea then ContentArea.Visible = false end
        end)
        -- As an extra guard, hide all UI descendants immediately, then re-show MainContainer for animation
        pcall(function()
            if UI then
                for _, d in ipairs(UI:GetDescendants()) do
                    if d:IsA("GuiObject") then
                        d.Visible = false
                    end
                end
                -- keep main visible for the closing animation
                if MainContainer then MainContainer.Visible = true end
            end
        end)

        -- Ultra-futuristic close: subtle scale, glow pulse, fast fade, neon streak trails
        local ui = UI
        local main = MainContainer
        local center = main.AbsolutePosition + main.AbsoluteSize/2

        -- Anchor to center for clean scaling (no sibling movement)
        local origAnchor, origPos = main.AnchorPoint, main.Position
        main.AnchorPoint = Vector2.new(0.5, 0.5)
        main.Position = UDim2.new(0.5, 0, 0.5, 0)

        -- Scale pulse
        local scaleObj = main:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
        scaleObj.Parent = main
        scaleObj.Scale = 1
        local pulseUp = TweenService:Create(scaleObj, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.04 })
        local pulseDown = TweenService:Create(scaleObj, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Scale = 0.92 })

        -- Glow pulse on border (self-contained)
        local glowColor = Theme.Accent
        pcall(function()
            local v = ui:GetAttribute("CloseGlowColor")
            if typeof(v) == "Vector3" then
                glowColor = Color3.fromRGB(math.clamp(v.X,0,255), math.clamp(v.Y,0,255), math.clamp(v.Z,0,255))
            end
        end)
        local stroke = main:FindFirstChild("_ClosePulse") or Instance.new("UIStroke")
        stroke.Name = "_ClosePulse"
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Color = glowColor
        stroke.Thickness = 2
        stroke.Transparency = 0.85
        stroke.LineJoinMode = Enum.LineJoinMode.Round
        stroke.Parent = main
        local glowIn = TweenService:Create(stroke, TweenInfo.new(0.10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 0.25, Thickness = 3 })
        local glowOut = TweenService:Create(stroke, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Transparency = 1 })

        -- Fast dissolve of window content
        local fadeDur = 0.18
        for _, d in ipairs(main:GetDescendants()) do
            if d:IsA("GuiObject") then
                pcall(function()
                    if d ~= main then
                        TweenService:Create(d, TweenInfo.new(fadeDur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end)
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    pcall(function()
                        TweenService:Create(d, TweenInfo.new(fadeDur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
                    end)
                end
                if d:IsA("ImageLabel") or d:IsA("ImageButton") then
                    pcall(function()
                        TweenService:Create(d, TweenInfo.new(fadeDur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { ImageTransparency = 1 }):Play()
                    end)
                end
            end
        end
        pcall(function()
            TweenService:Create(main, TweenInfo.new(fadeDur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
        end)

        -- Neon streak trails (does not touch other UI elements)
        local streakFolder = Instance.new("Folder"); streakFolder.Name = "_CloseStreaks"; streakFolder.Parent = ui
        local neonAsset = "rbxassetid://107914684814320"
        local function spawnStreak()
            local st = Instance.new("ImageLabel")
            st.BackgroundTransparency = 1
            st.Image = neonAsset
            st.ScaleType = Enum.ScaleType.Slice
            st.SliceCenter = Rect.new(10,10,118,118)
            st.ImageColor3 = glowColor
            st.ImageTransparency = 0.2
            local w = math.random(80, 140)
            local h = math.random(2, 3)
            st.Size = UDim2.fromOffset(w, h)
            st.AnchorPoint = Vector2.new(0.5, 0.5)
            st.Rotation = math.random(-25, 25)
            st.ZIndex = 10001
            st.Position = UDim2.fromOffset(center.X + math.random(-8,8), center.Y + math.random(-6,6))
            st.Parent = streakFolder
            local ang = math.rad(math.random(0,359))
            local dist = math.random(60, 140)
            local dx, dy = math.cos(ang)*dist, math.sin(ang)*dist
            local dur = math.random(10,14)/100 -- 0.10 - 0.14s
            TweenService:Create(st, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(center.X + dx, center.Y + dy),
                ImageTransparency = 1
            }):Play()
            task.delay(dur + 0.02, function() if st then st:Destroy() end end)
        end
        for i=1,8 do task.spawn(spawnStreak) end

        -- Play pulses and finish
        pulseUp:Play(); glowIn:Play()
        pulseUp.Completed:Wait()
        pulseDown:Play(); glowOut:Play()

        -- Cleanup and close
        task.delay(0.22, function()
            pcall(function() if streakFolder then streakFolder:Destroy() end end)
            pcall(function()
                main.AnchorPoint = origAnchor
                main.Position = origPos
            end)
            if ui then ui:Destroy() end
        end)
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

    -- Animator + Profiler (single, guarded)
    do
        -- guard against duplicate connections per UI
        if self._animConn and self._animConn.Connected then
            self._animConn:Disconnect()
            self._animConn = nil
        end
        local t0 = os.clock()
        local drift = 0
        local lastLog = t0
        local lastMem = collectgarbage and collectgarbage("count") or 0
        -- helpers to read attributes with defaults
        local function getNumberAttr(name, default)
            local ok, v = pcall(function() return UI:GetAttribute(name) end)
            if ok and typeof(v) == "number" then return v end
            return default
        end
        local function getBoolAttr(name, default)
            local ok, v = pcall(function() return UI:GetAttribute(name) end)
            if ok and typeof(v) == "boolean" then return v end
            return default
        end
        -- main animator
        self._animConn = RunService.RenderStepped:Connect(function(dt)
            if not UI or not UI.Parent then
                if self._animConn then self._animConn:Disconnect(); self._animConn = nil end
                return
            end
            local reduced = getBoolAttr("ReducedMotion", false)
            local intensity = getNumberAttr("AnimIntensity", 1)
            intensity = math.clamp(intensity, 0, 2)
            if reduced then intensity = intensity * 0.3 end

            -- time accumulators
            drift += dt * 0.06 * intensity -- very slow drift
            local pulse = (math.sin(os.clock() * 1.2) * 0.5 + 0.5) -- 0..1

            -- Avatar ring subtle breathing
            if aStroke and aStroke.Parent then
                local targetT = 0.35 + (0.35 * (1 - pulse)) * (0.6 * intensity)
                aStroke.Transparency = targetT
            end

            -- Optional: drift gradients subtly (NavBar/MainContainer if gradients exist)
            -- Avoid expensive traversals; just tweak known gradients if present
            local function driftGradients(parent)
                if not parent then return end
                for _, d in ipairs(parent:GetChildren()) do
                    if d:IsA("UIGradient") then
                        d.Offset = Vector2.new((drift % 1), 0)
                    end
                end
            end
            -- safe calls (pcall to avoid conflicts if replaced by other code)
            pcall(function()
                driftGradients(NavBar)
                driftGradients(MainContainer)
            end)

            -- Lightweight profiler (optional)
            if getBoolAttr("EnableProfiling", false) then
                local now = os.clock()
                if now - lastLog > 2 then
                    local mem = collectgarbage and collectgarbage("count") or 0
                    local ms = dt * 1000
                    print(string.format("[LeafUI] frame %.2f ms | mem %.1f KB (Δ %.1f)", ms, mem, mem - lastMem))
                    lastLog = now
                    lastMem = mem
                end
            end
        end)

        -- stop animator when UI is removed
        UI.AncestryChanged:Connect(function(_, parent)
            if not parent and self._animConn then
                self._animConn:Disconnect()
                self._animConn = nil
            end
        end)
    end

    -- Optional: auto-create tabs passed to CreateWindow
    -- Accept formats: { {"Main", 6031265977}, {name="Settings", icon=6031280882, activeIcon=..., inactiveIcon=...} }
    if type(tabs) == "table" and #tabs > 0 then
        print("[LeafUI] Tab oluşturuluyor, count: " .. #tabs)
        for _, def in ipairs(tabs) do
            local name = (type(def) == "table" and (def.name or def[1])) or tostring(def)
            local icon = (type(def) == "table" and (def.icon or def[2])) or nil
            local opts = (type(def) == "table" and def) or {}
            print("[LeafUI] Tab: " .. tostring(name) .. " | Icon: " .. tostring(icon))
            if name then
                self:CreateTab(name, icon, {
                    activeIcon = opts.activeIcon,
                    inactiveIcon = opts.inactiveIcon
                })
            end
        end
    else
        print("[LeafUI] Tab yok veya boş, sadece manuel ekleme yapılabilir")
    end
    
    return self
end

-- Tab Creation
function Leaf:CreateTab(name, icon, opts)
    opts = opts or {}
    local activeIcon = opts.activeIcon or icon
    local inactiveIcon = opts.inactiveIcon or icon
    
    local Tab = {}
    Tab.Name = name
    Tab.Buttons = {}
    Tab.Content = Instance.new("ScrollingFrame")
    Tab.Content.Size = UDim2.new(1, 0, 1, 0)
    -- İçerik başlangıç ofseti NavConfig.TabButton.SlideInOffset ile ayarlı
    Tab.Content.Position = NavConfig.TabButton.SlideInOffset
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
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingBottom = UDim.new(0, 10)
    TabPadding.Parent = Tab.Content
    pcall(function()
        print("[LeafUI] Tab content created for", tostring(name), "->", Tab.Content:GetFullName())
    end)
    
    -- Tab button
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0.90, 0, 0, NavConfig.TabButton.Height)
    TabButton.Text = ""
    TabButton.BackgroundColor3 = Theme.Dark
    TabButton.BackgroundTransparency = NavConfig.TabButton.InactiveBgTransparency
    TabButton.AutoButtonColor = false
    TabButton.ZIndex = 3
    TabButton.Parent = self.TabContainer
    TabButton.LayoutOrder = #self.Tabs
    
    -- Rounded corners (16px) + masked neon background image under content
    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 16)
    tbCorner.Parent = TabButton
    -- subtle white stroke (very faint)
    CreateStroke(TabButton, Color3.fromRGB(255,255,255), 1, 0.92)
    -- masked neon background image (same asset as NavBar glow)
    local bgMask = Instance.new("Frame")
    bgMask.Name = "_NeonBGMask"
    bgMask.BackgroundTransparency = 1
    bgMask.Size = UDim2.new(1, 0, 1, 0)
    bgMask.Position = UDim2.new(0, 0, 0, 0)
    bgMask.ClipsDescendants = true
    bgMask.ZIndex = 3
    bgMask.Parent = TabButton
    do
        local mk = Instance.new("UICorner")
        mk.CornerRadius = tbCorner.CornerRadius
        mk.Parent = bgMask
    end
    local NeonBG = Instance.new("ImageLabel")
    NeonBG.Name = "_NeonBG"
    NeonBG.BackgroundTransparency = 1
    NeonBG.Image = "rbxassetid://107914684814320"
    -- NeonBG.ImageColor3 = Theme.Accent
    NeonBG.ImageTransparency = NavConfig.TabButton.NeonImageTransparencyIdle
    NeonBG.ScaleType = Enum.ScaleType.Slice
    NeonBG.SliceCenter = Rect.new(10, 10, 118, 118)
    -- proportional inset so the neon scales with TabButton size
    NeonBG.Size = UDim2.new(1.01, 0, 1, 0)
    NeonBG.Position = UDim2.new(0.01, 0, 0.01, 0)
    NeonBG.ZIndex = 3
    NeonBG.Parent = bgMask
    do -- ensure neon bg itself is rounded
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = tbCorner.CornerRadius
        bgCorner.Parent = NeonBG
    end
    CreateRippleEffect(TabButton)
    -- Cyan selection pill outline (hidden by default)
    local SelectStroke = Instance.new("UIStroke")
    SelectStroke.Name = "_SelectStroke"
    SelectStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SelectStroke.Color = Theme.Accent
    SelectStroke.Thickness = 1.5
    SelectStroke.Transparency = NavConfig.TabButton.SelectionStrokeHiddenAlpha -- hidden until active/hover
    SelectStroke.LineJoinMode = Enum.LineJoinMode.Round
    SelectStroke.Parent = TabButton
    
    -- Tab icon
    local TabIcon = nil
    if icon then
        TabIcon = CreateIcon(TabButton, inactiveIcon or icon, UDim2.new(0, 25, 0, 25), UDim2.new(0, 15, 0.5, -10))
        TabIcon.ZIndex = 4
        -- Store active/inactive icons for state changes
        Tab._activeIcon = activeIcon
        Tab._inactiveIcon = inactiveIcon or icon
        -- initialize as inactive state color
        local icfg = NavConfig.TabButton
        if icfg and TabIcon and TabIcon:IsA("ImageLabel") then
            TabIcon.ImageColor3 = icfg.IconInactiveColor or Theme.TextDim
        end
    end
    
    -- Tab text
    local TabText = Instance.new("TextLabel")
    TabText.Size = UDim2.new(1, -50, 1, 0)
    TabText.Position = UDim2.new(0, 45, 0, 0)
    TabText.Text = name
    TabText.Font = Enum.Font.Gotham
    TabText.TextSize = NavConfig.TabButton.TextSize
    TabText.TextColor3 = NavConfig.TabButton.TextDimColor
    TabText.TextXAlignment = Enum.TextXAlignment.Left
    TabText.TextTruncate = Enum.TextTruncate.AtEnd
    TabText.BackgroundTransparency = 1
    TabText.ZIndex = 4
    TabText.Parent = TabButton
    
    -- Tab indicator (single per tab) using image asset; supports Mode = "Bar" or "Image"
    local TabIndicator = Instance.new("ImageLabel")
    local indCfg = NavConfig.Indicator or {}
    local indW = indCfg.Width or 3
    local indTargetH = indCfg.TargetHeight or 20
    TabIndicator.BackgroundTransparency = 1
    TabIndicator.ZIndex = 5
    TabIndicator.Visible = (indCfg.Visible ~= false) and false
    if (indCfg.Mode or "Bar") == "Image" then
        -- image/dot indicator
        TabIndicator.Size = indCfg.Size or UDim2.fromOffset(12,12)
        TabIndicator.AnchorPoint = Vector2.new(0, 0.5)
        TabIndicator.Position = UDim2.new(0, 6, 0.5, 0)
        TabIndicator.Image = "rbxassetid://"..tostring(indCfg.ImageId or 88861960253549)
        TabIndicator.ImageColor3 = indCfg.InactiveColor or Theme.TextDim
        TabIndicator.ImageTransparency = indCfg.Transparency or 0.2
        TabIndicator.ScaleType = Enum.ScaleType.Fit
    else
        -- slim bar at the very left
        TabIndicator.Size = UDim2.new(0, indW, 0, 0)
        TabIndicator.AnchorPoint = Vector2.new(0, 0.5)
        TabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        TabIndicator.Image = "rbxassetid://"..tostring(indCfg.ImageId or 88861960253549)
        TabIndicator.ImageColor3 = indCfg.Color or Theme.AccentSecondary
        TabIndicator.ImageTransparency = indCfg.Transparency or 0.2
        TabIndicator.ScaleType = Enum.ScaleType.Stretch
    end
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
        pcall(function()
            local count = #Tab.Content:GetChildren()
            print(string.format("[LeafUI] Activating tab '%s'. Content children: %d. Visible=%s", tostring(name), count, tostring(Tab.Content.Visible)))
        end)

        -- atomically mark this activation and cancel any stale callbacks
        self.SwitchToken = (self.SwitchToken or 0) + 1
        local myToken = self.SwitchToken

        -- if a transition is already happening, instantly hide the previous to prevent ghosting
        local prevTab = self.CurrentTab
        -- Force-hide all other indicators and contents immediately to prevent ghost indicators/overlaps on rapid switching
        if self.Tabs then
            for _, t in ipairs(self.Tabs) do
                if t ~= Tab then
                    if t.Indicator then t.Indicator.Visible = false end
                    if t.Content then
                        t.Content.Visible = false
                        t.Content.Position = UDim2.new(0, 0, 0.03, 12)
                        tweenContentTransparency(t.Content, 0, 0.01)
                    end
                end
            end
        end
        if self.IsSwitching and prevTab and prevTab.Content then
            local prev = prevTab.Content
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
            TweenService:Create(Tab.Content, TweenInfo.new(NavConfig.TabButton.SlideDurIn, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            tweenContentTransparency(Tab.Content, 0, NavConfig.TabButton.SlideDurIn * 0.86) -- fade in contents softly

            -- keep background subtle; reveal cyan outline for active tab
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = NavConfig.TabButton.ActiveBgTransparency
            }):Play()
            -- emphasize neon background on active
            TweenService:Create(NeonBG, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                ImageTransparency = NavConfig.TabButton.NeonImageTransparencyActive
            }):Play()
            
            TweenService:Create(TabText, TweenInfo.new(0.2), {
                TextColor3 = NavConfig.TabButton.TextColor
            }):Play()
            -- show selection stroke
            TweenService:Create(SelectStroke, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Transparency = NavConfig.TabButton.SelectionStrokeVisibleAlpha
            }):Play()

            -- Animate per-tab indicator: expand vertically with slight bounce
            local cfg = NavConfig.Indicator or {}
            if (cfg.Visible ~= false) then
                TabIndicator.Visible = true
                if (cfg.Mode or "Bar") == "Image" then
                    -- swap to active appearance
                    if cfg.ActiveImageId then
                        TabIndicator.Image = "rbxassetid://"..tostring(cfg.ActiveImageId)
                    end
                    TabIndicator.ImageColor3 = cfg.Color or Theme.AccentSecondary
                    -- subtle pop
                    local s0 = TabIndicator.Size
                    TabIndicator.Size = UDim2.new(s0.X.Scale, s0.X.Offset + 2, s0.Y.Scale, s0.Y.Offset + 2)
                    TweenService:Create(TabIndicator, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = s0}):Play()
                else
                    -- bar expand
                    TabIndicator.Size = UDim2.new(0, indW, 0, 0)
                    TweenService:Create(TabIndicator, TweenInfo.new((cfg.ExpandDur or 0.18), Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, indW, 0, (cfg.TargetHeight or indTargetH))
                    }):Play()
                end
            end

            -- Update icon to active state
            if TabIcon and Tab._activeIcon then
                local icfg = NavConfig.TabButton
                if icfg then
                    -- Use custom active icon if provided
                    TabIcon.Image = "rbxassetid://"..tostring(Tab._activeIcon)
                    if TabIcon:IsA("ImageLabel") then
                        TabIcon.ImageColor3 = icfg.IconActiveColor or Theme.Text
                    end
                end
            end

            self.CurrentTab = Tab
        end

        if prevTab then
            -- Animate current tab out (slide up slightly + fade), then hide BEFORE showing new
            local oldContent = prevTab.Content
            if oldContent.Visible then
                if self.IsSwitching and oldContent.Visible then
                    -- normal path: animate out then show new
                    tweenContentTransparency(oldContent, 1, NavConfig.TabButton.SlideDurOut)
                    local tw = TweenService:Create(oldContent, TweenInfo.new(NavConfig.TabButton.SlideDurOut, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                        Position = NavConfig.TabButton.SlideOutOffset
                    })
                    tw:Play()
                    tw.Completed:Connect(function()
                        -- abort if a newer activation started
                        if myToken ~= self.SwitchToken then return end
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

            if prevTab.Button then
                TweenService:Create(prevTab.Button, TweenInfo.new(0.18), { BackgroundTransparency = NavConfig.TabButton.InactiveBgTransparency }):Play()
            end
            if prevTab.Text then
                TweenService:Create(prevTab.Text, TweenInfo.new(0.18), { TextColor3 = NavConfig.TabButton.TextDimColor }):Play()
            end
            -- hide previous selection stroke if exists
            if prevTab.SelectStroke then
                TweenService:Create(prevTab.SelectStroke, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = NavConfig.TabButton.SelectionStrokeHiddenAlpha }):Play()
            end
            if prevTab.NeonBG then
                TweenService:Create(prevTab.NeonBG, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { ImageTransparency = NavConfig.TabButton.NeonImageTransparencyIdle }):Play()
            end
            if prevTab.Indicator then
                prevTab.Indicator.Visible = false
            end
            -- Revert previous tab icon to inactive state
            if prevTab.Icon and prevTab._inactiveIcon then
                local icfg = NavConfig.TabButton
                if icfg then
                    -- Use custom inactive icon if provided
                    prevTab.Icon.Image = "rbxassetid://"..tostring(prevTab._inactiveIcon)
                    if prevTab.Icon:IsA("ImageLabel") then
                        prevTab.Icon.ImageColor3 = icfg.IconInactiveColor or Theme.TextDim
                    end
                end
            end
        else
            showNewTab()
            self.IsSwitching = false
        end
    end

    -- Tab button events
    TabButton.MouseEnter:Connect(function()
        if Tab ~= self.CurrentTab then
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = NavConfig.TabButton.HoverBgTransparency
            }):Play()
            
            TweenService:Create(TabText, TweenInfo.new(0.2), {
                TextColor3 = NavConfig.TabButton.TextColor
            }):Play()
            TweenService:Create(SelectStroke, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = NavConfig.TabButton.SelectionStrokeHoverAlpha }):Play()
            TweenService:Create(NeonBG, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { ImageTransparency = (NavConfig.TabButton.NeonImageTransparencyActive + NavConfig.TabButton.NeonImageTransparencyIdle)/2 }):Play()
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if Tab ~= self.CurrentTab then
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = NavConfig.TabButton.InactiveBgTransparency
            }):Play()
            
            TweenService:Create(TabText, TweenInfo.new(0.2), {
                TextColor3 = NavConfig.TabButton.TextDimColor
            }):Play()
            TweenService:Create(SelectStroke, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = NavConfig.TabButton.SelectionStrokeHiddenAlpha }):Play()
            TweenService:Create(NeonBG, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { ImageTransparency = NavConfig.TabButton.NeonImageTransparencyIdle }):Play()
        end
    end)
    
    -- Small click debounce to avoid spam racing
    if self._TabClickLocked == nil then self._TabClickLocked = false end
    TabButton.MouseButton1Click:Connect(function()
        if self._TabClickLocked then return end
        self._TabClickLocked = true
        ActivateTab()
        task.delay(0.2, function()
            self._TabClickLocked = false
        end)
    end)
    
    -- Store tab references
    Tab.Button = TabButton
    Tab.Text = TabText
    Tab.Icon = TabIcon
    Tab.Indicator = TabIndicator
    Tab.ContentFrame = Tab.Content
    Tab.SelectStroke = SelectStroke
    Tab.NeonBG = NeonBG
    
    table.insert(self.Tabs, Tab)
    
    -- Select first tab without firing RBXScriptSignal
    if #self.Tabs == 1 then
        ActivateTab()
    end
    
    return setmetatable(Tab, {__index = self})
end

-- Batch create tabs helper
function Leaf:CreateTabs(tabDefs)
    if not self.Tabs then self.Tabs = {} end
    if not tabDefs or type(tabDefs) ~= "table" then return end
    for _, def in ipairs(tabDefs) do
        local name = (type(def) == "table" and (def.name or def[1])) or tostring(def)
        local icon = (type(def) == "table" and (def.icon or def[2])) or nil
        local opts = (type(def) == "table" and def) or {}
        if name then
            self:CreateTab(name, icon, {
                activeIcon = opts.activeIcon,
                inactiveIcon = opts.inactiveIcon
            })
        end
    end
end

-- Section Creation (with optional config)
-- Usage: AddSection(title, {
--   LayoutPadding = 10,
--   Title = { Enabled=true, Text=nil, TextSize=16, Color=Theme.Text },
--   Divider = { Enabled=true, Color=Theme.Tertiary, Transparency=0.5 },
--   Content = { Padding=6, Align="Center" } -- Align: "Left"|"Center"|"Right"
-- })
function Leaf:AddSection(title, _)
    local Section = {}
    -- Hardcoded Neon Glass section style (no external configs)
    local LAYOUT_PADDING = 2
    local HAS_TITLE = (title ~= nil)
    local TITLE_HEIGHT = 30
    local CONTENT_GAP = 6
    local CPAD = { Left =1, Right = 10, Top = 8, Bottom = 8 }
    Section.Frame = Instance.new("Frame")
    Section.Frame.Size = UDim2.new(1, 0, 0, 0)
    Section.Frame.Position = UDim2.new(0, 0, 0, 0)
    Section.Frame.BackgroundColor3 = Theme.Tertiary
    Section.Frame.BackgroundTransparency = 1
    Section.Frame.ClipsDescendants = false
    Section.Frame.AutomaticSize = Enum.AutomaticSize.Y
    -- Derive a consistent Z-index stack relative to parent
    local parentZ = (self.ContentFrame and self.ContentFrame.ZIndex) or 0
    local baseZ = math.max(0, parentZ)
    Section.Frame.ZIndex = baseZ
    Section.Frame.Parent = self.ContentFrame
    pcall(function()
        print("[LeafUI] Section added:", tostring(title or "(untitled)"), "->", Section.Frame:GetFullName())
    end)
    -- Background image layer (does not participate in layout)
    local BG = Instance.new("ImageLabel")
    BG.Name = "_SectionBG"
    BG.BackgroundTransparency = 1
    BG.Image = "rbxassetid://" -- default off
    BG.ImageTransparency = 1     -- hidden until set
    BG.ScaleType = Enum.ScaleType.Stretch
    BG.Size = UDim2.fromScale(1,1)
    BG.Position = UDim2.fromScale(0,0)
    BG.ZIndex = baseZ -- background sits at the base
    BG.Visible = false
    BG.Parent = Section.Frame

    -- Content container (holds header and content, managed by layout)
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.BackgroundTransparency = 1
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.ZIndex = baseZ + 1
    Container.Parent = Section.Frame
    -- Visuals removed: no border/corner for section container (blend with main window)
    -- Optional background image
    -- No background image
    -- Shadow and neon glows
    -- Optional glows disabled in hardcoded mode
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, LAYOUT_PADDING)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Container
    
    -- Section header
    if HAS_TITLE then
        local Header = Instance.new("Frame")
        Header.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
        Header.Position = UDim2.new(0, 0, 0, 0)
        Header.BackgroundTransparency = 1
        Header.ZIndex = baseZ + 2
        Header.Parent = Container
        -- Align header text with content left/right padding
        local HP = Instance.new("UIPadding")
        HP.PaddingLeft = UDim.new(0, CPAD.Left)
        HP.PaddingRight = UDim.new(0, CPAD.Right)
        HP.Parent = Header
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 1, 0)
        Title.Position = UDim2.new(0, 0, 0, 0)
        Title.Text = tostring(title or "")
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 16
        Title.TextColor3 = Theme.Text
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.BackgroundTransparency = 1
        Title.ZIndex = baseZ + 2
        Title.Parent = Header
        -- Collapsible chevron
        local Chevron
        
        
        local Divider = Instance.new("Frame")
        Divider.Size = UDim2.new(1, 0, 0, 1)
        Divider.Position = UDim2.new(0, 0, 1, -1)
        Divider.BackgroundColor3 = Theme.Tertiary
        Divider.BackgroundTransparency = 0.5
        Divider.Visible = false
        Divider.ZIndex = baseZ + 2
        Divider.Parent = Header
        Section.__Header = Header
        Section.__Chevron = Chevron
    end
    
    -- Content holder with clip for collapse animation
    local ContentClip = Instance.new("Frame")
    ContentClip.Name = "ContentClip"
    ContentClip.Size = UDim2.new(1, 0, 0, 0)
    ContentClip.BackgroundTransparency = 1
    ContentClip.ClipsDescendants = true
    ContentClip.AutomaticSize = Enum.AutomaticSize.None
    ContentClip.ZIndex = baseZ + 1
    ContentClip.Parent = Container

    local holderMaxHeight = 0 -- scrolling disabled (hardcoded)

    local InnerParent
    if holderMaxHeight > 0 then
        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.new(1, 0, 1, 0)
        Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        Scroll.ScrollBarThickness = 4
        Scroll.ScrollBarImageTransparency = 0.5
        Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Scroll.BackgroundTransparency = 1
        Scroll.ZIndex = 2
        Scroll.Parent = ContentClip
        InnerParent = Scroll
    else
        InnerParent = ContentClip
    end

    Section.Content = Instance.new("Frame")
    Section.Content.Size = UDim2.new(1, 0, 0, 0)
    Section.Content.Position = UDim2.new(0, 0, 0, 0)
    Section.Content.BackgroundTransparency = 1
    Section.Content.AutomaticSize = Enum.AutomaticSize.Y
    Section.Content.ZIndex = 2
    Section.Content.Parent = InnerParent
    
    -- Per-side content padding
    local IPad = Instance.new("UIPadding")
    IPad.PaddingLeft = UDim.new(0, CPAD.Left)
    IPad.PaddingRight = UDim.new(0, CPAD.Right)
    IPad.PaddingTop = UDim.new(0, CPAD.Top)
    IPad.PaddingBottom = UDim.new(0, CPAD.Bottom)
    IPad.Parent = Section.Content

    -- Layout: single-column vertical list (stacked rows)
    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    Layout.VerticalAlignment = Enum.VerticalAlignment.Top
    Layout.Padding = UDim.new(0, CONTENT_GAP)
    Layout.Parent = Section.Content

    -- (Removed) duplicate inner padding to avoid nested-section look

    -- no grid sizing required for list layout

    -- Calculate and set initial clip height
    local function updateClipHeight()
        local h = Section.Content.AbsoluteSize.Y
        if holderMaxHeight > 0 then
            h = math.min(h, holderMaxHeight)
        end
        ContentClip.Size = UDim2.new(1, 0, 0, h)
    end
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        task.delay(0, updateClipHeight)
    end)
    Section.Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateClipHeight)
    task.delay(0, updateClipHeight)
    
    Section.Elements = {}
    -- Per-section button style (can be overridden via Section:SetButtonStyle)
    do
                        local cfgBtn = NavConfig.TabButton or {}
        Section.ButtonStyle = {
            -- Boyutlar
            Height = 36,
            CornerRadius = 8,

            -- Yazı
            TextSize = 14,
            TextColor = Color3.fromRGB(255,255,255),
            -- Daha okunaklı olsun diye dim yerine direkt Text kullan
            TextDimColor = Theme.Text,

            -- Arkaplan (tam opak)
            BgColor = Theme.Secondary,
            InactiveBgTransparency = 0,
            HoverBgTransparency = 0,
            ActiveBgTransparency = 0,

            -- Çerçeve (görünür: idle'da hafif, press'te belirgin)
            StrokeColor = Theme.AccentSecondary,
            StrokeThickness = 1.5,
            StrokeTransparencyIdle = 0.78,
            StrokeTransparencyHover = 0.65,
            StrokeTransparencyPress = 0.18,

            -- Neon (kapalı)
            NeonColor = Theme.Accent,
            NeonImageTransparencyActive = 1,
            NeonImageTransparencyIdle = 1,

            -- Animasyon (ölçek yok)
            HoverScale = 1,
            PressScale = 1,
            Ripple = false,
            -- Varsayılan olarak hover açık: buton hissi artsın
            Hover = true,

            -- Boyut ayarları (tam genişlik satır)
            MaxWidthRatio = 1,
            MinWidth = 0,
            MaxWidth = 9999,
        }
        
        function Section:SetButtonStyle(overrides)
            overrides = overrides or {}
            for k,v in pairs(overrides) do
                self.ButtonStyle[k] = v
            end
            -- Re-apply style to existing buttons in this section
            if not self._ButtonOverrides then self._ButtonOverrides = {} end
            if self.Elements then
                for _, el in ipairs(self.Elements) do
                    if el and el:IsA("TextButton") and el:FindFirstChild("_NeonBGMask") then
                        -- apply idle state with animation
                        if self.ApplyButtonStyle then
                            self:ApplyButtonStyle(el, "idle", true)
                        end
                    end
                end
            end
        end
    end
    
    -- Helpers to support live style updates for buttons
    if not Section._ButtonOverrides then Section._ButtonOverrides = {} end
    function Section:_mergeStyle(overrides)
        local base = table.clone(self.ButtonStyle)
        if overrides then
            for k,v in pairs(overrides) do base[k] = v end
        end
        return base
    end
    function Section:ApplyButtonStyle(btn, state, animate)
        local overrides = self._ButtonOverrides and self._ButtonOverrides[btn]
        local s = self:_mergeStyle(overrides)
        local tweenInfoFast = TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local tweenInfoMed = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        -- find parts
        local mask = btn:FindFirstChild("_NeonBGMask")
        local neon = mask and mask:FindFirstChild("_NeonBG")
        local scale = btn:FindFirstChildOfClass("UIScale")
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        local corner = btn:FindFirstChildOfClass("UICorner")
        local sizeConstraint = btn:FindFirstChildOfClass("UISizeConstraint")
        local chevron = btn:FindFirstChild("_Chevron")
        -- ensure divider never appears again
        local oldDivider = btn:FindFirstChild("_Divider")
        if oldDivider and oldDivider:IsA("Frame") then
            oldDivider:Destroy()
        end
        -- base visuals that don't depend on state
        -- hard-disable Roblox selection and any leftover strokes
        btn.AutoButtonColor = false
        btn.Selectable = false
        btn.SelectionImageObject = nil
        btn.TextSize = s.TextSize
        btn.BackgroundColor3 = s.BgColor
        if corner then corner.CornerRadius = UDim.new(0, s.CornerRadius) end
        if stroke then
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Color = s.StrokeColor
            stroke.Thickness = s.StrokeThickness or 1
            stroke.LineJoinMode = Enum.LineJoinMode.Round
            stroke.Enabled = true
        end
        if neon then
            neon.ImageColor3 = s.NeonColor
            neon.ImageTransparency = 1
            neon.Visible = false
        end
        -- full-width row height
        btn.Size = UDim2.new(1, 0, 0, s.Height)
        -- stateful visuals
        local target = {
            BackgroundTransparency = s.InactiveBgTransparency,
            -- idle'da da beyaz kalsın
            TextColor3 = s.TextColor,
            Scale = 1,
            NeonTransparency = 1,
            StrokeTransparency = s.StrokeTransparencyIdle or 0.88,
        }
        if state == "hover" then
            -- opak kal
            target.BackgroundTransparency = s.HoverBgTransparency
            target.TextColor3 = s.TextColor
            target.Scale = 1
            target.NeonTransparency = 1
            target.StrokeTransparency = s.StrokeTransparencyHover or 0.78
        elseif state == "press" then
            -- opak kal
            target.BackgroundTransparency = s.ActiveBgTransparency
            target.TextColor3 = s.TextColor
            target.Scale = 1
            target.NeonTransparency = 1
            target.StrokeTransparency = s.StrokeTransparencyPress or 0.25
        end
        if animate then
            TweenService:Create(btn, tweenInfoMed, { BackgroundTransparency = target.BackgroundTransparency }):Play()
            TweenService:Create(btn, tweenInfoMed, { TextColor3 = target.TextColor3 }):Play()
            -- text fully opaque
            TweenService:Create(btn, tweenInfoMed, { TextTransparency = 0 }):Play()
            if scale then TweenService:Create(scale, tweenInfoFast, { Scale = target.Scale }):Play() end
            if neon then
                neon.Visible = false
                TweenService:Create(neon, tweenInfoMed, { ImageTransparency = 1 }):Play()
            end
            if stroke then
                TweenService:Create(stroke, tweenInfoMed, { Transparency = target.StrokeTransparency }):Play()
            end
            -- no chevron
        else
            btn.BackgroundTransparency = target.BackgroundTransparency
            btn.TextColor3 = target.TextColor3
            btn.TextTransparency = 0
            if scale then scale.Scale = target.Scale end
            if neon then
                neon.Visible = false
                neon.ImageTransparency = 1
            end
            if stroke then
                stroke.Transparency = target.StrokeTransparency
            end
            -- no chevron
        end
    end
    -- Simple helper to set background image at runtime (keeps hardcoded mode)
    function Section:SetBackgroundImage(imageId, transparency, scaleType, tileSize)
        BG.Image = (imageId and ("rbxassetid://"..tostring(imageId))) or "rbxassetid://82773849228613"
        BG.ImageTransparency = (transparency ~= nil) and transparency or 0
        BG.ScaleType = scaleType or Enum.ScaleType.Stretch
        if BG.ScaleType == Enum.ScaleType.Tile then
            BG.TileSize = tileSize or UDim2.new(0, 128, 0, 128)
        end
    end
    -- collapse/disabled features removed in hardcoded mode
    -- Add element methods
    Section.AddButton = function(self, text, callback, styleOverrides)
        local s = self:_mergeStyle(styleOverrides)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, s.Height)
        Button.AutomaticSize = Enum.AutomaticSize.None
        Button.Text = text
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = s.TextSize
        Button.TextColor3 = s.TextColor
        Button.TextTransparency = 0
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.TextTruncate = Enum.TextTruncate.AtEnd
        Button.BackgroundColor3 = s.BgColor
        Button.BackgroundTransparency = s.InactiveBgTransparency
        Button.AutoButtonColor = false
        -- disable default blue selection outline
        Button.Selectable = false
        Button.SelectionImageObject = nil
        Button.ZIndex = 3
        Button.Parent = Section.Content
        -- track overrides for live updates
        if not self._ButtonOverrides then self._ButtonOverrides = {} end
        self._ButtonOverrides[Button] = styleOverrides

        -- Rounded corners (match TabButton)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, s.CornerRadius)
        corner.Parent = Button

        -- Subtle outline to make it read as a button
        local stroke = Button:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Color = s.StrokeColor
        stroke.Thickness = s.StrokeThickness or 1
        stroke.LineJoinMode = Enum.LineJoinMode.Round
        stroke.Transparency = s.StrokeTransparencyIdle or 0.88
        stroke.Parent = Button

        -- Gradient kaldırıldı: metnin üstüne binen overlay olmasın

        -- Subtle scale for hover/press without affecting layout too much
        local Scale = Instance.new("UIScale")
        Scale.Scale = 1
        Scale.Parent = Button

        -- İç boşluk: sol hizalı metin için padding
        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 14)
        Padding.PaddingRight = UDim.new(0, 14)
        Padding.Parent = Button

        -- Divider kaldırıldı: section butonları düz ve kesintisiz görünsün

        if s.Ripple then CreateRippleEffect(Button) end

        -- Optional hover effects (disabled by default unless s.Hover = true). Press effect will be added below unconditionally.
        if s.Hover == true then
            Button.MouseEnter:Connect(function()
                local live = self:_mergeStyle(self._ButtonOverrides and self._ButtonOverrides[Button])
                if not live.Hover then return end
                self:ApplyButtonStyle(Button, "hover", true)
            end)
            Button.MouseLeave:Connect(function()
                self:ApplyButtonStyle(Button, "idle", true)
            end)
        end

        -- Click press effect (ALWAYS enabled): mimic TabButton active look briefly
        Button.MouseButton1Down:Connect(function()
            self:ApplyButtonStyle(Button, "press", true)
        end)
        Button.MouseButton1Up:Connect(function()
            -- return to idle (no hover visuals by default)
            self:ApplyButtonStyle(Button, "idle", true)
        end)
        -- In case mouse is released outside the button area
        if UserInputService then
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    self:ApplyButtonStyle(Button, "idle", true)
                end
            end)
        end

        Button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
            -- ensure we end in idle after click
            task.delay(0.05, function()
                self:ApplyButtonStyle(Button, "idle", true)
            end)
        end)

        -- Apply and maintain idle style across tab/visibility changes
        local function applyIdle()
            self:ApplyButtonStyle(Button, "idle", false)
        end
        applyIdle()
        Button:GetPropertyChangedSignal("Visible"):Connect(applyIdle)
        Button.AncestryChanged:Connect(applyIdle)
        table.insert(Section.Elements, Button)
        return Button
    end
    
    Section.AddToggle = function(self, text, default, callback)
        local s = self.ButtonStyle or {}
        local Toggle = Instance.new("Frame")
        Toggle.Size = UDim2.new(1, 0, 0, s.Height or 36)
        Toggle.BackgroundColor3 = s.BgColor or Theme.Secondary
        Toggle.BackgroundTransparency = s.InactiveBgTransparency ~= nil and s.InactiveBgTransparency or 0.12
        Toggle.ZIndex = 2
        Toggle.Parent = Section.Content
        local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, s.CornerRadius or 8); corner.Parent = Toggle
        local divider = Instance.new("Frame"); divider.AnchorPoint = Vector2.new(0,1); divider.Position = UDim2.new(0,14,1,0); divider.Size = UDim2.new(1,-28,0,1); divider.BackgroundColor3 = Theme.AccentSecondary; divider.BackgroundTransparency = 0.9; divider.BorderSizePixel = 0; divider.ZIndex = 3; divider.Parent = Toggle
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -84, 1, 0)
        Label.Position = UDim2.new(0, 14, 0, 0)
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = s.TextSize or 14
        Label.TextColor3 = s.TextColor or Theme.Text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextTruncate = Enum.TextTruncate.AtEnd
        Label.BackgroundTransparency = 1
        Label.ZIndex = 3
        Label.Parent = Toggle
        
        local ToggleButton = Instance.new("ImageButton")
        local sz = math.max(20, (s.Height or 36) - 12)
        ToggleButton.Size = UDim2.new(0, sz, 0, sz)
        ToggleButton.Position = UDim2.new(1, -(14 + sz), 0.5, -math.floor(sz/2))
        ToggleButton.Image = ""
        ToggleButton.BackgroundColor3 = Theme.Tertiary
        ToggleButton.BackgroundTransparency = 0
        ToggleButton.AutoButtonColor = false
        -- disable default blue selection outline on toggle
        ToggleButton.Selectable = false
        ToggleButton.SelectionImageObject = nil
        ToggleButton.ScaleType = Enum.ScaleType.Fit
        ToggleButton.ZIndex = 3
        ToggleButton.Parent = Toggle
        -- rounded square and subtle stroke
        local tbCorner = Instance.new("UICorner"); tbCorner.CornerRadius = UDim.new(0, math.floor(sz*0.3)); tbCorner.Parent = ToggleButton
        local tbStroke = Instance.new("UIStroke"); tbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tbStroke.Color = Theme.AccentSecondary; tbStroke.Thickness = 1; tbStroke.Transparency = 0.9; tbStroke.LineJoinMode = Enum.LineJoinMode.Round; tbStroke.Parent = ToggleButton
        
        -- keep it square
        local AR = Instance.new("UIAspectRatioConstraint")
        AR.AspectRatio = 1
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
            -- background and stroke for clear toggle look
            ToggleButton.BackgroundColor3 = state and Theme.Secondary or Theme.Tertiary
            if tbStroke then tbStroke.Transparency = state and 0.75 or 0.9 end
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
            -- animate background and stroke
            TweenService:Create(ToggleButton, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundColor3 = state and Theme.Secondary or Theme.Tertiary }):Play()
            if tbStroke then
                TweenService:Create(tbStroke, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = state and 0.75 or 0.9 }):Play()
            end
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
                -- allow options to overflow section bounds without being clipped
                pcall(function()
                    ContentClip.ClipsDescendants = false
                end)
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
                -- restore clipping for section content
                pcall(function()
                    ContentClip.ClipsDescendants = true
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
function Leaf:Notify(title, message, duration, notiType)
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
function Leaf:CreateWatermark(text)
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
function Leaf:SetTheme(themeName)
    -- This would change the entire UI theme
    -- Implementation would go here
end

-- Main module return
local LeafUI = {}

function LeafUI.Init()
    -- Optional initialization function
    print("Leaf UI Ultimate Premium Edition Initialized")
end

function LeafUI.CreateWindow(options, size, accentColor, tabs)
    return Leaf:CreateWindow(options, size, accentColor, tabs)
end

-- Content (right-side section) Config API ----------------------------------
function LeafUI.SetContentConfig(newCfg)
    if type(newCfg) ~= "table" then return end
    _deepMerge(ContentConfig, newCfg)
    Leaf.ContentConfig = ContentConfig
    LeafUI.ContentConfig = ContentConfig
end

function LeafUI.GetContentConfig()
    return _deepCopy(ContentConfig)
end

-- also expose a live reference for reading defaults
LeafUI.ContentConfig = ContentConfig

-- Loader GUI (splash) ------------------------------------------------------
LeafUI._Loader = nil

function LeafUI.ShowLoader(opts)
    if LeafUI._Loader and LeafUI._Loader.UI then
        return LeafUI._Loader
    end
    opts = opts or {}
    local title = opts.title or "Leaf UI"
    local subtitle = opts.subtitle or "Initializing..."
    local logoId = opts.logoId or 95636565011705

    local UI = Instance.new("ScreenGui")
    UI.Name = "LeafLoader"
    UI.ResetOnSpawn = false
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    UI.IgnoreGuiInset = true
    UI.Parent = CoreGui

    -- Dimmed background
    local Backdrop = Instance.new("Frame")
    Backdrop.Size = UDim2.new(1, 0, 1, 0)
    Backdrop.BackgroundColor3 = Theme.Overlay
    Backdrop.BackgroundTransparency = 1
    Backdrop.ZIndex = 100
    Backdrop.Parent = UI

    -- Center card
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(0, 420, 0, 190)
    Card.Position = UDim2.new(0.5, 0, 0.5, 0)
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.BackgroundColor3 = Theme.Light
    Card.BackgroundTransparency = 1 -- make frame transparent so background image is visible
    Card.ClipsDescendants = true
    Card.ZIndex = 101
    Card.Parent = UI

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 18)
    Corner.Parent = Card

    -- Image background inside card (fills and respects corner radius)
    local CardBg = Instance.new("ImageLabel")
    CardBg.Name = "CardBackground"
    CardBg.Size = UDim2.new(1, 0, 1, 0)
    CardBg.Position = UDim2.new(0, 0, 0, 0)
    CardBg.BackgroundTransparency = 1
    CardBg.Image = "rbxassetid://" .. tostring(opts.cardImageId or 120042733877093)
    CardBg.ScaleType = Enum.ScaleType.Stretch
    CardBg.ZIndex = 100 -- behind content on the card
    CardBg.Parent = Card
    local CardBgCorner = Instance.new("UICorner")
    CardBgCorner.CornerRadius = UDim.new(0, 18)
    CardBgCorner.Parent = CardBg

    -- Removed gradient on Card to avoid covering the background image
    CreateShadow(Card, 0.82, 24)
    CreateStroke(Card, Color3.fromRGB(255,255,255), 1, 0.9)

    -- Accent top bar
    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(1, 0, 0, 3)
    AccentBar.Position = UDim2.new(0, 0, 0, 0)
    AccentBar.BackgroundColor3 = Theme.Accent
    AccentBar.BackgroundTransparency = 0.1
    AccentBar.BorderSizePixel = 0
    AccentBar.ZIndex = 102
    AccentBar.Parent = Card
    -- Remove top accent line for cleaner look
    pcall(function() AccentBar:Destroy() end)

    -- Logo
    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 42, 0, 42)
    Logo.Position = UDim2.new(0, 20, 0, 22)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://" .. tostring(logoId)
    Logo.ImageColor3 = Theme.Light
    Logo.ZIndex = 103
    Logo.Parent = Card

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -84, 0, 28)
    Title.Position = UDim2.new(0, 72, 0, 22)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.TextColor3 = Theme.Dark
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 103
    Title.Parent = Card

    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -84, 0, 22)
    Subtitle.Position = UDim2.new(0, 72, 0, 54)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = subtitle
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 14
    Subtitle.TextColor3 = Theme.Dark
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = 103
    Subtitle.Parent = Card

    -- Special styles removed: leaf_orbit and leaf_spiral

    -- Progress track
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -40, 0, 8)
    Track.Position = UDim2.new(0, 20, 1, -38)
    Track.BackgroundColor3 = Theme.Tertiary
    Track.BackgroundTransparency = 0.2
    Track.BorderSizePixel = 0
    Track.ZIndex = 103
    Track.Parent = Card
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 6)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.Position = UDim2.new(0, 0, 0, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(144, 238, 144) -- light green
    Fill.BackgroundTransparency = 0.05
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 104
    Fill.Parent = Track
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 6)
    FillCorner.Parent = Fill
    -- Subtle inner stroke for cleaner edge (static bar look)
    do
        local st = Instance.new("UIStroke")
        st.Thickness = 1
        st.Color = Color3.fromRGB(255, 255, 255)
        st.Transparency = 0.85
        st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        st.Parent = Fill
    end

    -- Leaf/snowflake head cap that follows the end of the bar
    local Head = Instance.new("ImageLabel")
    Head.Size = UDim2.new(0, 16, 0, 16)
    Head.AnchorPoint = Vector2.new(0.5, 0.5)
    Head.Position = UDim2.new(1, 0, 0.5, 0) -- attaches to Fill's right edge, vertically centered
    Head.BackgroundTransparency = 1
    Head.Image = "rbxassetid://84415711490874"
    Head.ImageColor3 = Color3.fromRGB(190, 220, 255)
    Head.ImageTransparency = 0.08
    Head.ZIndex = 105
    Head.Parent = Fill
   

    -- Tiny shimmering dot
    local Dot = Instance.new("ImageLabel")
    Dot.Size = UDim2.new(0, 10, 0, 10)
    Dot.AnchorPoint = Vector2.new(0.5, 0.5)
    Dot.Position = UDim2.new(0, 0, 0.5, 0)
    Dot.BackgroundTransparency = 1
    Dot.Image = "rbxassetid://84415711490874"
    Dot.ImageColor3 = Color3.fromRGB(190, 220, 255)
    Dot.ImageTransparency = 0.2
    Dot.ZIndex = 105
    Dot.Parent = Track

    -- Always show linear track

    -- Percent label (right aligned under subtitle)
    local PercentLbl = Instance.new("TextLabel")
    PercentLbl.Size = UDim2.new(0, 60, 0, 18)
    PercentLbl.Position = UDim2.new(1, -80, 0, 56)
    PercentLbl.BackgroundTransparency = 1
    PercentLbl.Text = "0%"
    PercentLbl.Font = Enum.Font.GothamMedium
    PercentLbl.TextSize = 14
    PercentLbl.TextColor3 = Theme.Light
    PercentLbl.TextTransparency = 0.15
    PercentLbl.TextXAlignment = Enum.TextXAlignment.Right
    PercentLbl.ZIndex = 103
    PercentLbl.Parent = Card
    -- Keep labels visible by default
    -- Hide percent label by default to avoid duplicate percentage text
    if not (opts.showPercentLabel == true) then
        PercentLbl.Visible = false
    end

    -- Footer label (bottom-right)
    local Footer = Instance.new("TextLabel")
    Footer.AnchorPoint = Vector2.new(1, 1)
    Footer.Size = UDim2.new(0, 140, 0, 16)
    Footer.Position = UDim2.new(1, -14, 1, -10)
    Footer.BackgroundTransparency = 1
    Footer.Text = tostring(opts.footerText or "Made by RLW")
    Footer.Font = Enum.Font.Gotham
    Footer.TextSize = 12
    Footer.TextColor3 = Color3.fromRGB(0,0,0)
    Footer.TextTransparency = 0.2
    Footer.TextXAlignment = Enum.TextXAlignment.Right
    Footer.ZIndex = 103
    Footer.Parent = Card

    CreateShadow(Footer, 0.8, 20)
    

    -- Entrance animation
    Card.Size = UDim2.new(0, 420, 0, 0)
    Card.ClipsDescendants = true
    TweenService:Create(Backdrop, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.25
    }):Play()
    TweenService:Create(Card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 420, 0, 190)
    }):Play()

    -- Looping progress animation
    local staged = (opts.staged == true) or (opts.stagedProgress == true)
    local auto = (opts.auto ~= false) and not staged -- disable auto loop if staged mode is requested
    local function loopProgress()
        coroutine.wrap(function()
            while Fill.Parent and LeafUI._Loader and LeafUI._Loader._running do
                -- safety check in case loop was stopped
                if not (LeafUI._Loader and LeafUI._Loader._running) then break end
                Fill.Size = UDim2.new(0, 0, 1, 0)
                Dot.Position = UDim2.new(0, 0, 0.5, 0)
                local loopFillTween = TweenService:Create(Fill, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 1, 0)
                })
                if LeafUI._Loader then LeafUI._Loader._loopFillTween = loopFillTween end
                loopFillTween:Play()
                local dotTween = TweenService:Create(Dot, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Position = UDim2.new(1, 0, 0.5, 0),
                    ImageTransparency = 0.05
                })
                if LeafUI._Loader then LeafUI._Loader._loopDotTween = dotTween end
                dotTween:Play()
                dotTween.Completed:Wait()
                if not (LeafUI._Loader and LeafUI._Loader._running) then break end
                TweenService:Create(Dot, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    ImageTransparency = 0.25
                }):Play()
                task.wait(0.1)
            end
        end)()
    end
    if auto then
        loopProgress()
    else
        Dot.Visible = false
    end

    -- Staged progress helper (optional)
    local function startStaged()
        -- defaults and customizations
        local milestoneMessages = {
            [10] = tostring((opts.milestones and opts.milestones[10]) or "Leaves gathering..."),
            [30] = tostring((opts.milestones and opts.milestones[30]) or "Cleaning..."),
            [50] = tostring((opts.milestones and opts.milestones[50]) or "Preparing..."),
            [90] = tostring((opts.milestones and opts.milestones[90]) or "Starting...")
        }
        local pauseAt = tonumber(opts.pauseAt) or 65
        local pauseDuration = tonumber(opts.pauseDuration) or 1.0

        local function messageFor(p)
            local msg = subtitle
            -- choose the latest milestone whose key <= p (deterministic order)
            local keys = {10, 30, 50, 90}
            for _, k in ipairs(keys) do
                local v = milestoneMessages[k]
                if v and p >= k then
                    msg = v
                end
            end
            return msg
        end

        task.spawn(function()
            local L = LeafUI._Loader
            if not L or not L.UI then return end
            L._stagedRunning = true
            -- start at 1%
            local p = 1
            LeafUI.UpdateLoader(p, messageFor(p))

            local segments = {
                { to = 10, step = 1, wait = 0.02 },
                { to = 30, step = 1, wait = 0.02 },
                { to = 50, step = 1, wait = 0.02 },
                { to = pauseAt, step = 1, wait = 0.02, dwell = pauseDuration },
                { to = 90, step = 1, wait = 0.02 },
                { to = 100, step = 1, wait = 0.015 },
            }

            for _, seg in ipairs(segments) do
                while L and L.UI and L._stagedRunning and p < seg.to do
                    p = p + seg.step
                    LeafUI.UpdateLoader(p, messageFor(p))
                    task.wait(seg.wait)
                end
                if not (L and L.UI and L._stagedRunning) then break end
                if seg.dwell and p >= pauseAt then
                    task.wait(seg.dwell)
                end
            end
            if L then L._stagedRunning = false end
        end)
    end

    LeafUI._Loader = {
        UI = UI,
        Backdrop = Backdrop,
        Card = Card,
        Fill = Fill,
        Dot = Dot,
        Head = Head,
        Title = Title,
        Subtitle = Subtitle,
        PercentLbl = PercentLbl,
        _running = auto,
        _stagedRunning = false,
        _progress = 0,
        _fillTween = nil,
        _dotTween = nil,
        _loopFillTween = nil,
        _loopDotTween = nil
    }
    -- kick off staged mode if requested
    if staged then
        startStaged()
    end
    return LeafUI._Loader
end

function LeafUI.HideLoader(success)
    local L = LeafUI._Loader
    if not L or not L.UI then return end
    L._running = false
    L._stagedRunning = false
    -- cancel any tweens
    if L._fillTween then pcall(function() L._fillTween:Cancel() end) end
    if L._dotTween then pcall(function() L._dotTween:Cancel() end) end
    if L._loopFillTween then pcall(function() L._loopFillTween:Cancel() end) end
    if L._loopDotTween then pcall(function() L._loopDotTween:Cancel() end) end

    -- Success color flash (optional)
    local flashColor = success and Theme.Success or Theme.Accent
    if L.Fill then
        TweenService:Create(L.Fill, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            BackgroundColor3 = flashColor
        }):Play()
    end

    -- Exit animation
    TweenService:Create(L.Backdrop, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(L.Card, TweenInfo.new(0.30, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 420, 0, 0)
    }):Play()
    task.delay(0.30, function()
        if L.UI then
            L.UI:Destroy()
        end
        LeafUI._Loader = nil
    end)
end

-- Update loader progress and text
function LeafUI.UpdateLoader(progress, subtitleText)
    local L = LeafUI._Loader
    if not L or not L.UI or not L.Fill then return end
    -- stop loop on first manual update
    if L._running then
        L._running = false
    end
    -- cancel any loop tweens to avoid resets
    if L._loopFillTween then pcall(function() L._loopFillTween:Cancel() end) L._loopFillTween = nil end
    if L._loopDotTween then pcall(function() L._loopDotTween:Cancel() end) L._loopDotTween = nil end
    progress = math.clamp(tonumber(progress) or 0, 0, 100)
    local prev = tonumber(L._progress) or 0
    local delta = math.abs(progress - prev)
    local duration = math.clamp(0.12 + (delta/100)*0.45, 0.12, 0.5)
    -- Hide shimmer dot for static look
    if L.Dot then L.Dot.Visible = false end
    if L.PercentLbl then
        L.PercentLbl.Text = tostring(math.floor(progress)) .. "%"
    end
    if typeof(subtitleText) == "string" and L.Subtitle then
        L.Subtitle.Text = subtitleText
    end
    -- cancel previous tweens for smoothness
    if L._fillTween then pcall(function() L._fillTween:Cancel() end) end
    if L._dotTween then pcall(function() L._dotTween:Cancel() end) end
    -- Always update linear bar
    local goal = { Size = UDim2.new(progress/100, 0, 1, 0) }
    L._fillTween = TweenService:Create(L.Fill, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), goal)
    L._fillTween:Play()
    -- Light flash on head (ImageLabel): soften image transparency briefly
    if L.Head then
        pcall(function()
            -- lower transparency (brighter), then tween slightly up for soft pulse
            L.Head.ImageTransparency = 0.06
            TweenService:Create(L.Head, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                ImageTransparency = 0.12
            }):Play()
        end)
    end
    -- Style-specific orbit/spiral animations removed
    L._progress = progress
end

-- Set loader title/subtitle without changing progress
function LeafUI.SetLoaderText(titleText, subtitleText)
    local L = LeafUI._Loader
    if not L or not L.UI then return end
    if typeof(titleText) == "string" and L.Title then
        L.Title.Text = titleText
    end
    if typeof(subtitleText) == "string" and L.Subtitle then
        L.Subtitle.Text = subtitleText
    end
end


return LeafUI




