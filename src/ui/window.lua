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
