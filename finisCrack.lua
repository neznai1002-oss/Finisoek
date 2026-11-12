-- ============================================================
-- Finis.Crack UI — Roblox (Delta Injector)
-- Вдохновлён интерфейсом Eta из видео
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Удаляем старый GUI если есть
local oldGui = CoreGui:FindFirstChild("FinisCrackUI")
if oldGui then oldGui:Destroy() end

-- ============================================================
-- УТИЛИТЫ
-- ============================================================

local function create(instanceType, properties, parent)
    local obj = Instance.new(instanceType)
    for prop, val in pairs(properties or {}) do
        obj[prop] = val
    end
    if parent then obj.Parent = parent end
    return obj
end

local function tween(obj, time, props, style, direction)
    local ti = TweenInfo.new(time, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, ti, props)
    t:Play()
    return t
end

local function roundFrame(frame, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius)}, frame)
end

local function strokeFrame(frame, color, thickness)
    create("UIStroke", {Color = color or Color3.fromRGB(255,255,255), Thickness = thickness or 1, Transparency = 0.7}, frame)
end

-- ============================================================
-- ГЛАВНЫЙ GUI
-- ============================================================

local ScreenGui = create("ScreenGui", {
    Name = "FinisCrackUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, CoreGui)

-- Затемнение фона
local overlay = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(10, 10, 25),
    BackgroundTransparency = 0.3,
    ZIndex = 1,
}, ScreenGui)
create("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 10, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 15, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 35)),
    }),
}, overlay)

-- Звёзды на фоне
for i = 1, 80 do
    local star = create("Frame", {
        Size = UDim2.new(0, math.random(1, 3), 0, math.random(1, 3)),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = math.random(20, 70) / 100,
        Position = UDim2.new(math.random() , 0, math.random(), 0),
        ZIndex = 2,
    }, overlay)
    roundFrame(star, 999)
    -- Мерцание
    spawn(function()
        while star and star.Parent do
            tween(star, math.random(20, 50)/10, {BackgroundTransparency = math.random(10, 80)/100})
            wait(math.random(20, 50)/10)
        end
    end)
end

-- ============================================================
-- ЛОГО (нижний левый угол, как в видео)
-- ============================================================

local logoBtn = create("Frame", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 20, 1, -70),
    BackgroundColor3 = Color3.fromRGB(30, 25, 55),
    BackgroundTransparency = 0.3,
    ZIndex = 10,
}, ScreenGui)
roundFrame(logoBtn, 999)
strokeFrame(logoBtn, Color3.fromRGB(150, 130, 255), 1.5)

local logoLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "η",
    TextColor3 = Color3.fromRGB(200, 180, 255),
    TextSize = 28,
    Font = Enum.Font.GothamBold,
    ZIndex = 11,
}, logoBtn)

-- Пульсация логотипа
spawn(function()
    while logoBtn and logoBtn.Parent do
        tween(logoBtn, 1.5, {BackgroundTransparency = 0.1})
        wait(1.5)
        tween(logoBtn, 1.5, {BackgroundTransparency = 0.4})
        wait(1.5)
    end
end)

-- ============================================================
-- ЭКРАН ВХОДА (ВВЕДИТЕ КЛЮЧ)
-- ============================================================

local loginFrame = create("Frame", {
    Size = UDim2.new(0, 420, 0, 320),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(25, 22, 50),
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 20,
}, ScreenGui)
roundFrame(loginFrame, 18)
strokeFrame(loginFrame, Color3.fromRGB(120, 100, 220), 1.2)

-- Размытие через UIGradient имитацию
create("UIGradient", {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 28, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 18, 45)),
    }),
}, loginFrame)

-- Логотип η
local loginLogo = create("TextLabel", {
    Size = UDim2.new(0, 70, 0, 70),
    Position = UDim2.new(0.5, 0, 0, 30),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1,
    Text = "η",
    TextColor3 = Color3.fromRGB(220, 200, 255),
    TextSize = 52,
    Font = Enum.Font.GothamBold,
    ZIndex = 21,
}, loginFrame)

-- Название
local loginTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 35),
    Position = UDim2.new(0, 0, 0, 105),
    BackgroundTransparency = 1,
    Text = "Finis.Crack",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 28,
    Font = Enum.Font.GothamBold,
    ZIndex = 21,
}, loginFrame)

-- Подсказка
local loginSub = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 140),
    BackgroundTransparency = 1,
    Text = "Введи ключ, чтобы продолжить",
    TextColor3 = Color3.fromRGB(180, 170, 210),
    TextSize = 13,
    Font = Enum.Font.Gotham,
    ZIndex = 21,
}, loginFrame)

-- Поле ввода ключа
local keyInputFrame = create("Frame", {
    Size = UDim2.new(1, -60, 0, 42),
    Position = UDim2.new(0, 30, 0, 175),
    BackgroundColor3 = Color3.fromRGB(15, 12, 35),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = 21,
}, loginFrame)
roundFrame(keyInputFrame, 10)
strokeFrame(keyInputFrame, Color3.fromRGB(100, 85, 180), 1)

local keyIcon = create("TextLabel", {
    Size = UDim2.new(0, 25, 1, 0),
    BackgroundTransparency = 1,
    Text = "🔑",
    TextSize = 16,
    ZIndex = 22,
}, keyInputFrame)

local keyInput = create("TextBox", {
    Size = UDim2.new(1, -30, 1, 0),
    Position = UDim2.new(0, 28, 0, 0),
    BackgroundTransparency = 1,
    PlaceholderText = "Ваш ключ",
    PlaceholderColor3 = Color3.fromRGB(120, 110, 160),
    Text = "",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    ZIndex = 22,
}, keyInputFrame)

