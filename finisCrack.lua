--!nocheck
--[[
	Finis.Crack · v1.0 · Delta / Roblox
	Только меню: анимации, разделы, система ключей.
	Единственная функция — Аимбот (визуальная, на игру не влияет).
	Ключ: @Finisokek
	Управление: тап по шару η — открыть/закрыть · RightShift / Insert на ПК · шапка — перетаскивание.
]]

-- ============================================================
--  СЕРВИСЫ / ОЧИСТКА
-- ============================================================
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInput    = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local HttpService  = game:GetService("HttpService")
local CoreGui      = game:GetService("CoreGui")
local LP           = Players.LocalPlayer

if _G.__FinisCrackCleanup then pcall(_G.__FinisCrackCleanup) end

local conns = {}
local function bind(sig, fn) local c = sig:Connect(fn) conns[#conns+1] = c return c end

local guiParent = CoreGui
pcall(function() if gethui then guiParent = gethui() end end)

local gui = Instance.new("ScreenGui")
gui.Name = "FinisCrack_" .. tostring(math.random(1000,9999))
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
pcall(function() gui.Parent = guiParent end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

_G.__FinisCrackCleanup = function()
	for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	if gui then gui:Destroy() end
	_G.__FinisCrackCleanup = nil
end

-- ============================================================
--  ПАЛИТРА / ТЕМЫ / СОСТОЯНИЕ
-- ============================================================
local C = {
	bg      = Color3.fromRGB(15,13,32),
	panel   = Color3.fromRGB(21,19,44),
	card    = Color3.fromRGB(29,26,56),
	cardHov = Color3.fromRGB(38,34,72),
	stroke  = Color3.fromRGB(97,87,172),
	text    = Color3.fromRGB(241,239,255),
	muted   = Color3.fromRGB(155,149,197),
	dim     = Color3.fromRGB(112,106,152),
	success = Color3.fromRGB(74,222,128),
	danger  = Color3.fromRGB(248,113,113),
	warn    = Color3.fromRGB(251,191,36),
	info    = Color3.fromRGB(96,165,250),
}
local THEMES = {
	{name="Жемчуг",  a=Color3.fromRGB(167,139,250), b=Color3.fromRGB(124,108,240)},
	{name="Мята",    a=Color3.fromRGB(45,212,191),  b=Color3.fromRGB(13,148,136)},
	{name="Янтарь",  a=Color3.fromRGB(251,191,36),  b=Color3.fromRGB(217,119,6)},
	{name="Роза",    a=Color3.fromRGB(244,114,182), b=Color3.fromRGB(219,39,119)},
	{name="Небо",    a=Color3.fromRGB(96,165,250),  b=Color3.fromRGB(37,99,235)},
	{name="Перламутр",a=Color3.fromRGB(226,232,240),b=Color3.fromRGB(148,163,184)},
}
local A, B = THEMES[1].a, THEMES[1].b
local themeFns, bindings, effects = {}, {}, {}

local State = { controls = {}, loggedIn = false, section = "Обзор", start = os.clock() }
local function ctl(k, d) if State.controls[k] == nil then State.controls[k] = d end return State.controls[k] end
local ANIM = {1.55, 1.0, 0.62}
local function dur(t) return t * ANIM[ctl("ui.anim",2)] end

local function setControl(k, v)
	State.controls[k] = v
	for _,h in ipairs(bindings[k] or {}) do h(v) end
	if effects[k] then effects[k](v) end
end

-- ============================================================
--  БАЗОВЫЕ ХЕЛПЕРЫ
-- ============================================================
local function new(class, props, parent)
	local o = Instance.new(class)
	for k,v in pairs(props or {}) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end
local function corner(o,r) return new("UICorner",{CornerRadius=UDim.new(0,r)},o) end
local function stroke(o,col,th,tr) return new("UIStroke",{Color=col,Thickness=th or 1,Transparency=tr or 0.7},o) end
local function pad(o,l,t,r,b) return new("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingTop=UDim.new(0,t or 0),PaddingRight=UDim.new(0,r or 0),PaddingBottom=UDim.new(0,b or 0)},o) end
local function tw(o,t,props,style,dir)
	local ti = TweenInfo.new(dur(t), style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local tween = TweenService:Create(o,ti,props) tween:Play() return tween
end
local function txt(p,s,size,col,font,align)
	return new("TextLabel",{BackgroundTransparency=1,Text=s,TextSize=size,TextColor3=col or C.text,
		Font=font or Enum.Font.Gotham,TextXAlignment=align or Enum.TextXAlignment.Left,
		TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,0,0,size+4)},p)
end

-- ============================================================
--  ВЕКТОРНЫЕ ИКОНКИ (чистые Frame, без эмодзи и ассетов)
-- ============================================================
local function icon(name, parent, s, color, pos, anchor)
	local f = new("Frame",{BackgroundTransparency=1,Size=UDim2.fromOffset(s,s),
		Position=pos or UDim2.new(0,0,0,0),AnchorPoint=anchor or Vector2.new(0,0)},parent)
	local parts = {}
	local function bar(w,h,x,y,rot,fill)
		local b = new("Frame",{BackgroundColor3=color,BackgroundTransparency=fill and 0 or 1,BorderSizePixel=0,
			Size=UDim2.fromOffset(w,h),Position=UDim2.fromOffset(x,y),AnchorPoint=Vector2.new(0.5,0.5),Rotation=rot or 0},f)
		corner(b, math.min(w,h)*0.35)
		if not fill then local st = stroke(b,color,math.max(1,s*0.085),0.1) parts[#parts+1]=st end
		parts[#parts+1]=b
		return b
	end
	if name=="grid" then
		for _,p in ipairs({{0.3,0.3},{0.7,0.3},{0.3,0.7},{0.7,0.7}}) do bar(s*0.32,s*0.32,p[1]*s,p[2]*s,0,true) end
	elseif name=="zap" then
		bar(s*0.17,s*0.5,0.57*s,0.28*s,30,true); bar(s*0.17,s*0.5,0.43*s,0.72*s,30,true); bar(s*0.44,s*0.15,0.5*s,0.5*s,0,true)
	elseif name=="eye" then
		bar(s*0.94,s*0.62,0.5*s,0.5*s,0,false); bar(s*0.27,s*0.27,0.5*s,0.5*s,0,true)
	elseif name=="cross" then
		bar(s*0.64,s*0.64,0.5*s,0.5*s,0,false)
		bar(s*0.09,s*0.22,0.5*s,0.07*s,0,true); bar(s*0.09,s*0.22,0.5*s,0.93*s,0,true)
		bar(s*0.22,s*0.09,0.07*s,0.5*s,0,true); bar(s*0.22,s*0.09,0.93*s,0.5*s,0,true)
		bar(s*0.14,s*0.14,0.5*s,0.5*s,0,true)
	elseif name=="cube" then
		bar(s*0.5,s*0.5,0.32*s,0.66*s,0,false); bar(s*0.5,s*0.5,0.66*s,0.32*s,0,false)
		bar(s*0.34,s*0.07,0.24*s,0.24*s,-45,true); bar(s*0.34,s*0.07,0.74*s,0.74*s,-45,true)
	elseif name=="folder" then
		bar(s*0.36,s*0.15,0.25*s,0.2*s,0,true); bar(s*0.88,s*0.58,0.5*s,0.57*s,0,true)
	elseif name=="sliders" then
		bar(s*0.86,s*0.09,0.5*s,0.2*s,0,true); bar(s*0.86,s*0.09,0.5*s,0.5*s,0,true); bar(s*0.86,s*0.09,0.5*s,0.8*s,0,true)
		bar(s*0.2,s*0.2,0.68*s,0.2*s,0,true); bar(s*0.2,s*0.2,0.3*s,0.5*s,0,true); bar(s*0.2,s*0.2,0.55*s,0.8*s,0,true)
	elseif name=="key" then
		bar(s*0.32,s*0.32,0.2*s,0.5*s,0,false); bar(s*0.56,s*0.12,0.6*s,0.5*s,0,true)
		bar(s*0.09,s*0.2,0.72*s,0.63*s,0,true); bar(s*0.09,s*0.2,0.87*s,0.63*s,0,true)
	elseif name=="clip" then
		bar(s*0.66,s*0.78,0.5*s,0.56*s,0,false); bar(s*0.3,s*0.15,0.5*s,0.14*s,0,true)
	elseif name=="save" then
		bar(s*0.8,s*0.8,0.5*s,0.5*s,0,false); bar(s*0.4,s*0.22,0.5*s,0.24*s,0,true); bar(s*0.44,s*0.3,0.5*s,0.72*s,0,true)
	elseif name=="load" then
		bar(s*0.7,s*0.14,0.5*s,0.78*s,0,true); bar(s*0.14,s*0.5,0.5*s,0.42*s,0,true)
		bar(s*0.34,s*0.1,0.36*s,0.6*s,45,true); bar(s*0.34,s*0.1,0.64*s,0.6*s,-45,true)
	elseif name=="trash" then
		bar(s*0.6,s*0.7,0.5*s,0.58*s,0,false); bar(s*0.8,s*0.1,0.5*s,0.18*s,0,true); bar(s*0.3,s*0.1,0.5*s,0.08*s,0,true)
	elseif name=="copy" then
		bar(s*0.55,s*0.55,0.36*s,0.62*s,0,false); bar(s*0.55,s*0.55,0.62*s,0.36*s,0,false)
	end
	local handle = {frame=f}
	function handle.setColor(col)
		for _,p in ipairs(parts) do
			if p:IsA("UIStroke") then p.Color = col else p.BackgroundColor3 = col end
		end
	end
	return handle
end

-- ============================================================
--  ЭФФЕКТЫ: НАЖАТИЕ / ТОСТ
-- ============================================================
local function pressFx(obj)
	if not ctl("ui.pressFx",true) then return end
	local r = new("Frame",{BackgroundColor3=A,BackgroundTransparency=0.7,BorderSizePixel=0,
		AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.fromOffset(0,0),ZIndex=50},obj)
	corner(r,999)
	local m = math.max(obj.AbsoluteSize.X,obj.AbsoluteSize.Y)*1.4
	tw(r,0.45,{Size=UDim2.fromOffset(m,m),BackgroundTransparency=1})
	task.delay(0.5,function() if r then r:Destroy() end end)
end

local toastHolder, currentToast
local function toast(msg, kind, actionText, actionFn)
	if currentToast then currentToast:Destroy() end
	local col = kind=="ok" and C.success or kind=="err" and C.danger or kind=="warn" and C.warn or A
	local t = new("Frame",{BackgroundColor3=C.panel,BackgroundTransparency=0.08,BorderSizePixel=0,
		AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,-60),Size=UDim2.fromOffset(300,42),ZIndex=200},gui)
	corner(t,12); stroke(t,col,1,0.4)
	local dot = new("Frame",{BackgroundColor3=col,Size=UDim2.fromOffset(8,8),Position=UDim2.new(0,14,0.5,0),AnchorPoint=Vector2.new(0,0.5),BorderSizePixel=0},t)
	corner(dot,999)
	local lbl = txt(t,msg,12,C.text,Enum.Font.GothamMedium)
	lbl.Position=UDim2.new(0,30,0,0); lbl.Size=UDim2.new(1, actionText and -110 or -42,1,0)
	lbl.TextYAlignment=Enum.TextYAlignment.Center
	if actionText then
		local ab = new("TextButton",{Text=actionText,TextColor3=col,Font=Enum.Font.GothamBold,TextSize=11,
			BackgroundColor3=col,BackgroundTransparency=0.85,Size=UDim2.fromOffset(76,26),Position=UDim2.new(1,-86,0.5,0),AnchorPoint=Vector2.new(0,0.5),BorderSizePixel=0,AutoButtonColor=false},t)
		corner(ab,8)
		ab.Activated:Connect(function() if actionFn then actionFn() end t:Destroy() currentToast=nil end)
	end
	currentToast = t
	tw(t,0.35,{Position=UDim2.new(0.5,0,0,16)},Enum.EasingStyle.Back)
	task.delay(2.6,function()
		if t and t.Parent then
			tw(t,0.3,{Position=UDim2.new(0.5,0,0,-60),BackgroundTransparency=1})
			task.delay(0.35,function() if t then t:Destroy() end if currentToast==t then currentToast=nil end end)
		end
	end)
end

-- ============================================================
--  ШАР η (нижний левый, тап = меню, drag = перемещение)
-- ============================================================
local orb = new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=C.panel,BackgroundTransparency=0.15,
	Size=UDim2.fromOffset(54,54),Position=UDim2.new(0,18,1,-76),BorderSizePixel=0,ZIndex=120},gui)
corner(orb,999); local orbStroke = stroke(orb,A,1.5,0.25)
local orbGlow = new("Frame",{BackgroundColor3=A,BackgroundTransparency=0.85,Size=UDim2.new(1,10,1,10),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BorderSizePixel=0,ZIndex=119},orb)
corner(orbGlow,999)
local orbEta = txt(orb,"η",26,A,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
orbEta.Size=UDim2.new(1,0,1,0); orbEta.TextYAlignment=Enum.TextYAlignment.Center
local orbVer = txt(gui,"v1.0 · Delta",9,C.dim,Enum.Font.Gotham,Enum.TextXAlignment.Center)
orbVer.Size=UDim2.fromOffset(90,12); orbVer.Position=UDim2.new(0,0,1,-18)
themeFns[#themeFns+1]=function(a) orbStroke.Color=a; orbGlow.BackgroundColor3=a; orbEta.TextColor3=a end
task.spawn(function()
	while orb and orb.Parent do
		tw(orbGlow,1.4,{BackgroundTransparency=0.93,Size=UDim2.new(1,16,1,16)})
		task.wait(1.4)
		if not orb.Parent then break end
		tw(orbGlow,1.4,{BackgroundTransparency=0.82,Size=UDim2.new(1,8,1,8)})
		task.wait(1.4)
	end
end)

-- ============================================================
--  ЭКРАН ВХОДА
-- ============================================================
local login = new("CanvasGroup",{BackgroundColor3=C.panel,BackgroundTransparency=0.06,BorderSizePixel=0,
	AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.fromOffset(420,344),
	ClipsDescendants=true,ZIndex=100,GroupTransparency=0},gui)
corner(login,20); stroke(login,C.stroke,1.2,0.45)
new("UIGradient",{Rotation=135,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(30,26,60)),ColorSequenceKeypoint.new(1,Color3.fromRGB(17,15,38))})},login)

local logoWrap = new("Frame",{BackgroundTransparency=1,Size=UDim2.fromOffset(90,70),Position=UDim2.new(0.5,0,0,22),AnchorPoint=Vector2.new(0.5,0)},login)
local orbitRing = new("Frame",{BackgroundTransparency=1,Size=UDim2.fromOffset(78,30),Position=UDim2.new(0.5,0,0.55,0),AnchorPoint=Vector2.new(0.5,0.5),Rotation=-16,BorderSizePixel=0},logoWrap)
corner(orbitRing,999); local ringStroke = stroke(orbitRing,A,1.2,0.35)
local loginEta = txt(logoWrap,"η",46,Color3.fromRGB(224,214,255),Enum.Font.GothamBold,Enum.TextXAlignment.Center)
loginEta.Size=UDim2.new(1,0,1,0); loginEta.TextYAlignment=Enum.TextYAlignment.Center
local spark1 = new("Frame",{BackgroundColor3=A,Size=UDim2.fromOffset(5,5),Position=UDim2.new(0,8,0,16),Rotation=45,BorderSizePixel=0},logoWrap)
local spark2 = new("Frame",{BackgroundColor3=C.text,BackgroundTransparency=0.3,Size=UDim2.fromOffset(3,3),Position=UDim2.new(1,-12,0,40),Rotation=45,BorderSizePixel=0},logoWrap)
themeFns[#themeFns+1]=function(a) ringStroke.Color=a; loginEta.TextColor3=a:Lerp(C.text,0.5); spark1.BackgroundColor3=a end

local loginTitle = txt(login,"Finis.Crack",27,C.text,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
loginTitle.Position=UDim2.new(0,0,0,98); loginTitle.Size=UDim2.new(1,0,0,32)
local loginSub = txt(login,"Введи ключ, чтобы продолжить",12,C.muted,Enum.Font.Gotham,Enum.TextXAlignment.Center)
loginSub.Position=UDim2.new(0,0,0,132); loginSub.Size=UDim2.new(1,0,0,16)

local inputCard = new("Frame",{BackgroundColor3=Color3.fromRGB(14,12,32),BackgroundTransparency=0.25,BorderSizePixel=0,
	Size=UDim2.new(1,-56,0,46),Position=UDim2.new(0,28,0,164)},login)
corner(inputCard,12); local inputStroke = stroke(inputCard,C.stroke,1,0.5)
icon("key",inputCard,18,Color3.fromRGB(230,150,110),UDim2.new(0,14,0.5,0),Vector2.new(0,0.5))
local keyBox = new("TextBox",{BackgroundTransparency=1,Text="",PlaceholderText="Ваш ключ",PlaceholderColor3=C.dim,
	TextColor3=C.text,TextSize=14,Font=Enum.Font.GothamMedium,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,
	Size=UDim2.new(1,-52,1,0),Position=UDim2.new(0,42,0,0)},inputCard)

local pasteBtn = new("TextButton",{Text="Вставить",TextColor3=C.text,Font=Enum.Font.GothamMedium,TextSize=12,
	BackgroundColor3=C.card,BackgroundTransparency=0.2,Size=UDim2.new(0,112,0,44),Position=UDim2.new(0,28,0,224),BorderSizePixel=0,AutoButtonColor=false},login)
corner(pasteBtn,12); stroke(pasteBtn,C.stroke,1,0.6)
icon("clip",pasteBtn,14,C.muted,UDim2.new(0,12,0.5,0),Vector2.new(0,0.5))
pasteBtn.TextXAlignment=Enum.TextXAlignment.Center

local loginBtn = new("TextButton",{Text="Войти  →",TextColor3=Color3.fromRGB(20,16,40),Font=Enum.Font.GothamBold,TextSize=14,
	BackgroundColor3=Color3.fromRGB(255,255,255),Size=UDim2.new(1,-156,0,44),Position=UDim2.new(0,148,0,224),BorderSizePixel=0,AutoButtonColor=false},login)
corner(loginBtn,12)
local loginGrad = new("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,B),ColorSequenceKeypoint.new(1,A)})},loginBtn)
themeFns[#themeFns+1]=function(a,b) loginGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,b),ColorSequenceKeypoint.new(1,a)}) end

local loginFoot = txt(login,"FINIS.CRACK  •  v1.0  •  Delta",10,C.dim,Enum.Font.Gotham,Enum.TextXAlignment.Center)
loginFoot.Position=UDim2.new(0,0,1,-30); loginFoot.Size=UDim2.new(1,0,0,14)

-- ============================================================
--  ГЛАВНОЕ МЕНЮ
-- ============================================================
local menu = new("CanvasGroup",{BackgroundColor3=C.panel,BackgroundTransparency=0.1,BorderSizePixel=0,
	AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.fromOffset(960,600),
	ClipsDescendants=true,Visible=false,ZIndex=90,GroupTransparency=1},gui)
corner(menu,20); local menuStroke = stroke(menu,C.stroke,1.2,0.45)
new("UIGradient",{Rotation=135,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(28,25,56)),ColorSequenceKeypoint.new(1,Color3.fromRGB(16,14,36))})},menu)
themeFns[#themeFns+1]=function(a) menuStroke.Color=a end
local menuScale = new("UIScale",{Scale=1},menu)

local particleLayer = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=1},menu)

-- Шапка
local header = new("Frame",{BackgroundColor3=Color3.fromRGB(17,15,38),BackgroundTransparency=0.35,BorderSizePixel=0,Size=UDim2.new(1,0,0,58),ZIndex=5},menu)
local headerFix = new("Frame",{BackgroundColor3=Color3.fromRGB(17,15,38),BackgroundTransparency=0.35,BorderSizePixel=0,Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,1,-20),ZIndex=5},header)
corner(header,20)
icon("grid",header,0.001,C.muted) -- placeholder removed below
header:FindFirstChildWhichIsA("Frame"):Destroy()
local hEta = txt(header,"η",26,A,Enum.Font.GothamBold)
hEta.Size=UDim2.fromOffset(34,34); hEta.Position=UDim2.new(0,18,0.5,0); hEta.AnchorPoint=Vector2.new(0,0.5); hEta.TextYAlignment=Enum.TextYAlignment.Center
themeFns[#themeFns+1]=function(a) hEta.TextColor3=a end
local hTitle = txt(header,"Finis.Crack",18,C.text,Enum.Font.GothamBold)
hTitle.Size=UDim2.fromOffset(220,20); hTitle.Position=UDim2.new(0,56,0,12)
local hSub = txt(header,"ROBLOX  •  DELTA INJECTOR",9,C.dim,Enum.Font.GothamMedium)
hSub.Size=UDim2.fromOffset(240,12); hSub.Position=UDim2.new(0,57,0,33)

local statusPill = new("Frame",{BackgroundColor3=Color3.fromRGB(18,48,34),BackgroundTransparency=0.4,BorderSizePixel=0,
	Size=UDim2.fromOffset(128,28),Position=UDim2.new(1,-178,0.5,0),AnchorPoint=Vector2.new(0,0.5),ZIndex=6},header)
corner(statusPill,999)
local statusDot = new("Frame",{BackgroundColor3=C.success,Size=UDim2.fromOffset(8,8),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),BorderSizePixel=0},statusPill)
corner(statusDot,999)
local statusTxt = txt(statusPill,"Подключено",11,Color3.fromRGB(178,247,205),Enum.Font.GothamMedium)
statusTxt.Position=UDim2.new(0,26,0,0); statusTxt.Size=UDim2.new(1,-30,1,0); statusTxt.TextYAlignment=Enum.TextYAlignment.Center
task.spawn(function()
	while statusDot and statusDot.Parent do
		tw(statusDot,1,{BackgroundTransparency=0.55}); task.wait(1)
		if not statusDot.Parent then break end
		tw(statusDot,1,{BackgroundTransparency=0}); task.wait(1)
	end
end)

