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
