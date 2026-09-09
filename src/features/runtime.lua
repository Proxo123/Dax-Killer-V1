return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local RunService=Dax.Services.RunService
    local UIS=Dax.Services.UIS
    local Workspace=Dax.Services.Workspace
    local env=Dax.env
    Dax.bind(UIS.InputBegan,function(input,processed)
        if Dax.keyMatches(input,Config.UI.PanicKey) then App:Unload() return end
        if Dax.keyMatches(input,Config.UI.MenuKey) then
            local w=Dax.UI.Window
            if w then w.Visible=not w.Visible end
            return
        end
        if not processed and Dax.keyMatches(input,Config.Combat.AimKey) then App.Aiming=true end
    end)
    Dax.bind(UIS.InputEnded,function(input)
        if Dax.keyMatches(input,Config.Combat.AimKey) then App.Aiming=false App.Target=nil end
    end)
    Dax.bind(RunService.RenderStepped,function(dt)
        if not App.Alive then return end
        local ok,err=pcall(function()
            Dax.Camera=Workspace.CurrentCamera or Dax.Camera
            for p,d in pairs(App.ESPObjects) do Dax.Features.ESP.update(p,d) end
            if Dax.Features.Aimbot and Dax.Features.Aimbot.update then Dax.Features.Aimbot.update(dt) end
            if Dax.Features.Triggerbot and Dax.Features.Triggerbot.update then Dax.Features.Triggerbot.update() end
            if Dax.Features.Crosshair and Dax.Features.Crosshair.update then Dax.Features.Crosshair.update(dt) end
        end)
        if not ok and not App.RenderErr then App.RenderErr=true warn("[DaxKiller] "..tostring(err)) end
    end)
    function App:Unload()
        if not self.Alive then return end
        Dax.saveOnLeave()
        self.Alive=false
        if Dax.Features.Weapons and Dax.Features.Weapons.restore then Dax.Features.Weapons.restore() end
        local mods=Dax.Features.Weapons and Dax.Features.Weapons.Mods
        if mods then
            for _,c in ipairs(mods.Connections) do pcall(function() c:Disconnect() end) end
            mods.Connections={}
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
    Dax.bind(Dax.Services.Players.PlayerRemoving,function(player)
        if player==Dax.LP then Dax.saveOnLeave() end
    end)
    if game.BindToClose then pcall(function() game:BindToClose(function() Dax.saveOnLeave() end) end) end
end
