local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local TweenService=game:GetService("TweenService")
local CoreGui=game:GetService("CoreGui")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local LP=Players.LocalPlayer
local Camera=Workspace.CurrentCamera
local env=getgenv()

for _,name in ipairs({"VapeFeatureMenu","DrawingESP","Aimbot","RotatingXCrosshair"}) do
    local old=env[name]
    if old and type(old.Unload)=="function" then pcall(function() old:Unload() end) end
end

local App={Connections={},Drawings={},ESPObjects={},HealthRefs={},Controls={},Alive=true,Aiming=false,Target=nil,Profile="default"}
local Config={
    UI={MenuKey="RightShift",PanicKey="End",Scale=100,Notifications=true,Accent={125,92,255}},
    Combat={Enabled=true,AimKey="MouseButton2",TeamCheck=true,WallCheck=true,TargetPart="Head",FOV=200,Smoothness=12,LockTarget=true,ShowFOV=true},
    ESP={Enabled=true,Boxes=true,Skeletons=true,Tracers=true,Names=true,Distance=true,Health=true,ShowTeam=true,MaxDistance=2500,Thickness=1,Opacity=95,TracerOrigin="Bottom",EnemyColor={255,74,92},TeamColor={70,180,255}},
    Crosshair={Enabled=true,Color={255,255,255},Gap=5,ArmLength=15,BendLength=9,Thickness=2,Speed=120,Direction="Clockwise",CenterDot=false},
    Weapons={NoSpread=false,NoRecoil=false}
}
App.Config=Config

local function c3(t) return Color3.fromRGB(t[1],t[2],t[3]) end
local function bind(signal,fn) local c=signal:Connect(fn); table.insert(App.Connections,c); return c end
local function draw(kind,props)
    local o=Drawing.new(kind)
    for k,v in pairs(props) do o[k]=v end
    table.insert(App.Drawings,o)
    return o
end
local function removeDraw(o) pcall(function() o.Visible=false end); pcall(function() o:Remove() end) end
local function keyName(input)
    if input.UserInputType==Enum.UserInputType.Keyboard then return input.KeyCode.Name end
    return input.UserInputType.Name
end
local function keyMatches(input,name) return keyName(input)==name end
local function deepCopy(t)
    local n={}
    for k,v in pairs(t) do n[k]=type(v)=="table" and deepCopy(v) or v end
    return n
end
local Defaults=deepCopy(Config)
local function mergeValid(dst,src)
    if type(src)~="table" then return end
    for k,v in pairs(src) do
        if dst[k]~=nil then
            if type(dst[k])=="table" and type(v)=="table" then mergeValid(dst[k],v)
            elseif type(dst[k])==type(v) then dst[k]=v end
        end
    end
end
local function normalize()
    Config.UI.Scale=math.clamp(Config.UI.Scale,75,130)
    Config.Combat.FOV=math.clamp(Config.Combat.FOV,30,600)
    Config.Combat.Smoothness=math.clamp(Config.Combat.Smoothness,0,100)
    Config.ESP.MaxDistance=math.clamp(Config.ESP.MaxDistance,100,5000)
    Config.ESP.Thickness=math.clamp(Config.ESP.Thickness,1,4)
    Config.ESP.Opacity=math.clamp(Config.ESP.Opacity,20,100)
    Config.Crosshair.Speed=math.clamp(Config.Crosshair.Speed,0,360)
    Config.Crosshair.Gap=math.clamp(Config.Crosshair.Gap,0,20)
    Config.Crosshair.ArmLength=math.clamp(Config.Crosshair.ArmLength,5,35)
    Config.Crosshair.BendLength=math.clamp(Config.Crosshair.BendLength,2,25)
    Config.Crosshair.Thickness=math.clamp(Config.Crosshair.Thickness,1,5)
end

local parent=(type(gethui)=="function" and gethui()) or CoreGui
local gui=Instance.new("ScreenGui")
gui.Name="SolVapeFeatureMenu"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=parent
App.Gui=gui

local function inst(class,props,parentObj)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    o.Parent=parentObj
    return o
