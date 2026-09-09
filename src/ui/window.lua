return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local UIS=Dax.Services.UIS
    local UI=Dax.UI
    local T=UI.Theme
    local inst=UI.new
    local gui=UI.Gui

    local DEF_W,DEF_H=660,496
    local MIN_W,MIN_H=540,400
    local MAX_W,MAX_H=920,720
    local HEADER=56
    local RAIL=154

    ----------------------------------------------------------------------------
    -- Glow, shadow and the window itself are children of one root, so dragging,
    -- resizing, scaling and showing/hiding only ever touch `root` and the
    -- decorations follow for free. They used to be siblings kept in sync by hand
    -- in three separate places, which is why they drifted apart.
    ----------------------------------------------------------------------------
    local root=inst("Frame",{
        Name="DaxRoot",
        AnchorPoint=Vector2.new(.5,.5),
        BackgroundTransparency=1,
        Position=UDim2.new(.5,0,.5,0),
        Size=UDim2.fromOffset(DEF_W,DEF_H),
        Visible=false,
    },gui)

    local scale=inst("UIScale",{Scale=Config.UI.Scale/100},root)
    UI.GuiScale=scale

    local glow=inst("Frame",{Name="Glow",BackgroundTransparency=.87,BorderSizePixel=0,Position=UDim2.fromOffset(-6,-7),Size=UDim2.new(1,12,1,16),ZIndex=1},root)
    UI.corner(glow,UI.Radius.Window+5)
    UI.paint(glow,"BackgroundColor3")

    local shadow=inst("Frame",{Name="Shadow",BackgroundColor3=T.Black,BackgroundTransparency=.45,BorderSizePixel=0,Position=UDim2.fromOffset(-3,-2),Size=UDim2.new(1,6,1,8),ZIndex=2},root)
    UI.corner(shadow,UI.Radius.Window+2)

    local window=inst("Frame",{Name="Window",BackgroundColor3=T.Void,BorderSizePixel=0,ClipsDescendants=true,Size=UDim2.new(1,0,1,0),ZIndex=3},root)
    UI.corner(window,UI.Radius.Window)
    local winStroke=UI.stroke(window,T.Line,1,.2)
    UI.paint(winStroke,"Color",function(a) return a:Lerp(T.Line,.72) end)

    ----------------------------------------------------------------------------
    -- Ambient layer: a static hairline grid, three slowly rotating gradient bars
    -- and one sweeping sheen. Eight infinite tweens in total, all owned by the
    -- engine. Nothing here touches RenderStepped.
    ----------------------------------------------------------------------------
    local amb=inst("Frame",{Name="Ambient",BackgroundTransparency=1,ClipsDescendants=true,Size=UDim2.new(1,0,1,0),ZIndex=1},window)

    -- Scale-positioned so the grid keeps its spacing when the window is resized.
    for i=1,15 do
        inst("Frame",{BackgroundColor3=T.White,BackgroundTransparency=.982,BorderSizePixel=0,
            Position=UDim2.new(i/16,0,0,0),Size=UDim2.new(0,1,1,0),ZIndex=1},amb)
    end
    for i=1,11 do
        inst("Frame",{BackgroundColor3=T.White,BackgroundTransparency=.982,BorderSizePixel=0,
            Position=UDim2.new(0,0,i/12,0),Size=UDim2.new(1,0,0,1),ZIndex=1},amb)
    end

    local BARS={
        {t=.80,rot=14,dur=34,drift=.06,second=false},
        {t=.87,rot=-28,dur=47,drift=-.08,second=true},
        {t=.90,rot=72,dur=61,drift=.04,second=false},
    }
    for _,b in ipairs(BARS) do
        local bar=inst("Frame",{
            BackgroundTransparency=b.t,
            BorderSizePixel=0,
            AnchorPoint=Vector2.new(.5,.5),
            Position=UDim2.new(.5,0,.5,0),
            Size=UDim2.new(1.5,0,.34,0),
            Rotation=b.rot,
            ZIndex=2,
        },amb)
        UI.corner(bar,UDim.new(.5,0))
        local g=UI.gradient(bar,{T.White,T.White,T.White},0)
        UI.fade(g,{{0,1},{.5,0},{1,1}})
        UI.onAccent(function(a,a2)
            local c=b.second and a2 or a
            if bar.Parent then UI.setGradient(g,{c,c,c}) end
        end)
        UI.loop(bar,{Rotation=b.rot+360},b.dur)
        UI.loop(bar,{Position=UDim2.new(.5,0,.5+b.drift,0)},b.dur*.55,Enum.EasingStyle.Sine,true)
    end

    local sheen=inst("Frame",{
        BackgroundColor3=T.White,
        BackgroundTransparency=.955,
        BorderSizePixel=0,
        Position=UDim2.new(-.55,0,-.45,0),
        Size=UDim2.new(.42,0,1.9,0),
        Rotation=18,
        ZIndex=3,
    },amb)
    local sheenGrad=UI.gradient(sheen,{T.White,T.White,T.White},0)
    UI.fade(sheenGrad,{{0,1},{.5,0},{1,1}})
    UI.loop(sheen,{Position=UDim2.new(1.25,0,-.45,0)},6,Enum.EasingStyle.Quad,false,3.4)

    ----------------------------------------------------------------------------
    -- Header
    ----------------------------------------------------------------------------
    local header=inst("Frame",{Name="Header",BackgroundColor3=T.Panel,BackgroundTransparency=.16,BorderSizePixel=0,Size=UDim2.new(1,0,0,HEADER),ZIndex=4},window)

    local mark=inst("Frame",{BorderSizePixel=0,Size=UDim2.fromOffset(3,22),Position=UDim2.fromOffset(18,17),ZIndex=5},header)
    UI.corner(mark,2)
    local markGrad=UI.gradient(mark,{T.White,T.White},90)
    UI.onAccent(function(a,a2) if mark.Parent then UI.setGradient(markGrad,{a2,a}) end end)

    UI.label(header,"DAX KILLER",UDim2.fromOffset(220,16),UDim2.fromOffset(30,16),14,T.Text,UI.Font.Heavy).ZIndex=5
    UI.label(header,"V1  \u{00B7}  ARSENAL",UDim2.fromOffset(220,12),UDim2.fromOffset(31,34),9,T.Faint,UI.Font.Mono).ZIndex=5

    local closeBtn=inst("TextButton",{Name="Close",Text="",AutoButtonColor=false,BackgroundColor3=T.Danger,BackgroundTransparency=1,Size=UDim2.fromOffset(28,28),Position=UDim2.new(1,-40,0,14),ZIndex=6},header)
    UI.corner(closeBtn,8)
    local closeIcon=UI.label(closeBtn,"\u{00D7}",UDim2.new(1,0,1,0),UDim2.new(),17,T.Dim,UI.Font.Body)
    closeIcon.TextXAlignment=Enum.TextXAlignment.Center
    closeIcon.ZIndex=7
    UI.hover(closeBtn,
        function()
            UI.tween(closeBtn,{BackgroundTransparency=.82},UI.Motion.Fast)
            UI.tween(closeIcon,{TextColor3=T.Danger},UI.Motion.Fast)
        end,
        function()
            UI.tween(closeBtn,{BackgroundTransparency=1},UI.Motion.Fast)
            UI.tween(closeIcon,{TextColor3=T.Dim},UI.Motion.Fast)
        end)

    local pill=inst("Frame",{BackgroundColor3=T.Raise,BorderSizePixel=0,Size=UDim2.fromOffset(78,24),Position=UDim2.new(1,-128,0,16),ZIndex=5},header)
    UI.corner(pill,UI.Radius.Pill)
    UI.stroke(pill,T.Line,1,.35)
    local dot=inst("Frame",{BackgroundColor3=T.Success,BorderSizePixel=0,Size=UDim2.fromOffset(6,6),Position=UDim2.new(0,11,.5,-3),ZIndex=6},pill)
    UI.corner(dot,3)
    UI.loop(dot,{BackgroundTransparency=.65},1.2,Enum.EasingStyle.Sine,true)
    local status=UI.label(pill,"ONLINE",UDim2.new(1,-26,1,0),UDim2.fromOffset(23,0),9,T.Dim,UI.Font.Mono)
    status.ZIndex=6

    -- Header hairline with a bright segment drifting along it.
    local rule=inst("Frame",{BackgroundColor3=T.LineSoft,BorderSizePixel=0,ClipsDescendants=true,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),ZIndex=5},header)
    local seg=inst("Frame",{BackgroundColor3=T.White,BorderSizePixel=0,Size=UDim2.new(0,180,0,1),Position=UDim2.new(-.08,0,0,0),ZIndex=6},rule)
    local segGrad=UI.gradient(seg,{T.White,T.White,T.White},0)
    UI.fade(segGrad,{{0,1},{.35,0},{1,1}})
    UI.onAccent(function(a,a2) if seg.Parent then UI.setGradient(segGrad,{a2,a,a}) end end)
    UI.loop(seg,{Position=UDim2.new(.34,0,0,0)},4.2,Enum.EasingStyle.Sine,true)

    ----------------------------------------------------------------------------
    -- Rail + page host
    ----------------------------------------------------------------------------
    local rail=inst("Frame",{Name="Rail",BackgroundColor3=T.Panel,BackgroundTransparency=.38,BorderSizePixel=0,Size=UDim2.new(0,RAIL,1,-HEADER),Position=UDim2.fromOffset(0,HEADER),ZIndex=2},window)
    inst("Frame",{BackgroundColor3=T.LineSoft,BorderSizePixel=0,Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),ZIndex=3},rail)

    local tabHolder=inst("Frame",{Name="Tabs",BackgroundTransparency=1,Size=UDim2.new(1,-20,1,-62),Position=UDim2.fromOffset(10,12),ZIndex=3},rail)

    local footRule=inst("Frame",{BackgroundColor3=T.LineSoft,BorderSizePixel=0,Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,1,-32),ZIndex=3},rail)
    local hint=UI.label(rail,"",UDim2.new(1,-20,0,14),UDim2.new(0,11,1,-24),9,T.Faint,UI.Font.Mono)
    hint.ZIndex=3
    local function refreshHint()
        hint.Text=string.upper(tostring(Config.UI.MenuKey)).."  \u{00B7}  MENU"
    end
    table.insert(App.Controls,refreshHint)
    refreshHint()

    local pageHost=inst("Frame",{Name="PageHost",BackgroundTransparency=1,ClipsDescendants=true,Size=UDim2.new(1,-RAIL,1,-HEADER),Position=UDim2.fromOffset(RAIL,HEADER),ZIndex=2},window)

    ----------------------------------------------------------------------------
    -- Popover layer. Sits above everything inside the window and dims the menu,
    -- so dropdowns and the colour picker can escape the scrolling frame.
    ----------------------------------------------------------------------------
    local overlay=inst("Frame",{Name="Overlay",BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Visible=false,ZIndex=20},window)
    local blocker=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=T.Black,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=1},overlay)

    local activePopover,popoverConns=nil,{}

    function UI.popoverBind(signal,fn)
        local c=signal:Connect(fn)
        table.insert(popoverConns,c)
        table.insert(App.Connections,c)
        return c
    end

    function UI.closePopover()
        for _,c in ipairs(popoverConns) do pcall(function() c:Disconnect() end) end
        popoverConns={}
        if activePopover then activePopover:Destroy() activePopover=nil end
        overlay.Visible=false
        blocker.BackgroundTransparency=1
    end

    Dax.bind(blocker.MouseButton1Click,function() UI.closePopover() end)

    -- Places a w x h panel under `anchor`, flipping and clamping so it always
    -- lands fully inside the window. Absolute sizes carry the UIScale, so they
    -- are divided back out to get local offsets.
    function UI.popover(anchor,w,h)
        UI.closePopover()
        overlay.Visible=true
        UI.tween(blocker,{BackgroundTransparency=.5},UI.Motion.Fast)

        local s=scale.Scale
        local rel=anchor.AbsolutePosition-overlay.AbsolutePosition
        local boxW,boxH=window.AbsoluteSize.X/s,window.AbsoluteSize.Y/s
        local x=rel.X/s
        local y=(rel.Y+anchor.AbsoluteSize.Y)/s+6
        if x+w>boxW-12 then x=boxW-12-w end
        if x<12 then x=12 end
        if y+h>boxH-12 then y=rel.Y/s-h-6 end
        if y<12 then y=12 end

        local f=inst("Frame",{BackgroundColor3=T.Raise,BorderSizePixel=0,
            Position=UDim2.fromOffset(math.floor(x),math.floor(y)),
            Size=UDim2.fromOffset(w,h),ZIndex=2},overlay)
        UI.corner(f,UI.Radius.Card)
        UI.stroke(f,T.Line,1,.1)
        local ps=inst("UIScale",{Scale=.96},f)
        UI.tween(ps,{Scale=1},UI.Motion.Base,UI.Motion.Smooth)

        activePopover=f
        return f
    end

    ----------------------------------------------------------------------------
    -- Drag, resize, open/close
    ----------------------------------------------------------------------------
    local grip=inst("TextButton",{Name="Grip",Text="",AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.fromOffset(18,18),Position=UDim2.new(1,-20,1,-20),ZIndex=8},window)
    local gripA=inst("Frame",{BackgroundColor3=T.Faint,BorderSizePixel=0,Size=UDim2.fromOffset(12,1),Position=UDim2.fromOffset(3,12),Rotation=-45,ZIndex=9},grip)
    local gripB=inst("Frame",{BackgroundColor3=T.Faint,BorderSizePixel=0,Size=UDim2.fromOffset(6,1),Position=UDim2.fromOffset(9,15),Rotation=-45,ZIndex=9},grip)
    UI.hover(grip,
        function()
            local a=UI.accent()
            UI.tween(gripA,{BackgroundColor3=a},UI.Motion.Fast)
            UI.tween(gripB,{BackgroundColor3=a},UI.Motion.Fast)
        end,
        function()
            UI.tween(gripA,{BackgroundColor3=T.Faint},UI.Motion.Fast)
            UI.tween(gripB,{BackgroundColor3=T.Faint},UI.Motion.Fast)
        end)

    local function sizePx()
        local s=scale.Scale
        return Vector2.new(root.Size.X.Offset*s,root.Size.Y.Offset*s)
    end

    -- root is centre-anchored; the gestures below work in top-left space and
    -- convert back once, which keeps the maths correct under UIScale.
    local function setTopLeft(x,y)
        local s=sizePx()
        root.Position=UDim2.fromOffset(math.floor(x+s.X/2),math.floor(y+s.Y/2))
    end

    local drag={active=false}
    local size={active=false}

    local function isPointer(i)
        return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch
    end
    local function isMove(i)
        return i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch
    end

    Dax.bind(header.InputBegan,function(i)
        if not isPointer(i) then return end
        drag.active=true
        drag.origin=i.Position
        drag.start=root.AbsolutePosition
    end)

    Dax.bind(grip.InputBegan,function(i)
        if not isPointer(i) then return end
        size.active=true
        size.origin=i.Position
        size.start=Vector2.new(root.Size.X.Offset,root.Size.Y.Offset)
        size.topLeft=root.AbsolutePosition
    end)

    -- One movement handler for both gestures rather than two competing ones.
    Dax.bind(UIS.InputChanged,function(i)
        if not isMove(i) then return end
        local v=Dax.Camera and Dax.Camera.ViewportSize or Vector2.new(1920,1080)
        if drag.active then
            local d=i.Position-drag.origin
            local s=sizePx()
            setTopLeft(
                math.clamp(drag.start.X+d.X,-(s.X-120),v.X-120),
                math.clamp(drag.start.Y+d.Y,0,v.Y-HEADER))
        elseif size.active then
            local d=i.Position-size.origin
            local s=scale.Scale
            local w=math.clamp(size.start.X+d.X/s,MIN_W,MAX_W)
            local h=math.clamp(size.start.Y+d.Y/s,MIN_H,MAX_H)
            root.Size=UDim2.fromOffset(math.floor(w),math.floor(h))
            root.Position=UDim2.fromOffset(
                math.floor(size.topLeft.X+w*s/2),
                math.floor(size.topLeft.Y+h*s/2))
        end
    end)

    Dax.bind(UIS.InputEnded,function(i)
        if isPointer(i) then drag.active=false size.active=false end
    end)

    local function userScale() return math.clamp(Config.UI.Scale,50,200)/100 end

    function UI.setOpen(open)
        UI.closePopover()
        if open then
            root.Visible=true
            scale.Scale=userScale()*.93
            UI.tween(scale,{Scale=userScale()},.26,UI.Motion.Smooth)
        else
            local tw=UI.tween(scale,{Scale=userScale()*.96},.13)
            tw.Completed:Connect(function()
                root.Visible=false
                scale.Scale=userScale()
            end)
        end
    end

    function UI.toggleMenu() UI.setOpen(not root.Visible) end

    Dax.bind(closeBtn.MouseButton1Click,function() UI.setOpen(false) end)
    task.defer(function() UI.setOpen(true) end)

    ----------------------------------------------------------------------------
    UI.Root=root
    UI.Window=window
    UI.Shadow=shadow
    UI.OuterGlow=glow
    UI.Header=header
    UI.Rail=tabHolder
    UI.PageHost=pageHost
    UI.Status=status
    UI.Overlay=overlay
end