-- Кнопка "Вставить"
local pasteBtn = create("TextButton", {
    Size = UDim2.new(0, 110, 0, 42),
    Position = UDim2.new(0, 30, 0, 230),
    BackgroundColor3 = Color3.fromRGB(35, 30, 65),
    BackgroundTransparency = 0.3,
    Text = "📋 Вставить",
    TextColor3 = Color3.fromRGB(220, 215, 240),
    TextSize = 13,
    Font = Enum.Font.GothamMedium,
    BorderSizePixel = 0,
    ZIndex = 21,
}, loginFrame)
roundFrame(pasteBtn, 10)

-- Кнопка "Войти"
local loginBtn = create("TextButton", {
    Size = UDim2.new(1, -155, 0, 42),
    Position = UDim2.new(1, -140, 0, 230),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundColor3 = Color3.fromRGB(130, 100, 230),
    Text = "Войти  →",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    ZIndex = 21,
}, loginFrame)
roundFrame(loginBtn, 10)

create("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 110, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 140, 255)),
    }),
}, loginBtn)

-- Версия внизу
local versionLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 15),
    Position = UDim2.new(0, 0, 1, -25),
    BackgroundTransparency = 1,
    Text = "FINIS.CRACK  •  v1.0  •  Delta",
    TextColor3 = Color3.fromRGB(120, 110, 160),
    TextSize = 10,
    Font = Enum.Font.Gotham,
    ZIndex = 21,
}, loginFrame)

-- Анимация появления экрана входа
loginFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
loginFrame.BackgroundTransparency = 1
tween(loginFrame, 0.8, {
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 0.15,
}, Enum.EasingStyle.Quart)

-- Кнопка вставить (берёт из буфера через SetClipboard — в Delta это работает)
pasteBtn.MouseButton1Click:Connect(function()
    -- Пытаемся вставить из буфера обмена
    local success, result = pcall(function()
        return getclipboard()
    end)
    if success then
        keyInput.Text = result or "@FinisOkek"
    else
        keyInput.Text = "@FinisOkek"
    end
    -- Визуальный фидбек
    local toast = create("Frame", {
        Size = UDim2.new(0, 180, 0, 36),
        Position = UDim2.new(0.5, 0, 0, 20),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(30, 28, 55),
        BackgroundTransparency = 0.2,
        ZIndex = 100,
    }, ScreenGui)
    roundFrame(toast, 10)
    create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "✓ Вставлено",
        TextColor3 = Color3.fromRGB(200, 255, 200),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        ZIndex = 101,
    }, toast)
    tween(toast, 0.3, {Position = UDim2.new(0.5, 0, 0, 40)})
    wait(1.5)
    tween(toast, 0.3, {Position = UDim2.new(0.5, 0, 0, 20), BackgroundTransparency = 1})
    wait(0.3)
    toast:Destroy()
end)

-- ============================================================
-- ГЛАВНОЕ МЕНЮ (изначально скрыто)
-- ============================================================

local mainMenu = create("Frame", {
    Size = UDim2.new(0, 820, 0, 540),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(22, 20, 45),
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ZIndex = 30,
    Visible = false,
}, ScreenGui)
roundFrame(mainMenu, 20)
strokeFrame(mainMenu, Color3.fromRGB(110, 95, 200), 1)

create("UIGradient", {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 25, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 16, 40)),
    }),
}, mainMenu)

-- Шапка меню
local header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 55),
    BackgroundColor3 = Color3.fromRGB(18, 16, 38),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 31,
}, mainMenu)
roundFrame(header, 20)
-- Скругляем только верх
local headerCorner = create("UICorner", {CornerRadius = UDim.new(0, 20)}, header)
-- Перекрываем нижние углы
local headerFix = create("Frame", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 1, -20),
    BackgroundColor3 = Color3.fromRGB(18, 16, 38),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 31,
}, header)