end
local function round(o,r) inst("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function stroke(o,color,thick,trans) inst("UIStroke",{Color=color or Color3.fromRGB(60,62,74),Thickness=thick or 1,Transparency=trans or 0},o) end
local function pad(o,l,r,t,b) inst("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or l or 0),PaddingTop=UDim.new(0,t or l or 0),PaddingBottom=UDim.new(0,b or t or l or 0)},o) end
local function gradient(o,seq,rot) local g=inst("UIGradient",{Color=seq,Rotation=rot or 0},o); return g end
local function tween(o,t,info) return TweenService:Create(o,info,t) end
local function label(parentObj,text,size,pos,fontSize,color,font)
    return inst("TextLabel",{BackgroundTransparency=1,Text=text,Size=size or UDim2.new(1,0,0,24),Position=pos or UDim2.new(),Font=font or Enum.Font.GothamMedium,TextSize=fontSize or 13,TextColor3=color or Color3.fromRGB(225,227,235),TextXAlignment=Enum.TextXAlignment.Left},parentObj)
end
local function refreshAll() for _,fn in ipairs(App.Controls) do pcall(fn) end end
local Theme={Accent=c3(Config.UI.Accent),AccentSoft=Color3.fromRGB(56,120,255),Bg=Color3.fromRGB(8,10,18),Panel=Color3.fromRGB(12,14,24),Card=Color3.fromRGB(16,19,32),Line=Color3.fromRGB(38,48,78)}
local function applyTheme()
    Theme.Accent=c3(Config.UI.Accent)
    Theme.AccentSoft=Color3.new(math.min(Theme.Accent.R*1.2,1),math.min(Theme.Accent.G*1.2,1),math.min(Theme.Accent.B*1.2,1))
    if status then status.TextColor3=Theme.Accent end
    if accentGlow then accentGlow.BackgroundColor3=Theme.Accent end
    if resize then resize.BackgroundColor3=Theme.Accent end
    refreshAll()
end
App.RefreshTheme=applyTheme

local toastHolder=inst("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,300,1,-30),Position=UDim2.new(1,-315,0,15),ZIndex=20},gui)
inst("UIListLayout",{Padding=UDim.new(0,8),VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right},toastHolder)
local function notify(text)
    if not Config.UI.Notifications or not App.Alive then return end
    local f=inst("Frame",{BackgroundColor3=Color3.fromRGB(10,12,22),BackgroundTransparency=.05,Size=UDim2.new(0,280,0,44),Position=UDim2.new(0,40,0,0),ZIndex=25},toastHolder); round(f,10)
    stroke(f,Theme.Accent,.8,.15)
    gradient(f,ColorSequence.new(Color3.fromRGB(18,24,42),Color3.fromRGB(10,12,22)),90)
    local bar=inst("Frame",{BackgroundColor3=Theme.Accent,BorderSizePixel=0,Size=UDim2.new(0,3,1,-14),Position=UDim2.new(0,7,0,7),ZIndex=26},f); round(bar,3)
    label(f,text,UDim2.new(1,-24,1,0),UDim2.new(0,18,0,0),12,Color3.fromRGB(235,238,248),Enum.Font.Code).ZIndex=26
    tween(f,{Position=UDim2.new(0,0,0,0)},TweenInfo.new(.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)):Play()
    task.delay(2.6,function()
        if f and f.Parent then
            local out=tween(f,{Position=UDim2.new(0,50,0,0),BackgroundTransparency=1},TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In))
            out:Play(); out.Completed:Connect(function() if f then f:Destroy() end end)
        end
    end)
end
App.Notify=notify

local outerGlow=inst("Frame",{BackgroundColor3=Theme.Accent,BackgroundTransparency=.82,Size=UDim2.new(0,600,0,456),Position=UDim2.new(.5,-295,.5,-225),ZIndex=1},gui); round(outerGlow,16)
local shadow=inst("Frame",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.35,Size=UDim2.new(0,592,0,448),Position=UDim2.new(.5,-291,.5,-221),ZIndex=2},gui); round(shadow,14)
local window=inst("Frame",{Name="Window",BackgroundColor3=Theme.Bg,BorderSizePixel=0,ClipsDescendants=true,Size=UDim2.new(0,586,0,444),Position=UDim2.new(.5,-293,.5,-222),ZIndex=3},gui); round(window,14)
stroke(window,Theme.Accent,.7,.55)
local bg=inst("Frame",{BackgroundTransparency=0,BackgroundColor3=Theme.Bg,Size=UDim2.new(1,0,1,0),ZIndex=1},window); round(bg,14)
gradient(bg,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(10,14,28)),ColorSequenceKeypoint.new(.55,Color3.fromRGB(7,9,16)),ColorSequenceKeypoint.new(1,Color3.fromRGB(4,6,12))}),125)
local stars=inst("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=2},bg)
local starData={}
for i=1,48 do
    local s=inst("Frame",{BackgroundColor3=Color3.fromRGB(180,210,255),BorderSizePixel=0,Size=UDim2.fromOffset(math.random(1,2),math.random(1,2)),Position=UDim2.new(math.random(),0,math.random(),0),BackgroundTransparency=math.random(20,70)/100,ZIndex=2},stars)
    starData[i]={obj=s,sx=math.random()*window.AbsoluteSize.X,sy=math.random()*window.AbsoluteSize.Y,sp=math.random(4,14)/100,drift=math.random()/3}
end
local scan=inst("Frame",{BackgroundColor3=Theme.Accent,BackgroundTransparency=.92,BorderSizePixel=0,Size=UDim2.new(1.4,0,0,120),Position=UDim2.new(-.2,0,-.25,0),Rotation=18,ZIndex=2},bg)
gradient(scan,ColorSequence.new(Theme.Accent,Color3.fromRGB(10,14,28)),90)
local vignette=inst("Frame",{BackgroundTransparency=0,Size=UDim2.new(1,0,1,0),ZIndex=3},bg); round(vignette,14)
gradient(vignette,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(.35,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}),90).Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.78),NumberSequenceKeypoint.new(.5,.92),NumberSequenceKeypoint.new(1,.55)})
local top=inst("Frame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,54),ZIndex=6},window)
local topGlass=inst("Frame",{BackgroundColor3=Color3.fromRGB(12,16,28),BackgroundTransparency=.18,Size=UDim2.new(1,-2,1,0),Position=UDim2.new(0,1,0,0),ZIndex=5},top); round(topGlass,0)
gradient(topGlass,ColorSequence.new(Color3.fromRGB(24,34,58),Color3.fromRGB(10,12,20)),90)
label(top,"daxkiller.net",UDim2.new(0,120,0,16),UDim2.new(0,18,0,8),10,Color3.fromRGB(120,140,180),Enum.Font.Code)
local title=label(top,"DAX KILLER",UDim2.new(0,180,0,24),UDim2.new(0,18,0,24),20,Color3.new(1,1,1),Enum.Font.GothamBlack)
title.TextStrokeTransparency=.7; title.TextStrokeColor3=Theme.Accent
label(top,"v1  //  arsenal suite",UDim2.new(0,160,0,16),UDim2.new(0,20,0,42),11,Theme.AccentSoft,Enum.Font.Code)
local status=label(top,"ONLINE",UDim2.new(0,90,0,20),UDim2.new(1,-110,0,18),11,Theme.Accent,Enum.Font.Code); status.TextXAlignment=Enum.TextXAlignment.Right
local accentGlow=inst("Frame",{BackgroundColor3=Theme.Accent,BackgroundTransparency=.35,BorderSizePixel=0,Size=UDim2.new(.45,0,0,3),Position=UDim2.new(.05,0,1,-8),ZIndex=7},top); round(accentGlow,3)
gradient(accentGlow,ColorSequence.new(Color3.fromRGB(255,255,255),Theme.Accent),0)
local accent=accentGlow
local closeBtn=inst("TextButton",{Text="×",AutoButtonColor=false,BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=18,TextColor3=Color3.fromRGB(170,180,200),Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-36,0,12),ZIndex=8},top)
bind(closeBtn.MouseButton1Click,function() window.Visible=false; shadow.Visible=false; outerGlow.Visible=false end)
local rail=inst("Frame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,132,1,-54),Position=UDim2.new(0,0,0,54),ZIndex=6},window)
local railGlass=inst("Frame",{BackgroundColor3=Color3.fromRGB(8,10,18),BackgroundTransparency=.12,Size=UDim2.new(1,0,1,0),ZIndex=5},rail)
gradient(railGlass,ColorSequence.new(Color3.fromRGB(14,18,30),Color3.fromRGB(6,8,14)),180)
inst("UIPadding",{PaddingTop=UDim.new(0,14),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},rail)
inst("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},rail)
local pageHost=inst("Frame",{BackgroundTransparency=1,ClipsDescendants=true,Size=UDim2.new(1,-132,1,-54),Position=UDim2.new(0,132,0,54),ZIndex=6},window)
local resize=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=Theme.Accent,BackgroundTransparency=.15,Size=UDim2.new(0,14,0,14),Position=UDim2.new(1,-18,1,-18),ZIndex=8},window); round(resize,3)
gradient(resize,ColorSequence.new(Theme.AccentSoft,Theme.Accent),45)
bind(RunService.RenderStepped,function(dt)
    if not App.Alive or not window.Visible then return end
    local t=os.clock()
    scan.Position=UDim2.new(-.2+math.sin(t*.25)*.04,0,-.25+math.cos(t*.2)*.03,0)
    accentGlow.BackgroundTransparency=.25+.1*math.sin(t*2)
    for i,data in ipairs(starData) do
        data.sy=(data.sy+data.sp*dt*18)%math.max(window.AbsoluteSize.Y,1)
        data.sx=(data.sx+math.sin(t*.4+data.drift)*dt*6)%math.max(window.AbsoluteSize.X,1)
        data.obj.Position=UDim2.fromOffset(data.sx,data.sy)
    end
end)
window.Size=UDim2.fromOffset(0,0); shadow.Size=UDim2.fromOffset(0,0); outerGlow.Size=UDim2.fromOffset(0,0)
task.defer(function()
    tween(window,{Size=UDim2.fromOffset(586,444)},TweenInfo.new(.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)):Play()
    tween(shadow,{Size=UDim2.fromOffset(592,448)},TweenInfo.new(.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)):Play()
    tween(outerGlow,{Size=UDim2.fromOffset(600,456)},TweenInfo.new(.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)):Play()
end)

