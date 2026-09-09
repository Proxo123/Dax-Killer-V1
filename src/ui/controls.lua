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