-- Логотип в шапке
local headerLogo = create("TextLabel", {
    Size = UDim2.new(0, 35, 0, 35),
    Position = UDim2.new(0, 20, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    Text = "η",
    TextColor3 = Color3.fromRGB(200, 180, 255),
    TextSize = 26,
    Font = Enum.Font.GothamBold,
    ZIndex = 32,
}, header)

local headerTitle = create("TextLabel", {
    Size = UDim2.new(0, 200, 0, 20),
    Position = UDim2.new(0, 62, 0.5, -2),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    Text = "Finis.Crack",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 32,
}, header)

local headerSub = create("TextLabel", {
    Size = UDim2.new(0, 200, 0, 14),
    Position = UDim2.new(0, 62, 0.5, 10),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    Text = "ROBLOX  •  DELTA INJECTOR",
    TextColor3 = Color3.fromRGB(140, 130, 180),
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 32,
}, header)

-- Статус "Подключено"
local statusFrame = create("Frame", {
    Size = UDim2.new(0, 130, 0, 28),
    Position = UDim2.new(1, -150, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Color3.fromRGB(20, 50, 35),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ZIndex = 32,
}, header)
roundFrame(statusFrame, 14)

local statusDot = create("Frame", {
    Size = UDim2.new(0, 8, 0, 8),
    Position = UDim2.new(0, 12, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Color3.fromRGB(100, 255, 150),
    ZIndex = 33,
}, statusFrame)
roundFrame(statusDot, 999)

-- Пульсация статуса
spawn(function()
    while statusDot and statusDot.Parent do
        tween(statusDot, 1, {BackgroundTransparency = 0.2})
        wait(1)
        tween(statusDot, 1, {BackgroundTransparency = 0})
        wait(1)
    end
end)

local statusText = create("TextLabel", {
    Size = UDim2.new(1, -28, 1, 0),
    Position = UDim2.new(0, 26, 0, 0),
    BackgroundTransparency = 1,
    Text = "Подключено",
    TextColor3 = Color3.fromRGB(180, 255, 210),
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    ZIndex = 33,
}, statusFrame)

-- Кнопка закрыть
local closeBtn = create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -40, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Color3.fromRGB(60, 30, 40),
    BackgroundTransparency = 0.5,
    Text = "✕",
    TextColor3 = Color3.fromRGB(255, 200, 200),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    ZIndex = 32,
}, header)
roundFrame(closeBtn, 999)

-- ============================================================
-- БОКОВАЯ НАВИГАЦИЯ
-- ============================================================

local sidebar = create("Frame", {
    Size = UDim2.new(0, 180, 1, -55),
    Position = UDim2.new(0, 0, 0, 55),
    BackgroundColor3 = Color3.fromRGB(18, 16, 38),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ZIndex = 31,
}, mainMenu)

-- Разделы меню
local sections = {
    {name = "Обзор", icon = "⊞"},
    {name = "Функции", icon = "⚡"},
    {name = "Визуал", icon = "👁"},
    {name = "Аим", icon = "◎"},
    {name = "Модели", icon = "🧊"},
    {name = "Конфиги", icon = "📁"},
    {name = "Настройки", icon = "⚙"},
}

local sectionButtons = {}
local currentSection = nil

local function createSectionButton(section, index)
    local btn = create("TextButton", {
        Size = UDim2.new(1, -20, 0, 42),
        Position = UDim2.new(0, 10, 0, 10 + (index - 1) * 48),
        BackgroundColor3 = Color3.fromRGB(30, 26, 55),
        BackgroundTransparency = 0.6,
        Text = "  " .. section.icon .. "  " .. section.name,
        TextColor3 = Color3.fromRGB(180, 175, 210),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        ZIndex = 32,
    }, sidebar)
    roundFrame(btn, 10)
    
    -- Индикатор слева (активный)
    local indicator = create("Frame", {
        Size = UDim2.new(0, 3, 0, 20),
        Position = UDim2.new(0, 4, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(150, 120, 255),
        BackgroundTransparency = 1,
        ZIndex = 33,
    }, btn)
    roundFrame(indicator, 999)
    
    sectionButtons[section.name] = {btn = btn, indicator = indicator}
    
    btn.MouseEnter:Connect(function()
        if currentSection ~= section.name then
            tween(btn, 0.2, {BackgroundTransparency = 0.3})
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentSection ~= section.name then
            tween(btn, 0.2, {BackgroundTransparency = 0.6})
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        switchSection(section.name)
    end)
    
    return btn
end

for i, section in ipairs(sections) do
    createSectionButton(section, i)
end

-- ============================================================
-- КОНТЕНТНАЯ ОБЛАСТЬ
-- ============================================================

local contentArea = create("Frame", {
    Size = UDim2.new(1, -190, 1, -65),
    Position = UDim2.new(0, 185, 0, 60),
    BackgroundTransparency = 1,
    ZIndex = 31,
}, mainMenu)

-- Контейнеры для каждого раздела
local sectionContents = {}

local function createSectionContent(name)
    local frame = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(120, 100, 200),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 32,
    }, contentArea)
    frame.ScrollBarImageTransparency = 0.5
    
    create("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, frame)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
    }, frame)
    
    sectionContents[name] = frame
    return frame
end

for _, section in ipairs(sections) do
    createSectionContent(section.name)
end

-- ============================================================
-- ФУНКЦИЯ ПЕРЕКЛЮЧЕНИЯ РАЗДЕЛОВ
-- ============================================================

function switchSection(name)
    if currentSection == name then return end
    
    -- Деактивируем старый
    if currentSection and sectionButtons[currentSection] then
        local old = sectionButtons[currentSection]
        tween(old.btn, 0.25, {BackgroundTransparency = 0.6, BackgroundColor3 = Color3.fromRGB(30, 26, 55)})
        tween(old.indicator, 0.25, {BackgroundTransparency = 1, Size = UDim2.new(0, 3, 0, 20)})
        tween(old.btn, 0.25, {TextColor3 = Color3.fromRGB(180, 175, 210)})
    end
    
    -- Активируем новый
    currentSection = name
    local new = sectionButtons[name]
    tween(new.btn, 0.3, {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(80, 60, 160)})
    tween(new.indicator, 0.3, {BackgroundTransparency = 0, Size = UDim2.new(0, 3, 0, 24)})
    tween(new.btn, 0.3, {TextColor3 = Color3.fromRGB(255, 255, 255)})
    
    -- Показываем контент с анимацией
    for sName, frame in pairs(sectionContents) do
        if sName == name then
            frame.Visible = true
            frame.Position = UDim2.new(0, 15, 0, 0)
            frame.BackgroundTransparency = 1
            tween(frame, 0.35, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quart)
        else
            frame.Visible = false
        end
    end
end

-- ============================================================
-- СОЗДАНИЕ UI-ЭЛЕМЕНТОВ (переключатели, слайдеры, заголовки)
-- ============================================================

local function createTitle(text, parent, order)
    local lbl = create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 22),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order or 0,
        ZIndex = 33,
    }, parent)
    create("UIPadding", {PaddingLeft = UDim.new(0, 10)}, lbl)
    return lbl
end

local function createSubtitle(text, parent, order)
    local lbl = create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(140, 135, 180),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = (order or 0) + 1,
        ZIndex = 33,
    }, parent)
    create("UIPadding", {PaddingLeft = UDim.new(0, 10)}, lbl)
    return lbl
end

