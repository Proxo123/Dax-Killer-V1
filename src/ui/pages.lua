return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local UI=Dax.UI
    local section=UI.section
    local note=UI.note
    local addToggle=UI.addToggle
    local addSlider=UI.addSlider
    local addDropdown=UI.addDropdown
    local addKeybind=UI.addKeybind
    local addColor=UI.addColor
    local addButton=UI.addButton

    local combatPage=UI.addTab("Combat")
    local espPage=UI.addTab("Visuals")
    local crossPage=UI.addTab("Crosshair")
    local weaponsPage=UI.addTab("Weapons")
    local settingsPage=UI.addTab("Settings")
    local profilePage=UI.addTab("Profiles")

    ----------------------------------------------------------------------------
    local s=section(combatPage,"Aimbot","9")
    addToggle(s,"Enabled",function() return Config.Combat.Enabled end,function(v) Config.Combat.Enabled=v App.Target=nil end)
    addKeybind(s,"Aim key",function() return Config.Combat.AimKey end,function(v) Config.Combat.AimKey=v end,"MouseButton2","hold to lock on")
    addToggle(s,"Ignore teammates",function() return Config.Combat.TeamCheck end,function(v) Config.Combat.TeamCheck=v end)
    addToggle(s,"Visibility check",function() return Config.Combat.WallCheck end,function(v) Config.Combat.WallCheck=v end,"skip targets behind walls")
    addToggle(s,"Lock current target",function() return Config.Combat.LockTarget end,function(v) Config.Combat.LockTarget=v App.Target=nil end)
    addToggle(s,"Show FOV circle",function() return Config.Combat.ShowFOV end,function(v) Config.Combat.ShowFOV=v end)
    addDropdown(s,"Target part",{"Head","UpperTorso","HumanoidRootPart"},function() return Config.Combat.TargetPart end,function(v) Config.Combat.TargetPart=v App.Target=nil end)
    addSlider(s,"Field of view",30,600,function() return Config.Combat.FOV end,function(v) Config.Combat.FOV=v end," px")
    addSlider(s,"Smoothness",0,100,function() return Config.Combat.Smoothness end,function(v) Config.Combat.Smoothness=v end,"%")

    ----------------------------------------------------------------------------
    s=section(espPage,"Player ESP","8")
    addToggle(s,"Enabled",function() return Config.ESP.Enabled end,function(v) Config.ESP.Enabled=v end)
    addToggle(s,"Boxes",function() return Config.ESP.Boxes end,function(v) Config.ESP.Boxes=v end)
    addToggle(s,"R15 skeletons",function() return Config.ESP.Skeletons end,function(v) Config.ESP.Skeletons=v end)
    addToggle(s,"Tracers",function() return Config.ESP.Tracers end,function(v) Config.ESP.Tracers=v end)
    addToggle(s,"Names",function() return Config.ESP.Names end,function(v) Config.ESP.Names=v end)
    addToggle(s,"Distance",function() return Config.ESP.Distance end,function(v) Config.ESP.Distance=v end)
    addToggle(s,"Health bars",function() return Config.ESP.Health end,function(v) Config.ESP.Health=v end)
    addToggle(s,"Show teammates",function() return Config.ESP.ShowTeam end,function(v) Config.ESP.ShowTeam=v end)

    s=section(espPage,"Rendering","4")
    addDropdown(s,"Tracer origin",{"Bottom","Center","Top"},function() return Config.ESP.TracerOrigin end,function(v) Config.ESP.TracerOrigin=v end)
    addSlider(s,"Max distance",100,5000,function() return Config.ESP.MaxDistance end,function(v) Config.ESP.MaxDistance=v end," st")
    addSlider(s,"Line thickness",1,4,function() return Config.ESP.Thickness end,function(v) Config.ESP.Thickness=v end,"")
    addSlider(s,"Opacity",20,100,function() return Config.ESP.Opacity end,function(v) Config.ESP.Opacity=v end,"%")

    s=section(espPage,"Colours","2")
    addColor(s,"Enemy colour",function() return Config.ESP.EnemyColor end,function(v) Config.ESP.EnemyColor=v end)
    addColor(s,"Team colour",function() return Config.ESP.TeamColor end,function(v) Config.ESP.TeamColor=v end)

    ----------------------------------------------------------------------------
    s=section(crossPage,"Rotating pinwheel","9")
    addToggle(s,"Enabled",function() return Config.Crosshair.Enabled end,function(v) Config.Crosshair.Enabled=v end)
    addToggle(s,"Center dot",function() return Config.Crosshair.CenterDot end,function(v) Config.Crosshair.CenterDot=v end)
    addDropdown(s,"Direction",{"Clockwise","Counterclockwise"},function() return Config.Crosshair.Direction end,function(v) Config.Crosshair.Direction=v end)
    addSlider(s,"Rotation speed",0,360,function() return Config.Crosshair.Speed end,function(v) Config.Crosshair.Speed=v end,"\u{00B0}")
    addSlider(s,"Center gap",0,20,function() return Config.Crosshair.Gap end,function(v) Config.Crosshair.Gap=v end," px")
    addSlider(s,"Arm length",5,35,function() return Config.Crosshair.ArmLength end,function(v) Config.Crosshair.ArmLength=v end," px")
    addSlider(s,"Bend length",2,25,function() return Config.Crosshair.BendLength end,function(v) Config.Crosshair.BendLength=v end," px")
    addSlider(s,"Thickness",1,5,function() return Config.Crosshair.Thickness end,function(v) Config.Crosshair.Thickness=v end,"")
    addColor(s,"Crosshair colour",function() return Config.Crosshair.Color end,function(v) Config.Crosshair.Color=v end)

    ----------------------------------------------------------------------------
    local weaponsFolder=Dax.Features.Weapons and Dax.Features.Weapons.Folder
    s=section(weaponsPage,"Gun mods","2")
    note(s,weaponsFolder and "Arsenal weapon database detected" or "Weapon database not found",weaponsFolder and "ok" or "warn")
    addToggle(s,"No spread",function() return Config.Weapons.NoSpread end,function(v)
        Config.Weapons.NoSpread=v
        Dax.Features.Weapons.sync()
        UI.notify(v and "Spread disabled" or "Spread restored",v and "ok" or nil)
    end,"writes Spread = 0 on every gun module")
    addToggle(s,"No recoil",function() return Config.Weapons.NoRecoil end,function(v)
        Config.Weapons.NoRecoil=v
        Dax.Features.Weapons.sync()
        UI.notify(v and "Recoil disabled" or "Recoil restored",v and "ok" or nil)
    end)

    ----------------------------------------------------------------------------
    s=section(settingsPage,"Interface","5")
    addKeybind(s,"Menu key",function() return Config.UI.MenuKey end,function(v) Config.UI.MenuKey=v end,"RightShift")
    addKeybind(s,"Panic key",function() return Config.UI.PanicKey end,function(v) Config.UI.PanicKey=v end,"End","unloads everything instantly")
    addToggle(s,"Notifications",function() return Config.UI.Notifications end,function(v) Config.UI.Notifications=v end)
    addSlider(s,"UI scale",75,130,function() return Config.UI.Scale end,function(v)
        Config.UI.Scale=v
        UI.GuiScale.Scale=v/100
    end,"%")
    addColor(s,"Accent colour",function() return Config.UI.Accent end,function(v)
        Config.UI.Accent=v
        UI.applyTheme()
    end)

    s=section(settingsPage,"Session")
    addButton(s,"Unload everything",function() App:Unload() end,"danger")

    ----------------------------------------------------------------------------
    local function sanitizeName(n)
        n=tostring(n or ""):gsub("[^%w_%-]",""):sub(1,32)
        return n=="" and "default" or n
    end

    local profileSection=section(profilePage,"Profiles","4")
    local persistenceLabel=note(profileSection,"Persistent JSON storage: available","ok")
    note(profileSection,"Settings auto-save when you leave the game")
    if not Dax.Persistent then
        persistenceLabel.Text="Persistent JSON storage unavailable \u{2014} session only"
        persistenceLabel.TextColor3=UI.Theme.Warn
    end

    local _,pickerRefresh=addDropdown(profileSection,"Saved profile",Dax.listSavedProfiles,
        function()
            local options=Dax.listSavedProfiles()
            local current=sanitizeName(App.Profile)
            if not table.find(options,current) then
                current=options[1]
                App.Profile=current
            end
            return current
        end,
        function(v)
            App.Profile=sanitizeName(v)
            Dax.loadProfileByName(App.Profile)
        end)

    function UI.refreshProfilePicker()
        if pickerRefresh then pcall(pickerRefresh) end
    end

    addButton(profileSection,"Save current profile",Dax.saveProfile)
    addButton(profileSection,"Create new profile",Dax.createProfile,"ghost")
    addButton(profileSection,"Reset defaults",Dax.resetProfile,"danger")

    ----------------------------------------------------------------------------
    Dax.RestoredFrom=Dax.loadAutosaveOrLast()
    UI.refreshProfilePicker()
    UI.showTab("Combat")
end