local closeBtn = new("TextButton",{Text="✕",TextColor3=C.muted,Font=Enum.Font.GothamBold,TextSize=13,
	BackgroundColor3=C.card,BackgroundTransparency=0.3,Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-42,0.5,0),AnchorPoint=Vector2.new(0,0.5),BorderSizePixel=0,AutoButtonColor=false,ZIndex=6},header)
corner(closeBtn,999)

-- Сайдбар
local sidebar = new("Frame",{BackgroundColor3=Color3.fromRGB(17,15,38),BackgroundTransparency=0.45,BorderSizePixel=0,
	Size=UDim2.new(0,168,1,-86),Position=UDim2.new(0,0,0,58),ZIndex=4},menu)
local sideList = new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},sidebar)
pad(sidebar,10,12,10,10)

-- Футер
local footer = txt(menu,"FINIS.CRACK  •  v1.0  •  Delta",9,C.dim,Enum.Font.GothamMedium)
footer.Position=UDim2.new(0,18,1,-24); footer.Size=UDim2.fromOffset(260,14); footer.ZIndex=6
local grip = new("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.fromOffset(26,26),Position=UDim2.new(1,-30,1,-30),BorderSizePixel=0,ZIndex=6},menu)
for gy=0,2 do for gx=0,1 do
	local d=new("Frame",{BackgroundColor3=C.dim,Size=UDim2.fromOffset(3,3),Position=UDim2.fromOffset(8+gx*7,8+gy*7),BorderSizePixel=0},grip); corner(d,999)
end end

-- Контент
local contentArea = new("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,180,0,68),Size=UDim2.new(1,-196,1,-100),ZIndex=3},menu)

-- ============================================================
--  КОМПОНЕНТЫ
-- ============================================================
local function sectionHeader(parent, iconName, title, sub)
	local f = new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0, sub and 46 or 28)},parent)
	local ic = icon(iconName,f,18,A,UDim2.new(0,2,0,4))
	themeFns[#themeFns+1]=function(a) ic.setColor(a) end
	local t = txt(f,title,17,C.text,Enum.Font.GothamBold); t.Position=UDim2.new(0,28,0,0); t.Size=UDim2.new(1,-28,0,22)
	if sub then local s=txt(f,sub,11,C.muted); s.Position=UDim2.new(0,28,0,24); s.Size=UDim2.new(1,-28,0,16) end
	return f
end

local function cardBase(parent,h)
	local c = new("Frame",{BackgroundColor3=C.card,BackgroundTransparency=0.35,BorderSizePixel=0,Size=UDim2.new(1,0,0,h)},parent)
	corner(c,12); stroke(c,C.stroke,1,0.78)
	return c
end

local function toggle(parent,key,title,desc,iconName,default)
	ctl(key,default)
	local h = desc and 58 or 44
	local c = new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=C.card,BackgroundTransparency=0.35,BorderSizePixel=0,Size=UDim2.new(1,0,0,h)},parent)
	corner(c,12); stroke(c,C.stroke,1,0.78)
	local x = 14
	if iconName then icon(iconName,c,17,C.muted,UDim2.new(0,14,0.5,0),Vector2.new(0,0.5)); x=42 end
	local t = txt(c,title,13,C.text,Enum.Font.GothamMedium)
	t.Size=UDim2.new(1,-x-66,0,18)
	if desc then t.Position=UDim2.new(0,x,0,9) else t.Position=UDim2.new(0,x,0.5,0); t.AnchorPoint=Vector2.new(0,0.5) end
	if desc then local d=txt(c,desc,10,C.muted); d.Position=UDim2.new(0,x,0,29); d.Size=UDim2.new(1,-x-66,0,16) end
	local sw = new("Frame",{BackgroundColor3=Color3.fromRGB(52,48,86),Size=UDim2.fromOffset(44,24),Position=UDim2.new(1,-56,0.5,0),AnchorPoint=Vector2.new(0,0.5),BorderSizePixel=0},c)
	corner(sw,999)
	local knob = new("Frame",{BackgroundColor3=Color3.fromRGB(236,234,250),Size=UDim2.fromOffset(18,18),Position=UDim2.fromOffset(3,3),BorderSizePixel=0},sw)
	corner(knob,999)
	local function paint(v)
		tw(sw,0.2,{BackgroundColor3=v and A or Color3.fromRGB(52,48,86)})
		tw(knob,0.2,{Position=v and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3)})
	end
	bindings[key]=bindings[key] or {}; bindings[key][#bindings[key]+1]=paint
	paint(State.controls[key])
	c.Activated:Connect(function() setControl(key,not State.controls[key]); pressFx(c) end)
	return c
end

local function slider(parent,key,title,desc,min,max,default,suffix,step)
	ctl(key,default)
	step = step or 1
	local c = cardBase(parent, desc and 70 or 60)
	local t = txt(c,title,13,C.text,Enum.Font.GothamMedium); t.Position=UDim2.new(0,14,0,9); t.Size=UDim2.new(1,-90,0,18)
	local val = txt(c,"",12,A,Enum.Font.GothamBold,Enum.TextXAlignment.Right); val.Position=UDim2.new(1,-76,0,9); val.Size=UDim2.fromOffset(62,18)
	themeFns[#themeFns+1]=function(a) val.TextColor3=a end
	if desc then local d=txt(c,desc,10,C.muted); d.Position=UDim2.new(0,14,0,28); d.Size=UDim2.new(1,-28,0,14) end
	local trackY = desc and 52 or 42
	local track = new("Frame",{BackgroundColor3=Color3.fromRGB(44,40,76),Size=UDim2.new(1,-28,0,6),Position=UDim2.new(0,14,0,trackY),BorderSizePixel=0},c)
	corner(track,999)
	local fill = new("Frame",{BackgroundColor3=A,Size=UDim2.new(0,0,1,0),BorderSizePixel=0},track); corner(fill,999)
	local knob = new("Frame",{BackgroundColor3=Color3.fromRGB(238,236,252),Size=UDim2.fromOffset(14,14),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0),BorderSizePixel=0,ZIndex=3},track)
	corner(knob,999)
	local hit = new("TextButton",{Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,0.5,-13),BorderSizePixel=0},track)
	local function fmt(v)
		if step<1 then return string.format("%.1f",v)..(suffix or "") end
		return tostring(math.floor(v+0.5))..(suffix or "")
	end
	local function paint(v)
		local p = math.clamp((v-min)/(max-min),0,1)
		fill.Size=UDim2.new(p,0,1,0); knob.Position=UDim2.new(p,0,0.5,0); val.Text=fmt(v)
		fill.BackgroundColor3=A
	end
	bindings[key]=bindings[key] or {}; bindings[key][#bindings[key]+1]=paint
	paint(State.controls[key])
	local dragging=false
	local function update(x)
		local p = math.clamp((x-track.AbsolutePosition.X)/math.max(1,track.AbsoluteSize.X),0,1)
		local v = min+(max-min)*p
		v = math.floor(v/step+0.5)*step
		setControl(key, math.clamp(v,min,max))
	end
	hit.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging=true; update(i.Position.X)
		end
	end)
	bind(UserInput.InputChanged,function(i)
		if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i.Position.X) end
	end)
	bind(UserInput.InputEnded,function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
	end)
	return c