local function createToggle(text, desc, parent, order, defaultOn)
    local container = create("Frame", {
        Size = UDim2.new(1, -20, 0, 60),
        BackgroundColor3 = Color3.fromRGB(28, 25, 55),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        LayoutOrder = order or 0,
        ZIndex = 33,
    }, parent)
    roundFrame(container, 12)
    strokeFrame(container, Color3.fromRGB(80, 70, 140), 0.8)
    
    local title = create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 14, 0, 10),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(240, 240, 255),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 34,
    }, container)
    
    local descLbl = create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 28),
        Position = UDim2.new(0, 14, 0, 30),
        BackgroundTransparency = 1,
        Text = desc or "",
        TextColor3 = Color3.fromRGB(130, 125, 170),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 34,
    }, container)
    
    -- Переключатель
    local toggleBg = create("Frame", {
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -56, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(50, 45, 80),
        BorderSizePixel = 0,
        ZIndex = 34,
    }, container)
    roundFrame(toggleBg, 999)
    
    local toggleKnob = create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(200, 200, 220),
        ZIndex = 35,
    }, toggleBg)
    roundFrame(toggleKnob, 999)
    
    local isOn = defaultOn or false
    
    local function updateToggle()
        if isOn then
            tween(toggleBg, 0.25, {BackgroundColor3 = Color3.fromRGB(130, 100, 230)})
            tween(toggleKnob, 0.25, {Position = UDim2.new(0, 23, 0.5, 0)})
        else
            tween(toggleBg, 0.25, {BackgroundColor3 = Color3.fromRGB(50, 45, 80)})
            tween(toggleKnob, 0.25, {Position = UDim2.new(0, 3, 0.5, 0)})
        end
    end
    
    updateToggle()
    
    local toggleBtn = create("TextButton", {
        Size = UDim2.new(0, 50, 0, 30),
        Position = UDim2.new(1, -59, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 36,
    }, container)
    
    toggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        updateToggle()
    end)
    
    return {container = container, isOn = function() return isOn end, setOn = function(v) isOn = v; updateToggle() end}
end

local function createSlider(text, desc, parent, order, min, max, default, suffix)
    local container = create("Frame", {
        Size = UDim2.new(1, -20, 0, 70),
        BackgroundColor3 = Color3.fromRGB(28, 25, 55),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        LayoutOrder = order or 0,
        ZIndex = 33,
    }, parent)
    roundFrame(container, 12)
    strokeFrame(container, Color3.fromRGB(80, 70, 140), 0.8)
    
    local title = create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 14, 0, 10),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(240, 240, 255),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 34,
    }, container)
    
    local valLabel = create("TextLabel", {
        Size = UDim2.new(0, 70, 0, 20),
        Position = UDim2.new(1, -80, 0, 10),
        BackgroundTransparency = 1,
        Text = tostring(default) .. (suffix or ""),
        TextColor3 = Color3.fromRGB(180, 170, 230),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 34,
    }, container)
    
    local descLbl = create("TextLabel", {
        Size = UDim2.new(1, -28, 0, 14),
        Position = UDim2.new(0, 14, 0, 30),
        BackgroundTransparency = 1,
        Text = desc or "",
        TextColor3 = Color3.fromRGB(130, 125, 170),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 34,
    }, container)
    
    -- Слайдер
    local sliderBg = create("Frame", {
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.new(0, 14, 0, 52),
        BackgroundColor3 = Color3.fromRGB(40, 35, 70),
        BorderSizePixel = 0,
        ZIndex = 34,
    }, container)
    roundFrame(sliderBg, 999)
    
    local sliderFill = create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(140, 110, 240),
        BorderSizePixel = 0,
        ZIndex = 35,
    }, sliderBg)
    roundFrame(sliderFill, 999)
    
    local sliderKnob = create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(230, 220, 255),
        ZIndex = 36,
    }, sliderBg)
    roundFrame(sliderKnob, 999)
    
    local currentValue = default
    local dragging = false
    
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local relX = mousePos.X - sliderBg.AbsolutePosition.X
            local percent = math.clamp(relX / sliderBg.AbsoluteSize.X, 0, 1)
            currentValue = math.floor(min + (max - min) * percent)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
            valLabel.Text = tostring(currentValue) .. (suffix or "")
        end
    end)
    
    return {getValue = function() return currentValue end}
end

-- ============================================================
-- ЗАПОЛНЕНИЕ РАЗДЕЛОВ
-- ============================================================

-- ===== ОБЗОР =====
local overview = sectionContents["Обзор"]

createTitle("Finis.Crack готов", overview, 1)
createSubtitle("ВХ, аимбот и твики для Roblox. Быстрые переключатели ниже.", overview, 2)

-- Статус-карточки
local statusRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 80),
    BackgroundTransparency = 1,
    LayoutOrder = 3,
    ZIndex = 33,
}, overview)
create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 10),
}, statusRow)

local function statusCard(title, value, parent)
    local card = create("Frame", {
        Size = UDim2.new(0, 180, 0, 75),
        BackgroundColor3 = Color3.fromRGB(28, 25, 55),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 34,
    }, parent)
    roundFrame(card, 12)
    strokeFrame(card, Color3.fromRGB(80, 70, 140), 0.8)
    
    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(160, 155, 200),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 35,
    }, card)
    
    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 28),
        Position = UDim2.new(0, 10, 0, 38),
        BackgroundTransparency = 1,
        Text = value,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 35,
    }, card)
end

statusCard("В поле зрения", "—", statusRow)
statusCard("Частота кадров", "60 FPS", statusRow)
statusCard("Включено", "3 / 10", statusRow)

-- Быстрые переключатели
createTitle("Быстрые переключатели", overview, 4)

local quickRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 90),
    BackgroundTransparency = 1,
    LayoutOrder = 5,
    ZIndex = 33,
}, overview)
create("UIGridLayout", {
    CellSize = UDim2.new(0, 170, 0, 75),
    CellPadding = UDim2.new(0, 10, 0, 10),
}, quickRow)

local function quickToggle(text, parent, defaultOn)
    local card = create("Frame", {
        BackgroundColor3 = defaultOn and Color3.fromRGB(80, 60, 160) or Color3.fromRGB(28, 25, 55),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 34,
    }, parent)
    roundFrame(card, 12)
    strokeFrame(card, Color3.fromRGB(100, 85, 200), 0.8)
    
    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 35,
    }, card)
    
    local stateLbl = create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.new(0, 10, 1, -24),
        BackgroundTransparency = 1,
        Text = defaultOn and "Вкл" or "Выкл",
        TextColor3 = Color3.fromRGB(180, 175, 220),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 35,
    }, card)
    
    local dot = create("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(1, -14, 0, 10),
        BackgroundColor3 = defaultOn and Color3.fromRGB(150, 255, 180) or Color3.fromRGB(80, 75, 110),
        ZIndex = 35,
    }, card)
    roundFrame(dot, 999)
    
    local isOn = defaultOn
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 36,
    }, card)
    
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        tween(card, 0.25, {BackgroundColor3 = isOn and Color3.fromRGB(80, 60, 160) or Color3.fromRGB(28, 25, 55)})
        stateLbl.Text = isOn and "Вкл" or "Выкл"
        tween(dot, 0.25, {BackgroundColor3 = isOn and Color3.fromRGB(150, 255, 180) or Color3.fromRGB(80, 75, 110)})
    end)
