return function(Dax)
    local App=Dax.App
    local UIS=Dax.Services.UIS
    local UI=Dax.UI
    local T=UI.Theme
    local inst=UI.new
    local label=UI.label

    local PRESETS={{255,74,92},{124,92,255},{56,224,255},{61,214,140},{255,184,77},{255,255,255}}

    ----------------------------------------------------------------------------
    -- Containers
    ----------------------------------------------------------------------------
    function UI.section(page,titleText,count)
        local f=inst("Frame",{BackgroundColor3=T.Raise,BackgroundTransparency=.22,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,-4,0,0),ZIndex=4},page)
        UI.corner(f,UI.Radius.Card)
        UI.stroke(f,T.LineSoft,1,.25)
        UI.padding(f,11,11,11,12)
        UI.list(f,8)

        local head=inst("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,16),ZIndex=4},f)
        label(head,string.upper(titleText),UDim2.new(1,-40,1,0),UDim2.new(),11,T.Text,UI.Font.Heavy).ZIndex=5
        if count then
            local c=label(head,tostring(count),UDim2.fromOffset(36,16),UDim2.new(1,-36,0,0),9,T.Faint,UI.Font.Mono)
            c.TextXAlignment=Enum.TextXAlignment.Right
            c.ZIndex=5
        end

        local rule=inst("Frame",{BackgroundColor3=T.White,BorderSizePixel=0,Size=UDim2.new(1,0,0,1),ZIndex=4},f)
        local rg=UI.gradient(rule,{T.White,T.White},0)
        UI.fade(rg,{{0,.35},{1,1}})
        UI.onAccent(function(a) if rule.Parent then UI.setGradient(rg,{a,a}) end end)
        return f
    end

    function UI.note(parent,text,kind)
        local c=T.Dim
        if kind=="ok" then c=T.Success elseif kind=="warn" then c=T.Warn elseif kind=="bad" then c=T.Danger end
        local l=label(parent,text,UDim2.new(1,0,0,15),nil,10,c,UI.Font.Mono)
        l.ZIndex=5
        return l
    end

    -- Rows are TextButtons so the whole row is a hit target and hover states are
    -- available; the accent edge grows in on hover.
    function UI.row(parentObj,height)
        local r=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=T.Row,BackgroundTransparency=.3,Size=UDim2.new(1,0,0,height or 38),ZIndex=4},parentObj)
        UI.corner(r,UI.Radius.Row)
        local border=UI.stroke(r,T.LineSoft,1,1)
        local edge=inst("Frame",{BorderSizePixel=0,AnchorPoint=Vector2.new(0,.5),Size=UDim2.new(0,2,0,0),Position=UDim2.new(0,0,.5,0),ZIndex=6},r)
        UI.corner(edge,1)
        UI.paint(edge,"BackgroundColor3")
        UI.hover(r,
            function()
                UI.tween(r,{BackgroundColor3=T.RowHover,BackgroundTransparency=.06},UI.Motion.Fast)
                UI.tween(border,{Transparency=.45},UI.Motion.Fast)
                UI.tween(edge,{Size=UDim2.new(0,2,0,18)},UI.Motion.Base,UI.Motion.Smooth)
            end,
            function()
                UI.tween(r,{BackgroundColor3=T.Row,BackgroundTransparency=.3},UI.Motion.Fast)
                UI.tween(border,{Transparency=1},UI.Motion.Fast)
                UI.tween(edge,{Size=UDim2.new(0,2,0,0)},UI.Motion.Fast)
            end)
        return r
    end

    local function rowText(r,text,sub,rightGap)
        local w=UDim2.new(1,-(rightGap or 64),0,sub and 15 or 0)
        if sub then
            label(r,text,UDim2.new(1,-(rightGap or 64),0,15),UDim2.fromOffset(12,7),12,T.TextSoft,UI.Font.Body).ZIndex=5
            label(r,sub,UDim2.new(1,-(rightGap or 64),0,12),UDim2.fromOffset(12,23),9,T.Faint,UI.Font.Mono).ZIndex=5
        else
            local l=label(r,text,UDim2.new(1,-(rightGap or 64),1,0),UDim2.fromOffset(12,0),12,T.TextSoft,UI.Font.Body)
            l.ZIndex=5
        end
        return w
    end

    local function controlButton(parent,width)
        local b=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=T.Panel,AnchorPoint=Vector2.new(1,.5),Size=UDim2.fromOffset(width,28),Position=UDim2.new(1,-11,.5,0),ZIndex=6},parent)
        UI.corner(b,UI.Radius.Control)
        local st=UI.stroke(b,T.Line,1,0)
        UI.hover(b,
            function()
                UI.tween(b,{BackgroundColor3=T.Row},UI.Motion.Fast)
                UI.tween(st,{Color=UI.accent()},UI.Motion.Fast)
            end,
            function()
                UI.tween(b,{BackgroundColor3=T.Panel},UI.Motion.Fast)
                UI.tween(st,{Color=T.Line},UI.Motion.Fast)
            end)
        return b,st
    end

    ----------------------------------------------------------------------------
    -- Switch
    ----------------------------------------------------------------------------
    function UI.addToggle(parentObj,text,get,set,sub)
        local r=UI.row(parentObj,sub and 46 or 38)
        rowText(r,text,sub,66)

        local track=inst("Frame",{BackgroundColor3=T.Control,BorderSizePixel=0,AnchorPoint=Vector2.new(1,.5),Size=UDim2.fromOffset(42,23),Position=UDim2.new(1,-12,.5,0),ZIndex=6},r)
        UI.corner(track,UI.Radius.Pill)

        -- Solid track carries the colour transition; the gradient fades in over it.
        local fill=inst("Frame",{BackgroundColor3=T.White,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=7},track)
        UI.corner(fill,UI.Radius.Pill)
        local fg=UI.gradient(fill,{T.White,T.White},0)
        UI.onAccent(function(a,a2) if fill.Parent then UI.setGradient(fg,{a2,a}) end end)

        local ring=inst("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),Size=UDim2.fromOffset(50,31),ZIndex=6},track)
        UI.corner(ring,UI.Radius.Pill)
        local ringStroke=UI.stroke(ring,T.White,1,1)
        UI.paint(ringStroke,"Color")

        local knob=inst("Frame",{BackgroundColor3=T.Knob,BorderSizePixel=0,AnchorPoint=Vector2.new(0,.5),Size=UDim2.fromOffset(17,17),Position=UDim2.new(0,3,.5,0),ZIndex=8},track)
        UI.corner(knob,UI.Radius.Pill)

        local function refresh()
            local v=get() and true or false
            UI.tween(track,{BackgroundColor3=v and UI.accent() or T.Control},.24)
            UI.tween(fill,{BackgroundTransparency=v and 0 or 1},.26)
            UI.tween(knob,{
                Position=v and UDim2.new(1,-20,.5,0) or UDim2.new(0,3,.5,0),
                Size=UDim2.fromOffset(17,17),
                BackgroundColor3=v and T.White or T.Knob,
            },.26,UI.Motion.Spring)
        end

        -- Press stretches the knob; release springs it to the other end.
        Dax.bind(r.InputBegan,function(i)
            if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            local v=get() and true or false
            UI.tween(knob,{Size=UDim2.fromOffset(22,17),Position=v and UDim2.new(1,-25,.5,0) or UDim2.new(0,3,.5,0)},.14)
        end)

        table.insert(App.Controls,refresh)
        Dax.bind(r.MouseButton1Click,function()
            set(not get())
            refresh()
            ring.Size=UDim2.fromOffset(50,31)
            ringStroke.Transparency=.25
            UI.tween(ring,{Size=UDim2.fromOffset(64,43)},.45)
            UI.tween(ringStroke,{Transparency=1},.45)
        end)
        refresh()
        return r
    end

    ----------------------------------------------------------------------------
    -- Slider
    ----------------------------------------------------------------------------
    function UI.addSlider(parentObj,text,min,max,get,set,suffix)
        local r=UI.row(parentObj,56)
        label(r,text,UDim2.new(1,-92,0,24),UDim2.fromOffset(12,6),12,T.TextSoft,UI.Font.Body).ZIndex=5
        local val=label(r,"",UDim2.fromOffset(78,24),UDim2.new(1,-90,0,6),11,T.Text,UI.Font.Mono)
        val.TextXAlignment=Enum.TextXAlignment.Right
        val.ZIndex=5
        UI.paint(val,"TextColor3")

        local bar=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=T.Control,BorderSizePixel=0,Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,1,-16),ZIndex=6},r)
        UI.corner(bar,3)
        local fill=inst("Frame",{BackgroundColor3=T.White,BorderSizePixel=0,Size=UDim2.new(0,0,1,0),ZIndex=7},bar)
        UI.corner(fill,3)
        local fg=UI.gradient(fill,{T.White,T.White},0)
        UI.onAccent(function(a,a2) if fill.Parent then UI.setGradient(fg,{a2,a}) end end)

        local knob=inst("Frame",{BackgroundColor3=T.White,BorderSizePixel=0,AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(12,12),Position=UDim2.new(0,0,.5,0),ZIndex=8},bar)
        UI.corner(knob,6)
        local halo=inst("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),Size=UDim2.fromOffset(12,12),ZIndex=7},knob)
        UI.corner(halo,10)
        local haloStroke=UI.stroke(halo,T.White,4,1)
        UI.paint(haloStroke,"Color")

        local sliding=false

        local function refresh()
            local v=math.clamp(tonumber(get()) or min,min,max)
            local a=(v-min)/math.max(max-min,1)
            fill.Size=UDim2.new(a,0,1,0)
            knob.Position=UDim2.new(a,0,.5,0)
            val.Text=tostring(math.floor(v+.5))..(suffix or "")
        end

        local function update(x)
            local a=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
            set(math.floor(min+(max-min)*a+.5))
            refresh()
        end

        UI.hover(bar,
            function() if not sliding then UI.tween(haloStroke,{Transparency=.72},UI.Motion.Fast) UI.tween(knob,{Size=UDim2.fromOffset(14,14)},UI.Motion.Fast) end end,
            function() if not sliding then UI.tween(haloStroke,{Transparency=1},UI.Motion.Fast) UI.tween(knob,{Size=UDim2.fromOffset(12,12)},UI.Motion.Fast) end end)

        Dax.bind(bar.InputBegan,function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                sliding=true
                UI.tween(haloStroke,{Transparency=.6},UI.Motion.Fast)
                UI.tween(knob,{Size=UDim2.fromOffset(15,15)},UI.Motion.Fast)
                update(i.Position.X)
            end
        end)
        Dax.bind(UIS.InputChanged,function(i)
            if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                update(i.Position.X)
            end
        end)
        Dax.bind(UIS.InputEnded,function(i)
            if sliding and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
                sliding=false
                UI.tween(haloStroke,{Transparency=1},UI.Motion.Fast)
                UI.tween(knob,{Size=UDim2.fromOffset(12,12)},UI.Motion.Fast)
            end
        end)

        table.insert(App.Controls,refresh)
        refresh()
        return r
    end

    ----------------------------------------------------------------------------
    -- Dropdown
    ----------------------------------------------------------------------------
    function UI.addDropdown(parentObj,text,options,get,set,sub)
        local r=UI.row(parentObj,sub and 46 or 40)
        rowText(r,text,sub,152)
        local b=controlButton(r,138)
        local txt=label(b,"",UDim2.new(1,-26,1,0),UDim2.fromOffset(10,0),10,T.Text,UI.Font.Mono)
        txt.ZIndex=7
        local car=label(b,"\u{25BE}",UDim2.fromOffset(14,28),UDim2.new(1,-20,0,0),9,T.Faint,UI.Font.Body)
        car.ZIndex=7

        local function refresh() txt.Text=tostring(get()) end

        Dax.bind(b.MouseButton1Click,function()
            -- `options` may be a function so lists that change at runtime (saved
            -- profiles) stay current without rebuilding the row.
            local opts=type(options)=="function" and options() or options
            if #opts==0 then return end
            local h=#opts*30+12
            local pop=UI.popover(b,170,h)
            UI.padding(pop,6,6)
            UI.list(pop,0)
            for _,opt in ipairs(opts) do
                local sel=opt==get()
                local it=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=T.Row,BackgroundTransparency=sel and .1 or 1,Size=UDim2.new(1,0,0,30),ZIndex=3},pop)
                UI.corner(it,UI.Radius.Control)
                if sel then UI.paint(it,"BackgroundColor3",function(a) return a:Lerp(T.Void,.5) end) end
                local l=label(it,tostring(opt),UDim2.new(1,-32,1,0),UDim2.fromOffset(10,0),10,sel and T.White or T.Dim,UI.Font.Mono)
                l.ZIndex=4
                if sel then
                    local ck=label(it,"\u{2713}",UDim2.fromOffset(18,30),UDim2.new(1,-24,0,0),10,T.White,UI.Font.Body)
                    ck.ZIndex=4
                    UI.paint(ck,"TextColor3",function(_,a2) return a2 end)
                end
                if not sel then
                    UI.hover(it,
                        function() UI.tween(it,{BackgroundTransparency=.35},UI.Motion.Fast) UI.tween(l,{TextColor3=T.Text},UI.Motion.Fast) end,
                        function() UI.tween(it,{BackgroundTransparency=1},UI.Motion.Fast) UI.tween(l,{TextColor3=T.Dim},UI.Motion.Fast) end)
                end
                Dax.bind(it.MouseButton1Click,function()
                    set(opt)
                    refresh()
                    UI.closePopover()
                end)
            end
        end)

        table.insert(App.Controls,refresh)
        refresh()
        return r,refresh
    end

    -- Old name from the cycle-button era.
    UI.addCycle=UI.addDropdown

    ----------------------------------------------------------------------------
    -- Keybind
    ----------------------------------------------------------------------------
    UI.Capture=nil

    function UI.cancelCapture()
        local cap=UI.Capture
        UI.Capture=nil
        if cap and cap.refresh then cap.refresh() end
    end

    function UI.finishCapture(keyName)
        local cap=UI.Capture
        if not cap then return end
        if keyName=="Escape" then UI.cancelCapture() return end
        UI.Capture=nil
        cap.set(keyName)
        cap.refresh()
        Dax.refreshAll()
        if UI.notify then UI.notify("Keybind set \u{00B7} "..keyName,"ok") end
    end

    function UI.addKeybind(parentObj,text,get,set,default,sub)
        local r=UI.row(parentObj,sub and 46 or 40)
        rowText(r,text,sub,130)
        local b,st=controlButton(r,116)
        local txt=label(b,"",UDim2.new(1,0,1,0),UDim2.new(),10,T.Text,UI.Font.Mono)
        txt.TextXAlignment=Enum.TextXAlignment.Center
        txt.ZIndex=7

        local entry
        local pulse

        local function refresh()
            if UI.Capture==entry then return end
            if pulse then pulse:Cancel() pulse=nil end
            txt.Text=tostring(get())
            txt.TextColor3=T.Text
            txt.TextTransparency=0
            st.Color=T.Line
        end

        entry={set=set,refresh=refresh,button=b}

        Dax.bind(b.MouseButton1Click,function()
            if UI.Capture==entry then UI.cancelCapture() return end
            if UI.Capture then UI.cancelCapture() end
            UI.Capture=entry
            txt.Text="press a key..."
            txt.TextColor3=UI.accent()
            st.Color=UI.accent()
            pulse=UI.loop(txt,{TextTransparency=.55},.55,Enum.EasingStyle.Sine,true)
        end)

        Dax.bind(b.MouseButton2Click,function()
            if UI.Capture==entry then UI.cancelCapture() end
            set(default)
            refresh()
            Dax.refreshAll()
            if UI.notify then UI.notify("Keybind reset \u{00B7} "..tostring(default)) end
        end)

        table.insert(App.Controls,refresh)
        refresh()
        return r
    end

    ----------------------------------------------------------------------------
    -- Colour picker
    ----------------------------------------------------------------------------
    function UI.addColor(parentObj,text,get,set,sub)
        local r=UI.row(parentObj,sub and 46 or 40)
        rowText(r,text,sub,70)
        local sw=inst("TextButton",{Text="",AutoButtonColor=false,AnchorPoint=Vector2.new(1,.5),Size=UDim2.fromOffset(46,26),Position=UDim2.new(1,-12,.5,0),BackgroundColor3=Dax.c3(get()),ZIndex=6},r)
        UI.corner(sw,UI.Radius.Control)
        local swStroke=UI.stroke(sw,T.Line,1,0)
        UI.hover(sw,
            function() UI.tween(swStroke,{Color=UI.accent()},UI.Motion.Fast) end,
            function() UI.tween(swStroke,{Color=T.Line},UI.Motion.Fast) end)

        local function refresh() sw.BackgroundColor3=Dax.c3(get()) end

        Dax.bind(sw.MouseButton1Click,function()
            local pop=UI.popover(sw,216,212)
            UI.padding(pop,8,8)

            local h,s,v=Color3.toHSV(Dax.c3(get()))

            local sv=inst("Frame",{BackgroundColor3=Color3.fromHSV(h,1,1),BorderSizePixel=0,Size=UDim2.new(1,0,0,112),ZIndex=3},pop)
            UI.corner(sv,UI.Radius.Control)
            local whiteLayer=inst("Frame",{BackgroundColor3=T.White,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=4},sv)
            UI.corner(whiteLayer,UI.Radius.Control)
            UI.fade(UI.gradient(whiteLayer,{T.White,T.White},0),{{0,0},{1,1}})
            local blackLayer=inst("Frame",{BackgroundColor3=T.Black,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=5},sv)
            UI.corner(blackLayer,UI.Radius.Control)
            UI.fade(UI.gradient(blackLayer,{T.Black,T.Black},90),{{0,1},{1,0}})
            local svCur=inst("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(12,12),ZIndex=6},sv)
            UI.corner(svCur,6)
            UI.stroke(svCur,T.White,2,0)

            local hue=inst("Frame",{BorderSizePixel=0,Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,0,120),ZIndex=3},pop)
            UI.corner(hue,6)
            UI.gradient(hue,{
                Color3.fromRGB(255,0,0),Color3.fromRGB(255,255,0),Color3.fromRGB(0,255,0),
                Color3.fromRGB(0,255,255),Color3.fromRGB(0,0,255),Color3.fromRGB(255,0,255),
                Color3.fromRGB(255,0,0),
            },0)
            local hueCur=inst("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(12,12),Position=UDim2.new(0,0,.5,0),ZIndex=4},hue)
            UI.corner(hueCur,6)
            UI.stroke(hueCur,T.White,2,0)

            local chip=inst("Frame",{BorderSizePixel=0,Size=UDim2.fromOffset(26,26),Position=UDim2.new(0,0,0,142),ZIndex=3},pop)
            UI.corner(chip,UI.Radius.Control)
            UI.stroke(chip,T.Line,1,0)
            local hexLabel=label(pop,"",UDim2.new(1,-34,0,26),UDim2.new(0,34,0,142),11,T.Dim,UI.Font.Mono)
            hexLabel.ZIndex=3

            local presetRow=inst("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,176),ZIndex=3},pop)
            UI.list(presetRow,5,Enum.FillDirection.Horizontal)

            local function paint()
                sv.BackgroundColor3=Color3.fromHSV(h,1,1)
                svCur.Position=UDim2.new(s,0,1-v,0)
                hueCur.Position=UDim2.new(h,0,.5,0)
                local c=Color3.fromHSV(h,s,v)
                chip.BackgroundColor3=c
                local rr,gg,bb=math.floor(c.R*255+.5),math.floor(c.G*255+.5),math.floor(c.B*255+.5)
                hexLabel.Text=string.format("#%02X%02X%02X",rr,gg,bb)
                set({rr,gg,bb})
                refresh()
            end

            local dragging=nil
            local function applySV(px,py)
                s=math.clamp((px-sv.AbsolutePosition.X)/math.max(sv.AbsoluteSize.X,1),0,1)
                v=1-math.clamp((py-sv.AbsolutePosition.Y)/math.max(sv.AbsoluteSize.Y,1),0,1)
                paint()
            end
            local function applyHue(px)
                h=math.clamp((px-hue.AbsolutePosition.X)/math.max(hue.AbsoluteSize.X,1),0,.9999)
                paint()
            end

            UI.popoverBind(sv.InputBegan,function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    dragging="sv" applySV(i.Position.X,i.Position.Y)
                end
            end)
            UI.popoverBind(hue.InputBegan,function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    dragging="hue" applyHue(i.Position.X)
                end
            end)
            UI.popoverBind(UIS.InputChanged,function(i)
                if not dragging then return end
                if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
                if dragging=="sv" then applySV(i.Position.X,i.Position.Y) else applyHue(i.Position.X) end
            end)
            UI.popoverBind(UIS.InputEnded,function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=nil end
            end)

            for _,p in ipairs(PRESETS) do
                local q=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=Dax.c3(p),Size=UDim2.fromOffset(20,20),ZIndex=4},presetRow)
                UI.corner(q,5)
                UI.stroke(q,T.Line,1,.4)
                Dax.bind(q.MouseButton1Click,function()
                    h,s,v=Color3.toHSV(Dax.c3(p))
                    paint()
                end)
            end

            paint()
        end)

        table.insert(App.Controls,refresh)
        refresh()
        return r
    end

    ----------------------------------------------------------------------------
    -- Buttons
    ----------------------------------------------------------------------------
    function UI.addButton(parentObj,text,fn,variant)
        local b=inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=T.Row,Size=UDim2.new(1,-4,0,36),ZIndex=5},parentObj)
        UI.corner(b,UI.Radius.Row)
        local l=label(b,string.upper(text),UDim2.new(1,0,1,0),UDim2.new(),11,T.White,UI.Font.Heavy)
        l.TextXAlignment=Enum.TextXAlignment.Center
        l.ZIndex=7

        if variant=="danger" then
            b.BackgroundColor3=T.Danger:Lerp(T.Row,.72)
            l.TextColor3=T.Danger
            local st=UI.stroke(b,T.Danger,1,.55)
            UI.hover(b,
                function() UI.tween(b,{BackgroundColor3=T.Danger:Lerp(T.Row,.5)},UI.Motion.Fast) UI.tween(l,{TextColor3=T.White},UI.Motion.Fast) UI.tween(st,{Transparency=.2},UI.Motion.Fast) end,
                function() UI.tween(b,{BackgroundColor3=T.Danger:Lerp(T.Row,.72)},UI.Motion.Fast) UI.tween(l,{TextColor3=T.Danger},UI.Motion.Fast) UI.tween(st,{Transparency=.55},UI.Motion.Fast) end)
        elseif variant=="ghost" then
            l.TextColor3=T.Dim
            local st=UI.stroke(b,T.Line,1,0)
            UI.hover(b,
                function() UI.tween(b,{BackgroundColor3=T.RowHover},UI.Motion.Fast) UI.tween(l,{TextColor3=T.Text},UI.Motion.Fast) UI.tween(st,{Color=UI.accent()},UI.Motion.Fast) end,
                function() UI.tween(b,{BackgroundColor3=T.Row},UI.Motion.Fast) UI.tween(l,{TextColor3=T.Dim},UI.Motion.Fast) UI.tween(st,{Color=T.Line},UI.Motion.Fast) end)
        else
            local g=UI.gradient(b,{T.White,T.White},0)
            UI.onAccent(function(a,a2)
                if b.Parent then
                    b.BackgroundColor3=a
                    UI.setGradient(g,{a2:Lerp(a,.45),a})
                end
            end)
            UI.hover(b,
                function() UI.tween(b,{BackgroundTransparency=.12},UI.Motion.Fast) end,
                function() UI.tween(b,{BackgroundTransparency=0},UI.Motion.Fast) end)
        end

        UI.press(b,b,2)
        Dax.bind(b.MouseButton1Click,fn)
        return b
    end
end
