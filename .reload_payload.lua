local MODULES = {
["core/bootstrap.lua"]=[=[
return function(Dax)
    local Players=game:GetService("Players")
    local RunService=game:GetService("RunService")
    local UIS=game:GetService("UserInputService")
    local HttpService=game:GetService("HttpService")
    local TweenService=game:GetService("TweenService")
    local CoreGui=game:GetService("CoreGui")
    local ReplicatedStorage=game:GetService("ReplicatedStorage")
    local Workspace=game:GetService("Workspace")
    local env=getgenv()
    for _,name in ipairs({"VapeFeatureMenu","DrawingESP","Aimbot","RotatingXCrosshair","DaxKiller"}) do
        local old=env[name]
        if old and type(old.Unload)=="function" then pcall(function() old:Unload() end) end
    end
    Dax.Services={Players=Players,RunService=RunService,UIS=UIS,HttpService=HttpService,TweenService=TweenService,CoreGui=CoreGui,ReplicatedStorage=ReplicatedStorage,Workspace=Workspace}
    Dax.LP=Players.LocalPlayer
    Dax.Camera=Workspace.CurrentCamera
    Dax.env=env
    Dax.App={Connections={},Drawings={},ESPObjects={},HealthRefs={},Controls={},Alive=true,Aiming=false,Target=nil,Profile="default"}
    Dax.UI={}
    Dax.Features={}
    local parent=(type(gethui)=="function" and gethui()) or CoreGui
    local gui=Instance.new("ScreenGui")
    gui.Name="DaxKillerMenu"
    gui.ResetOnSpawn=false
    gui.IgnoreGuiInset=true
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.Parent=parent
    Dax.App.Gui=gui
    Dax.UI.Gui=gui
end

]=],
["core/config.lua"]=[=[
return function(Dax)
    local Config={
        UI={MenuKey="RightShift",PanicKey="End",Scale=100,Notifications=true,Accent={125,92,255}},
        Combat={Enabled=true,AimKey="MouseButton2",TeamCheck=true,WallCheck=true,TargetPart="Head",FOV=200,Smoothness=12,LockTarget=true,ShowFOV=true,RedirectEnabled=true,RedirectTeamCheck=true,RedirectMaxDist=600},
        ESP={Enabled=true,Boxes=true,Skeletons=true,Tracers=true,Names=true,Distance=true,Health=true,ShowTeam=true,MaxDistance=2500,Thickness=1,Opacity=95,TracerOrigin="Bottom",EnemyColor={255,74,92},TeamColor={70,180,255}},
        Crosshair={Enabled=true,Color={255,255,255},Gap=5,ArmLength=15,BendLength=9,Thickness=2,Speed=120,Direction="Clockwise",CenterDot=false},
        Weapons={NoSpread=false,NoRecoil=false}
    }
    Dax.Config=Config
    Dax.App.Config=Config
    function Dax.deepCopy(t)
        local n={}
        for k,v in pairs(t) do n[k]=type(v)=="table" and Dax.deepCopy(v) or v end
        return n
    end
    Dax.Defaults=Dax.deepCopy(Config)
    function Dax.mergeValid(dst,src)
        if type(src)~="table" then return end
        for k,v in pairs(src) do
            if dst[k]~=nil then
                if type(dst[k])=="table" and type(v)=="table" then Dax.mergeValid(dst[k],v)
                elseif type(dst[k])==type(v) then dst[k]=v end
            end
        end
    end
    function Dax.normalize()
        local Config=Dax.Config
        Config.UI.Scale=math.clamp(Config.UI.Scale,75,130)
        Config.Combat.FOV=math.clamp(Config.Combat.FOV,30,600)
        Config.Combat.Smoothness=math.clamp(Config.Combat.Smoothness,0,100)
        Config.Combat.RedirectMaxDist=math.clamp(Config.Combat.RedirectMaxDist,50,2000)
        Config.ESP.MaxDistance=math.clamp(Config.ESP.MaxDistance,100,5000)
        Config.ESP.Thickness=math.clamp(Config.ESP.Thickness,1,4)
        Config.ESP.Opacity=math.clamp(Config.ESP.Opacity,20,100)
        Config.Crosshair.Speed=math.clamp(Config.Crosshair.Speed,0,360)
        Config.Crosshair.Gap=math.clamp(Config.Crosshair.Gap,0,20)
        Config.Crosshair.ArmLength=math.clamp(Config.Crosshair.ArmLength,5,35)
        Config.Crosshair.BendLength=math.clamp(Config.Crosshair.BendLength,2,25)
        Config.Crosshair.Thickness=math.clamp(Config.Crosshair.Thickness,1,5)
    end
end

]=],
["core/util.lua"]=[=[
return function(Dax)
    local App=Dax.App
    function Dax.c3(t) return Color3.fromRGB(t[1],t[2],t[3]) end
    function Dax.bind(signal,fn)
        local c=signal:Connect(fn)
        table.insert(App.Connections,c)
        return c
    end
    function Dax.draw(kind,props)
        local o=Drawing.new(kind)
        for k,v in pairs(props) do o[k]=v end
        table.insert(App.Drawings,o)
        return o
    end
    function Dax.removeDraw(o)
        pcall(function() o.Visible=false end)
        pcall(function() o:Remove() end)
    end
    function Dax.keyName(input)
        if input.UserInputType==Enum.UserInputType.Keyboard then return input.KeyCode.Name end
        return input.UserInputType.Name
    end
    function Dax.keyMatches(input,name) return Dax.keyName(input)==name end
    function Dax.getCamera()
        return game.Workspace.CurrentCamera
    end
    function Dax.project(pos)
        local cam=Dax.getCamera()
        if not cam then return Vector2.zero,false end
        local p,on=cam:WorldToViewportPoint(pos)
        return Vector2.new(p.X,p.Y),on and p.Z>0
    end
    function Dax.refreshAll()
        for _,fn in ipairs(App.Controls) do pcall(fn) end
    end
end

]=],
["core/health.lua"]=[=[
return function(Dax)
    local App=Dax.App
    local LP=Dax.LP
    local Players=Dax.Services.Players
    function Dax.trackPlayerHealth(player)
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
        Dax.bind(player.ChildAdded,function(child) if child.Name=="NRPBS" then bindNrpbs(child) end end)
    end
    function Dax.getPlayerHealth(player,hum)
        local refs=App.HealthRefs[player]
        if not refs then Dax.trackPlayerHealth(player) refs=App.HealthRefs[player] end
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
    function Dax.isPlayerAlive(player)
        local ch=player.Character
        local hum=ch and ch:FindFirstChildOfClass("Humanoid")
        local root=ch and ch:FindFirstChild("HumanoidRootPart")
        if not ch or not root then return false end
        local health=Dax.getPlayerHealth(player,hum)
        if health<=0 then return false end
        if ch:GetAttribute("DIED")==true or player:GetAttribute("DIED")==true then return false end
        if root.Position.Y<-100 then return false end
        local localRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if localRoot and root.Position.Y<localRoot.Position.Y-120 then return false end
        return true
    end
    function Dax.formatHealth(health) return tostring(math.max(0,math.floor(health+.5))) end
    Dax.bind(Players.PlayerRemoving,function(player) App.HealthRefs[player]=nil end)
end

]=],
["ui/theme.lua"]=[=[
return function(Dax)
    local TweenService=Dax.Services.TweenService
    Dax.UI.Theme={
        BG=Color3.fromRGB(8,8,14),
        Panel=Color3.fromRGB(14,14,22),
        Card=Color3.fromRGB(18,18,28),
        Stroke=Color3.fromRGB(45,40,70),
        Text=Color3.fromRGB(235,235,245),
        Dim=Color3.fromRGB(120,115,140),
        Accent=Color3.fromRGB(125,92,255),
        Accent2=Color3.fromRGB(255,74,140),
        Success=Color3.fromRGB(70,220,140),
        Danger=Color3.fromRGB(255,70,90),
    }
    function Dax.UI.accent()
        local a=Dax.Config.UI.Accent
        return Color3.fromRGB(a[1],a[2],a[3])
    end
    function Dax.UI.tween(obj,props,t,delay)
        local info=TweenInfo.new(t or .2,delay and Enum.EasingStyle.Back or Enum.EasingStyle.Quad,delay and Enum.EasingDirection.Out or Enum.EasingDirection.Out)
        local tw=TweenService:Create(obj,info,props)
        tw:Play()
        return tw
    end
end

]=],
["ui/primitives.lua"]=[=[
return function(Dax)
    local Theme=Dax.UI.Theme
    function Dax.UI.new(class,props,parent)
        local o=Instance.new(class)
        for k,v in pairs(props or {}) do o[k]=v end
        if parent then o.Parent=parent end
        return o
    end
    function Dax.UI.corner(parent,r)
        return Dax.UI.new("UICorner",{CornerRadius=UDim.new(0,r or 6)},parent)
    end
    function Dax.UI.stroke(parent,color,thickness)
        return Dax.UI.new("UIStroke",{Color=color or Theme.Stroke,Thickness=thickness or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},parent)
    end
    function Dax.UI.padding(parent,px,py)
        return Dax.UI.new("UIPadding",{PaddingTop=UDim.new(0,py or px),PaddingBottom=UDim.new(0,py or px),PaddingLeft=UDim.new(0,px),PaddingRight=UDim.new(0,px)},parent)
    end
    function Dax.UI.gradient(parent,colors,rot)
        local g=Dax.UI.new("UIGradient",{Rotation=rot or 90},parent)
        local seq={}
        for i,c in ipairs(colors) do seq[i]=ColorSequenceKeypoint.new((i-1)/(#colors-1),c) end
        g.Color=ColorSequence.new(seq)
        return g
    end
    function Dax.UI.label(parent,text,size,pos,fontSize,color,font)
        return Dax.UI.new("TextLabel",{BackgroundTransparency=1,Text=text,Size=size or UDim2.new(1,0,0,24),Position=pos or UDim2.new(),Font=font or Enum.Font.GothamMedium,TextSize=fontSize or 13,TextColor3=color or Color3.fromRGB(225,227,235),TextXAlignment=Enum.TextXAlignment.Left},parent)
    end
end

]=],
["ui/notify.lua"]=[=[
return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local Theme=Dax.UI.Theme
    local inst=Dax.UI.new
    local toastHolder=inst("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,300,1,-30),Position=UDim2.new(1,-315,0,15),ZIndex=20},Dax.UI.Gui)
    inst("UIListLayout",{Padding=UDim.new(0,8),VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right},toastHolder)
    function Dax.UI.notify(text)
        if not Config.UI.Notifications or not App.Alive then return end
        local f=inst("Frame",{BackgroundColor3=Color3.fromRGB(10,12,22),BackgroundTransparency=.05,Size=UDim2.new(0,280,0,44),Position=UDim2.new(0,40,0,0),ZIndex=25},toastHolder)
        Dax.UI.corner(f,10)
        Dax.UI.stroke(f,Dax.UI.accent(),.8)
        Dax.UI.gradient(f,{Color3.fromRGB(18,24,42),Color3.fromRGB(10,12,22)},90)
        local bar=inst("Frame",{BackgroundColor3=Dax.UI.accent(),BorderSizePixel=0,Size=UDim2.new(0,3,1,-14),Position=UDim2.new(0,7,0,7),ZIndex=26},f)
        Dax.UI.corner(bar,3)
        Dax.UI.label(f,text,UDim2.new(1,-24,1,0),UDim2.new(0,18,0,0),12,Color3.fromRGB(235,238,248),Enum.Font.Code).ZIndex=26
        Dax.UI.tween(f,{Position=UDim2.new(0,0,0,0)},.28)
        task.delay(2.6,function()
            if f and f.Parent then
                local out=Dax.Services.TweenService:Create(f,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0,50,0,0),BackgroundTransparency=1})
                out:Play()
                out.Completed:Connect(function() if f then f:Destroy() end end)
            end
        end)
    end
    App.Notify=Dax.UI.notify
end

]=],
["ui/window.lua"]=[=[
return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local RunService=Dax.Services.RunService
    local UIS=Dax.Services.UIS
    local TweenService=Dax.Services.TweenService
    local inst=Dax.UI.new
    local Theme=Dax.UI.Theme
    local gui=Dax.UI.Gui
    local accent=Dax.c3(Config.UI.Accent)
    local outerGlow=inst("Frame",{BackgroundColor3=accent,BackgroundTransparency=.82,Size=UDim2.new(0,600,0,456),Position=UDim2.new(.5,-295,.5,-225),ZIndex=1},gui)
    Dax.UI.corner(outerGlow,16)
    local shadow=inst("Frame",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.35,Size=UDim2.new(0,592,0,448),Position=UDim2.new(.5,-291,.5,-221),ZIndex=2},gui)
    Dax.UI.corner(shadow,14)
    local window=inst("Frame",{Name="Window",BackgroundColor3=Color3.fromRGB(8,10,18),BorderSizePixel=0,ClipsDescendants=true,Size=UDim2.new(0,586,0,444),Position=UDim2.new(.5,-293,.5,-222),ZIndex=3},gui)
    Dax.UI.corner(window,14)
    Dax.UI.stroke(window,accent,.7)
    local bg=inst("Frame",{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(8,10,18),Size=UDim2.new(1,0,1,0),ZIndex=1},window)
    Dax.UI.corner(bg,14)
    local bgGrad=inst("UIGradient",{Rotation=125},bg)
    bgGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(10,14,28)),ColorSequenceKeypoint.new(.55,Color3.fromRGB(7,9,16)),ColorSequenceKeypoint.new(1,Color3.fromRGB(4,6,12))})
    local stars=inst("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=2},bg)
    local starData={}
    for i=1,48 do
        local s=inst("Frame",{BackgroundColor3=Color3.fromRGB(180,210,255),BorderSizePixel=0,Size=UDim2.fromOffset(math.random(1,2),math.random(1,2)),Position=UDim2.new(math.random(),0,math.random(),0),BackgroundTransparency=math.random(20,70)/100,ZIndex=2},stars)
        starData[i]={obj=s,sx=math.random()*586,sy=math.random()*444,sp=math.random(4,14)/100,drift=math.random()/3}
    end
    local scan=inst("Frame",{BackgroundColor3=accent,BackgroundTransparency=.92,BorderSizePixel=0,Size=UDim2.new(1.4,0,0,120),Position=UDim2.new(-.2,0,-.25,0),Rotation=18,ZIndex=2},bg)
    Dax.UI.gradient(scan,{accent,Color3.fromRGB(10,14,28)},90)
    local vignette=inst("Frame",{BackgroundTransparency=0,Size=UDim2.new(1,0,1,0),ZIndex=3},bg)
    Dax.UI.corner(vignette,14)
    local vigGrad=inst("UIGradient",{Rotation=90},vignette)
    vigGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(.35,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))})
    vigGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.78),NumberSequenceKeypoint.new(.5,.92),NumberSequenceKeypoint.new(1,.55)})
    local top=inst("Frame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,54),ZIndex=6},window)
    local topGlass=inst("Frame",{BackgroundColor3=Color3.fromRGB(12,16,28),BackgroundTransparency=.18,Size=UDim2.new(1,-2,1,0),Position=UDim2.new(0,1,0,0),ZIndex=5},top)
    Dax.UI.gradient(topGlass,{Color3.fromRGB(24,34,58),Color3.fromRGB(10,12,20)},90)
    Dax.UI.label(top,"daxkiller.net",UDim2.new(0,120,0,16),UDim2.new(0,18,0,8),10,Color3.fromRGB(120,140,180),Enum.Font.Code)
    local title=Dax.UI.label(top,"DAX KILLER",UDim2.new(0,180,0,24),UDim2.new(0,18,0,24),20,Color3.new(1,1,1),Enum.Font.GothamBlack)
    title.TextStrokeTransparency=.7
    title.TextStrokeColor3=accent
    Dax.UI.label(top,"v1  //  arsenal suite",UDim2.new(0,160,0,16),UDim2.new(0,20,0,42),11,Color3.fromRGB(56,120,255),Enum.Font.Code)
    local status=Dax.UI.label(top,"ONLINE",UDim2.new(0,90,0,20),UDim2.new(1,-110,0,18),11,accent,Enum.Font.Code)
    status.TextXAlignment=Enum.TextXAlignment.Right
    local accentGlow=inst("Frame",{BackgroundColor3=accent,BackgroundTransparency=.35,BorderSizePixel=0,Size=UDim2.new(.45,0,0,3),Position=UDim2.new(.05,0,1,-8),ZIndex=7},top)
    Dax.UI.corner(accentGlow,3)
    Dax.UI.gradient(accentGlow,{Color3.fromRGB(255,255,255),accent},0)
    local closeBtn=inst("TextButton",{Text="×",AutoButtonColor=false,BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=18,TextColor3=Color3.fromRGB(170,180,200),Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-36,0,12),ZIndex=8},top)
    Dax.bind(closeBtn.MouseButton1Click,function() window.Visible=false shadow.Visible=false outerGlow.Visible=false end)
    local rail=inst("Frame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,132,1,-54),Position=UDim2.new(0,0,0,54),ZIndex=6},window)
    local railGlass=inst("Frame",{BackgroundColor3=Color3.fromRGB(8,10,18),BackgroundTransparency=.12,Size=UDim2.new(1,0,1,0),ZIndex=5},rail)
    Dax.UI.gradient(railGlass,{Color3.fromRGB(14,18,30),Color3.fromRGB(6,8,14)},180)
    Dax.UI.padding(rail,10,14)
    inst("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},rail)
    local pageHost=inst("Frame",{BackgroundTransparency=1,ClipsDescendants=true,Size=UDim2.new(1,-132,1,-54),Position=UDim2.new(0,132,0,54),ZIndex=6},window)
    local resize=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=accent,BackgroundTransparency=.15,Size=UDim2.new(0,14,0,14),Position=UDim2.new(1,-18,1,-18),ZIndex=8},window)
    Dax.UI.corner(resize,3)
    Dax.UI.gradient(resize,{Color3.fromRGB(56,120,255),accent},45)
    Dax.bind(RunService.RenderStepped,function(dt)
        if not App.Alive or not window.Visible then return end
        local t=os.clock()
        scan.Position=UDim2.new(-.2+math.sin(t*.25)*.04,0,-.25+math.cos(t*.2)*.03,0)
        accentGlow.BackgroundTransparency=.25+.1*math.sin(t*2)
        for _,data in ipairs(starData) do
            data.sy=(data.sy+data.sp*dt*18)%math.max(window.AbsoluteSize.Y,1)
            data.sx=(data.sx+math.sin(t*.4+data.drift)*dt*6)%math.max(window.AbsoluteSize.X,1)
            data.obj.Position=UDim2.fromOffset(data.sx,data.sy)
        end
    end)
    window.Size=UDim2.fromOffset(0,0)
    shadow.Size=UDim2.fromOffset(0,0)
    outerGlow.Size=UDim2.fromOffset(0,0)
    task.defer(function()
        TweenService:Create(window,TweenInfo.new(.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(586,444)}):Play()
        TweenService:Create(shadow,TweenInfo.new(.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(592,448)}):Play()
        TweenService:Create(outerGlow,TweenInfo.new(.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(600,456)}):Play()
    end)
    local dragging,dragStart,startPos=false,nil,nil
    Dax.bind(top.InputBegan,function(i)
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
    Dax.bind(UIS.InputChanged,function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-dragStart
            local viewport=Dax.Camera.ViewportSize
            local x=math.clamp(startPos.X.Offset+d.X,-window.AbsoluteSize.X+80,viewport.X-80)
            local y=math.clamp(startPos.Y.Offset+d.Y,0,viewport.Y-48)
            window.Position=UDim2.new(startPos.X.Scale,x,startPos.Y.Scale,y)
            shadow.Position=window.Position+UDim2.fromOffset(5,7)
            outerGlow.Position=window.Position+UDim2.fromOffset(2,2)
        end
    end)
    Dax.bind(UIS.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    local resizing,resizeStart,startSize=false,nil,nil
    Dax.bind(resize.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then resizing=true resizeStart=i.Position startSize=window.AbsoluteSize end end)
    Dax.bind(UIS.InputChanged,function(i)
        if resizing and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-resizeStart
            local v=Dax.Camera.ViewportSize
            local w=math.clamp(startSize.X+d.X,500,math.min(850,v.X-20))
            local h=math.clamp(startSize.Y+d.Y,360,math.min(650,v.Y-20))
            window.Size=UDim2.fromOffset(w,h)
            shadow.Size=UDim2.fromOffset(w+6,h+6)
            outerGlow.Size=UDim2.fromOffset(w+10,h+10)
        end
    end)
    Dax.bind(UIS.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then resizing=false end end)
    function Dax.UI.applyTheme()
        local a=Dax.UI.accent()
        if status then status.TextColor3=a end
        if accentGlow then accentGlow.BackgroundColor3=a end
        if resize then resize.BackgroundColor3=a end
        Dax.refreshAll()
    end
    App.RefreshTheme=Dax.UI.applyTheme
    Dax.UI.Window=window
    Dax.UI.Shadow=shadow
    Dax.UI.OuterGlow=outerGlow
    Dax.UI.Rail=rail
    Dax.UI.PageHost=pageHost
    Dax.UI.Status=status
    Dax.UI.AccentGlow=accentGlow
    Dax.UI.Resize=resize
    Dax.UI.Line=Color3.fromRGB(38,48,78)
    Dax.UI.Card=Color3.fromRGB(16,19,32)
end

]=],
["ui/tabs.lua"]=[=[
return function(Dax)
    local TweenService=Dax.Services.TweenService
    local inst=Dax.UI.new
    local rail=Dax.UI.Rail
    local pageHost=Dax.UI.PageHost
    local accent=Dax.UI.accent()
    local line=Dax.UI.Line
    Dax.UI.Pages={}
    Dax.UI.TabButtons={}
    Dax.UI.ActiveTab=nil
    function Dax.UI.showTab(name)
        Dax.UI.ActiveTab=name
        for n,p in pairs(Dax.UI.Pages) do
            if n==name then
                p.Visible=true
                p.Position=UDim2.new(0,10,0,0)
                TweenService:Create(p,TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)}):Play()
            else
                p.Visible=false
            end
        end
        for n,tab in pairs(Dax.UI.TabButtons) do
            local active=n==name
            TweenService:Create(tab.Button,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=active and .08 or .55,TextColor3=active and Color3.new(1,1,1) or Color3.fromRGB(150,160,185)}):Play()
            tab.Indicator.Visible=active
            if active then TweenService:Create(tab.Indicator,TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,3,1,-10)}):Play() end
        end
    end
    function Dax.UI.addTab(name)
        local b=inst("TextButton",{AutoButtonColor=false,Text=name:upper(),Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(150,160,185),BackgroundColor3=Color3.fromRGB(18,24,40),BackgroundTransparency=.55,Size=UDim2.new(1,0,0,36),ZIndex=7},rail)
        Dax.UI.corner(b,8)
        Dax.UI.padding(b,14,8)
        Dax.UI.gradient(b,{Color3.fromRGB(24,34,58),Color3.fromRGB(12,16,28)},90)
        Dax.UI.stroke(b,line,.6)
        local indicator=inst("Frame",{BackgroundColor3=accent,BorderSizePixel=0,Size=UDim2.new(0,0,1,-10),Position=UDim2.new(0,4,.5,0),AnchorPoint=Vector2.new(0,.5),Visible=false,ZIndex=8},b)
        Dax.UI.corner(indicator,2)
        local p=inst("Frame",{Name=name,Visible=false,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=6},pageHost)
        local scroll=inst("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=accent,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,1,0)},p)
        Dax.UI.padding(scroll,14,14)
        inst("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
        Dax.UI.Pages[name]=p
        Dax.UI.TabButtons[name]={Button=b,Indicator=indicator}
        Dax.bind(b.MouseButton1Click,function() Dax.UI.showTab(name) end)
        return scroll
    end
end

]=],
["ui/controls.lua"]=[=[
return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local UIS=Dax.Services.UIS
    local TweenService=Dax.Services.TweenService
    local inst=Dax.UI.new
    local label=Dax.UI.label
    local accent=Dax.UI.accent
    local line=Dax.UI.Line
    local card=Dax.UI.Card
    Dax.UI.Capture=nil
    local palettes={{255,74,92},{125,92,255},{70,180,255},{65,220,150},{255,185,65},{255,255,255}}
    function Dax.UI.section(page,titleText)
        local f=inst("Frame",{BackgroundColor3=card,BackgroundTransparency=.08,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,-2,0,0),ZIndex=6},page)
        Dax.UI.corner(f,10)
        Dax.UI.stroke(f,line,.7)
        Dax.UI.gradient(f,{Color3.fromRGB(20,28,48),Color3.fromRGB(12,16,28)},100)
        Dax.UI.padding(f,12,10)
        inst("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},f)
        label(f,titleText:upper(),UDim2.new(1,0,0,22),nil,12,Color3.fromRGB(235,240,255),Enum.Font.GothamBlack)
        local lineFrame=inst("Frame",{BackgroundColor3=accent(),BackgroundTransparency=.2,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)},f)
        Dax.UI.gradient(lineFrame,{accent(),Color3.fromRGB(10,14,28)},0)
        return f
    end
    function Dax.UI.row(parentObj,height)
        local r=inst("Frame",{BackgroundColor3=Color3.fromRGB(10,14,24),BackgroundTransparency=.2,Size=UDim2.new(1,0,0,height or 36),ZIndex=6},parentObj)
        Dax.UI.corner(r,8)
        Dax.UI.stroke(r,line,.5)
        return r
    end
    function Dax.UI.addToggle(parentObj,text,get,set)
        local r=Dax.UI.row(parentObj,38)
        label(r,text,UDim2.new(1,-58,1,0),UDim2.new(0,12,0,0),12,Color3.fromRGB(220,226,240),Enum.Font.GothamMedium)
        local sw=inst("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.new(0,42,0,22),Position=UDim2.new(1,-52,.5,-11),BackgroundColor3=Color3.fromRGB(30,36,54),ZIndex=7},r)
        Dax.UI.corner(sw,11)
        Dax.UI.stroke(sw,line,.6)
        local dot=inst("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,.5,-8),BackgroundColor3=Color3.fromRGB(220,228,255),ZIndex=8},sw)
        Dax.UI.corner(dot,8)
        local function refresh()
            local v=get()
            TweenService:Create(sw,TweenInfo.new(.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundColor3=v and accent() or Color3.fromRGB(30,36,54)}):Play()
            TweenService:Create(dot,TweenInfo.new(.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=v and UDim2.new(1,-19,.5,-8) or UDim2.new(0,3,.5,-8),BackgroundColor3=v and Color3.new(1,1,1) or Color3.fromRGB(220,228,255)}):Play()
        end
        table.insert(App.Controls,refresh)
        Dax.bind(sw.MouseButton1Click,function() set(not get()) refresh() end)
        refresh()
        return r
    end
    function Dax.UI.addSlider(parentObj,text,min,max,get,set,suffix)
        local r=Dax.UI.row(parentObj,54)
        label(r,text,UDim2.new(1,-72,0,28),UDim2.new(0,12,0,2),12,Color3.fromRGB(220,226,240),Enum.Font.GothamMedium)
        local val=label(r,"",UDim2.new(0,64,0,28),UDim2.new(1,-72,0,2),11,accent(),Enum.Font.Code)
        val.TextXAlignment=Enum.TextXAlignment.Right
        local bar=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(24,30,48),Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,1,-14),ZIndex=7},r)
        Dax.UI.corner(bar,3)
        local fill=inst("Frame",{BorderSizePixel=0,BackgroundColor3=accent(),Size=UDim2.new(0,0,1,0),ZIndex=8},bar)
        Dax.UI.corner(fill,3)
        Dax.UI.gradient(fill,{Color3.fromRGB(56,120,255),accent()},0)
        local knob=inst("Frame",{BackgroundColor3=Color3.new(1,1,1),Size=UDim2.new(0,8,0,8),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),ZIndex=9},bar)
        Dax.UI.corner(knob,4)
        local sliding=false
        local function refresh()
            local v=math.clamp(get(),min,max)
            local a=(v-min)/(max-min)
            fill.Size=UDim2.new(a,0,1,0)
            knob.Position=UDim2.new(a,0,.5,0)
            val.Text=tostring(math.floor(v+.5))..(suffix or "")
        end
        local function update(x)
            local a=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
            set(min+(max-min)*a)
            refresh()
        end
        table.insert(App.Controls,refresh)
        Dax.bind(bar.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true update(i.Position.X) end end)
        Dax.bind(UIS.InputChanged,function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
        Dax.bind(UIS.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
        refresh()
        return r
    end
    function Dax.UI.addCycle(parentObj,text,options,get,set)
        local r=Dax.UI.row(parentObj,40)
        label(r,text,UDim2.new(.55,-12,1,0),UDim2.new(0,12,0,0),12,Color3.fromRGB(220,226,240),Enum.Font.GothamMedium)
        local b=inst("TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(16,22,38),Size=UDim2.new(.42,0,0,28),Position=UDim2.new(.56,0,.5,-14),Font=Enum.Font.Code,TextSize=11,TextColor3=accent(),ZIndex=7},r)
        Dax.UI.corner(b,7)
        Dax.UI.stroke(b,accent(),.5)
        Dax.UI.gradient(b,{Color3.fromRGB(24,34,58),Color3.fromRGB(10,14,24)},90)
        local function refresh() b.Text=tostring(get()).."  ›" end
        table.insert(App.Controls,refresh)
        Dax.bind(b.MouseButton1Click,function()
            local current=get()
            local idx=table.find(options,current) or 0
            set(options[idx%#options+1])
            refresh()
            TweenService:Create(b,TweenInfo.new(.08,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(.42,0,0,26)}):Play()
            task.delay(.08,function() TweenService:Create(b,TweenInfo.new(.12,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(.42,0,0,28)}):Play() end)
        end)
        refresh()
        return r
    end
    function Dax.UI.addKeybind(parentObj,text,get,set)
        local r=Dax.UI.row(parentObj,40)
        label(r,text,UDim2.new(.55,-12,1,0),UDim2.new(0,12,0,0),12,Color3.fromRGB(220,226,240),Enum.Font.GothamMedium)
        local b=inst("TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(16,22,38),Size=UDim2.new(.42,0,0,28),Position=UDim2.new(.56,0,.5,-14),Font=Enum.Font.Code,TextSize=11,TextColor3=accent(),ZIndex=7},r)
        Dax.UI.corner(b,7)
        Dax.UI.stroke(b,accent(),.5)
        local idx=#App.Controls+1
        local function refresh() if Dax.UI.Capture~=b then b.Text="[ "..get().." ]" end end
        table.insert(App.Controls,refresh)
        Dax.bind(b.MouseButton1Click,function() Dax.UI.Capture=b b.Text="press a key..." end)
        b.MouseButton2Click:Connect(function()
            set(text=="Aim key" and "MouseButton2" or (text=="Menu key" and "RightShift" or "End"))
            Dax.UI.Capture=nil
            refresh()
        end)
        b:SetAttribute("ControlIndex",idx)
        App["KeySetter"..tostring(idx)]=set
        App["KeyRefresh"..tostring(idx)]=refresh
        refresh()
        return r
    end
    function Dax.UI.addColor(parentObj,text,get,set)
        local r=Dax.UI.row(parentObj,40)
        label(r,text,UDim2.new(1,-58,1,0),UDim2.new(0,12,0,0),12,Color3.fromRGB(220,226,240),Enum.Font.GothamMedium)
        local b=inst("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.new(0,38,0,24),Position=UDim2.new(1,-48,.5,-12),ZIndex=7},r)
        Dax.UI.corner(b,7)
        Dax.UI.stroke(b,line,.8)
        local function refresh() b.BackgroundColor3=Dax.c3(get()) end
        table.insert(App.Controls,refresh)
        Dax.bind(b.MouseButton1Click,function()
            local cur=get()
            local pick=1
            for i,p in ipairs(palettes) do if p[1]==cur[1] and p[2]==cur[2] and p[3]==cur[3] then pick=i break end end
            set(Dax.deepCopy(palettes[pick%#palettes+1]))
            refresh()
        end)
        refresh()
        return r
    end
    function Dax.UI.addButton(parentObj,text,fn,danger)
        local b=inst("TextButton",{AutoButtonColor=false,BackgroundColor3=danger and Color3.fromRGB(120,34,48) or accent(),Text=text:upper(),Font=Enum.Font.GothamBlack,TextSize=11,TextColor3=Color3.new(1,1,1),Size=UDim2.new(1,0,0,38),ZIndex=7},parentObj)
        Dax.UI.corner(b,8)
        Dax.UI.gradient(b,{danger and Color3.fromRGB(170,50,70) or Color3.fromRGB(56,120,255),danger and Color3.fromRGB(90,24,36) or accent()},90)
        Dax.UI.stroke(b,danger and Color3.fromRGB(255,120,140) or Color3.fromRGB(56,120,255),.7)
        Dax.bind(b.MouseButton1Click,fn)
        Dax.bind(b.MouseEnter,function() TweenService:Create(b,TweenInfo.new(.12),{BackgroundTransparency=.05}):Play() end)
        Dax.bind(b.MouseLeave,function() TweenService:Create(b,TweenInfo.new(.12),{BackgroundTransparency=0}):Play() end)
        return b
    end
end

]=],
["features/weapons.lua"]=[=[
return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local ReplicatedStorage=Dax.Services.ReplicatedStorage
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
                if weaponValue(obj) then fn(obj) count+=1 end
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
        table.insert(WeaponMods.Connections,Dax.bind(WeaponsFolder.DescendantAdded,function(obj)
            if weaponValue(obj) then applyWeaponValue(obj) end
        end))
    end
    App.ApplyWeaponMods=syncWeaponMods
    App.RestoreWeaponMods=restoreWeaponMods
    Dax.Features.Weapons={
        Folder=WeaponsFolder,
        sync=syncWeaponMods,
        restore=restoreWeaponMods,
        Mods=WeaponMods,
    }
end

]=],
["core/persistence.lua"]=[=[
return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local HttpService=Dax.Services.HttpService
    local folder="SolVapeProfiles"
    local AUTOSAVE_NAME="_autosave"
    local META_FILE="_meta.json"
    local persistent=type(writefile)=="function" and type(readfile)=="function"
    if persistent and type(makefolder)=="function" then
        pcall(function() if type(isfolder)~="function" or not isfolder(folder) then makefolder(folder) end end)
    end
    local memoryProfiles={}
    local savedProfiles={"default"}
    local function profilePath(n) return folder.."/"..n..".json" end
    local function sanitizeName(n) n=tostring(n or ""):gsub("[^%w_%-]",""):sub(1,32) return n=="" and "default" or n end
    function Dax.listSavedProfiles()
        local names={}
        local seen={}
        if persistent and type(listfiles)=="function" then
            local ok,files=pcall(function() return listfiles(folder) end)
            if ok and type(files)=="table" then
                for _,file in ipairs(files) do
                    local name=file:match("^(.+)%.json$")
                    if name and name~="_autosave" and name~="_meta" and not seen[name] then seen[name]=true table.insert(names,name) end
                end
            end
        end
        for name in pairs(memoryProfiles) do
            if name~="_autosave" and name~="_meta" and not seen[name] then seen[name]=true table.insert(names,name) end
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
        pcall(function() writefile(folder.."/"..META_FILE,HttpService:JSONEncode({LastProfile=App.Profile,Profiles=Dax.listSavedProfiles()})) end)
    end
    function Dax.applyConfig(data,profileName)
        if type(data)~="table" then return false end
        Dax.mergeValid(Config,data)
        Dax.normalize()
        App.Profile=sanitizeName(profileName or App.Profile)
        Dax.listSavedProfiles()
        Dax.refreshAll()
        if Dax.UI.GuiScale then Dax.UI.GuiScale.Scale=Config.UI.Scale/100 end
        App.Target=nil
        if Dax.Features.Weapons and Dax.Features.Weapons.sync then Dax.Features.Weapons.sync() end
        writeMeta()
        return true
    end
    function Dax.saveAutosave()
        Dax.normalize()
        local encoded=HttpService:JSONEncode(Config)
        memoryProfiles[AUTOSAVE_NAME]=encoded
        if persistent then pcall(function() writefile(profilePath(AUTOSAVE_NAME),encoded) end) writeMeta() end
    end
    App.SaveAutosave=Dax.saveAutosave
    function Dax.saveProfile()
        Dax.normalize()
        local n=sanitizeName(App.Profile)
        local ok,err=writeProfileEncoded(n,HttpService:JSONEncode(Config))
        if not ok then Dax.UI.notify("Save failed: "..tostring(err)) return end
        Dax.listSavedProfiles()
        writeMeta()
        if Dax.UI.refreshProfilePicker then Dax.UI.refreshProfilePicker() end
        Dax.UI.notify("Saved profile: "..n)
    end
    function Dax.loadProfileByName(name)
        name=sanitizeName(name)
        local encoded=readProfileEncoded(name)
        if not encoded then Dax.UI.notify("Profile not found: "..name) return false end
        local ok,data=pcall(function() return HttpService:JSONDecode(encoded) end)
        if not ok or not Dax.applyConfig(data,name) then Dax.UI.notify("Invalid profile: "..name) return false end
        if Dax.UI.refreshProfilePicker then Dax.UI.refreshProfilePicker() end
        Dax.UI.notify("Loaded profile: "..name)
        return true
    end
    function Dax.loadAutosaveOrLast()
        Dax.listSavedProfiles()
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
            if ok and Dax.applyConfig(data,App.Profile) then return true end
        end
        if App.Profile~="default" then
            encoded=readProfileEncoded(App.Profile)
            if encoded then
                local ok,data=pcall(function() return HttpService:JSONDecode(encoded) end)
                if ok and Dax.applyConfig(data,App.Profile) then return true end
            end
        end
        return false
    end
    function Dax.resetProfile()
        if Dax.Features.Weapons and Dax.Features.Weapons.restore then Dax.Features.Weapons.restore() end
        for k in pairs(Config) do Config[k]=nil end
        Dax.mergeValid(Config,Dax.deepCopy(Dax.Defaults))
        Dax.normalize()
        Dax.refreshAll()
        if Dax.UI.GuiScale then Dax.UI.GuiScale.Scale=Config.UI.Scale/100 end
        App.Target=nil
        if Dax.Features.Weapons and Dax.Features.Weapons.sync then Dax.Features.Weapons.sync() end
        Dax.saveAutosave()
        Dax.UI.notify("Settings reset")
    end
    function Dax.createProfile()
        local base="Profile"
        local n=1
        while table.find(savedProfiles,base..n) do n+=1 end
        App.Profile=base..n
        Dax.listSavedProfiles()
        if Dax.UI.refreshProfilePicker then Dax.UI.refreshProfilePicker() end
        Dax.saveProfile()
    end
    Dax.Persistent=persistent
end

]=],
["ui/pages.lua"]=[=[
return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local inst=Dax.UI.new
    local section=Dax.UI.section
    local addToggle=Dax.UI.addToggle
    local addSlider=Dax.UI.addSlider
    local addCycle=Dax.UI.addCycle
    local addKeybind=Dax.UI.addKeybind
    local addColor=Dax.UI.addColor
    local addButton=Dax.UI.addButton
    local label=Dax.UI.label
    local row=Dax.UI.row
    local combatPage=Dax.UI.addTab("Combat")
    local espPage=Dax.UI.addTab("Visuals")
    local crossPage=Dax.UI.addTab("Crosshair")
    local weaponsPage=Dax.UI.addTab("Weapons")
    local settingsPage=Dax.UI.addTab("Settings")
    local profilePage=Dax.UI.addTab("Profiles")
    local s=section(combatPage,"Aimbot")
    addToggle(s,"Enabled",function() return Config.Combat.Enabled end,function(v) Config.Combat.Enabled=v App.Target=nil end)
    addKeybind(s,"Aim key",function() return Config.Combat.AimKey end,function(v) Config.Combat.AimKey=v end)
    addToggle(s,"Ignore teammates",function() return Config.Combat.TeamCheck end,function(v) Config.Combat.TeamCheck=v end)
    addToggle(s,"Visibility check",function() return Config.Combat.WallCheck end,function(v) Config.Combat.WallCheck=v end)
    addToggle(s,"Lock current target",function() return Config.Combat.LockTarget end,function(v) Config.Combat.LockTarget=v App.Target=nil end)
    addToggle(s,"Show FOV circle",function() return Config.Combat.ShowFOV end,function(v) Config.Combat.ShowFOV=v end)
    addCycle(s,"Target part",{"Head","UpperTorso","HumanoidRootPart"},function() return Config.Combat.TargetPart end,function(v) Config.Combat.TargetPart=v App.Target=nil end)
    addSlider(s,"Field of view",30,600,function() return Config.Combat.FOV end,function(v) Config.Combat.FOV=v end," px")
    addSlider(s,"Smoothness",0,100,function() return Config.Combat.Smoothness end,function(v) Config.Combat.Smoothness=v end,"%")
    s=section(combatPage,"Bullet Redirect")
    addToggle(s,"Enabled",function() return Config.Combat.RedirectEnabled end,function(v) Config.Combat.RedirectEnabled=v end)
    addToggle(s,"Ignore teammates",function() return Config.Combat.RedirectTeamCheck end,function(v) Config.Combat.RedirectTeamCheck=v end)
    addSlider(s,"Max distance",50,2000,function() return Config.Combat.RedirectMaxDist end,function(v) Config.Combat.RedirectMaxDist=v end," st")
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
    local WeaponsFolder=Dax.Features.Weapons and Dax.Features.Weapons.Folder
    s=section(weaponsPage,"Gun Mods")
    label(s,WeaponsFolder and "Detected Arsenal weapon database" or "Weapon database not found",UDim2.new(1,0,0,20),nil,11,WeaponsFolder and Color3.fromRGB(88,220,150) or Color3.fromRGB(255,185,65))
    addToggle(s,"No spread",function() return Config.Weapons.NoSpread end,function(v) Config.Weapons.NoSpread=v Dax.Features.Weapons.sync() Dax.UI.notify(v and "Spread disabled" or "Spread restored") end)
    addToggle(s,"No recoil",function() return Config.Weapons.NoRecoil end,function(v) Config.Weapons.NoRecoil=v Dax.Features.Weapons.sync() Dax.UI.notify(v and "Recoil disabled" or "Recoil restored") end)
    s=section(settingsPage,"Interface")
    addKeybind(s,"Menu key",function() return Config.UI.MenuKey end,function(v) Config.UI.MenuKey=v end)
    addKeybind(s,"Panic key",function() return Config.UI.PanicKey end,function(v) Config.UI.PanicKey=v end)
    addToggle(s,"Notifications",function() return Config.UI.Notifications end,function(v) Config.UI.Notifications=v end)
    addSlider(s,"UI scale",75,130,function() return Config.UI.Scale end,function(v) Config.UI.Scale=v Dax.UI.GuiScale.Scale=v/100 end,"%")
    addColor(s,"Accent color",function() return Config.UI.Accent end,function(v) Config.UI.Accent=v Dax.UI.applyTheme() end)
    addButton(s,"Unload everything",function() App:Unload() end,true)
    local profileSection=section(profilePage,"Profiles")
    local persistenceLabel=label(profileSection,"Persistent JSON storage: available",UDim2.new(1,0,0,24),nil,11,Color3.fromRGB(88,220,150))
    label(profileSection,"Settings auto-save when you leave the game",UDim2.new(1,0,0,20),nil,11,Color3.fromRGB(130,133,146))
    if not Dax.Persistent then persistenceLabel.Text="Persistent JSON storage unavailable — session only" persistenceLabel.TextColor3=Color3.fromRGB(255,185,65) end
    local profilePicker
    local function sanitizeName(n) n=tostring(n or ""):gsub("[^%w_%-]",""):sub(1,32) return n=="" and "default" or n end
    local function addProfilePicker(parentObj,text,get,set)
        local r=row(parentObj,38)
        Dax.UI.corner(r,7)
        label(r,text,UDim2.new(.55,-11,1,0),UDim2.new(0,11,0,0),12)
        local b=inst("TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(38,40,49),Size=UDim2.new(.42,0,0,26),Position=UDim2.new(.56,0,.5,-13),Font=Enum.Font.GothamSemibold,TextSize=11,TextColor3=Dax.c3(Config.UI.Accent)},r)
        Dax.UI.corner(b,6)
        local function refresh()
            local options=Dax.listSavedProfiles()
            local current=sanitizeName(get())
            if not table.find(options,current) then current=options[1] set(current) end
            b.Text=current.."  ›"
        end
        profilePicker={Refresh=refresh,Button=b}
        table.insert(App.Controls,refresh)
        Dax.bind(b.MouseButton1Click,function()
            local options=Dax.listSavedProfiles()
            local current=sanitizeName(get())
            local idx=table.find(options,current) or 0
            local nextName=options[idx%#options+1]
            set(nextName)
            Dax.loadProfileByName(nextName)
            refresh()
        end)
        refresh()
        return r
    end
    function Dax.UI.refreshProfilePicker()
        if profilePicker and profilePicker.Refresh then profilePicker.Refresh() end
    end
    addProfilePicker(profileSection,"Saved profile",function() return App.Profile end,function(v) App.Profile=sanitizeName(v) end)
    addButton(profileSection,"Save current profile",Dax.saveProfile)
    addButton(profileSection,"Create new profile",Dax.createProfile)
    addButton(profileSection,"Reset defaults",Dax.resetProfile,true)
    Dax.UI.GuiScale=inst("UIScale",{Scale=Config.UI.Scale/100},Dax.UI.Window)
    Dax.RestoredFrom=Dax.loadAutosaveOrLast()
    Dax.UI.refreshProfilePicker()
    Dax.UI.showTab("Combat")
end

]=],
["features/esp.lua"]=[=[
return function(Dax)
    Dax.Features.ESP={}
    local App=Dax.App
    local Config=Dax.Config
    local LP=Dax.LP
    local Players=Dax.Services.Players
    local skeletonPairs={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
    local bodyNames={"Head","UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftFoot","RightFoot"}
    local function makeESP(player)
        if player==LP or App.ESPObjects[player] then return end
        local d={BoxO=Dax.draw("Square",{Visible=false,Filled=false,Color=Color3.new(),Thickness=3}),Box=Dax.draw("Square",{Visible=false,Filled=false,Color=Color3.new(1,1,1),Thickness=1}),HealthO=Dax.draw("Square",{Visible=false,Filled=true,Color=Color3.new()}),Health=Dax.draw("Square",{Visible=false,Filled=true,Color=Color3.new(0,1,0)}),Name=Dax.draw("Text",{Visible=false,Center=true,Outline=true,Size=14,Font=2}),Info=Dax.draw("Text",{Visible=false,Center=true,Outline=true,Size=13,Font=2}),TracerO=Dax.draw("Line",{Visible=false,Color=Color3.new(),Thickness=3}),Tracer=Dax.draw("Line",{Visible=false,Thickness=1}),Skeleton={}}
        for i=1,#skeletonPairs do d.Skeleton[i]={O=Dax.draw("Line",{Visible=false,Color=Color3.new(),Thickness=3}),L=Dax.draw("Line",{Visible=false,Thickness=1})} end
        App.ESPObjects[player]=d
    end
    local function hideESP(d)
        for k,v in pairs(d) do
            if k=="Skeleton" then for _,s2 in ipairs(v) do s2.O.Visible=false s2.L.Visible=false end
            else v.Visible=false end
        end
    end
    local function destroyESP(player)
        local d=App.ESPObjects[player]
        if not d then return end
        hideESP(d)
        for k,v in pairs(d) do
            if k=="Skeleton" then for _,s2 in ipairs(v) do Dax.removeDraw(s2.O) Dax.removeDraw(s2.L) end
            else Dax.removeDraw(v) end
        end
        App.ESPObjects[player]=nil
    end
    local function bounds(char)
        local pts={}
        for _,n in ipairs(bodyNames) do
            local part=char:FindFirstChild(n)
            if part then
                local p,on=Dax.project(part.Position)
                if on then table.insert(pts,p) end
            end
        end
        if #pts<5 then return end
        local x1,y1,x2,y2=math.huge,math.huge,-math.huge,-math.huge
        for _,p in ipairs(pts) do x1=math.min(x1,p.X) y1=math.min(y1,p.Y) x2=math.max(x2,p.X) y2=math.max(y2,p.Y) end
        local h=y2-y1
        local px=math.max(4,h*.12)
        local py=math.max(4,h*.08)
        return Vector2.new(x1-px,y1-py),Vector2.new(x2-x1+px*2,h+py*2)
    end
    function Dax.Features.ESP.update(player,d)
        if not Config.ESP.Enabled then hideESP(d) return end
        local cam=Dax.getCamera()
        if not cam then hideESP(d) return end
        local char=player.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        local root=char and char:FindFirstChild("HumanoidRootPart")
        if not Dax.isPlayerAlive(player) then hideESP(d) return end
        local health,maxHealth=Dax.getPlayerHealth(player,hum)
        local same=LP.Team~=nil and player.Team==LP.Team
        if same and not Config.ESP.ShowTeam then hideESP(d) return end
        local _,on=Dax.project(root.Position)
        local dist=(cam.CFrame.Position-root.Position).Magnitude
        if not on or dist>Config.ESP.MaxDistance then hideESP(d) return end
        local pos,size=bounds(char)
        if not pos then hideESP(d) return end
        local color=Dax.c3(same and Config.ESP.TeamColor or Config.ESP.EnemyColor)
        local alpha=Config.ESP.Opacity/100
        local thick=Config.ESP.Thickness
        d.BoxO.Position=pos d.BoxO.Size=size d.BoxO.Thickness=thick+2 d.BoxO.Transparency=alpha*.85 d.BoxO.Visible=Config.ESP.Boxes
        d.Box.Position=pos d.Box.Size=size d.Box.Color=color d.Box.Thickness=thick d.Box.Transparency=alpha d.Box.Visible=Config.ESP.Boxes
        local displayHealth=math.max(0,health)
        local ratio=math.clamp(displayHealth/math.max(maxHealth,1),0,1)
        local bx=pos.X-8
        d.HealthO.Position=Vector2.new(bx-1,pos.Y-1) d.HealthO.Size=Vector2.new(6,size.Y+2) d.HealthO.Transparency=alpha*.85 d.HealthO.Visible=Config.ESP.Health
        d.Health.Position=Vector2.new(bx,pos.Y+size.Y*(1-ratio)) d.Health.Size=Vector2.new(4,math.max(2,size.Y*ratio)) d.Health.Color=Color3.fromRGB(255*(1-ratio),255*ratio,70) d.Health.Transparency=alpha d.Health.Visible=Config.ESP.Health
        local nameText=player.DisplayName
        if player.Team then nameText=nameText.."  ["..player.Team.Name.."]" end
        if Config.ESP.Health then nameText=nameText.."  "..Dax.formatHealth(health).." HP" end
        d.Name.Text=nameText d.Name.Position=Vector2.new(pos.X+size.X/2,pos.Y-17) d.Name.Color=color d.Name.Transparency=alpha d.Name.Visible=Config.ESP.Names or Config.ESP.Health
        local infos={}
        if Config.ESP.Distance then table.insert(infos,tostring(math.floor(dist/3.571)).."m") end
        if Config.ESP.Health and not Config.ESP.Names then table.insert(infos,Dax.formatHealth(health).." HP") end
        d.Info.Text=table.concat(infos,"  •  ") d.Info.Position=Vector2.new(pos.X+size.X/2,pos.Y+size.Y+3) d.Info.Color=Color3.fromRGB(225,228,238) d.Info.Transparency=alpha d.Info.Visible=#infos>0
        local origin=Config.ESP.TracerOrigin=="Top" and Vector2.new(cam.ViewportSize.X/2,0) or (Config.ESP.TracerOrigin=="Center" and cam.ViewportSize/2 or Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y-2))
        local target=Vector2.new(pos.X+size.X/2,pos.Y+size.Y)
        d.TracerO.From=origin d.TracerO.To=target d.TracerO.Thickness=thick+2 d.TracerO.Transparency=alpha*.8 d.TracerO.Visible=Config.ESP.Tracers
        d.Tracer.From=origin d.Tracer.To=target d.Tracer.Color=color d.Tracer.Thickness=thick d.Tracer.Transparency=alpha d.Tracer.Visible=Config.ESP.Tracers
        for i,pair in ipairs(skeletonPairs) do
            local a,b=char:FindFirstChild(pair[1]),char:FindFirstChild(pair[2])
            local seg=d.Skeleton[i]
            if Config.ESP.Skeletons and a and b then
                local pa,oa=Dax.project(a.Position)
                local pb,ob=Dax.project(b.Position)
                if oa and ob then
                    seg.O.From=pa seg.O.To=pb seg.O.Thickness=thick+2 seg.O.Transparency=alpha*.8 seg.O.Visible=true
                    seg.L.From=pa seg.L.To=pb seg.L.Color=color seg.L.Thickness=thick seg.L.Transparency=alpha seg.L.Visible=true
                else seg.O.Visible=false seg.L.Visible=false end
            else seg.O.Visible=false seg.L.Visible=false end
        end
    end
    for _,p in ipairs(Players:GetPlayers()) do Dax.trackPlayerHealth(p) makeESP(p) end
    Dax.bind(Players.PlayerAdded,function(p) Dax.trackPlayerHealth(p) makeESP(p) end)
    Dax.bind(Players.PlayerRemoving,function(p) destroyESP(p) end)
end

]=],
["features/aimbot.lua"]=[=[
return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local LP=Dax.LP
    local Players=Dax.Services.Players
    local Workspace=Dax.Services.Workspace
    local UIS=Dax.Services.UIS
    local function validEnemy(p)
        if p==LP then return false end
        if Config.Combat.TeamCheck and LP.Team and p.Team==LP.Team then return false end
        return Dax.isPlayerAlive(p)
    end
    local function visibleTo(p,part)
        if not Config.Combat.WallCheck then return true end
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances={LP.Character}
        params.IgnoreWater=true
        local hit=Workspace:Raycast(Dax.Camera.CFrame.Position,part.Position-Dax.Camera.CFrame.Position,params)
        return hit==nil or (p.Character and hit.Instance:IsDescendantOf(p.Character))
    end
    local function acquire()
        local mouse=UIS:GetMouseLocation()
        local best,bestD=nil,Config.Combat.FOV
        for _,p in ipairs(Players:GetPlayers()) do
            if validEnemy(p) then
                local part=p.Character and p.Character:FindFirstChild(Config.Combat.TargetPart)
                if part then
                    local sp,on=Dax.project(part.Position)
                    if on then
                        local d=(sp-mouse).Magnitude
                        if d<bestD and visibleTo(p,part) then best,bestD=p,d end
                    end
                end
            end
        end
        return best
    end
    Dax.Features.Aimbot={
        validEnemy=validEnemy,
        visibleTo=visibleTo,
        acquire=acquire,
        FOV=Dax.draw("Circle",{Visible=false,Filled=false,Color=Dax.c3(Config.UI.Accent),Thickness=1,Transparency=.8,NumSides=64,Radius=Config.Combat.FOV}),
    }
    function Dax.Features.Aimbot.update(dt)
        local mouse=UIS:GetMouseLocation()
        local fov=Dax.Features.Aimbot.FOV
        fov.Position=mouse
        fov.Radius=Config.Combat.FOV
        fov.Color=Dax.c3(Config.UI.Accent)
        fov.Visible=Config.Combat.Enabled and Config.Combat.ShowFOV
        if Config.Combat.Enabled and App.Aiming then
            if App.Target and not validEnemy(App.Target) then App.Target=nil end
            if not App.Target or not Config.Combat.LockTarget then App.Target=acquire() end
            local part=App.Target and App.Target.Character and App.Target.Character:FindFirstChild(Config.Combat.TargetPart)
            if App.Target and part and validEnemy(App.Target) and visibleTo(App.Target,part) then
                local goal=CFrame.lookAt(Dax.Camera.CFrame.Position,part.Position)
                local smooth=Config.Combat.Smoothness/100
                Dax.Camera.CFrame=smooth<=0 and goal or Dax.Camera.CFrame:Lerp(goal,1-math.pow(1-math.clamp(smooth,.01,.95),dt*60))
            else
                App.Target=nil
            end
        elseif App.Target then
            App.Target=nil
        end
    end
end

]=],
["features/bulletredirect.lua"]=[=[
return function(Dax)
    local Config=Dax.Config
    local LP=Dax.LP
    local Players=Dax.Services.Players
    local Workspace=Dax.Services.Workspace
    local UIS=Dax.Services.UIS
    local RS=Dax.Services.ReplicatedStorage
    local Camera=Dax.Camera
    local State={oldNC=nil}
    local ShootNames={HitPart=true,Fire=true,Trail=true,CreateProjectile=true,ReplicateProjectile=true,["###zzz###"]=true}
    local function readVec3(buf,off)
        return Vector3.new(buffer.readf32(buf,off),buffer.readf32(buf,off+4),buffer.readf32(buf,off+8))
    end
    local function writeVec3(buf,off,v)
        buffer.writef32(buf,off,v.X)
        buffer.writef32(buf,off+4,v.Y)
        buffer.writef32(buf,off+8,v.Z)
    end
    local function plausiblePos(v)
        if v.X~=v.X or v.Y~=v.Y or v.Z~=v.Z then return false end
        if math.abs(v.X)>6000 or math.abs(v.Z)>6000 or v.Y<-400 or v.Y>1200 then return false end
        if math.abs(v.X)<0.05 and math.abs(v.Y)<0.05 and math.abs(v.Z)<0.05 then return false end
        return true
    end
    local function plausibleDir(v)
        local m=v.Magnitude
        return m>0.8 and m<1.2
    end
    local function validEnemy(p)
        if p==LP then return false end
        if Config.Combat.RedirectTeamCheck and LP.Team and p.Team==LP.Team then return false end
        return Dax.isPlayerAlive(p)
    end
    local function hitbox(char)
        return char and (char:FindFirstChild("Hitbox") or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
    end
    local function myPos()
        local char=LP.Character
        local head=char and char:FindFirstChild("Head")
        return head and head.Position or Camera.CFrame.Position
    end
    local function acquire()
        local origin=myPos()
        local best,bestD=nil,Config.Combat.RedirectMaxDist or 600
        for _,p in ipairs(Players:GetPlayers()) do
            if validEnemy(p) then
                local box=hitbox(p.Character)
                if box then
                    local d=(box.Position-origin).Magnitude
                    if d<bestD then best,bestD=box,d end
                end
            end
        end
        return best
    end
    local function analyze(buf,anchor)
        local len=buffer.len(buf)
        local positions={}
        local directions={}
        for off=0,len-12,4 do
            local v=readVec3(buf,off)
            if plausiblePos(v) then
                table.insert(positions,{off=off,v=v,dist=(v-anchor).Magnitude})
            elseif plausibleDir(v) then
                table.insert(directions,{off=off})
            end
        end
        table.sort(positions,function(a,b) return a.dist<b.dist end)
        local originOff=positions[1] and positions[1].off
        local origin=positions[1] and positions[1].v or anchor
        local hitOff=nil
        local hitDist=-1
        for _,item in ipairs(positions) do
            if item.off~=originOff then
                local d=(item.v-origin).Magnitude
                if d>hitDist then hitDist=d hitOff=item.off end
            end
        end
        if not hitOff and #positions>1 then hitOff=positions[#positions].off end
        return origin,hitOff,directions
    end
    local function redirectBuffer(buf,refs,box)
        if typeof(buf)~="buffer" or buffer.len(buf)<32 then return end
        local anchor=box.Position
        local origin,hitOff,directions=analyze(buf,anchor)
        local hitPos=box.Position
        local dir=hitPos-origin
        if dir.Magnitude<0.05 then dir=(hitPos-anchor).Unit else dir=dir.Unit end
        if hitOff then writeVec3(buf,hitOff,hitPos) end
        for _,item in ipairs(directions) do writeVec3(buf,item.off,dir) end
        if type(refs)=="table" then
            for i=#refs,1,-1 do
                local inst=refs[i]
                if typeof(inst)=="Instance" and inst:IsA("BasePart") and not inst:IsDescendantOf(LP.Character) then
                    refs[i]=box
                    break
                end
            end
        end
    end
    local function redirectArgs(name,args,box)
        local pos=box.Position
        if name=="HitPart" then
            args[1]=box
            if typeof(args[2])=="Vector3" then args[2]=pos end
            return true
        elseif name=="Fire" then
            args[1]=pos
            return true
        elseif name=="Trail" and type(args[1])=="table" then
            if type(args[1][5])=="string" then
                args[1][6]=box
                args[1][2]=pos
            end
            return true
        elseif name=="CreateProjectile" then
            args[3]=pos
            args[4]=box.CFrame
            args[10]=pos
            args[17]=pos
            args[18]=box
            args[19]=pos
            return true
        elseif name=="ReplicateProjectile" and type(args[1])=="table" then
            args[1][3]=pos
            args[1][4]=pos
            args[1][10]=pos
            return true
        end
        return false
    end
    local function onFire(self,args)
        if not Config.Combat.RedirectEnabled then return false end
        if checkcaller and checkcaller() then return false end
        local box=acquire()
        if not box then return false end
        local name=self.Name
        if name=="###zzz###" and typeof(args[1])=="buffer" then
            redirectBuffer(args[1],args[2],box)
            return true
        end
        if redirectArgs(name,args,box) then return true end
        if typeof(args[1])=="buffer" then
            redirectBuffer(args[1],args[2],box)
            return true
        end
        return false
    end
    local function unhook()
        if State.oldNC and hookmetamethod then
            pcall(function() hookmetamethod(game,"__namecall",State.oldNC) end)
        end
        State.oldNC=nil
    end
    local function install()
        unhook()
        if not hookmetamethod then return false end
        State.oldNC=hookmetamethod(game,"__namecall",function(self,...)
            local method=getnamecallmethod()
            if method~="FireServer" then return State.oldNC(self,...) end
            if checkcaller and checkcaller() then return State.oldNC(self,...) end
            if not (self:IsA("RemoteEvent") or self:IsA("UnreliableRemoteEvent")) then return State.oldNC(self,...) end
            local args={...}
            if not ShootNames[self.Name] and typeof(args[1])~="buffer" then return State.oldNC(self,...) end
            if onFire(self,args) then
                return self.FireServer(self,table.unpack(args))
            end
            return State.oldNC(self,...)
        end)
        return true
    end
    local ok=install()
    Dax.Features.Redirect={unhook=unhook,installed=ok}
end

]=],
["features/crosshair.lua"]=[=[
return function(Dax)
    local Config=Dax.Config
    local cross={Angle=0,Arms={},AO={},Bends={},BO={}}
    for i=1,4 do
        cross.AO[i]=Dax.draw("Line",{Visible=false,Color=Color3.new(),Thickness=4})
        cross.Arms[i]=Dax.draw("Line",{Visible=false,Thickness=2})
        cross.BO[i]=Dax.draw("Line",{Visible=false,Color=Color3.new(),Thickness=4})
        cross.Bends[i]=Dax.draw("Line",{Visible=false,Thickness=2})
    end
    cross.DotO=Dax.draw("Circle",{Visible=false,Filled=true,Color=Color3.new(),Radius=3,NumSides=20})
    cross.Dot=Dax.draw("Circle",{Visible=false,Filled=true,Color=Color3.new(1,1,1),Radius=1.5,NumSides=20})
    function cross.update(dt)
        local enabled=Config.Crosshair.Enabled
        local col=Dax.c3(Config.Crosshair.Color)
        local center=Dax.Camera.ViewportSize/2
        local sign=Config.Crosshair.Direction=="Clockwise" and 1 or -1
        cross.Angle=(cross.Angle+Config.Crosshair.Speed*dt*sign)%360
        for i=1,4 do
            local a=math.rad(cross.Angle+(i-1)*90)
            local dir=Vector2.new(math.cos(a),math.sin(a))
            local side=Vector2.new(-dir.Y,dir.X)*sign
            local p1=center+dir*Config.Crosshair.Gap
            local p2=center+dir*(Config.Crosshair.Gap+Config.Crosshair.ArmLength)
            local p3=p2+side*Config.Crosshair.BendLength
            local ao,arm,bo,bend=cross.AO[i],cross.Arms[i],cross.BO[i],cross.Bends[i]
            ao.From=p1 ao.To=p2 ao.Thickness=Config.Crosshair.Thickness+2 ao.Visible=enabled
            arm.From=p1 arm.To=p2 arm.Color=col arm.Thickness=Config.Crosshair.Thickness arm.Visible=enabled
            bo.From=p2 bo.To=p3 bo.Thickness=Config.Crosshair.Thickness+2 bo.Visible=enabled
            bend.From=p2 bend.To=p3 bend.Color=col bend.Thickness=Config.Crosshair.Thickness bend.Visible=enabled
        end
        cross.DotO.Position=center cross.DotO.Visible=enabled and Config.Crosshair.CenterDot
        cross.Dot.Position=center cross.Dot.Color=col cross.Dot.Visible=enabled and Config.Crosshair.CenterDot
    end
    Dax.Features.Crosshair=cross
end

]=],
["features/runtime.lua"]=[=[
return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local RunService=Dax.Services.RunService
    local UIS=Dax.Services.UIS
    local Workspace=Dax.Services.Workspace
    local TweenService=Dax.Services.TweenService
    local env=Dax.env
    Dax.bind(UIS.InputBegan,function(input,processed)
        if Dax.UI.Capture then
            if Dax.keyName(input)~="Unknown" then
                for idx,fn in ipairs(App.Controls) do
                    local setter=App["KeySetter"..tostring(idx)]
                    local refresher=App["KeyRefresh"..tostring(idx)]
                    if setter and refresher and Dax.UI.Capture:GetAttribute("ControlIndex")==idx then
                        setter(Dax.keyName(input))
                        Dax.UI.Capture=nil
                        refresher()
                        Dax.UI.notify("Keybind set: "..Dax.keyName(input))
                        return
                    end
                end
            end
            return
        end
        if Dax.keyMatches(input,Config.UI.PanicKey) then App:Unload() return end
        if Dax.keyMatches(input,Config.UI.MenuKey) then
            local window=Dax.UI.Window
            local shadow=Dax.UI.Shadow
            local outerGlow=Dax.UI.OuterGlow
            local open=not window.Visible
            window.Visible=open
            shadow.Visible=open
            outerGlow.Visible=open
            if open then
                window.Size=UDim2.fromOffset(586,444)
                TweenService:Create(window,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(586,444)}):Play()
            end
            return
        end
        if not processed and Dax.keyMatches(input,Config.Combat.AimKey) then App.Aiming=true end
    end)
    Dax.bind(UIS.InputEnded,function(input)
        if Dax.keyMatches(input,Config.Combat.AimKey) then App.Aiming=false App.Target=nil end
    end)
    local RENDER_STEP="DaxKiller_Frame"
    local function onFrame(dt)
        if not App.Alive then return end
        Dax.Camera=Workspace.CurrentCamera
        if not Dax.Camera then return end
        for p,d in pairs(App.ESPObjects) do Dax.Features.ESP.update(p,d) end
        Dax.Features.Aimbot.update(dt)
        Dax.Features.Crosshair.update(dt)
    end
    if RunService.PreRender then
        Dax.bind(RunService.PreRender,onFrame)
    else
        App.UsesRenderStep=true
        App.RenderStepName=RENDER_STEP
        RunService:BindToRenderStep(RENDER_STEP,Enum.RenderPriority.Camera.Value+1,onFrame)
    end
    Dax.bind(Workspace:GetPropertyChangedSignal("CurrentCamera"),function()
        Dax.Camera=Workspace.CurrentCamera
    end)
    function App:Unload()
        if not self.Alive then return end
        Dax.saveAutosave()
        self.Alive=false
        if Dax.Features.Redirect and Dax.Features.Redirect.unhook then Dax.Features.Redirect.unhook() end
        if Dax.Features.Weapons and Dax.Features.Weapons.restore then Dax.Features.Weapons.restore() end
        local mods=Dax.Features.Weapons and Dax.Features.Weapons.Mods
        if mods then
            for _,c in ipairs(mods.Connections) do pcall(function() c:Disconnect() end) end
            mods.Connections={}
        end
        if self.UsesRenderStep and self.RenderStepName then
            pcall(function() RunService:UnbindFromRenderStep(self.RenderStepName) end)
        end
        for _,c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
        for _,d in ipairs(self.Drawings) do Dax.removeDraw(d) end
        self.Connections={}
        self.Drawings={}
        self.ESPObjects={}
        self.HealthRefs={}
        pcall(function() self.Gui:Destroy() end)
        env.VapeFeatureMenu=nil
        env.DrawingESP=nil
        env.Aimbot=nil
        env.RotatingXCrosshair=nil
        env.DaxKiller=nil
    end
    if game.BindToClose then pcall(function() game:BindToClose(function() Dax.saveAutosave() end) end) end
end

]=],
["init.lua"]=[=[
return function(Dax)
    local App=Dax.App
    local env=Dax.env
    env.VapeFeatureMenu=App
    env.DrawingESP=App
    env.Aimbot=App
    env.RotatingXCrosshair=App
    env.DaxKiller=App
    local WeaponsFolder=Dax.Features.Weapons and Dax.Features.Weapons.Folder
    Dax.UI.notify(Dax.RestoredFrom and "Restored saved settings" or "Feature suite loaded — RightShift opens menu")
    print("[DaxKiller] loaded ui=true resize=true profiles="..tostring(Dax.Persistent).." restored="..tostring(Dax.RestoredFrom).." esp=true aimbot=true crosshair=true weapons="..tostring(WeaponsFolder~=nil))
end

]=],
}
local ORDER = {
"core/bootstrap.lua",
"core/config.lua",
"core/util.lua",
"core/health.lua",
"ui/theme.lua",
"ui/primitives.lua",
"ui/notify.lua",
"ui/window.lua",
"ui/tabs.lua",
"ui/controls.lua",
"features/weapons.lua",
"core/persistence.lua",
"ui/pages.lua",
"features/esp.lua",
"features/aimbot.lua",
"features/bulletredirect.lua",
"features/crosshair.lua",
"features/runtime.lua",
"init.lua",
}
local function loadModule(path)
    local source = MODULES[path]
    if not source then error("[DaxKiller] missing " .. path) end
    local chunk, err = loadstring(source, "@" .. path)
    if not chunk then error("[DaxKiller] compile failed " .. path .. ": " .. tostring(err)) end
    return chunk()
end
local Dax = { Repo = "local" }
for _, path in ipairs(ORDER) do
    local module = loadModule(path)
    if type(module) == "function" then module(Dax) end
end