end

quickToggle("ВХ", quickRow, true)
quickToggle("Аимбот", quickRow, true)
quickToggle("Силент-аим", quickRow, true)
quickToggle("Быстрая перезарядка", quickRow, true)
quickToggle("АвтоФарм", quickRow, false)
quickToggle("Свободная камера", quickRow, false)
quickToggle("Вид от 3-го лица", quickRow, false)
quickToggle("Своя модель", quickRow, false)

-- ===== ФУНКЦИИ (главное, что просил пользователь) =====
local functions = sectionContents["Функции"]

createTitle("Функции", functions, 1)
createSubtitle("Бой, камера и фарм", functions, 2)

-- Бой
createTitle("⚔ Бой", functions, 3)

createToggle("Без разброса", "Каждый выстрел летит туда, куда указывает перекрестье", functions, 4, true)
createToggle("Без отдачи", "Камера не дёргается при стрельбе", functions, 5, true)
createToggle("Быстрая перезарядка", "Перезарядка заканчивается почти мгновенно", functions, 6, true)
createToggle("Быстрая стрельба", "Стрельба быстрее, чем позволяет оружие", functions, 7, false)
createSlider("Скорострельность", "", functions, 8, 1, 10, 2, "x")

-- АИМБОТ (визуальный, нерабочий — как просил пользователь)
createTitle("◎ Аимбот (визуальный)", functions, 9)
createSubtitle("Демонстрация интерфейса — функция не активна", functions, 10)

local aimbotToggle = createToggle("Аимбот", "Автоматическое наведение на цель (ДЕМО)", functions, 11, true)
createSlider("Угол обзора", "Радиус захвата цели", functions, 12, 0, 360, 60, "°")
createSlider("Плавность", "Насколько плавно поворачивается камера", functions, 13, 0, 100, 10, "")
createSlider("Шанс попадания", "Только для silent-аима", functions, 14, 0, 100, 100, "%")

createToggle("Приоритет", "Голова → Шея → Грудь → Таз", functions, 15, true)
createToggle("Игнорировать за укрытием", "Целится только в части тела в прямой видимости", functions, 16, true)
createSlider("Макс. дистанция", "", functions, 17, 50, 1000, 400, " м")
createToggle("Автострельба", "Стреляет, пока выстрел попадает в цель", functions, 18, false)
createSlider("Реакция", "Ожидание после захвата цели перед первым выстрелом", functions, 19, 0, 500, 0, " мс")
createSlider("Скорострельность", "", functions, 20, 1, 60, 20, " / с")
createSlider("Контроль отдачи", "", functions, 21, 0, 100, 100, "%")

-- Камера
createTitle("📷 Камера", functions, 22)
createToggle("Свой FOV", "", functions, 23, false)
createSlider("Угол обзора", "", functions, 24, 60, 120, 90, "°")
createToggle("Свободная камера", "Отсоединяет камеру и позволяет летать", functions, 25, false)
createSlider("Скорость", "", functions, 26, 1, 50, 10, " м/с")
createToggle("Вид от 3-го лица", "Вид на себя сзади, выстрелы по-прежнему вылетают из головы", functions, 27, false)
createSlider("Дистанция", "", functions, 28, 1, 10, 3, " м")
createSlider("Угол", "", functions, 29, -90, 90, 0, "°")
createToggle("Лицом ко мне", "", functions, 30, false)

-- Автофарм
createTitle("🌲 АвтоФарм", functions, 31)
createSubtitle("Непрерывно добывает ресурс, возвращается к нему и добывает, держа нужную кнопку", functions, 32)
createToggle("Автофарм", "", functions, 33, false)
createTitle("Ресурс", functions, 34)

local resRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 40),
    BackgroundTransparency = 1,
    LayoutOrder = 35,
    ZIndex = 33,
}, functions)
create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, resRow)

local function resBtn(text, parent, active)
    local btn = create("TextButton", {
        Size = UDim2.new(0, 90, 0, 32),
        BackgroundColor3 = active and Color3.fromRGB(80, 60, 160) or Color3.fromRGB(28, 25, 55),
        BackgroundTransparency = 0.3,
        Text = text,
        TextColor3 = Color3.fromRGB(230, 225, 255),
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        BorderSizePixel = 0,
        ZIndex = 34,
    }, parent)
    roundFrame(btn, 8)
    btn.MouseButton1Click:Connect(function()
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextButton") then
                tween(child, 0.2, {BackgroundColor3 = Color3.fromRGB(28, 25, 55)})
            end
        end
        tween(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(80, 60, 160)})
    end)
end

resBtn("Дерево", resRow, true)
resBtn("Металл", resRow, false)
resBtn("Сера", resRow, false)
resBtn("Камень", resRow, false)

createToggle("Идти к нему", "", functions, 36, true)
createSlider("Добывать каждые", "", functions, 37, 0.1, 2, 0.2, " с")

-- ===== ВИЗУАЛ =====
local visuals = sectionContents["Визуал"]
createTitle("Визуал", visuals, 1)
createSubtitle("ВХ, радары, боксы и ресурсы мира", visuals, 2)

