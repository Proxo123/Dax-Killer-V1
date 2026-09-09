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