end

local function segmented(parent,key,options,default)
	ctl(key,default)
	local c = new("Frame",{BackgroundColor3=Color3.fromRGB(20,18,42),BackgroundTransparency=0.3,BorderSizePixel=0,Size=UDim2.new(1,0,0,38)},parent)
	corner(c,10); pad(c,4,4,4,4)
	local lay = new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},c)
	local btns={}
	for i,opt in ipairs(options) do
		local b=new("TextButton",{Text=opt,TextColor3=C.muted,Font=Enum.Font.GothamMedium,TextSize=11,
			BackgroundColor3=A,BackgroundTransparency=1,Size=UDim2.new(1/#options,-4,1,0),BorderSizePixel=0,AutoButtonColor=false,LayoutOrder=i},c)
		corner(b,8); btns[i]=b
		b.Activated:Connect(function() setControl(key,opt); pressFx(b) end)
	end
	local function paint(v)
		for i,b in ipairs(btns) do
			local on = options[i]==v
			tw(b,0.18,{BackgroundTransparency=on and 0.15 or 1,TextColor3=on and C.text or C.muted})
			b.BackgroundColor3=A
		end
	end
	bindings[key]=bindings[key] or {}; bindings[key][#bindings[key]+1]=paint
	paint(State.controls[key])
	return c
end

local function button(parent,text,kind,fn)
	local b=new("TextButton",{Text=text,TextColor3=kind=="primary" and Color3.fromRGB(20,16,40) or C.text,
		Font=Enum.Font.GothamBold,TextSize=12,BackgroundColor3=kind=="primary" and Color3.fromRGB(255,255,255) or C.card,
		BackgroundTransparency=kind=="primary" and 0 or 0.25,Size=UDim2.new(1,0,0,40),BorderSizePixel=0,AutoButtonColor=false},parent)
	corner(b,10)
	if kind=="primary" then
		local g=new("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,B),ColorSequenceKeypoint.new(1,A)})},b)
		themeFns[#themeFns+1]=function(a,bb) g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,bb),ColorSequenceKeypoint.new(1,a)}) end
	else stroke(b,C.stroke,1,0.6) end
	b.Activated:Connect(function() pressFx(b); if fn then fn() end end)
	return b
end

local function chip(parent,text,col)
	local f=new("Frame",{BackgroundColor3=col,BackgroundTransparency=0.85,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,24)},parent)
	corner(f,999); pad(f,10,0,12,0)
	local d=new("Frame",{BackgroundColor3=col,Size=UDim2.fromOffset(6,6),Position=UDim2.new(0,0,0.5,0),AnchorPoint=Vector2.new(0,0.5),BorderSizePixel=0},f); corner(d,999)
	local t=txt(f,text,10,col,Enum.Font.GothamMedium); t.Position=UDim2.new(0,12,0,0); t.Size=UDim2.fromOffset(0,24); t.AutomaticSize=Enum.AutomaticSize.X; t.TextYAlignment=Enum.TextYAlignment.Center
	return f,t
end

-- Двухколоночный контейнер с рефлоу
local columnRegistry={}
local function columns(parent)
	local cont=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,10)},parent)
	local L=new("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,0),Size=UDim2.new(0.5,-6,0,0)},cont)
	local R=new("Frame",{BackgroundTransparency=1,Position=UDim2.new(0.5,6,0,0),Size=UDim2.new(0.5,-6,0,0)},cont)
	local ll=new("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},L)
	local rl=new("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},R)
	local reg={L=L,R=R,compact=false}
	function reg.update()
		local lh,rh=ll.AbsoluteContentSize.Y,rl.AbsoluteContentSize.Y
		if reg.compact then
			L.Position=UDim2.new(0,0,0,0); L.Size=UDim2.new(1,0,0,lh)
			R.Position=UDim2.new(0,0,0,lh+10); R.Size=UDim2.new(1,0,0,rh)
			cont.Size=UDim2.new(1,0,0,lh+rh+10)
		else
			L.Position=UDim2.new(0,0,0,0); L.Size=UDim2.new(0.5,-6,0,lh)
			R.Position=UDim2.new(0.5,6,0,0); R.Size=UDim2.new(0.5,-6,0,rh)
			cont.Size=UDim2.new(1,0,0,math.max(lh,rh))
		end
	end
	ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(reg.update)
	rl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(reg.update)
	columnRegistry[#columnRegistry+1]=reg
	task.defer(reg.update)
	return L,R
end

-- ============================================================
--  РАЗДЕЛЫ
-- ============================================================
local sections, navItems = {}, {}
local function makeSection(name)
	local root=new("CanvasGroup",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Visible=false,GroupTransparency=1},contentArea)
	local scroll=new("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),
		CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,
		ScrollBarThickness=4,ScrollBarImageColor3=A,ScrollBarImageTransparency=0.4},root)
	themeFns[#themeFns+1]=function(a) scroll.ScrollBarImageColor3=a end
	local lay=new("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
	pad(scroll,2,2,10,10)
	sections[name]={root=root,scroll=scroll}
	return scroll
end

local switchSection
local function buildNav()
	local defs={
		{"Обзор","grid"},{"Функции","zap"},{"Визуал","eye"},{"Аим","cross"},
		{"Модели","cube"},{"Конфиги","folder"},{"Настройки","sliders"},
	}
	for i,d in ipairs(defs) do
		local name,ic=d[1],d[2]
		local b=new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=C.card,BackgroundTransparency=0.7,
			Size=UDim2.new(1,0,0,40),BorderSizePixel=0,LayoutOrder=i},sidebar)
		corner(b,10)
		local ind=new("Frame",{BackgroundColor3=A,BackgroundTransparency=1,Size=UDim2.fromOffset(3,20),Position=UDim2.new(0,-6,0.5,0),AnchorPoint=Vector2.new(0,0.5),BorderSizePixel=0},b)
		corner(ind,999)
		local ih=icon(ic,b,17,C.muted,UDim2.new(0,14,0.5,0),Vector2.new(0,0.5))
		local lb=txt(b,name,12,C.muted,Enum.Font.GothamMedium); lb.Position=UDim2.new(0,40,0,0); lb.Size=UDim2.new(1,-46,1,0); lb.TextYAlignment=Enum.TextYAlignment.Center
		navItems[#navItems+1]={name=name,btn=b,ind=ind,icon=ih,label=lb}
		b.Activated:Connect(function() switchSection(name) end)
	end
end

local switchToken=0
switchSection=function(name)
	if State.section==name and sections[name] and sections[name].root.Visible then return end
	State.section=name
	for _,it in ipairs(navItems) do
		local on=it.name==name
		tw(it.btn,0.22,{BackgroundTransparency=on and 0.15 or 0.7,BackgroundColor3=on and A or C.card})
		tw(it.ind,0.22,{BackgroundTransparency=on and 0 or 1})
		it.label.TextColor3=on and C.text or C.muted
		it.icon.setColor(on and C.text or C.muted)
		it.ind.BackgroundColor3=A
	end
	switchToken+=1
	local tok=switchToken
	for n,s in pairs(sections) do
		if n==name then
			s.root.Visible=true; s.root.GroupTransparency=1; s.scroll.CanvasPosition=Vector2.new(0,0)
			tw(s.root,0.3,{GroupTransparency=0})
		elseif s.root.Visible then
			tw(s.root,0.18,{GroupTransparency=1})
			task.delay(dur(0.18),function() if tok==switchToken and State.section~=n then s.root.Visible=false end end)
		end
	end
end

-- ---------- ОБЗОР ----------
local function buildOverview()
	local s=makeSection("Обзор")
	sectionHeader(s,"grid","Обзор","Игра вкратце и несколько переключателей под рукой")

	local hero=cardBase(s,120)
	local eta=txt(hero,"η",40,A,Enum.Font.GothamBold); eta.Size=UDim2.fromOffset(56,56); eta.Position=UDim2.new(0,16,0,14); eta.TextYAlignment=Enum.TextYAlignment.Center
	themeFns[#themeFns+1]=function(a) eta.TextColor3=a end
	local ht=txt(hero,"Finis.Crack готов",16,C.text,Enum.Font.GothamBold); ht.Position=UDim2.new(0,80,0,14); ht.Size=UDim2.new(1,-96,0,20)
	local hd=txt(hero,"Визуальное меню для Roblox. Аимбот — демо, на игру не влияет. Переключатели ниже и быстрый шар поверх игры.",10,C.muted); hd.Position=UDim2.new(0,80,0,36); hd.Size=UDim2.new(1,-96,0,28); hd.TextWrapped=true; hd.TextYAlignment=Enum.TextYAlignment.Top
	local chips=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-96,0,24),Position=UDim2.new(0,80,0,76)},hero)
	new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6)},chips)
	chip(chips,"В игре",C.success)
	chip(chips,"Ключ · @Finisokek",C.info)
	chip(chips,"Лицензия активна",C.success)
	local _,upT=chip(chips,"Аптайм 00:00",A)
	State.uptimeLabel=upT

	local stTitle=sectionHeader(s,"zap","Статус")
	local row=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,84)},s)
	new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,10)},row)
	local function statCard(title,value)
		local c=new("Frame",{BackgroundColor3=C.card,BackgroundTransparency=0.35,BorderSizePixel=0,Size=UDim2.new(1/3,-7,1,0)},row)
		corner(c,12); stroke(c,C.stroke,1,0.78)
		local t=txt(c,title,10,C.muted); t.Position=UDim2.new(0,12,0,10); t.Size=UDim2.new(1,-24,0,14)
		local v=txt(c,value,22,C.text,Enum.Font.GothamBold); v.Position=UDim2.new(0,12,0,34); v.Size=UDim2.new(1,-24,0,28)
		return c,v
	end
	local _,fovV=statCard("В поле зрения","—")
	local fpsCard,fpsV=statCard("Частота кадров","60")
	local _,enV=statCard("Включено","0 / 6")
	State.enabledLabel=enV
	local spark=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-24,0,22),Position=UDim2.new(0,12,1,-28)},fpsCard)
	State.sparkBars={}
	for i=1,24 do
		local bbar=new("Frame",{BackgroundColor3=A,BackgroundTransparency=0.35,BorderSizePixel=0,Size=UDim2.new(1/24,-2,0.5,0),Position=UDim2.new((i-1)/24,1,1,0),AnchorPoint=Vector2.new(0,1)},spark)
		corner(bbar,2); State.sparkBars[i]=bbar
		themeFns[#themeFns+1]=function(a) bbar.BackgroundColor3=a end
	end

	sectionHeader(s,"grid","Быстрые переключатели")
	local grid=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,168)},s)
	new("UIGridLayout",{CellSize=UDim2.new(0.5,-6,0,78),CellPadding=UDim2.new(0,10,0,10),SortOrder=Enum.SortOrder.LayoutOrder},grid)
	local quickDefs={
		{"aim.enabled","Аимбот","cross",true},
		{"aim.silent","Силент-аим","zap",true},
		{"orb","Быстрый шар","grid",true},
		{"ui.particles","Фоновые частицы","spark",true},
		{"ui.pressFx","Эффект нажатия","cross",true},
		{"ui.touchTrail","След от касаний","eye",true},
	}
	State.quickCount=#quickDefs
	for i,q in ipairs(quickDefs) do
		ctl(q[1],q[4])
		local c=new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=C.card,BackgroundTransparency=0.3,BorderSizePixel=0,LayoutOrder=i},grid)
		corner(c,12); stroke(c,C.stroke,1,0.7)
		local ih=icon(q[3]=="spark" and "zap" or q[3],c,16,C.muted,UDim2.new(0,12,0,12))
		local dot=new("Frame",{Size=UDim2.fromOffset(8,8),Position=UDim2.new(1,-16,0,12),BorderSizePixel=0},c); corner(dot,999)
		local nm=txt(c,q[2],12,C.text,Enum.Font.GothamBold); nm.Position=UDim2.new(0,12,0,36); nm.Size=UDim2.new(1,-24,0,16)
		local st=txt(c,"Выкл",10,C.muted); st.Position=UDim2.new(0,12,0,54); st.Size=UDim2.new(1,-24,0,14)
		local function paint(v)
			tw(c,0.2,{BackgroundColor3=v and A or C.card,BackgroundTransparency=v and 0.55 or 0.3})
			dot.BackgroundColor3=v and C.success or Color3.fromRGB(70,66,104)
			st.Text=v and "Вкл" or "Выкл"
			ih.setColor(v and C.text or C.muted)
			nm.TextColor3=C.text
		end
		bindings[q[1]]=bindings[q[1]] or {}; bindings[q[1]][#bindings[q[1]]+1]=paint
		paint(State.controls[q[1]])
		c.Activated:Connect(function() setControl(q[1],not State.controls[q[1]]); pressFx(c) end)
	end

	button(s,"Настроить  →","ghost",function() switchSection("Настройки") end)
	toggle(s,"orb","Быстрый шар","Стеклянный шар поверх игры; перетащи его к любому краю","grid",true)
end

-- ---------- ФУНКЦИИ (единственная визуальная функция) ----------
local previewTargets, previewLine, previewCircle, previewCross, previewSpark
local function buildFunctions()
	local s=makeSection("Функции")
	sectionHeader(s,"zap","Функции","Доступна одна визуальная функция — Аимбот")

	local L,R=columns(s)

	local pc=cardBase(L,210)
	local pt=txt(pc,"Предпросмотр",12,C.text,Enum.Font.GothamBold); pt.Position=UDim2.new(0,14,0,10); pt.Size=UDim2.new(1,-100,0,16)
	local demo=txt(pc,"DEMO · визуально",9,A,Enum.Font.GothamBold,Enum.TextXAlignment.Right); demo.Position=UDim2.new(1,-110,0,12); demo.Size=UDim2.fromOffset(96,14)
	themeFns[#themeFns+1]=function(a) demo.TextColor3=a end
	local arena=new("Frame",{BackgroundColor3=Color3.fromRGB(12,10,28),BackgroundTransparency=0.2,BorderSizePixel=0,Size=UDim2.new(1,-28,1,-44),Position=UDim2.new(0,14,0,32),ClipsDescendants=true},pc)
	corner(arena,10); stroke(arena,C.stroke,1,0.8)
	previewCircle=new("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.fromOffset(80,80),BorderSizePixel=0},arena)
	corner(previewCircle,999); local pcStroke=stroke(previewCircle,A,1.2,0.3)
	themeFns[#themeFns+1]=function(a) pcStroke.Color=a end
	previewCross=new("Frame",{BackgroundColor3=C.text,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.fromOffset(4,4),BorderSizePixel=0,ZIndex=4},arena); corner(previewCross,999)
	previewLine=new("Frame",{BackgroundColor3=A,BackgroundTransparency=0.2,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.fromOffset(0,2),BorderSizePixel=0,ZIndex=3},arena)
	themeFns[#themeFns+1]=function(a) previewLine.BackgroundColor3=a end
	previewTargets={}
	for i=1,5 do
		local d=new("Frame",{BackgroundColor3=i==1 and C.danger or C.muted,AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(8,8),BorderSizePixel=0,ZIndex=2},arena)
		corner(d,999)
		previewTargets[i]={obj=d,ang=math.random()*6.28,rad=0.2+math.random()*0.3,spd=(0.2+math.random()*0.4)*(i%2==0 and 1 or -1)}
	end
	State.arena=arena

	toggle(L,"aim.enabled","Аимбот","Автоматическое наведение на цель (демо, не влияет на игру)","cross",true)
	toggle(L,"aim.silent","Силент-аим","Выстрелы летят в цель, камера не двигается (демо)","zap",true)
	button(L,"Настроить аим  →","primary",function() switchSection("Аим") end)

	local note=cardBase(R,86)
	local nt=txt(note,"Только меню",12,C.text,Enum.Font.GothamBold); nt.Position=UDim2.new(0,14,0,10); nt.Size=UDim2.new(1,-28,0,16)
	local nd=txt(note,"Все остальные функции удалены из сборки. Переключатели и слайдеры анимируются и сохраняются в конфиг, но gameplay не трогают.",10,C.muted); nd.Position=UDim2.new(0,14,0,30); nd.Size=UDim2.new(1,-28,0,44); nd.TextWrapped=true; nd.TextYAlignment=Enum.TextYAlignment.Top
	slider(R,"aim.fov","Угол обзора","Радиус захвата цели",10,180,60,"°")
	slider(R,"aim.smooth","Плавность","Насколько плавно идёт наведение",1,100,10,"")
	slider(R,"aim.hitChance","Шанс попадания","Только для silent-аима",0,100,100,"%")
end

-- ---------- ВИЗУАЛ / МОДЕЛИ (удалены → пустые состояния) ----------
local function buildEmpty(name,iconName,title,desc)
	local s=makeSection(name)
	local wrap=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0)},s)
	local box=new("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,-40,0,220)},wrap)
	local ic=icon(iconName,box,44,C.dim,UDim2.new(0.5,0,0,0),Vector2.new(0.5,0))
	local t=txt(box,title,16,C.text,Enum.Font.GothamBold,Enum.TextXAlignment.Center); t.Position=UDim2.new(0,0,0,64); t.Size=UDim2.new(1,0,0,22)
	local d=txt(box,desc,11,C.muted,Enum.Font.Gotham,Enum.TextXAlignment.Center); d.Position=UDim2.new(0,0,0,92); d.Size=UDim2.new(1,0,0,40); d.TextWrapped=true
	local b=button(box,"К Аимботу  →","primary",function() switchSection("Функции") end)
	b.Size=UDim2.new(0,200,0,40); b.Position=UDim2.new(0.5,0,0,150); b.AnchorPoint=Vector2.new(0.5,0)
end

-- ---------- АИМ ----------
local function buildAim()
	local s=makeSection("Аим")
	sectionHeader(s,"cross","Аим","Аимбот: цели, точки прицеливания и стрельба · визуально")
	local L,R=columns(s)

	toggle(L,"aim.enabled","Включено","Аимбот: точки прицеливания и стрельба (демо)","cross",true)
	toggle(L,"aim.silent","Силент-аим","Выстрелы летят в цель, камера не двигается","zap",true)
	local actT=txt(L,"Активация",12,C.text,Enum.Font.GothamBold); actT.Size=UDim2.new(1,0,0,16)
	segmented(L,"aim.activation",{"Всегда","Стрельба","Целься"},"Всегда")
	slider(L,"aim.fov","Угол обзора","",10,180,60,"°")
	slider(L,"aim.smooth","Плавность","Только ассист: насколько плавно поворачивается камера",1,100,10,"")
	slider(L,"aim.hitChance","Шанс попадания","Только silent: остальные выстрелы могут намеренно промахнуться",0,100,100,"%")
	local boneT=txt(L,"Кости · Целиться в",12,C.text,Enum.Font.GothamBold); boneT.Size=UDim2.new(1,0,0,16)
	segmented(L,"aim.bone",{"Голова","Шея","Грудь","Таз"},"Голова")
	local selT=txt(L,"Выбор",12,C.text,Enum.Font.GothamBold); selT.Size=UDim2.new(1,0,0,16)
	segmented(L,"aim.select",{"Ближайшая","Приоритет"},"Приоритет")

	toggle(R,"aim.ignoreCover","Игнорировать за укрытием","Целится только в части тела в прямой видимости","eye",true)
	slider(R,"aim.maxDist","Макс. дистанция","",50,1000,400," м")
	toggle(R,"aim.predict","Упреждение","Движущаяся цель — упреждение по её скорости","zap",false)
	toggle(R,"aim.autofire","Автострельба","Стреляет, пока выстрел попадает в цель (демо)","cross",false)
	slider(R,"aim.reaction","Реакция","Ожидание после захвата цели перед первым выстрелом",0,500,0," мс")
	slider(R,"aim.fireRate","Скорострельность","",1,60,20," / с")
	slider(R,"aim.recoil","Контроль отдачи","",0,100,100,"%")
	toggle(R,"aim.showFov","Круг FOV","", "cross",true)
	toggle(R,"aim.showLine","Линия прицела","","zap",true)
	toggle(R,"aim.showPanel","Панель цели","Кто, как далеко, какая кость и что делает","grid",true)
end

-- ---------- КОНФИГИ ----------
local configs={}
local configListFrame, refreshConfigs
local function serialize()
	return {controls=State.controls}
end
local function persist()
	task.delay(0.2,function()
		pcall(function()
			if writefile then
				if makefolder and not isfolder("FinisCrack") then makefolder("FinisCrack") end
				writefile("FinisCrack/configs.json",HttpService:JSONEncode(configs))
			end
		end)
	end)
end
local function applyConfig(data)
	for k,v in pairs(data.controls or {}) do setControl(k,v) end
	applyLayout()
end
local function buildConfigs()
	local s=makeSection("Конфиги")
	sectionHeader(s,"folder","Конфиги","Сохранение и переключение наборов настроек меню")

	local lib=cardBase(s,0); lib.AutomaticSize=Enum.AutomaticSize.Y
	local lt=txt(lib,"Библиотека",12,C.text,Enum.Font.GothamBold); lt.Position=UDim2.new(0,14,0,10); lt.Size=UDim2.new(1,-120,0,16)
	local cnt=txt(lib,"",10,C.muted,Enum.Font.Gotham,Enum.TextXAlignment.Right); cnt.Position=UDim2.new(1,-110,0,12); cnt.Size=UDim2.fromOffset(96,14)
	configListFrame=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-28,0,0),Position=UDim2.new(0,14,0,34),AutomaticSize=Enum.AutomaticSize.Y},lib)
	new("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},configListFrame)
	pad(lib,0,0,0,14)

	refreshConfigs=function()
		for _,c in ipairs(configListFrame:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
		cnt.Text="Сохранено: "..#configs
		if #configs==0 then
			local e=txt(configListFrame,"Пока пусто — сохрани текущие настройки ниже",10,C.dim); e.Size=UDim2.new(1,0,0,24)
		end
		for i,cfg in ipairs(configs) do
			local row=new("Frame",{BackgroundColor3=Color3.fromRGB(22,20,46),BackgroundTransparency=0.3,BorderSizePixel=0,Size=UDim2.new(1,0,0,52),LayoutOrder=i},configListFrame)
			corner(row,10)
			local av=new("Frame",{BackgroundColor3=A,Size=UDim2.fromOffset(30,30),Position=UDim2.new(0,10,0.5,0),AnchorPoint=Vector2.new(0,0.5),BorderSizePixel=0},row); corner(av,8)
			local al=txt(av,cfg.name:sub(1,1):upper(),13,Color3.fromRGB(20,16,40),Enum.Font.GothamBold,Enum.TextXAlignment.Center); al.Size=UDim2.new(1,0,1,0); al.TextYAlignment=Enum.TextYAlignment.Center
			local nm=txt(row,cfg.name,12,C.text,Enum.Font.GothamBold); nm.Position=UDim2.new(0,48,0,8); nm.Size=UDim2.new(1,-200,0,16)
			local mt=txt(row,(cfg.time or "только что"),9,C.dim); mt.Position=UDim2.new(0,48,0,27); mt.Size=UDim2.new(1,-200,0,14)
			local function act(x,icn,fn,col)
				local b=new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=col or C.card,BackgroundTransparency=0.2,Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,x,0.5,0),AnchorPoint=Vector2.new(0,0.5),BorderSizePixel=0},row)
				corner(b,8); icon(icn,b,14,col and C.text or C.muted,UDim2.new(0.5,0,0.5,0),Vector2.new(0.5,0.5))
				b.Activated:Connect(function() pressFx(b); fn() end)
			end
			act(-142,"load",function() applyConfig(cfg.data); toast("Загружен «"..cfg.name.."»","ok") end)
			act(-106,"save",function() cfg.data=serialize(); cfg.time=os.date("%H:%M"); persist(); refreshConfigs(); toast("Сохранено в «"..cfg.name.."»","ok") end)
			act(-70,"copy",function()
				table.insert(configs,{name=cfg.name.." (копия)",time=os.date("%H:%M"),data=serialize()})
				persist(); refreshConfigs(); toast("Конфиг дублирован","ok")
			end)
			act(-34,"trash",function()
				local removed=table.remove(configs,i)
				persist(); refreshConfigs()
				toast("Удалён «"..removed.name.."»","warn","Отменить",function()
					table.insert(configs,i,removed); persist(); refreshConfigs()
				end)
			end,C.danger)
		end
		task.defer(function() lib.Size=UDim2.new(1,0,0,0) end)
	end

	local newCard=cardBase(s,116)
	local nt=txt(newCard,"Новый конфиг",12,C.text,Enum.Font.GothamBold); nt.Position=UDim2.new(0,14,0,10); nt.Size=UDim2.new(1,-28,0,16)
	local nameBox=new("TextBox",{BackgroundColor3=Color3.fromRGB(14,12,32),BackgroundTransparency=0.3,Text="",PlaceholderText="Название (необязательно)",PlaceholderColor3=C.dim,TextColor3=C.text,TextSize=12,Font=Enum.Font.Gotham,ClearTextOnFocus=false,Size=UDim2.new(1,-28,0,34),Position=UDim2.new(0,14,0,32),BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Left},newCard)
	corner(nameBox,8); pad(nameBox,10,0,10,0)
	local saveCur=button(newCard,"Сохранить текущие","primary",function()
		local n=nameBox.Text; if n=="" then n="Мой конфиг "..(#configs+1) end
		table.insert(configs,{name=n,time=os.date("%H:%M"),data=serialize()})
		nameBox.Text=""; persist(); refreshConfigs(); toast("Конфиг «"..n.."» сохранён","ok")
	end)
	saveCur.Size=UDim2.new(0.5,-20,0,34); saveCur.Position=UDim2.new(0,14,0,72)
	local emptyB=button(newCard,"+ Пустой","ghost",function()
		table.insert(configs,{name="Пустой "..(#configs+1),time=os.date("%H:%M"),data={controls={}}})
		persist(); refreshConfigs(); toast("Пустой конфиг создан","ok")
	end)
	emptyB.Size=UDim2.new(0.5,-20,0,34); emptyB.Position=UDim2.new(0.5,6,0,72)

	pcall(function()
		if readfile and isfile and isfile("FinisCrack/configs.json") then
			configs=HttpService:JSONDecode(readfile("FinisCrack/configs.json")) or {}
		end
	end)
	refreshConfigs()
end

-- ---------- НАСТРОЙКИ ----------
local function buildSettings()
	local s=makeSection("Настройки")
	sectionHeader(s,"sliders","Настройки","Внешний вид меню и поведение")
	local L,R=columns(s)

	local tt=txt(L,"Тема",12,C.text,Enum.Font.GothamBold); tt.Size=UDim2.new(1,0,0,16)
	local themeRow=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,36)},L)
	new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,10)},themeRow)
	ctl("ui.theme",1)
	for i,th in ipairs(THEMES) do
		local b=new("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=th.a,Size=UDim2.fromOffset(30,30),BorderSizePixel=0,LayoutOrder=i},themeRow)
		corner(b,999)
		local chk=txt(b,"✓",14,Color3.fromRGB(20,16,40),Enum.Font.GothamBold,Enum.TextXAlignment.Center)
		chk.Size=UDim2.new(1,0,1,0); chk.TextYAlignment=Enum.TextYAlignment.Center; chk.TextTransparency=1
		b.Activated:Connect(function() setControl("ui.theme",i); pressFx(b); toast("Тема: "..th.name,"ok") end)
		bindings["ui.theme"]=bindings["ui.theme"] or {}
		bindings["ui.theme"][#bindings["ui.theme"]+1]=function(v) chk.TextTransparency = (v==i) and 0 or 1 end
	end
	slider(L,"ui.opacity","Непрозрачность панели","Чем меньше, тем лучше видна игра за меню",30,100,88,"%")
	slider(L,"ui.scale","Масштаб интерфейса","",70,130,100,"%")
	local at=txt(L,"Анимация",12,C.text,Enum.Font.GothamBold); at.Size=UDim2.new(1,0,0,16)
	segmented(L,"ui.anim",{"Спокойно","Обычно","Живо"},"Обычно")
	-- ui.anim хранится как строка; маппинг
	local animMap={"Спокойно","Обычно","Живо"}
	-- нормализуем в индекс
	local function animIndex() for i,v in ipairs(animMap) do if v==State.controls["ui.anim"] then return i end end return 2 end
	-- переопределяем dur через эффект
	effects["ui.anim"]=function() end

	local lt=txt(R,"Язык",12,C.text,Enum.Font.GothamBold); lt.Size=UDim2.new(1,0,0,16)
	local langGrid=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,104)},R)
	new("UIGridLayout",{CellSize=UDim2.new(1/3,-6,0,30),CellPadding=UDim2.new(0,8,0,8)},langGrid)
	local langs={"Система","English","Русский","Türkçe","العربية","فارسی","繁體中文","日本語","???"}
	ctl("ui.lang","Система")
	for i,lng in ipairs(langs) do
		local b=new("TextButton",{Text=lng,TextColor3=C.muted,Font=Enum.Font.GothamMedium,TextSize=10,BackgroundColor3=A,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,LayoutOrder=i},langGrid)
		corner(b,8)
		b.Activated:Connect(function() setControl("ui.lang",lng); toast("Язык: "..lng,"ok") end)
		bindings["ui.lang"]=bindings["ui.lang"] or {}
		bindings["ui.lang"][#bindings["ui.lang"]+1]=function(v)
			local on=v==lng
			b.BackgroundTransparency=on and 0.2 or 1; b.TextColor3=on and C.text or C.muted; b.BackgroundColor3=A
		end
	end

	sectionHeader(R,"zap","Частицы")
	toggle(R,"ui.particles","Фоновые частицы","Парящие частицы вокруг меню","zap",true)
	slider(R,"ui.density","Плотность частиц","",0,100,60,"%")
	toggle(R,"ui.touchTrail","След от касаний","Частицы там, где ты касаешься меню","eye",true)
	toggle(R,"ui.pressFx","Эффект нажатия","Частицы при нажатии на переключатель или кнопку","cross",true)

	local about=cardBase(R,84)
	local ae=txt(about,"η",30,A,Enum.Font.GothamBold); ae.Size=UDim2.fromOffset(44,44); ae.Position=UDim2.new(0,14,0.5,0); ae.AnchorPoint=Vector2.new(0,0.5); ae.TextYAlignment=Enum.TextYAlignment.Center
	themeFns[#themeFns+1]=function(a) ae.TextColor3=a end
	local an=txt(about,"Finis.Crack",14,C.text,Enum.Font.GothamBold); an.Position=UDim2.new(0,64,0,16); an.Size=UDim2.new(1,-80,0,18)
	local ad=txt(about,"Визуальное меню для Roblox · Delta. Аимбот — демо, gameplay не затрагивается.",10,C.muted); ad.Position=UDim2.new(0,64,0,38); ad.Size=UDim2.new(1,-80,0,32); ad.TextWrapped=true; ad.TextYAlignment=Enum.TextYAlignment.Top
end

-- ============================================================
--  ТЕМЫ / ЭФФЕКТЫ СОСТОЯНИЯ
-- ============================================================
local function applyTheme()
	local th=THEMES[State.controls["ui.theme"] or 1]
	A,B=th.a,th.b
	for _,fn in ipairs(themeFns) do fn(A,B) end
	for k,hs in pairs(bindings) do for _,h in ipairs(hs) do h(State.controls[k]) end end
end

effects["ui.theme"]=function() applyTheme() end
effects["ui.opacity"]=function(v) menu.BackgroundTransparency=1-(v/100) end
effects["ui.scale"]=function() applyLayout() end
effects["orb"]=function(v) orb.Visible=v; orbVer.Visible=v end
effects["ui.particles"]=function() rebuildParticles() end
effects["ui.density"]=function() rebuildParticles() end

-- ============================================================
--  ЧАСТИЦЫ
-- ============================================================
local particles={}
function rebuildParticles()
	for _,p in ipairs(particles) do p.obj:Destroy() end
	particles={}
	if not ctl("ui.particles",true) then return end
	local n=math.floor((ctl("ui.density",60)/100)*34)
	for i=1,n do
		local o=new("Frame",{BackgroundColor3=C.text,BackgroundTransparency=0.7,BorderSizePixel=0,Size=UDim2.fromOffset(math.random(1,3),math.random(1,3)),Position=UDim2.new(math.random(),0,math.random(),0),ZIndex=2},particleLayer)
		corner(o,999)
		particles[i]={obj=o,x=math.random(),y=math.random(),v=0.01+math.random()*0.03,ph=math.random()*6.28}
	end
end

-- ============================================================
--  ЛЕЙАУТ / АДАПТИВ
-- ============================================================
function applyLayout()
	local cam=workspace.CurrentCamera
	local vs=cam and cam.ViewportSize or Vector2.new(1280,720)
	local bw=math.clamp(vs.X-20,300,960)
	local bh=math.clamp(vs.Y-20,340,600)
	menu.Size=UDim2.fromOffset(bw,bh)
	local maxScale=math.min((vs.X-8)/bw,(vs.Y-8)/bh)
	menuScale.Scale=math.min((ctl("ui.scale",100)/100),maxScale)
	local compact=bw<640
	sidebar.Size=UDim2.new(0,compact and 56 or 168,1,-86)
	for _,it in ipairs(navItems) do
		it.label.Visible=not compact
		if compact then
			it.icon.frame.Position=UDim2.new(0.5,0,0.5,0); it.icon.frame.AnchorPoint=Vector2.new(0.5,0.5)
		else
			it.icon.frame.Position=UDim2.new(0,14,0.5,0); it.icon.frame.AnchorPoint=Vector2.new(0,0.5)
		end
	end
	contentArea.Position=UDim2.new(0,(compact and 56 or 168)+12,0,68)
	contentArea.Size=UDim2.new(1,-((compact and 56 or 168)+24),1,-100)
	for _,reg in ipairs(columnRegistry) do reg.compact=compact; reg.update() end
	login.Size=UDim2.fromOffset(math.min(420,vs.X-24),344)
	orbVer.Position=UDim2.new(0,orb.Position.X.Offset-18,1,-18)
end

-- ============================================================
--  ОТКРЫТИЕ / ЗАКРЫТИЕ / ВХОД
-- ============================================================
local menuOpen=false
local function openMenu()
	menuOpen=true; menu.Visible=true
	menu.GroupTransparency=1; menuScale.Scale=menuScale.Scale*0.94
	tw(menu,0.35,{GroupTransparency=0})
	local target=math.min((ctl("ui.scale",100)/100),1)
	tw(menuScale,0.35,{Scale=target},Enum.EasingStyle.Back)
end
local function closeMenu()
	menuOpen=false
	tw(menu,0.25,{GroupTransparency=1})
	task.delay(dur(0.25),function() if not menuOpen then menu.Visible=false end end)
end
local function toggleMenu()
	if not State.loggedIn then
		login.Visible=true; tw(login,0.3,{GroupTransparency=0})
		return
	end
	if menuOpen then closeMenu() else openMenu() end
end

local function tryLogin()
	local raw=(keyBox.Text or ""):lower():gsub("^%s+",""):gsub("%s+$","")
	if raw=="@finisokek" or raw=="finisokek" then
		State.loggedIn=true
		keyBox.TextEditable=false
		local check=new("Frame",{BackgroundColor3=A,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.fromOffset(0,0),ZIndex=20},login)
		corner(check,999)
		local ct=txt(check,"✓",30,Color3.fromRGB(20,16,40),Enum.Font.GothamBold,Enum.TextXAlignment.Center)
		ct.Size=UDim2.new(1,0,1,0); ct.TextYAlignment=Enum.TextYAlignment.Center
		tw(check,0.3,{Size=UDim2.fromOffset(64,64)},Enum.EasingStyle.Back)
		toast("Ключ принят · добро пожаловать","ok")
		task.delay(0.55,function()
			tw(login,0.3,{GroupTransparency=1})
			task.delay(0.32,function()
				login.Visible=false
				applyLayout()
				openMenu()
				switchSection("Обзор")
			end)
		end)
	else
		toast("Неверный ключ · подсказка: @Finisokek","err")
		inputStroke.Color=C.danger
		local base=login.Position
		for i=1,4 do
			tw(login,0.05,{Position=base+UDim2.fromOffset(i%2==0 and -8 or 8,0)})
			task.wait(0.05)
		end
		tw(login,0.08,{Position=base})
		task.delay(0.8,function() inputStroke.Color=C.stroke end)
	end
end

-- ============================================================
--  ПЕРЕТАСКИВАНИЕ
-- ============================================================
local function dragify(handle, obj, onMove, onTap)
	local dragging,moved,startPos,objStart=false,false,nil,nil
	handle.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging=true; moved=false; startPos=i.Position; objStart=obj.Position
		end
	end)
	bind(UserInput.InputChanged,function(i)
		if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local d=i.Position-startPos
			if math.abs(d.X)+math.abs(d.Y)>6 then moved=true end
			if onMove then onMove(d,objStart) end
		end
	end)
	bind(UserInput.InputEnded,function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			if dragging and not moved and onTap then onTap() end
			dragging=false
		end
	end)
end

dragify(header,menu,function(d,os)
	menu.Position=UDim2.new(os.X.Scale,os.X.Offset+d.X,os.Y.Scale,os.Y.Offset+d.Y)
end)
dragify(orb,orb,function(d,os)
	orb.Position=UDim2.new(os.X.Scale,os.X.Offset+d.X,os.Y.Scale,os.Y.Offset+d.Y)
	orbVer.Position=UDim2.new(0,orb.Position.X.Offset-18,1,orb.Position.Y.Offset+58)
end,toggleMenu)
dragify(grip,menu,function(d,os)
	setControl("ui.scale",math.clamp(100+d.X/3,70,130))
end)

-- ============================================================
--  ГЛАВНЫЙ ЦИКЛ (FPS / аптайм / частицы / превью)
-- ============================================================
local fpsAcc,fpsFrames,fpsValue=0,0,60
local sparkHist={}
local lineEnd=Vector2.new(0,0)
local sparkTimer=0
bind(RunService.Heartbeat,function(dt)
	fpsAcc+=dt; fpsFrames+=1
	if fpsAcc>=0.5 then
		fpsValue=math.floor(fpsFrames/fpsAcc+0.5)
		fpsAcc=0; fpsFrames=0
		if fpsV then fpsV.Text=tostring(fpsValue) end
		table.insert(sparkHist,fpsValue); if #sparkHist>24 then table.remove(sparkHist,1) end
		for i,bbar in ipairs(State.sparkBars or {}) do
			local v=sparkHist[i] or 0
			bbar.Size=UDim2.new(1/24,-2,math.clamp(v/120,0.06,1),0)
		end
		local up=os.clock()-State.start
		if State.uptimeLabel then State.uptimeLabel.Text=string.format("Аптайм %02d:%02d",math.floor(up/60),math.floor(up%60)) end
		local en=0
		for _,k in ipairs({"aim.enabled","aim.silent","orb","ui.particles","ui.pressFx","ui.touchTrail"}) do if State.controls[k] then en+=1 end end
		if State.enabledLabel then State.enabledLabel.Text=en.." / 6" end
	end

	local t=os.clock()
	for _,p in ipairs(particles) do
		p.y-=p.v*dt
		if p.y<-0.02 then p.y=1.02; p.x=math.random() end
		p.obj.Position=UDim2.new(p.x+math.sin(t+p.ph)*0.004,0,p.y,0)
		p.obj.BackgroundTransparency=0.55+math.sin(t*2+p.ph)*0.25
	end

	if State.arena and State.arena.Parent and sections["Функции"] and sections["Функции"].root.Visible then
		local ar=State.arena
		local w,h=ar.AbsoluteSize.X,ar.AbsoluteSize.Y
		local cx,cy=w/2,h/2
		local radius=math.clamp((ctl("aim.fov",60)/180)*(math.min(w,h)/2-6),8,math.min(w,h)/2)
		previewCircle.Size=UDim2.fromOffset(radius*2,radius*2)
		previewCircle.Visible=ctl("aim.showFov",true)
		local best,bd=nil,1e9
		for _,tg in ipairs(previewTargets) do
			tg.ang+=tg.spd*dt
			local rx,ry=tg.rad*w*0.45,tg.rad*h*0.45
			local x,y=cx+math.cos(tg.ang)*rx,cy+math.sin(tg.ang*1.3)*ry
			tg.obj.Position=UDim2.fromOffset(x,y)
			local d=math.sqrt((x-cx)^2+(y-cy)^2)
			if d<radius and d<bd then bd=d; best={x=x,y=y,obj=tg.obj} end
			tg.obj.BackgroundColor3=C.muted
		end
		if ctl("aim.enabled",true) and best then
			best.obj.BackgroundColor3=C.danger
			local alpha=math.clamp(1-(ctl("aim.smooth",10)/100),0.06,1)*math.clamp(dt*12,0,1)
			lineEnd=lineEnd:Lerp(Vector2.new(best.x,best.y),alpha)
			local dx,dy=lineEnd.X-cx,lineEnd.Y-cy
			local dist=math.sqrt(dx*dx+dy*dy)
			previewLine.Visible=ctl("aim.showLine",true)
			previewLine.Size=UDim2.fromOffset(dist,2)
			previewLine.Rotation=math.deg(math.atan2(dy,dx))
			if ctl("aim.autofire",false) then
				sparkTimer-=dt
				if sparkTimer<=0 then
					sparkTimer=1/math.clamp(ctl("aim.fireRate",20),1,60)
					local sp=new("Frame",{BackgroundColor3=C.warn,BackgroundTransparency=0.2,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(best.x,best.y),Size=UDim2.fromOffset(4,4),BorderSizePixel=0,ZIndex=5},ar)
					corner(sp,999)
					tw(sp,0.3,{Size=UDim2.fromOffset(22,22),BackgroundTransparency=1})
					task.delay(0.32,function() sp:Destroy() end)
				end
			end
		else
			previewLine.Visible=false
			lineEnd=Vector2.new(cx,cy)
		end
	end
end)

-- След от касаний
bind(UserInput.InputBegan,function(i,gpe)
	if gpe then return end
	if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
		if ctl("ui.touchTrail",true) and menu.Visible then
			local mp=menu.AbsolutePosition
			local rx,ry=i.Position.X-mp.X,i.Position.Y-mp.Y
			if rx>=0 and ry>=0 and rx<=menu.AbsoluteSize.X and ry<=menu.AbsoluteSize.Y then
				for k=1,3 do
					local d=new("Frame",{BackgroundColor3=A,BackgroundTransparency=0.4,BorderSizePixel=0,Size=UDim2.fromOffset(3,3),Position=UDim2.fromOffset(rx,ry),ZIndex=8},particleLayer)
					corner(d,999)
					tw(d,0.6,{Position=UDim2.fromOffset(rx+math.random(-24,24),ry-math.random(10,34)),BackgroundTransparency=1})
					task.delay(0.65,function() d:Destroy() end)
				end
			end
		end
	end
	if i.KeyCode==Enum.KeyCode.RightShift or i.KeyCode==Enum.KeyCode.Insert then toggleMenu() end
end)

-- ============================================================
--  СБОРКА / СТАРТ
-- ============================================================
buildNav()
buildOverview()
buildFunctions()
buildEmpty("Визуал","eye","Визуал отключён","В сборке оставлена только визуальная функция Аимбот. Остальные функции удалены.")
buildAim()
buildEmpty("Модели","cube","Модели отключены","Раздел удалён из сборки. Доступен только визуальный Аимбот.")
buildConfigs()
buildSettings()

-- маппинг анимации строка→индекс
local animNames={"Спокойно","Обычно","Живо"}
local _dur=dur
dur=function(t)
	local idx=2
	for i,v in ipairs(animNames) do if State.controls["ui.anim"]==v then idx=i end end
	return t*ANIM[idx]
end

pasteBtn.Activated:Connect(function()
	local ok,clip=pcall(function() if getclipboard then return getclipboard() end end)
	keyBox.Text=(ok and type(clip)=="string" and clip~="") and clip or "@Finisokek"
	pressFx(pasteBtn)
	toast("Вставлено","ok")
end)
loginBtn.Activated:Connect(function() pressFx(loginBtn); tryLogin() end)
keyBox.FocusLost:Connect(function(enter) if enter then tryLogin() end end)
closeBtn.Activated:Connect(function() pressFx(closeBtn); closeMenu() end)

bind(workspace:GetPropertyChangedSignal("CurrentCamera"),function()
	applyLayout()
	local cam=workspace.CurrentCamera
	if cam then bind(cam:GetPropertyChangedSignal("ViewportSize"),applyLayout) end
end)

applyTheme()
rebuildParticles()
applyLayout()
effects["ui.opacity"](ctl("ui.opacity",88))
switchSection("Обзор")

login.GroupTransparency=1
login.Visible=true
tw(login,0.5,{GroupTransparency=0},Enum.EasingStyle.Back)

print("[Finis.Crack] загружен · ключ @Finisokek · шар η или RightShift/Insert")