createToggle("ВХ", "Показывает игроков, животных и лут", visuals, 3, true)
createToggle("Радар", "Круговой радар в углу экрана", visuals, 4, true)
createSlider("Дистанция тревоги", "", visuals, 5, 10, 200, 50, " м")
createToggle("Животные и лут на радаре", "", visuals, 6, false)
createToggle("Рисовать поверх игры", "Живой ВХ поверх игры", visuals, 7, true)
createToggle("Островок статуса", "Мини-радар в углу экрана", visuals, 8, true)
createToggle("Тревога островка", "", visuals, 9, true)
createSlider("Дистанция тревоги", "", visuals, 10, 10, 200, 50, " м")

createTitle("Игроки", visuals, 11)
createToggle("Игроки не в сети", "Тела вышедших из игры игроков, отмечены луной", visuals, 12, false)
createToggle("Рисовать поверх игры", "Бокс ВХ поверх игры", visuals, 13, true)

createTitle("Стиль бокса", visuals, 14)
local styleRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 40),
    BackgroundTransparency = 1,
    LayoutOrder = 15,
    ZIndex = 33,
}, visuals)
create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, styleRow)
resBtn("Углы", styleRow, false)
resBtn("Контур", styleRow, false)
resBtn("Стекло", styleRow, true)

createToggle("Скелет", "Подсвечивает части тела вне укрытия", visuals, 16, true)
createTitle("Показывать", visuals, 17)
local showRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 40),
    BackgroundTransparency = 1,
    LayoutOrder = 18,
    ZIndex = 33,
}, visuals)
create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, showRow)
resBtn("Игроки", showRow, true)
resBtn("Боты", showRow, true)
resBtn("Враги", showRow, true)

createToggle("Ники", "", visuals, 19, true)
createToggle("Полоска здоровья", "", visuals, 20, true)
createSlider("Дальность", "", visuals, 21, 50, 1000, 500, " м")

-- ===== АИМ =====
local aim = sectionContents["Аим"]
createTitle("Аим", aim, 1)
createSubtitle("Аимбот: цели, точки прицеливания и стрельба", aim, 2)

createToggle("Включено", "Аимбот: точки прицеливания и стрельба", aim, 3, true)
createToggle("Силент-аим", "Выстрелы летят в цель, камера не двигается", aim, 4, true)

createTitle("Активация", aim, 5)
local actRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 40),
    BackgroundTransparency = 1,
    LayoutOrder = 6,
    ZIndex = 33,
}, aim)
create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, actRow)
resBtn("Всегда", actRow, true)
resBtn("Стрельба", actRow, false)
resBtn("Целься", actRow, false)

createSlider("Угол обзора", "", aim, 7, 0, 360, 60, "°")
createSlider("Плавность", "Только ассист: насколько плавно поворачивается камера", aim, 8, 0, 100, 10, "")
createSlider("Шанс попадания", "Только silent: остальные выстрелы могут намеренно промахнуться", aim, 9, 0, 100, 100, "%")

createTitle("Кости", aim, 10)
createSubtitle("Куда целиться на каждой допустимой цели", aim, 11)

createTitle("Целиться в", aim, 12)
local boneRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 40),
    BackgroundTransparency = 1,
    LayoutOrder = 13,
    ZIndex = 33,
}, aim)
create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, boneRow)
resBtn("Голова", boneRow, true)
resBtn("Шея", boneRow, false)
resBtn("Грудь", boneRow, false)
resBtn("Таз", boneRow, false)

createTitle("Панель цели", aim, 14)
createSubtitle("Кто, как далеко, какая кость и что делает", aim, 15)

createTitle("Выбор", aim, 16)
local selRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 40),
    BackgroundTransparency = 1,
    LayoutOrder = 17,
    ZIndex = 33,
}, aim)
create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, selRow)
resBtn("Ближайшая", selRow, false)
resBtn("Приоритет", selRow, true)

createToggle("Отображение", "", aim, 18, true)
createToggle("Круг FOV", "", aim, 19, true)
createToggle("Точки костей", "Каждая отмеченная точка на каждой допустимой цели", aim, 20, true)
createToggle("Линия прицела", "", aim, 21, true)
createToggle("Панель цели", "Кто, как далеко, какая кость и что делает", aim, 22, true)
createToggle("Игнорировать игроков не в сети", "Пропускает тела вышедших из игры игроков", aim, 23, true)
createToggle("Игнорировать за укрытием", "Целится только в части тела в прямой видимости", aim, 24, true)
createSlider("Макс. дистанция", "", aim, 25, 50, 1000, 400, " м")
createToggle("Автострельба", "Стреляет, пока выстрел попадает в цель", aim, 26, false)
createSlider("Реакция", "Ожидание после захвата цели перед первым выстрелом", aim, 27, 0, 500, 0, " мс")
createSlider("Скорострельность", "", aim, 28, 1, 60, 20, " / с")
createSlider("Контроль отдачи", "", aim, 29, 0, 100, 100, "%")

-- ===== МОДЕЛИ =====
local models = sectionContents["Модели"]
createTitle("Модели", models, 1)
createSubtitle("Вид от 3-го лица рисует выбранную модель вместо тела", models, 2)

createTitle("Надето", models, 3)
local modelPreview = create("Frame", {
    Size = UDim2.new(1, -20, 0, 140),
    BackgroundColor3 = Color3.fromRGB(28, 25, 55),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    LayoutOrder = 4,
    ZIndex = 33,
}, models)
roundFrame(modelPreview, 12)
strokeFrame(modelPreview, Color3.fromRGB(80, 70, 140), 0.8)

create("TextLabel", {
    Size = UDim2.new(0, 60, 0, 60),
    Position = UDim2.new(0.5, 0, 0.5, -10),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(50, 45, 80),
    Text = "?",
    TextColor3 = Color3.fromRGB(180, 170, 220),
    TextSize = 32,
    Font = Enum.Font.GothamBold,
    ZIndex = 34,
}, modelPreview)
roundFrame(modelPreview:FindFirstChildWhichIsA("Frame") or modelPreview:WaitForChild("Frame"), 10)

create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 1, -30),
    BackgroundTransparency = 1,
    Text = "Нет модели  •  Выкл",
    TextColor3 = Color3.fromRGB(140, 135, 180),
    TextSize = 11,
    Font = Enum.Font.Gotham,
    ZIndex = 34,
}, modelPreview)