local dragging,dragStart,startPos=false,nil,nil
bind(top.InputBegan,function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        local absolute=window.AbsolutePosition
        window.Position=UDim2.fromOffset(absolute.X,absolute.Y)
        shadow.Position=UDim2.fromOffset(absolute.X+5,absolute.Y+7)
        outerGlow.Position=UDim2.fromOffset(absolute.X+2,absolute.Y+2)
        dragging=true
        dragStart=i.Position
        startPos=window.Position
    end
end)
bind(UIS.InputChanged,function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dragStart
        local viewport=Camera.ViewportSize
        local x=math.clamp(startPos.X.Offset+d.X,-window.AbsoluteSize.X+80,viewport.X-80)
        local y=math.clamp(startPos.Y.Offset+d.Y,0,viewport.Y-48)
        window.Position=UDim2.new(startPos.X.Scale,x,startPos.Y.Scale,y)
        shadow.Position=window.Position+UDim2.fromOffset(5,7)
        outerGlow.Position=window.Position+UDim2.fromOffset(2,2)
    end
end)
bind(UIS.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
local resizing,resizeStart,startSize=false,nil,nil
bind(resize.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then resizing=true; resizeStart=i.Position; startSize=window.AbsoluteSize end end)
bind(UIS.InputChanged,function(i)
    if resizing and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-resizeStart
        local v=Camera.ViewportSize
        local w=math.clamp(startSize.X+d.X,500,math.min(850,v.X-20))
        local h=math.clamp(startSize.Y+d.Y,360,math.min(650,v.Y-20))
        window.Size=UDim2.fromOffset(w,h); shadow.Size=UDim2.fromOffset(w+6,h+6); outerGlow.Size=UDim2.fromOffset(w+10,h+10)
    end
end)
bind(UIS.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then resizing=false end end)

local pages={}
local tabButtons={}
local activeTab=nil
local function showTab(name)
    activeTab=name
    for n,p in pairs(pages) do
        if n==name then
            p.Visible=true; p.Position=UDim2.new(0,10,0,0)
            tween(p,{Position=UDim2.new(0,0,0,0)},TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)):Play()
        else
            p.Visible=false
        end
    end
    for n,tab in pairs(tabButtons) do
        local active=n==name
        tween(tab.Button,{BackgroundTransparency=active and .08 or .55,TextColor3=active and Color3.new(1,1,1) or Color3.fromRGB(150,160,185)},TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)):Play()
        tab.Indicator.Visible=active
        if active then tween(tab.Indicator,{Size=UDim2.new(0,3,1,-10)},TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out)):Play() end
    end
end
local function addTab(name)
    local b=inst("TextButton",{AutoButtonColor=false,Text=name:upper(),Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(150,160,185),BackgroundColor3=Color3.fromRGB(18,24,40),BackgroundTransparency=.55,Size=UDim2.new(1,0,0,36),ZIndex=7},rail); round(b,8); pad(b,14,8,0,0)
    gradient(b,ColorSequence.new(Color3.fromRGB(24,34,58),Color3.fromRGB(12,16,28)),90)
    stroke(b,Theme.Line,.6,.35)
    local indicator=inst("Frame",{BackgroundColor3=Theme.Accent,BorderSizePixel=0,Size=UDim2.new(0,0,1,-10),Position=UDim2.new(0,4,.5,0),AnchorPoint=Vector2.new(0,.5),Visible=false,ZIndex=8},b); round(indicator,2)
    local p=inst("Frame",{Name=name,Visible=false,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=6},pageHost)
    local scroll=inst("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=Theme.Accent,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,1,0)},p)
    pad(scroll,14,14,14,14)
    inst("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
    pages[name]=p; tabButtons[name]={Button=b,Indicator=indicator}; bind(b.MouseButton1Click,function() showTab(name) end)
    return scroll
end
local combatPage=addTab("Combat")
local espPage=addTab("Visuals")
local crossPage=addTab("Crosshair")
local weaponsPage=addTab("Weapons")
local settingsPage=addTab("Settings")
local profilePage=addTab("Profiles")

local function section(page,titleText)
    local f=inst("Frame",{BackgroundColor3=Theme.Card,BackgroundTransparency=.08,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,-2,0,0),ZIndex=6},page); round(f,10)
    stroke(f,Theme.Line,.7,.45)
    gradient(f,ColorSequence.new(Color3.fromRGB(20,28,48),Color3.fromRGB(12,16,28)),100)
    pad(f,12,12,10,12)
    inst("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},f)
    local h=label(f,titleText:upper(),UDim2.new(1,0,0,22),nil,12,Color3.fromRGB(235,240,255),Enum.Font.GothamBlack)
    local line=inst("Frame",{BackgroundColor3=Theme.Accent,BackgroundTransparency=.2,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)},f)
    gradient(line,ColorSequence.new(Theme.Accent,Color3.fromRGB(10,14,28)),0)
    return f
end
local function row(parentObj,height)
    local r=inst("Frame",{BackgroundColor3=Color3.fromRGB(10,14,24),BackgroundTransparency=.2,Size=UDim2.new(1,0,0,height or 36),ZIndex=6},parentObj); round(r,8)
    stroke(r,Theme.Line,.5,.55)
    return r
end
local function addToggle(parentObj,text,get,set)
    local r=row(parentObj,38); label(r,text,UDim2.new(1,-58,1,0),UDim2.new(0,12,0,0),12,Color3.fromRGB(220,226,240),Enum.Font.GothamMedium)
    local sw=inst("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.new(0,42,0,22),Position=UDim2.new(1,-52,.5,-11),BackgroundColor3=Color3.fromRGB(30,36,54),ZIndex=7},r); round(sw,11)
    stroke(sw,Theme.Line,.6,.2)
    local dot=inst("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,.5,-8),BackgroundColor3=Color3.fromRGB(220,228,255),ZIndex=8},sw); round(dot,8)
    local function refresh()
        local v=get()
        tween(sw,{BackgroundColor3=v and Theme.Accent or Color3.fromRGB(30,36,54)},TweenInfo.new(.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)):Play()
        tween(dot,{Position=v and UDim2.new(1,-19,.5,-8) or UDim2.new(0,3,.5,-8),BackgroundColor3=v and Color3.new(1,1,1) or Color3.fromRGB(220,228,255)},TweenInfo.new(.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out)):Play()
    end
    table.insert(App.Controls,refresh); bind(sw.MouseButton1Click,function() set(not get()); refresh() end); refresh(); return r
end
local function addSlider(parentObj,text,min,max,get,set,suffix)
    local r=row(parentObj,54); label(r,text,UDim2.new(1,-72,0,28),UDim2.new(0,12,0,2),12,Color3.fromRGB(220,226,240),Enum.Font.GothamMedium)
    local val=label(r,"",UDim2.new(0,64,0,28),UDim2.new(1,-72,0,2),11,Theme.Accent,Enum.Font.Code); val.TextXAlignment=Enum.TextXAlignment.Right
    local bar=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(24,30,48),Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,1,-14),ZIndex=7},r); round(bar,3)
    local fill=inst("Frame",{BorderSizePixel=0,BackgroundColor3=Theme.Accent,Size=UDim2.new(0,0,1,0),ZIndex=8},bar); round(fill,3)
    gradient(fill,ColorSequence.new(Theme.AccentSoft,Theme.Accent),0)
    local knob=inst("Frame",{BackgroundColor3=Color3.new(1,1,1),Size=UDim2.new(0,8,0,8),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),ZIndex=9},bar); round(knob,4)
    local sliding=false
    local function refresh()
        local v=math.clamp(get(),min,max); local a=(v-min)/(max-min)
        fill.Size=UDim2.new(a,0,1,0); knob.Position=UDim2.new(a,0,.5,0)
        val.Text=tostring(math.floor(v+.5))..(suffix or "")
    end
    local function update(x) local a=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1); set(min+(max-min)*a); refresh() end
    table.insert(App.Controls,refresh); bind(bar.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true; update(i.Position.X) end end); bind(UIS.InputChanged,function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end); bind(UIS.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end); refresh(); return r
