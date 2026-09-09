return function(Dax)
    Dax.Features.Triggerbot={}
    local App=Dax.App
    local Config=Dax.Config
    local LP=Dax.LP
    local Players=Dax.Services.Players
    local Workspace=Dax.Services.Workspace
    local UIS=Dax.Services.UIS
    local lastFire=0
    local clickBusy=false
    local function playerFromHit(inst)
        if not inst then return nil end
        local model=inst:FindFirstAncestorOfClass("Model")
        if model then
            local player=Players:GetPlayerFromCharacter(model)
            if player then return player end
        end
        for _,player in ipairs(Players:GetPlayers()) do
            if player.Character and inst:IsDescendantOf(player.Character) then return player end
        end
        return nil
    end
    local function onEnemy()
        local cam=Dax.Camera
        local char=LP.Character
        if not cam or not char then return false end
        local ray=cam:ViewportPointToRay(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances={char}
        params.IgnoreWater=true
        local hit=Workspace:Raycast(ray.Origin,ray.Direction*1200,params)
        if not hit then return false end
        local player=playerFromHit(hit.Instance)
        if not player then return false end
        local aim=Dax.Features.Aimbot
        if aim and aim.validEnemy then return aim.validEnemy(player) end
        return player~=LP
    end
    local function releaseBusy(delay)
        task.delay(delay or Config.Combat.TriggerDelay,function() clickBusy=false end)
    end
    local function click()
        if clickBusy then return end
        clickBusy=true
        local char=LP.Character
        local tool=char and char:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
            releaseBusy()
            return
        end
        if mouse1click then
            mouse1click()
            releaseBusy(0.05)
            return
        end
        if mouse1press and mouse1release then
            mouse1press()
            task.delay(0.03,function()
                mouse1release()
                clickBusy=false
            end)
            return
        end
        clickBusy=false
    end
    function Dax.Features.Triggerbot.update()
        if not Config.Combat.Triggerbot or not App.Alive then return end
        local menu=Dax.UI.Window
        if menu and menu.Visible then return end
        if UIS:GetFocusedTextBox() then return end
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
        if clickBusy then return end
        if not onEnemy() then return end
        local now=tick()
        if now-lastFire<Config.Combat.TriggerDelay then return end
        lastFire=now
        click()
    end
end