createToggle("Своя модель", "", models, 5, false)

local previewBtn = create("TextButton", {
    Size = UDim2.new(1, -20, 0, 38),
    BackgroundColor3 = Color3.fromRGB(80, 60, 160),
    BackgroundTransparency = 0.3,
    Text = "👁 Предпросмотр",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    BorderSizePixel = 0,
    LayoutOrder = 6,
    ZIndex = 33,
}, models)
roundFrame(previewBtn, 10)

createTitle("Вид", models, 7)
createTitle("Освещение", models, 8)
local lightRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 40),
    BackgroundTransparency = 1,
    LayoutOrder = 9,
    ZIndex = 33,
}, models)
create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, lightRow)
resBtn("Игра", lightRow, false)
resBtn("Свет", lightRow, true)
resBtn("Плоский", lightRow, false)

createTitle("Выражение", models, 10)
local exprRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 40),
    BackgroundTransparency = 1,
    LayoutOrder = 11,
    ZIndex = 33,
}, models)
create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, exprRow)
resBtn("Спокойно", exprRow, true)
resBtn("Радость", exprRow, false)
resBtn("Злость", exprRow, false)
resBtn("Грусть", exprRow, false)
resBtn("Веселье", exprRow, false)
resBtn("Вау", exprRow, false)

createToggle("Моргание", "Время от времени, как у человека", models, 12, true)
createToggle("Физика волос и ткани", "Волосы, юбка и ленты качаются так, как задано в модели", models, 13, true)

-- ===== КОНФИГИ =====
local configs = sectionContents["Конфиги"]
createTitle("Конфиги", configs, 1)
createSubtitle("Сохранение, переключение и обмен целыми наборами настроек", configs, 2)

local cfgCard = create("Frame", {
    Size = UDim2.new(1, -20, 0, 70),
    BackgroundColor3 = Color3.fromRGB(28, 25, 55),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    LayoutOrder = 3,
    ZIndex = 33,
}, configs)
roundFrame(cfgCard, 12)
strokeFrame(cfgCard, Color3.fromRGB(80, 70, 140), 0.8)

create("TextLabel", {
    Size = UDim2.new(0, 36, 0, 36),
    Position = UDim2.new(0, 12, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Color3.fromRGB(80, 60, 160),
    Text = "M",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    ZIndex = 34,
}, cfgCard)
roundFrame(cfgCard:FindFirstChildWhichIsA("Frame"), 999)

create("TextLabel", {
    Size = UDim2.new(1, -70, 0, 20),
    Position = UDim2.new(0, 58, 0, 12),
    BackgroundTransparency = 1,
    Text = "My setup",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 34,
}, cfgCard)

create("TextLabel", {
    Size = UDim2.new(1, -70, 0, 16),
    Position = UDim2.new(0, 58, 0, 34),
    BackgroundTransparency = 1,
    Text = "2 ч назад  •  изменений: 21",
    TextColor3 = Color3.fromRGB(140, 135, 180),
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 34,
}, cfgCard)

create("TextLabel", {
    Size = UDim2.new(0, 80, 0, 16),
    Position = UDim2.new(1, -90, 0, 12),
    BackgroundTransparency = 1,
    Text = "Сохранено: 1",
    TextColor3 = Color3.fromRGB(140, 135, 180),
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 34,
}, cfgCard)

local saveBtn = create("TextButton", {
    Size = UDim2.new(1, -20, 0, 38),
    BackgroundColor3 = Color3.fromRGB(80, 60, 160),
    BackgroundTransparency = 0.3,
    Text = "💾 Сохранить текущие",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    BorderSizePixel = 0,
    LayoutOrder = 4,
    ZIndex = 33,
}, configs)
roundFrame(saveBtn, 10)

-- ===== НАСТРОЙКИ =====
local settings = sectionContents["Настройки"]
createTitle("Настройки", settings, 1)
createSubtitle("Внешний вид меню и конфиги", settings, 2)

createTitle("Внешний вид", settings, 3)
createTitle("Тема", settings, 4)

local themeRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 45),
    BackgroundTransparency = 1,
    LayoutOrder = 5,
    ZIndex = 33,
}, settings)
create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10)}, themeRow)

local themes = {
    Color3.fromRGB(140, 110, 240),
    Color3.fromRGB(80, 200, 220),
    Color3.fromRGB(230, 180, 100),
    Color3.fromRGB(230, 130, 180),
    Color3.fromRGB(80, 150, 240),
    Color3.fromRGB(200, 200, 220),
}

for i, color in ipairs(themes) do
    local themeBtn = create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        ZIndex = 34,
    }, themeRow)
    roundFrame(themeBtn, 999)
    if i == 1 then
        create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "✓",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            ZIndex = 35,
        }, themeBtn)
    end
    themeBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(themeRow:GetChildren()) do
            if child:IsA("TextButton") then
                for _, gc in ipairs(child:GetChildren()) do
                    if gc:IsA("TextLabel") then gc:Destroy() end
                end
            end
        end
        create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "✓",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            ZIndex = 35,
        }, themeBtn)
    end)
end

createSlider("Непрозрачность панели", "Чем меньше, тем лучше видна игра за меню", settings, 6, 30, 100, 88, "%")
createSlider("Масштаб интерфейса", "", settings, 7, 0.5, 2, 1, "x")

createTitle("Анимация", settings, 8)
local animRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 40),
    BackgroundTransparency = 1,
    LayoutOrder = 9,
    ZIndex = 33,
}, settings)
create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)}, animRow)
resBtn("Спокойно", animRow, false)
resBtn("Обычно", animRow, true)
resBtn("Живо", animRow, false)

