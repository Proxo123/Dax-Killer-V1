return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local UIS=Dax.Services.UIS
    local gui=Dax.UI.Gui
    local BG=Color3.fromRGB(192,192,192)
    local TAB=Color3.fromRGB(212,208,200)
    local WHITE=Color3.fromRGB(255,255,255)
    local BLACK=Color3.fromRGB(0,0,0)
    local FONT=Enum.Font.Legacy
    local SIZE=13
    local root=Instance.new("Frame")
    root.Name="Main"
    root.BackgroundColor3=BG
    root.BorderSizePixel=1
    root.BorderColor3=BLACK
    root.Size=UDim2.fromOffset(420,400)
    root.Position=UDim2.fromOffset(24,24)
    root.Active=true
    root.Parent=gui
    local header=Instance.new("Frame")
    header.BackgroundColor3=BLACK
    header.BorderSizePixel=0
    header.Size=UDim2.new(1,0,0,22)
    header.Parent=root
    local title=Instance.new("TextLabel")
    title.BackgroundTransparency=1
    title.Size=UDim2.new(1,-6,1,0)
    title.Position=UDim2.fromOffset(4,0)
    title.Font=FONT
    title.TextSize=SIZE
    title.TextColor3=WHITE
    title.TextXAlignment=Enum.TextXAlignment.Left
    title.Text="Unnamed Cheats @ "..os.date("%b %d %Y %H:%M:%S").." (INSERT)"
    title.Parent=header
    local tabBar=Instance.new("Frame")
    tabBar.BackgroundTransparency=1
    tabBar.Size=UDim2.new(1,0,0,24)
    tabBar.Position=UDim2.fromOffset(0,22)
    tabBar.Parent=root
    local tabLayout=Instance.new("UIListLayout")
    tabLayout.FillDirection=Enum.FillDirection.Horizontal
    tabLayout.Padding=UDim.new(0,2)
    tabLayout.Parent=tabBar
    local tabPad=Instance.new("UIPadding")
    tabPad.PaddingLeft=UDim.new(0,4)
    tabPad.PaddingTop=UDim.new(0,2)
    tabPad.Parent=tabBar
    local body=Instance.new("Frame")
    body.BackgroundColor3=BG
    body.BorderSizePixel=0
    body.Size=UDim2.new(1,-8,1,-54)
    body.Position=UDim2.fromOffset(4,48)
    body.Parent=root
    local pages={}
    local tabBtns={}
    local function markDirty() if Dax.scheduleAutosave then Dax.scheduleAutosave() end end
    local function showTab(name)
        for n,p in pairs(pages) do p.Visible=n==name end
        for n,b in pairs(tabBtns) do b.BackgroundColor3=n==name and WHITE or TAB end
    end
    local function addTab(name)
        local btn=Instance.new("TextButton")
        btn.AutoButtonColor=false
        btn.BackgroundColor3=TAB
        btn.BorderSizePixel=1
        btn.BorderColor3=BLACK
        btn.Size=UDim2.fromOffset(72,20)
        btn.Font=FONT
        btn.TextSize=SIZE
        btn.TextColor3=BLACK
        btn.Text=name
        btn.Parent=tabBar
        local page=Instance.new("ScrollingFrame")
        page.Name=name
        page.Visible=false
        page.BackgroundTransparency=1
        page.BorderSizePixel=0
        page.Size=UDim2.new(1,0,1,0)
        page.Active=true
        page.ScrollBarThickness=6
        page.ScrollBarImageColor3=BLACK
        page.CanvasSize=UDim2.new()
        page.AutomaticCanvasSize=Enum.AutomaticSize.Y
        page.ScrollingDirection=Enum.ScrollingDirection.Y
        page.Parent=body
        local list=Instance.new("UIListLayout")
        list.Padding=UDim.new(0,2)
        list.SortOrder=Enum.SortOrder.LayoutOrder
        list.Parent=page
        local pagePad=Instance.new("UIPadding")
        pagePad.PaddingTop=UDim.new(0,4)
        pagePad.PaddingLeft=UDim.new(0,4)
        pagePad.Parent=page
        pages[name]=page
        tabBtns[name]=btn
        btn.MouseButton1Click:Connect(function() showTab(name) end)
        return page
    end
    local function addLabel(page,text)
        local lbl=Instance.new("TextLabel")
        lbl.BackgroundTransparency=1
        lbl.Size=UDim2.new(1,-8,0,16)
        lbl.Font=FONT
        lbl.TextSize=SIZE
        lbl.TextColor3=BLACK
        lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.Text=text
        lbl.Interactable=false
        lbl.Parent=page
        return lbl
    end
    local function addCheck(page,text,get,set)
        local row=Instance.new("TextButton")
        row.AutoButtonColor=false
        row.BackgroundTransparency=1
        row.Size=UDim2.new(1,-8,0,18)
        row.Text=""
        row.ZIndex=2
        row.Parent=page
        local box=Instance.new("Frame")
        box.BackgroundColor3=WHITE
        box.BorderSizePixel=1
        box.BorderColor3=BLACK
        box.Size=UDim2.fromOffset(13,13)
        box.Position=UDim2.fromOffset(0,2)
        box.Parent=row
        local mark=Instance.new("TextLabel")
        mark.BackgroundTransparency=1
        mark.Size=UDim2.fromOffset(13,13)
        mark.Font=FONT
        mark.TextSize=11
        mark.TextColor3=BLACK
        mark.Text="x"
        mark.Visible=false
        mark.Parent=box
        local lbl=Instance.new("TextLabel")
        lbl.BackgroundTransparency=1
        lbl.Size=UDim2.new(1,-20,1,0)
        lbl.Position=UDim2.fromOffset(18,0)
        lbl.Font=FONT
        lbl.TextSize=SIZE
        lbl.TextColor3=BLACK
        lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.Text=text
        lbl.Interactable=false
        lbl.Parent=row
        local function refresh() mark.Visible=get() end
        row.MouseButton1Click:Connect(function() set(not get()) markDirty() refresh() end)
        table.insert(App.Controls,refresh)
        refresh()
        return row
    end
    local function addSlider(page,text,min,max,get,set,suffix)
        local wrap=Instance.new("Frame")
        wrap.BackgroundTransparency=1
        wrap.Size=UDim2.new(1,-8,0,34)
        wrap.Parent=page
        local lbl=Instance.new("TextLabel")
        lbl.BackgroundTransparency=1
        lbl.Size=UDim2.new(1,0,0,16)
        lbl.Font=FONT
        lbl.TextSize=SIZE
        lbl.TextColor3=BLACK
        lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.Interactable=false
        lbl.Parent=wrap
        local track=Instance.new("TextButton")
        track.AutoButtonColor=false
        track.BackgroundColor3=WHITE
        track.BorderSizePixel=1
        track.BorderColor3=BLACK
        track.Size=UDim2.new(1,-4,0,10)
        track.Position=UDim2.fromOffset(0,20)
        track.Text=""
        track.Parent=wrap
        local fill=Instance.new("Frame")
        fill.BackgroundColor3=BLACK
        fill.BorderSizePixel=0
        fill.Size=UDim2.new(0,0,1,0)
        fill.Parent=track
        local knob=Instance.new("Frame")
        knob.BackgroundColor3=BLACK
        knob.BorderSizePixel=0
        knob.Size=UDim2.fromOffset(6,14)
        knob.Parent=wrap
        local sliding=false
        local function refresh()
            local v=math.clamp(get(),min,max)
            local a=(v-min)/(max-min)
            lbl.Text=text..": "..string.format("%.0f",v)..(suffix or "")
            fill.Size=UDim2.new(a,0,1,0)
            knob.Position=UDim2.new(a,-3,0,18)
        end
        local function setFrom(x)
            local a=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
            set(min+(max-min)*a)
            markDirty()
            refresh()
        end
        track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true setFrom(i.Position.X) end end)
        UIS.InputChanged:Connect(function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then setFrom(i.Position.X) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
        table.insert(App.Controls,refresh)
        refresh()
        return wrap
    end
    local function addCycle(page,text,options,get,set)
        local btn=Instance.new("TextButton")
        btn.AutoButtonColor=true
        btn.BackgroundColor3=TAB
        btn.BorderSizePixel=1
        btn.BorderColor3=BLACK
        btn.Size=UDim2.new(1,-8,0,20)
        btn.Font=FONT
        btn.TextSize=SIZE
        btn.TextColor3=BLACK
        btn.TextXAlignment=Enum.TextXAlignment.Left
        btn.Parent=page
        local function refresh() btn.Text="  "..text..": "..tostring(get()) end
        btn.MouseButton1Click:Connect(function()
            local cur=get()
            local idx=table.find(options,cur) or 0
            set(options[idx%#options+1])
            markDirty()
            refresh()
        end)
        table.insert(App.Controls,refresh)
        refresh()
        return btn
    end
    local activeDropdown=nil
    local function addDropdown(page,text,getOptions,get,set)
        local wrap=Instance.new("Frame")
        wrap.BackgroundTransparency=1
        wrap.Size=UDim2.new(1,-8,0,20)
        wrap.Parent=page
        local btn=Instance.new("TextButton")
        btn.AutoButtonColor=true
        btn.BackgroundColor3=TAB
        btn.BorderSizePixel=1
        btn.BorderColor3=BLACK
        btn.Size=UDim2.new(1,0,0,20)
        btn.Font=FONT
        btn.TextSize=SIZE
        btn.TextColor3=BLACK
        btn.TextXAlignment=Enum.TextXAlignment.Left
        btn.Parent=wrap
        local overlay=Instance.new("Frame")
        overlay.Visible=false
        overlay.BackgroundColor3=WHITE
        overlay.BorderSizePixel=1
        overlay.BorderColor3=BLACK
        overlay.ZIndex=100
        overlay.Parent=gui
        local scroll=Instance.new("ScrollingFrame")
        scroll.BackgroundTransparency=1
        scroll.BorderSizePixel=0
        scroll.Size=UDim2.new(1,0,1,0)
        scroll.CanvasSize=UDim2.new()
        scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
        scroll.ScrollBarThickness=4
        scroll.ScrollBarImageColor3=BLACK
        scroll.Parent=overlay
        local listLayout=Instance.new("UIListLayout")
        listLayout.Padding=UDim.new(0,0)
        listLayout.Parent=scroll
        local open=false
        local blockClose=false
        local function closeList()
            open=false
            overlay.Visible=false
            if activeDropdown==closeList then activeDropdown=nil end
        end
        local function positionOverlay()
            local a=btn.AbsolutePosition
            local s=btn.AbsoluteSize
            local opts=getOptions()
            local h=math.clamp(#opts*18+2,20,140)
            overlay.Position=UDim2.fromOffset(a.X,a.Y+s.Y+2)
            overlay.Size=UDim2.fromOffset(s.X,h)
        end
        local function rebuildList()
            for _,child in ipairs(scroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for _,opt in ipairs(getOptions()) do
                local optBtn=Instance.new("TextButton")
                optBtn.AutoButtonColor=true
                optBtn.BackgroundColor3=opt==get() and BG or WHITE
                optBtn.BorderSizePixel=0
                optBtn.Size=UDim2.new(1,0,0,18)
                optBtn.Font=FONT
                optBtn.TextSize=SIZE
                optBtn.TextColor3=BLACK
                optBtn.TextXAlignment=Enum.TextXAlignment.Left
                optBtn.Text="  "..tostring(opt)
                optBtn.ZIndex=101
                optBtn.Parent=scroll
                optBtn.MouseButton1Click:Connect(function()
                    set(opt)
                    closeList()
                    refresh()
                end)
            end
        end
        local function refresh() btn.Text="  "..text..": "..tostring(get()).."  v" end
        btn.MouseButton1Click:Connect(function()
            if open then closeList() return end
            if activeDropdown and activeDropdown~=closeList then activeDropdown() end
            rebuildList()
            positionOverlay()
            open=true
            overlay.Visible=true
            activeDropdown=closeList
            blockClose=true
            task.delay(0.15,function() blockClose=false end)
        end)
        Dax.bind(UIS.InputEnded,function(input)
            if not open or blockClose or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            local pos=input.Position
            local function inside(guiObj)
                local a=guiObj.AbsolutePosition local sz=guiObj.AbsoluteSize
                return pos.X>=a.X and pos.X<=a.X+sz.X and pos.Y>=a.Y and pos.Y<=a.Y+sz.Y
            end
            if not inside(btn) and not inside(overlay) then closeList() end
        end)
        table.insert(App.Controls,refresh)
        refresh()
        return wrap,refresh,rebuildList,closeList
    end
    local function addButton(page,text,fn)
        local btn=Instance.new("TextButton")
        btn.AutoButtonColor=true
        btn.BackgroundColor3=TAB
        btn.BorderSizePixel=1
        btn.BorderColor3=BLACK
        btn.Size=UDim2.new(1,-8,0,22)
        btn.Font=FONT
        btn.TextSize=SIZE
        btn.TextColor3=BLACK
        btn.Text=text
        btn.Parent=page
        btn.MouseButton1Click:Connect(fn)
        return btn
    end
    local aimPage=addTab("Aimbot")
    local visPage=addTab("Visuals")
    local modsPage=addTab("Mods")
    local miscPage=addTab("Misc")
    addLabel(aimPage,"-- aimbot --")
    addCheck(aimPage,"enabled",function() return Config.Combat.Enabled end,function(v) Config.Combat.Enabled=v App.Target=nil end)
    addCycle(aimPage,"aim key",{"MouseButton2","MouseButton1","E","Q"},function() return Config.Combat.AimKey end,function(v) Config.Combat.AimKey=v end)
    addCheck(aimPage,"ignore teammates",function() return Config.Combat.TeamCheck end,function(v) Config.Combat.TeamCheck=v end)
    addCheck(aimPage,"visibility check",function() return Config.Combat.WallCheck end,function(v) Config.Combat.WallCheck=v end)
    addCheck(aimPage,"lock target",function() return Config.Combat.LockTarget end,function(v) Config.Combat.LockTarget=v App.Target=nil end)
    addCheck(aimPage,"show fov circle",function() return Config.Combat.ShowFOV end,function(v) Config.Combat.ShowFOV=v end)
    addCycle(aimPage,"target part",{"Head","UpperTorso","HumanoidRootPart"},function() return Config.Combat.TargetPart end,function(v) Config.Combat.TargetPart=v App.Target=nil end)
    addSlider(aimPage,"field of view",30,600,function() return Config.Combat.FOV end,function(v) Config.Combat.FOV=v end," px")
    addSlider(aimPage,"smoothness",0,100,function() return Config.Combat.Smoothness end,function(v) Config.Combat.Smoothness=v end,"%")
    addCheck(aimPage,"triggerbot",function() return Config.Combat.Triggerbot end,function(v) Config.Combat.Triggerbot=v end)
    addSlider(aimPage,"trigger delay",20,500,function() return Config.Combat.TriggerDelay*1000 end,function(v) Config.Combat.TriggerDelay=v/1000 end," ms")
    addLabel(visPage,"-- esp --")
    addCheck(visPage,"esp enabled",function() return Config.ESP.Enabled end,function(v) Config.ESP.Enabled=v end)
    addCheck(visPage,"boxes",function() return Config.ESP.Boxes end,function(v) Config.ESP.Boxes=v end)
    addCheck(visPage,"skeletons",function() return Config.ESP.Skeletons end,function(v) Config.ESP.Skeletons=v end)
    addCheck(visPage,"3d wireframe (expensive)",function() return Config.ESP.Wireframe end,function(v) Config.ESP.Wireframe=v end)
    addCheck(visPage,"tracers",function() return Config.ESP.Tracers end,function(v) Config.ESP.Tracers=v end)
    addCheck(visPage,"names",function() return Config.ESP.Names end,function(v) Config.ESP.Names=v end)
    addCheck(visPage,"distance",function() return Config.ESP.Distance end,function(v) Config.ESP.Distance=v end)
    addCheck(visPage,"health bars",function() return Config.ESP.Health end,function(v) Config.ESP.Health=v end)
    addCheck(visPage,"show teammates",function() return Config.ESP.ShowTeam end,function(v) Config.ESP.ShowTeam=v end)
    addCycle(visPage,"tracer origin",{"Bottom","Center","Top"},function() return Config.ESP.TracerOrigin end,function(v) Config.ESP.TracerOrigin=v end)
    addSlider(visPage,"esp max distance",100,5000,function() return Config.ESP.MaxDistance end,function(v) Config.ESP.MaxDistance=v end," st")
    addSlider(visPage,"line thickness",1,4,function() return Config.ESP.Thickness end,function(v) Config.ESP.Thickness=v end,"")
    addSlider(visPage,"opacity",20,100,function() return Config.ESP.Opacity end,function(v) Config.ESP.Opacity=v end,"%")
    addLabel(visPage,"-- crosshair --")
    addCheck(visPage,"crosshair enabled",function() return Config.Crosshair.Enabled end,function(v) Config.Crosshair.Enabled=v end)
    addCheck(visPage,"center dot",function() return Config.Crosshair.CenterDot end,function(v) Config.Crosshair.CenterDot=v end)
    addCycle(visPage,"direction",{"Clockwise","Counterclockwise"},function() return Config.Crosshair.Direction end,function(v) Config.Crosshair.Direction=v end)
    addSlider(visPage,"rotation speed",0,360,function() return Config.Crosshair.Speed end,function(v) Config.Crosshair.Speed=v end," deg")
    addSlider(visPage,"center gap",0,20,function() return Config.Crosshair.Gap end,function(v) Config.Crosshair.Gap=v end," px")
    addSlider(visPage,"arm length",5,35,function() return Config.Crosshair.ArmLength end,function(v) Config.Crosshair.ArmLength=v end," px")
    addSlider(visPage,"bend length",2,25,function() return Config.Crosshair.BendLength end,function(v) Config.Crosshair.BendLength=v end," px")
    addSlider(visPage,"thickness",1,5,function() return Config.Crosshair.Thickness end,function(v) Config.Crosshair.Thickness=v end,"")
    local WeaponsFolder=Dax.Features.Weapons and Dax.Features.Weapons.Folder
    addLabel(modsPage,WeaponsFolder and "arsenal weapon db detected" or "weapon db not found")
    addCheck(modsPage,"no spread",function() return Config.Weapons.NoSpread end,function(v) Config.Weapons.NoSpread=v if Dax.Features.Weapons then Dax.Features.Weapons.sync() end end)
    addCheck(modsPage,"no recoil",function() return Config.Weapons.NoRecoil end,function(v) Config.Weapons.NoRecoil=v if Dax.Features.Weapons then Dax.Features.Weapons.sync() end end)
    addCheck(modsPage,"instant equip",function() return Config.Weapons.InstantEquip end,function(v) Config.Weapons.InstantEquip=v if Dax.Features.Weapons then Dax.Features.Weapons.sync() end end)
    addCheck(modsPage,"always automatic",function() return Config.Weapons.AlwaysAuto end,function(v) Config.Weapons.AlwaysAuto=v if Dax.Features.Weapons then Dax.Features.Weapons.sync() end end)
    addCheck(modsPage,"instant reload",function() return Config.Weapons.InstantReload end,function(v) Config.Weapons.InstantReload=v if Dax.Features.Weapons then Dax.Features.Weapons.sync() end end)
    addCheck(modsPage,"infinite reserve ammo",function() return Config.Weapons.InfiniteAmmo end,function(v) Config.Weapons.InfiniteAmmo=v if Dax.Features.Weapons then Dax.Features.Weapons.sync() end end)
    addCheck(modsPage,"rapid fire (0.025)",function() return Config.Weapons.RapidFire end,function(v) Config.Weapons.RapidFire=v if Dax.Features.Weapons then Dax.Features.Weapons.sync() end end)
    addLabel(miscPage,"menu: INSERT  |  panic: END")
    addCycle(miscPage,"menu key",{"Insert","RightShift","Home","Delete"},function() return Config.UI.MenuKey end,function(v) Config.UI.MenuKey=v end)
    addLabel(miscPage,"-- profiles --")
    local _,profileRefresh,profileRebuild=addDropdown(miscPage,"profile",function() return Dax.listSavedProfiles() end,function() return App.Profile end,function(name) Dax.loadProfileByName(name) end)
    addButton(miscPage,"save profile",function() Dax.saveProfile() end)
    addButton(miscPage,"new profile",function() Dax.createProfile() end)
    addButton(miscPage,"reset defaults",Dax.resetProfile)
    addButton(miscPage,"unload",function() App:Unload() end)
    function Dax.UI.refreshProfilePicker()
        if profileRefresh then profileRefresh() end
        if profileRebuild then profileRebuild() end
    end
    showTab("Aimbot")
    local dragging,dragStart,startPos=false,nil,nil
    header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true
            dragStart=i.Position
            startPos=root.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-dragStart
            root.Position=UDim2.fromOffset(startPos.X.Offset+d.X,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    function Dax.UI.notify(text)
        if Config.UI.Notifications then print("[DaxKiller]",text) end
    end
    function Dax.UI.applyTheme() Dax.refreshAll() end
    Dax.UI.Window=root
    local ok,err=pcall(function() Dax.RestoredFrom=Dax.loadAutosaveOrLast() end)
    if not ok then warn("[DaxKiller] profile load failed: "..tostring(err)) end
    Dax.refreshAll()
end