end
local function addCycle(parentObj,text,options,get,set)
    local r=row(parentObj,40); label(r,text,UDim2.new(.55,-12,1,0),UDim2.new(0,12,0,0),12,Color3.fromRGB(220,226,240),Enum.Font.GothamMedium)
    local b=inst("TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(16,22,38),Size=UDim2.new(.42,0,0,28),Position=UDim2.new(.56,0,.5,-14),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.Accent,ZIndex=7},r); round(b,7)
    stroke(b,Theme.Accent,.5,.35)
    gradient(b,ColorSequence.new(Color3.fromRGB(24,34,58),Color3.fromRGB(10,14,24)),90)
    local function refresh() b.Text=tostring(get()).."  ›" end
    table.insert(App.Controls,refresh); bind(b.MouseButton1Click,function() local current=get(); local idx=table.find(options,current) or 0; set(options[idx%#options+1]); refresh(); tween(b,{Size=UDim2.new(.42,0,0,26)},TweenInfo.new(.08,Enum.EasingStyle.Back,Enum.EasingDirection.Out)):Play(); task.delay(.08,function() tween(b,{Size=UDim2.new(.42,0,0,28)},TweenInfo.new(.12,Enum.EasingStyle.Back,Enum.EasingDirection.Out)):Play() end) end); refresh(); return r
end
local capture=nil
local function addKeybind(parentObj,text,get,set)
    local r=row(parentObj,40); label(r,text,UDim2.new(.55,-12,1,0),UDim2.new(0,12,0,0),12,Color3.fromRGB(220,226,240),Enum.Font.GothamMedium)
    local b=inst("TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(16,22,38),Size=UDim2.new(.42,0,0,28),Position=UDim2.new(.56,0,.5,-14),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.Accent,ZIndex=7},r); round(b,7)
    stroke(b,Theme.Accent,.5,.35)
    local function refresh() if capture~=b then b.Text="[ "..get().." ]" end end
    table.insert(App.Controls,refresh); bind(b.MouseButton1Click,function() capture=b; b.Text="press a key..." end); b:SetAttribute("SetKey",true); b:SetAttribute("ControlIndex",#App.Controls); b:SetAttribute("Label",text); b:SetAttribute("Active",false)
    b.MouseButton2Click:Connect(function() set(text=="Aim key" and "MouseButton2" or (text=="Menu key" and "RightShift" or "End")); capture=nil; refresh() end)
    b:SetAttribute("SetterId",#App.Controls)
    App["KeySetter"..tostring(#App.Controls)]=set
    App["KeyRefresh"..tostring(#App.Controls)]=refresh
    refresh(); return r
end
local palettes={{255,74,92},{125,92,255},{70,180,255},{65,220,150},{255,185,65},{255,255,255}}
local function addColor(parentObj,text,get,set)
    local r=row(parentObj,40); label(r,text,UDim2.new(1,-58,1,0),UDim2.new(0,12,0,0),12,Color3.fromRGB(220,226,240),Enum.Font.GothamMedium)
    local b=inst("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.new(0,38,0,24),Position=UDim2.new(1,-48,.5,-12),ZIndex=7},r); round(b,7); stroke(b,Theme.Line,.8,.2)
    local function refresh() b.BackgroundColor3=c3(get()) end
    table.insert(App.Controls,refresh); bind(b.MouseButton1Click,function() local cur=get(); local idx=1; for i,p in ipairs(palettes) do if p[1]==cur[1] and p[2]==cur[2] and p[3]==cur[3] then idx=i break end end; set(deepCopy(palettes[idx%#palettes+1])); refresh() end); refresh(); return r
end
local function addButton(parentObj,text,fn,danger)
    local b=inst("TextButton",{AutoButtonColor=false,BackgroundColor3=danger and Color3.fromRGB(120,34,48) or Theme.Accent,Text=text:upper(),Font=Enum.Font.GothamBlack,TextSize=11,TextColor3=Color3.new(1,1,1),Size=UDim2.new(1,0,0,38),ZIndex=7},parentObj); round(b,8)
    gradient(b,ColorSequence.new(danger and Color3.fromRGB(170,50,70) or Theme.AccentSoft,danger and Color3.fromRGB(90,24,36) or Theme.Accent),90)
    stroke(b,danger and Color3.fromRGB(255,120,140) or Theme.AccentSoft,.7,.2)
    bind(b.MouseButton1Click,fn)
    bind(b.MouseEnter,function() tween(b,{BackgroundTransparency=.05},TweenInfo.new(.12)):Play() end)
    bind(b.MouseLeave,function() tween(b,{BackgroundTransparency=0},TweenInfo.new(.12)):Play() end)
    return b
end

local guiScale
local s=section(combatPage,"Aimbot")
addToggle(s,"Enabled",function() return Config.Combat.Enabled end,function(v) Config.Combat.Enabled=v; App.Target=nil end)
addKeybind(s,"Aim key",function() return Config.Combat.AimKey end,function(v) Config.Combat.AimKey=v end)
addToggle(s,"Ignore teammates",function() return Config.Combat.TeamCheck end,function(v) Config.Combat.TeamCheck=v end)
addToggle(s,"Visibility check",function() return Config.Combat.WallCheck end,function(v) Config.Combat.WallCheck=v end)
addToggle(s,"Lock current target",function() return Config.Combat.LockTarget end,function(v) Config.Combat.LockTarget=v; App.Target=nil end)
addToggle(s,"Show FOV circle",function() return Config.Combat.ShowFOV end,function(v) Config.Combat.ShowFOV=v end)
addCycle(s,"Target part",{"Head","UpperTorso","HumanoidRootPart"},function() return Config.Combat.TargetPart end,function(v) Config.Combat.TargetPart=v; App.Target=nil end)
addSlider(s,"Field of view",30,600,function() return Config.Combat.FOV end,function(v) Config.Combat.FOV=v end," px")
addSlider(s,"Smoothness",0,100,function() return Config.Combat.Smoothness end,function(v) Config.Combat.Smoothness=v end,"%")

s=section(espPage,"Player ESP")
addToggle(s,"Enabled",function() return Config.ESP.Enabled end,function(v) Config.ESP.Enabled=v end)
addToggle(s,"Boxes",function() return Config.ESP.Boxes end,function(v) Config.ESP.Boxes=v end)
addToggle(s,"R15 skeletons",function() return Config.ESP.Skeletons end,function(v) Config.ESP.Skeletons=v end)
addToggle(s,"Tracers",function() return Config.ESP.Tracers end,function(v) Config.ESP.Tracers=v end)
addToggle(s,"Names",function() return Config.ESP.Names end,function(v) Config.ESP.Names=v end)
addToggle(s,"Distance",function() return Config.ESP.Distance end,function(v) Config.ESP.Distance=v end)
addToggle(s,"Health bars",function() return Config.ESP.Health end,function(v) Config.ESP.Health=v end)
addToggle(s,"Show teammates",function() return Config.ESP.ShowTeam end,function(v) Config.ESP.ShowTeam=v end)
addCycle(s,"Tracer origin",{"Bottom","Center","Top"},function() return Config.ESP.TracerOrigin end,function(v) Config.ESP.TracerOrigin=v end)
addSlider(s,"Max distance",100,5000,function() return Config.ESP.MaxDistance end,function(v) Config.ESP.MaxDistance=v end," st")
addSlider(s,"Line thickness",1,4,function() return Config.ESP.Thickness end,function(v) Config.ESP.Thickness=v end,"")
addSlider(s,"Opacity",20,100,function() return Config.ESP.Opacity end,function(v) Config.ESP.Opacity=v end,"%")
addColor(s,"Enemy color",function() return Config.ESP.EnemyColor end,function(v) Config.ESP.EnemyColor=v end)
addColor(s,"Team color",function() return Config.ESP.TeamColor end,function(v) Config.ESP.TeamColor=v end)

s=section(crossPage,"Rotating Pinwheel")
addToggle(s,"Enabled",function() return Config.Crosshair.Enabled end,function(v) Config.Crosshair.Enabled=v end)
addToggle(s,"Center dot",function() return Config.Crosshair.CenterDot end,function(v) Config.Crosshair.CenterDot=v end)
addCycle(s,"Direction",{"Clockwise","Counterclockwise"},function() return Config.Crosshair.Direction end,function(v) Config.Crosshair.Direction=v end)
addSlider(s,"Rotation speed",0,360,function() return Config.Crosshair.Speed end,function(v) Config.Crosshair.Speed=v end,"°")
addSlider(s,"Center gap",0,20,function() return Config.Crosshair.Gap end,function(v) Config.Crosshair.Gap=v end," px")
addSlider(s,"Arm length",5,35,function() return Config.Crosshair.ArmLength end,function(v) Config.Crosshair.ArmLength=v end," px")
addSlider(s,"Bend length",2,25,function() return Config.Crosshair.BendLength end,function(v) Config.Crosshair.BendLength=v end," px")
addSlider(s,"Thickness",1,5,function() return Config.Crosshair.Thickness end,function(v) Config.Crosshair.Thickness=v end,"")
addColor(s,"Crosshair color",function() return Config.Crosshair.Color end,function(v) Config.Crosshair.Color=v end)

local WeaponsFolder=ReplicatedStorage:FindFirstChild("Weapons")
local WeaponMods={Originals={},Connections={}}
local function weaponValue(obj)
    return obj and obj:IsA("ValueBase") and (obj.Name=="Spread" or obj.Name=="MaxSpread" or obj.Name=="RecoilControl")
end
local function rememberWeaponValue(obj)
    if weaponValue(obj) and WeaponMods.Originals[obj]==nil then WeaponMods.Originals[obj]=obj.Value end
end
local function applyWeaponValue(obj)
    if not weaponValue(obj) then return end
    rememberWeaponValue(obj)
    if Config.Weapons.NoSpread and (obj.Name=="Spread" or obj.Name=="MaxSpread") then obj.Value=0 end
    if Config.Weapons.NoRecoil and obj.Name=="RecoilControl" then obj.Value=0 end
end
local function restoreWeaponValue(obj)
    if not weaponValue(obj) then return end
    local original=WeaponMods.Originals[obj]
    if original==nil then return end
    if obj.Name=="Spread" or obj.Name=="MaxSpread" then
        if not Config.Weapons.NoSpread then obj.Value=original end
    elseif obj.Name=="RecoilControl" and not Config.Weapons.NoRecoil then
        obj.Value=original
    end
end
local function scanWeapons(fn)
    if not WeaponsFolder then return 0 end
    local count=0
    for _,weapon in ipairs(WeaponsFolder:GetChildren()) do
        for _,obj in ipairs(weapon:GetDescendants()) do
            if weaponValue(obj) then fn(obj); count+=1 end
        end
    end
    return count
end
local function syncWeaponMods()
    if not WeaponsFolder then return end
    for obj,original in pairs(WeaponMods.Originals) do
        if obj.Parent and weaponValue(obj) then
            if obj.Name=="Spread" or obj.Name=="MaxSpread" then
                obj.Value=Config.Weapons.NoSpread and 0 or original
            elseif obj.Name=="RecoilControl" then
                obj.Value=Config.Weapons.NoRecoil and 0 or original
            end
        end
    end
    scanWeapons(applyWeaponValue)
end
local function restoreWeaponMods()
    Config.Weapons.NoSpread=false
    Config.Weapons.NoRecoil=false
    for obj in pairs(WeaponMods.Originals) do restoreWeaponValue(obj) end
end
if WeaponsFolder then
    scanWeapons(applyWeaponValue)
    table.insert(WeaponMods.Connections,bind(WeaponsFolder.DescendantAdded,function(obj)
        if weaponValue(obj) then applyWeaponValue(obj) end
    end))
end
App.ApplyWeaponMods=syncWeaponMods
App.RestoreWeaponMods=restoreWeaponMods

s=section(weaponsPage,"Gun Mods")
local weaponStatus=label(s,WeaponsFolder and "Detected Arsenal weapon database" or "Weapon database not found",UDim2.new(1,0,0,20),nil,11,WeaponsFolder and Color3.fromRGB(88,220,150) or Color3.fromRGB(255,185,65))
addToggle(s,"No spread",function() return Config.Weapons.NoSpread end,function(v) Config.Weapons.NoSpread=v; syncWeaponMods(); notify(v and "Spread disabled" or "Spread restored") end)
addToggle(s,"No recoil",function() return Config.Weapons.NoRecoil end,function(v) Config.Weapons.NoRecoil=v; syncWeaponMods(); notify(v and "Recoil disabled" or "Recoil restored") end)

s=section(settingsPage,"Interface")
addKeybind(s,"Menu key",function() return Config.UI.MenuKey end,function(v) Config.UI.MenuKey=v end)
addKeybind(s,"Panic key",function() return Config.UI.PanicKey end,function(v) Config.UI.PanicKey=v end)
addToggle(s,"Notifications",function() return Config.UI.Notifications end,function(v) Config.UI.Notifications=v end)
addSlider(s,"UI scale",75,130,function() return Config.UI.Scale end,function(v) Config.UI.Scale=v; guiScale.Scale=v/100 end,"%")
addColor(s,"Accent color",function() return Config.UI.Accent end,function(v) Config.UI.Accent=v; applyTheme() end)
addButton(s,"Unload everything",function() App:Unload() end,true)

local profileSection=section(profilePage,"Profiles")
local persistenceLabel=label(profileSection,"Persistent JSON storage: available",UDim2.new(1,0,0,24),nil,11,Color3.fromRGB(88,220,150))
label(profileSection,"Settings auto-save when you leave the game",UDim2.new(1,0,0,20),nil,11,Color3.fromRGB(130,133,146))

local folder="SolVapeProfiles"
local AUTOSAVE_NAME="_autosave"
local META_FILE="_meta.json"
local persistent=type(writefile)=="function" and type(readfile)=="function"
if persistent and type(makefolder)=="function" then pcall(function() if type(isfolder)~="function" or not isfolder(folder) then makefolder(folder) end end) end
if not persistent then persistenceLabel.Text="Persistent JSON storage unavailable — session only"; persistenceLabel.TextColor3=Color3.fromRGB(255,185,65) end
local memoryProfiles={}
local savedProfiles={"default"}
App.Profile="default"
local function profilePath(n) return folder.."/"..n..".json" end
local function sanitizeName(n) n=tostring(n or ""):gsub("[^%w_%-]",""):sub(1,32); return n=="" and "default" or n end
local function listSavedProfiles()
    local names={}
    local seen={}
    if persistent and type(listfiles)=="function" then
        local ok,files=pcall(function() return listfiles(folder) end)
        if ok and type(files)=="table" then
            for _,file in ipairs(files) do
                local name=file:match("^(.+)%.json$")
                if name and name~="_autosave" and name~="_meta" and not seen[name] then seen[name]=true; table.insert(names,name) end
            end
        end
    end
    for name in pairs(memoryProfiles) do
        if name~="_autosave" and name~="_meta" and not seen[name] then seen[name]=true; table.insert(names,name) end
    end
    table.sort(names)
    if #names==0 then table.insert(names,"default") end
    savedProfiles=names
    if not table.find(savedProfiles,App.Profile) then App.Profile=savedProfiles[1] end
    return savedProfiles
end
local function readProfileEncoded(name)
    local encoded=memoryProfiles[name]
    if persistent and not encoded then
        local ok,data=pcall(function() return readfile(profilePath(name)) end)
        if ok then encoded=data end
    end
    return encoded
end
local function writeProfileEncoded(name,encoded)
    name=sanitizeName(name)
    memoryProfiles[name]=encoded
    if persistent then
        local ok,err=pcall(function() writefile(profilePath(name),encoded) end)
        if not ok then return false,err end
    end
    return true
end
local function writeMeta()
    if not persistent then return end
    pcall(function() writefile(folder.."/"..META_FILE,HttpService:JSONEncode({LastProfile=App.Profile,Profiles=listSavedProfiles()})) end)
end
local function applyConfig(data,profileName)
    if type(data)~="table" then return false end
    mergeValid(Config,data); normalize(); App.Profile=sanitizeName(profileName or App.Profile); listSavedProfiles(); refreshAll()
    if guiScale then guiScale.Scale=Config.UI.Scale/100 end
    App.Target=nil; syncWeaponMods(); writeMeta(); return true
end
local function saveAutosave()
    normalize()
    local encoded=HttpService:JSONEncode(Config)
    memoryProfiles[AUTOSAVE_NAME]=encoded
    if persistent then pcall(function() writefile(profilePath(AUTOSAVE_NAME),encoded) end); writeMeta() end
end
App.SaveAutosave=saveAutosave
local function saveProfile()
    normalize(); local n=sanitizeName(App.Profile); local ok,err=writeProfileEncoded(n,HttpService:JSONEncode(Config))
    if not ok then notify("Save failed: "..tostring(err)); return end
    listSavedProfiles(); writeMeta(); refreshProfilePicker(); notify("Saved profile: "..n)
end
local function loadProfileByName(name)
    name=sanitizeName(name); local encoded=readProfileEncoded(name)
    if not encoded then notify("Profile not found: "..name); return false end
    local ok,data=pcall(function() return HttpService:JSONDecode(encoded) end)
    if not ok or not applyConfig(data,name) then notify("Invalid profile: "..name); return false end
    refreshProfilePicker(); notify("Loaded profile: "..name); return true
end
local function loadProfile() return loadProfileByName(App.Profile) end
local function loadAutosaveOrLast()
    listSavedProfiles()
    local encoded=readProfileEncoded(AUTOSAVE_NAME)
    if persistent then
        local ok,metaData=pcall(function() return readfile(folder.."/"..META_FILE) end)
        if ok and metaData then
            local okMeta,meta=pcall(function() return HttpService:JSONDecode(metaData) end)
            if okMeta and type(meta)=="table" and meta.LastProfile then App.Profile=sanitizeName(meta.LastProfile) end
        end
    end
    if encoded then
        local ok,data=pcall(function() return HttpService:JSONDecode(encoded) end)
        if ok and applyConfig(data,App.Profile) then return true end
    end
    if App.Profile~="default" then
        encoded=readProfileEncoded(App.Profile)
        if encoded then
            local ok,data=pcall(function() return HttpService:JSONDecode(encoded) end)
            if ok and applyConfig(data,App.Profile) then return true end
        end
    end
    return false
end
local function resetProfile()
    restoreWeaponMods(); for k in pairs(Config) do Config[k]=nil end; mergeValid(Config,deepCopy(Defaults)); normalize(); refreshAll()
    if guiScale then guiScale.Scale=Config.UI.Scale/100 end
    App.Target=nil; syncWeaponMods(); saveAutosave(); notify("Settings reset")
end
local function createProfile()
    local base="Profile"
    local n=1
    while table.find(savedProfiles,base..n) do n+=1 end
    App.Profile=base..n
    listSavedProfiles()
    refreshProfilePicker()
    saveProfile()
end
local profilePicker
local function refreshProfilePicker()
    listSavedProfiles()
    if profilePicker and profilePicker.Refresh then profilePicker.Refresh() end
end
local function addProfilePicker(parentObj,text,get,set)
    local r=row(parentObj,38); round(r,7); label(r,text,UDim2.new(.55,-11,1,0),UDim2.new(0,11,0,0),12)
    local b=inst("TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(38,40,49),Size=UDim2.new(.42,0,0,26),Position=UDim2.new(.56,0,.5,-13),Font=Enum.Font.GothamSemibold,TextSize=11,TextColor3=c3(Config.UI.Accent)},r); round(b,6)
    local function refresh()
        listSavedProfiles()
        local current=sanitizeName(get())
        if not table.find(savedProfiles,current) then current=savedProfiles[1]; set(current) end
        b.Text=current.."  ›"
    end
    profilePicker={Refresh=refresh,Button=b}
    table.insert(App.Controls,refresh)
    bind(b.MouseButton1Click,function()
        listSavedProfiles()
        local options=savedProfiles
        local current=sanitizeName(get())
        local idx=table.find(options,current) or 0
        local nextName=options[idx%#options+1]
        set(nextName)
        loadProfileByName(nextName)
        refresh()
    end)
    refresh()
    return r
end
addProfilePicker(profileSection,"Saved profile",function() return App.Profile end,function(v) App.Profile=sanitizeName(v) end)
addButton(profileSection,"Save current profile",saveProfile)
addButton(profileSection,"Create new profile",createProfile)
addButton(profileSection,"Reset defaults",resetProfile,true)

guiScale=inst("UIScale",{Scale=Config.UI.Scale/100},window)
local restoredFrom=loadAutosaveOrLast()
refreshProfilePicker()
showTab("Combat")

local skeletonPairs={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local function makeESP(player)
    if player==LP or App.ESPObjects[player] then return end
    local d={BoxO=draw("Square",{Visible=false,Filled=false,Color=Color3.new(),Thickness=3}),Box=draw("Square",{Visible=false,Filled=false,Color=Color3.new(1,1,1),Thickness=1}),HealthO=draw("Square",{Visible=false,Filled=true,Color=Color3.new()}),Health=draw("Square",{Visible=false,Filled=true,Color=Color3.new(0,1,0)}),Name=draw("Text",{Visible=false,Center=true,Outline=true,Size=14,Font=2}),Info=draw("Text",{Visible=false,Center=true,Outline=true,Size=13,Font=2}),TracerO=draw("Line",{Visible=false,Color=Color3.new(),Thickness=3}),Tracer=draw("Line",{Visible=false,Thickness=1}),Skeleton={}}
    for i=1,#skeletonPairs do d.Skeleton[i]={O=draw("Line",{Visible=false,Color=Color3.new(),Thickness=3}),L=draw("Line",{Visible=false,Thickness=1})} end
    App.ESPObjects[player]=d
end
local function hideESP(d)
    for k,v in pairs(d) do if k=="Skeleton" then for _,s2 in ipairs(v) do s2.O.Visible=false;s2.L.Visible=false end else v.Visible=false end end
end
local function destroyESP(player)
    local d=App.ESPObjects[player]; if not d then return end; hideESP(d)
    for k,v in pairs(d) do if k=="Skeleton" then for _,s2 in ipairs(v) do removeDraw(s2.O);removeDraw(s2.L) end else removeDraw(v) end end
    App.ESPObjects[player]=nil
end
local function project(pos) local p,on=Camera:WorldToViewportPoint(pos); return Vector2.new(p.X,p.Y),on and p.Z>0 end
local bodyNames={"Head","UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftFoot","RightFoot"}
local function trackPlayerHealth(player)
    if player==LP or App.HealthRefs[player] then return end
    local function bindNrpbs(nrpbs)
        if not nrpbs or App.HealthRefs[player] then return end
        task.spawn(function()
            local health=nrpbs:WaitForChild("Health",5)
            if not health or not health:IsA("ValueBase") or App.HealthRefs[player] then return end
            local maxHealth=nrpbs:FindFirstChild("MaxHealth") or nrpbs:FindFirstChild("OMaxHealth")
            App.HealthRefs[player]={Health=health,MaxHealth=maxHealth}
        end)
    end
    if player:FindFirstChild("NRPBS") then bindNrpbs(player.NRPBS) end
    bind(player.ChildAdded,function(child) if child.Name=="NRPBS" then bindNrpbs(child) end end)
end
local function getPlayerHealth(player,hum)
    local refs=App.HealthRefs[player]
    if not refs then trackPlayerHealth(player); refs=App.HealthRefs[player] end
    if refs and refs.Health and refs.Health.Parent then
        local max=100
        if refs.MaxHealth and refs.MaxHealth:IsA("ValueBase") then max=refs.MaxHealth.Value end
        return refs.Health.Value,math.max(max,1)
    end
    local nrpbs=player:FindFirstChild("NRPBS")
    local health=nrpbs and nrpbs:FindFirstChild("Health")
    local maxHealth=nrpbs and (nrpbs:FindFirstChild("MaxHealth") or nrpbs:FindFirstChild("OMaxHealth"))
    if health and health:IsA("ValueBase") then
        local max=maxHealth and maxHealth:IsA("ValueBase") and maxHealth.Value or 100
        return health.Value,math.max(max,1)
    end
    if hum then return hum.Health,math.max(hum.MaxHealth,1) end
    return 0,100
end
local function formatHealth(health)
    return tostring(math.max(0,math.floor(health+.5)))
end
local function isPlayerAlive(player)
    local ch=player.Character
    local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    local root=ch and ch:FindFirstChild("HumanoidRootPart")
    if not ch or not root then return false end
    local health,maxHealth=getPlayerHealth(player,hum)
    if health<=0 then return false end
    if ch:GetAttribute("DIED")==true or player:GetAttribute("DIED")==true then return false end
    if root.Position.Y<-100 then return false end
    local localRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if localRoot and root.Position.Y<localRoot.Position.Y-120 then return false end
    return true
end
local function bounds(char)
    local pts={}; for _,n in ipairs(bodyNames) do local part=char:FindFirstChild(n); if part then local p,on=project(part.Position); if on then table.insert(pts,p) end end end
    if #pts<5 then return end
    local x1,y1,x2,y2=math.huge,math.huge,-math.huge,-math.huge
    for _,p in ipairs(pts) do x1=math.min(x1,p.X);y1=math.min(y1,p.Y);x2=math.max(x2,p.X);y2=math.max(y2,p.Y) end
    local h=y2-y1; local px=math.max(4,h*.12); local py=math.max(4,h*.08)
    return Vector2.new(x1-px,y1-py),Vector2.new(x2-x1+px*2,h+py*2)
end
local function updateESP(player,d)
    if not Config.ESP.Enabled then hideESP(d); return end
    local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); local root=char and char:FindFirstChild("HumanoidRootPart")
    if not isPlayerAlive(player) then hideESP(d); return end
    local health,maxHealth=getPlayerHealth(player,hum)
    local same=LP.Team~=nil and player.Team==LP.Team
    if same and not Config.ESP.ShowTeam then hideESP(d); return end
    local rp,on=project(root.Position); local dist=(Camera.CFrame.Position-root.Position).Magnitude
    if not on or dist>Config.ESP.MaxDistance then hideESP(d); return end
    local pos,size=bounds(char); if not pos then hideESP(d); return end
    local color=c3(same and Config.ESP.TeamColor or Config.ESP.EnemyColor); local alpha=Config.ESP.Opacity/100; local thick=Config.ESP.Thickness
    d.BoxO.Position=pos;d.BoxO.Size=size;d.BoxO.Thickness=thick+2;d.BoxO.Transparency=alpha*.85;d.BoxO.Visible=Config.ESP.Boxes
    d.Box.Position=pos;d.Box.Size=size;d.Box.Color=color;d.Box.Thickness=thick;d.Box.Transparency=alpha;d.Box.Visible=Config.ESP.Boxes
    local displayHealth=math.max(0,health)
    local ratio=math.clamp(displayHealth/math.max(maxHealth,1),0,1)
    local bx=pos.X-8
    d.HealthO.Position=Vector2.new(bx-1,pos.Y-1);d.HealthO.Size=Vector2.new(6,size.Y+2);d.HealthO.Transparency=alpha*.85;d.HealthO.Visible=Config.ESP.Health
    d.Health.Position=Vector2.new(bx,pos.Y+size.Y*(1-ratio));d.Health.Size=Vector2.new(4,math.max(2,size.Y*ratio));d.Health.Color=Color3.fromRGB(255*(1-ratio),255*ratio,70);d.Health.Transparency=alpha;d.Health.Visible=Config.ESP.Health
    local nameText=player.DisplayName
    if player.Team then nameText=nameText.."  ["..player.Team.Name.."]" end
    if Config.ESP.Health then nameText=nameText.."  "..formatHealth(health).." HP" end
    d.Name.Text=nameText;d.Name.Position=Vector2.new(pos.X+size.X/2,pos.Y-17);d.Name.Color=color;d.Name.Transparency=alpha;d.Name.Visible=Config.ESP.Names or Config.ESP.Health
    local infos={}
    if Config.ESP.Distance then table.insert(infos,tostring(math.floor(dist/3.571)).."m") end
    if Config.ESP.Health and not Config.ESP.Names then table.insert(infos,formatHealth(health).." HP") end
    d.Info.Text=table.concat(infos,"  •  ");d.Info.Position=Vector2.new(pos.X+size.X/2,pos.Y+size.Y+3);d.Info.Color=Color3.fromRGB(225,228,238);d.Info.Transparency=alpha;d.Info.Visible=#infos>0
    local origin=Config.ESP.TracerOrigin=="Top" and Vector2.new(Camera.ViewportSize.X/2,0) or (Config.ESP.TracerOrigin=="Center" and Camera.ViewportSize/2 or Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y-2)); local target=Vector2.new(pos.X+size.X/2,pos.Y+size.Y)
    d.TracerO.From=origin;d.TracerO.To=target;d.TracerO.Thickness=thick+2;d.TracerO.Transparency=alpha*.8;d.TracerO.Visible=Config.ESP.Tracers
    d.Tracer.From=origin;d.Tracer.To=target;d.Tracer.Color=color;d.Tracer.Thickness=thick;d.Tracer.Transparency=alpha;d.Tracer.Visible=Config.ESP.Tracers
    for i,pair in ipairs(skeletonPairs) do
        local a,b=char:FindFirstChild(pair[1]),char:FindFirstChild(pair[2]); local seg=d.Skeleton[i]
        if Config.ESP.Skeletons and a and b then local pa,oa=project(a.Position);local pb,ob=project(b.Position); if oa and ob then seg.O.From=pa;seg.O.To=pb;seg.O.Thickness=thick+2;seg.O.Transparency=alpha*.8;seg.O.Visible=true;seg.L.From=pa;seg.L.To=pb;seg.L.Color=color;seg.L.Thickness=thick;seg.L.Transparency=alpha;seg.L.Visible=true else seg.O.Visible=false;seg.L.Visible=false end else seg.O.Visible=false;seg.L.Visible=false end
    end
end
for _,p in ipairs(Players:GetPlayers()) do trackPlayerHealth(p); makeESP(p) end
bind(Players.PlayerAdded,function(p) trackPlayerHealth(p); makeESP(p) end)
bind(Players.PlayerRemoving,function(p) destroyESP(p); App.HealthRefs[p]=nil end)

local fovCircle=draw("Circle",{Visible=false,Filled=false,Color=c3(Config.UI.Accent),Thickness=1,Transparency=.8,NumSides=64,Radius=Config.Combat.FOV})
local cross={Angle=0,Arms={},AO={},Bends={},BO={}}
for i=1,4 do cross.AO[i]=draw("Line",{Visible=false,Color=Color3.new(),Thickness=4});cross.Arms[i]=draw("Line",{Visible=false,Thickness=2});cross.BO[i]=draw("Line",{Visible=false,Color=Color3.new(),Thickness=4});cross.Bends[i]=draw("Line",{Visible=false,Thickness=2}) end
cross.DotO=draw("Circle",{Visible=false,Filled=true,Color=Color3.new(),Radius=3,NumSides=20});cross.Dot=draw("Circle",{Visible=false,Filled=true,Color=Color3.new(1,1,1),Radius=1.5,NumSides=20})

local function validEnemy(p)
    if p==LP then return false end
    if Config.Combat.TeamCheck and LP.Team and p.Team==LP.Team then return false end
    return isPlayerAlive(p)
end
local function visibleTo(p,part)
    if not Config.Combat.WallCheck then return true end
    local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={LP.Character};params.IgnoreWater=true
    local hit=Workspace:Raycast(Camera.CFrame.Position,part.Position-Camera.CFrame.Position,params)
    return hit==nil or (p.Character and hit.Instance:IsDescendantOf(p.Character))
end
local function acquire()
    local mouse=UIS:GetMouseLocation();local best,bestD=nil,Config.Combat.FOV
    for _,p in ipairs(Players:GetPlayers()) do if validEnemy(p) then local part=p.Character and p.Character:FindFirstChild(Config.Combat.TargetPart);if part then local sp,on=project(part.Position);if on then local d=(sp-mouse).Magnitude;if d<bestD and visibleTo(p,part) then best,bestD=p,d end end end end end
    return best
end

bind(UIS.InputBegan,function(input,processed)
    if capture then
        if keyName(input)~="Unknown" then
            for idx,fn in ipairs(App.Controls) do
                local setter=App["KeySetter"..tostring(idx)]
                local refresher=App["KeyRefresh"..tostring(idx)]
                if setter and refresher and capture:GetAttribute("ControlIndex")==idx then setter(keyName(input));capture=nil;refresher();notify("Keybind set: "..keyName(input));return end
            end
        end
        return
    end
    if keyMatches(input,Config.UI.PanicKey) then App:Unload();return end
    if keyMatches(input,Config.UI.MenuKey) then
        local open=not window.Visible
        window.Visible=open; shadow.Visible=open; outerGlow.Visible=open
        if open then window.Size=UDim2.fromOffset(586,444); tween(window,{Size=UDim2.fromOffset(586,444)},TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out)):Play() end
        return
    end
    if not processed and keyMatches(input,Config.Combat.AimKey) then App.Aiming=true end
end)
bind(UIS.InputEnded,function(input) if keyMatches(input,Config.Combat.AimKey) then App.Aiming=false;App.Target=nil end end)

bind(RunService.RenderStepped,function(dt)
    if not App.Alive then return end
    Camera=Workspace.CurrentCamera or Camera
    for p,d in pairs(App.ESPObjects) do updateESP(p,d) end

    local mouse=UIS:GetMouseLocation();fovCircle.Position=mouse;fovCircle.Radius=Config.Combat.FOV;fovCircle.Color=c3(Config.UI.Accent);fovCircle.Visible=Config.Combat.Enabled and Config.Combat.ShowFOV
    if Config.Combat.Enabled and App.Aiming then
        if App.Target and not validEnemy(App.Target) then App.Target=nil end
        if not App.Target or not Config.Combat.LockTarget then App.Target=acquire() end
        local part=App.Target and App.Target.Character and App.Target.Character:FindFirstChild(Config.Combat.TargetPart)
        if App.Target and part and validEnemy(App.Target) and visibleTo(App.Target,part) then
            local goal=CFrame.lookAt(Camera.CFrame.Position,part.Position)
            local smooth=Config.Combat.Smoothness/100
            Camera.CFrame=smooth<=0 and goal or Camera.CFrame:Lerp(goal,1-math.pow(1-math.clamp(smooth,.01,.95),dt*60))
        else
            App.Target=nil
        end
    elseif App.Target then
        App.Target=nil
    end

    local enabled=Config.Crosshair.Enabled;local col=c3(Config.Crosshair.Color);local center=Camera.ViewportSize/2;local sign=Config.Crosshair.Direction=="Clockwise" and 1 or -1
    cross.Angle=(cross.Angle+Config.Crosshair.Speed*dt*sign)%360
    for i=1,4 do
        local a=math.rad(cross.Angle+(i-1)*90);local dir=Vector2.new(math.cos(a),math.sin(a));local side=Vector2.new(-dir.Y,dir.X)*sign;local p1=center+dir*Config.Crosshair.Gap;local p2=center+dir*(Config.Crosshair.Gap+Config.Crosshair.ArmLength);local p3=p2+side*Config.Crosshair.BendLength
        local ao,arm,bo,bend=cross.AO[i],cross.Arms[i],cross.BO[i],cross.Bends[i];ao.From=p1;ao.To=p2;ao.Thickness=Config.Crosshair.Thickness+2;ao.Visible=enabled;arm.From=p1;arm.To=p2;arm.Color=col;arm.Thickness=Config.Crosshair.Thickness;arm.Visible=enabled;bo.From=p2;bo.To=p3;bo.Thickness=Config.Crosshair.Thickness+2;bo.Visible=enabled;bend.From=p2;bend.To=p3;bend.Color=col;bend.Thickness=Config.Crosshair.Thickness;bend.Visible=enabled
    end
    cross.DotO.Position=center;cross.DotO.Visible=enabled and Config.Crosshair.CenterDot;cross.Dot.Position=center;cross.Dot.Color=col;cross.Dot.Visible=enabled and Config.Crosshair.CenterDot
end)

function App:Unload()
    if not self.Alive then return end
    saveAutosave()
    self.Alive=false
    restoreWeaponMods()
    for _,c in ipairs(WeaponMods.Connections) do pcall(function() c:Disconnect() end) end
    WeaponMods.Connections={}
    for _,c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
    for _,d in ipairs(self.Drawings) do removeDraw(d) end
    self.Connections={};self.Drawings={};self.ESPObjects={};self.HealthRefs={}
    pcall(function() self.Gui:Destroy() end)
    env.VapeFeatureMenu=nil;env.DrawingESP=nil;env.Aimbot=nil;env.RotatingXCrosshair=nil
end

env.VapeFeatureMenu=App
env.DrawingESP=App
env.Aimbot=App
env.RotatingXCrosshair=App
if game.BindToClose then pcall(function() game:BindToClose(function() saveAutosave() end) end) end
notify(restoredFrom and "Restored saved settings" or "Feature suite loaded — RightShift opens menu")
print("[VapeFeatureMenu] loaded ui=true resize=true profiles="..tostring(persistent).." restored="..tostring(restoredFrom).." esp=true aimbot=true crosshair=true weapons="..tostring(WeaponsFolder~=nil))