createTitle("Язык", settings, 10)
local langRow = create("Frame", {
    Size = UDim2.new(1, -20, 0, 70),
    BackgroundTransparency = 1,
    LayoutOrder = 11,
    ZIndex = 33,
}, settings)
create("UIGridLayout", {
    CellSize = UDim2.new(0, 110, 0, 32),
    CellPadding = UDim.new(0, 8, 0, 8),
}, langRow)

local langs = {"Система", "English", "Русский", "Türkçe", "العربية", "فارسی", "繁體中文", "日本語", "???"}
for i, lang in ipairs(langs) do
    local btn = create("TextButton", {
        BackgroundColor3 = (i == 1) and Color3.fromRGB(80, 60, 160) or Color3.fromRGB(28, 25, 55),
        BackgroundTransparency = 0.3,
        Text = lang,
        TextColor3 = Color3.fromRGB(230, 225, 255),
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        BorderSizePixel = 0,
        ZIndex = 34,
    }, langRow)
    roundFrame(btn, 8)
    btn.MouseButton1Click:Connect(function()
        for _, child in ipairs(langRow:GetChildren()) do
            if child:IsA("TextButton") then
                tween(child, 0.2, {BackgroundColor3 = Color3.fromRGB(28, 25, 55)})
            end
        end
        tween(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(80, 60, 160)})
    end)
end

createTitle("Частицы", settings, 12)
createToggle("Фоновые частицы", "Парящие частицы вокруг меню", settings, 13, true)
createSlider("Плотность частиц", "", settings, 14, 0, 100, 60, "%")
createToggle("След от касаний", "Частицы там, где ты касаешься меню", settings, 15, true)
createToggle("Эффект нажатия", "Частицы при нажатии на переключатель или кнопку", settings, 16, true)

createTitle("О программе", settings, 17)
local aboutFrame = create("Frame", {
    Size = UDim2.new(1, -20, 0, 70),
    BackgroundColor3 = Color3.fromRGB(28, 25, 55),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    LayoutOrder = 18,
    ZIndex = 33,
}, settings)
roundFrame(aboutFrame, 12)

create("TextLabel", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(0, 14, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    Text = "η",
    TextColor3 = Color3.fromRGB(200, 180, 255),
    TextSize = 28,
    Font = Enum.Font.GothamBold,
    ZIndex = 34,
}, aboutFrame)

create("TextLabel", {
    Size = UDim2.new(1, -70, 0, 20),
    Position = UDim2.new(0, 62, 0, 14),
    BackgroundTransparency = 1,
    Text = "Finis.Crack",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 34,
}, aboutFrame)

create("TextLabel", {
    Size = UDim2.new(1, -70, 0, 30),
    Position = UDim2.new(0, 62, 0, 36),
    BackgroundTransparency = 1,
    Text = "ВХ, аимбот и твики для Roblox (Delta Injector)",
    TextColor3 = Color3.fromRGB(140, 135, 180),
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 34,
}, aboutFrame)

-- ============================================================
-- ОБРАБОТЧИКИ КНОПОК
-- ============================================================

-- Войти
loginBtn.MouseButton1Click:Connect(function()
    if keyInput.Text == "" then
        keyInput.PlaceholderText = "Введите ключ!"
        tween(keyInputFrame, 0.2, {BackgroundColor3 = Color3.fromRGB(80, 30, 40)})
        wait(1)
        keyInput.PlaceholderText = "Ваш ключ"
        tween(keyInputFrame, 0.2, {BackgroundColor3 = Color3.fromRGB(15, 12, 35)})
        return
    end
    
    -- Анимация успешного входа
    local check = create("Frame", {
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(80, 60, 160),
        ZIndex = 25,
    }, loginFrame)
    roundFrame(check, 999)
    create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "✓",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 32,
        Font = Enum.Font.GothamBold,
        ZIndex = 26,
    }, check)
    
    tween(check, 0.3, {Size = UDim2.new(0, 80, 0, 80)})
    wait(0.5)
    
    -- Скрываем экран входа, показываем главное меню
    tween(loginFrame, 0.4, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.45, 0)})
    wait(0.3)
    loginFrame.Visible = false
    
    mainMenu.Visible = true
    mainMenu.Position = UDim2.new(0.5, 0, 0.55, 0)
    mainMenu.BackgroundTransparency = 1
    tween(mainMenu, 0.5, {
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0.12,
    }, Enum.EasingStyle.Quart)
    
    -- Открываем раздел "Обзор" по умолчанию
    switchSection("Обзор")
end)

-- Закрыть меню
closeBtn.MouseButton1Click:Connect(function()
    tween(mainMenu, 0.35, {
        Position = UDim2.new(0.5, 0, 0.55, 0),
        BackgroundTransparency = 1,
    }, Enum.EasingStyle.Quart)
    wait(0.35)
    mainMenu.Visible = false
end)

-- ============================================================
-- ГОРЯЧАЯ КЛАВИША (INSERT или правая кнопка мыши)
-- ============================================================

local menuOpen = false

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        
        if menuOpen then
            if loginFrame.Visible then
                -- Ничего, сначала нужно войти
            else
                mainMenu.Visible = true
                tween(mainMenu, 0.4, {
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    BackgroundTransparency = 0.12,
                }, Enum.EasingStyle.Quart)
            end
        else
            if mainMenu.Visible then
                tween(mainMenu, 0.35, {
                    Position = UDim2.new(0.5, 0, 0.55, 0),
                    BackgroundTransparency = 1,
                }, Enum.EasingStyle.Quart)
                wait(0.35)
                mainMenu.Visible = false
            end
        end
    end
end)

-- ============================================================
-- ПЕРЕТАСКИВАНИЕ МЕНЮ
-- ============================================================

local draggingMenu = false
local dragStart = nil
local startPos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = true
        dragStart = input.Position
        startPos = mainMenu.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMenu and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainMenu.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = false
    end
end)

-- ============================================================
-- ПРИВЕТСТВИЕ В ЧАТ
-- ============================================================

print("========================================")
print("  Finis.Crack загружен успешно!")
print("  Горячая клавиша: RightShift / Insert")
print("========================================")

-- Готово!