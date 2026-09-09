return function(Dax)
    Dax.Features.Triggerbot={}
    local App=Dax.App
    local Config=Dax.Config
    local LP=Dax.LP
    local Players=Dax.Services.Players
    local Workspace=Dax.Services.Workspace
    local UIS=Dax.Services.UIS
    local targetSince=0
    local trackedTarget=nil
    local firedForTarget=false
    local clearSince=nil
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
    local function targetUnderCrosshair()
        local cam=Dax.Camera
        local char=LP.Character
        if not cam or not char then return false end
        local ray=cam:ViewportPointToRay(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances={char}
        params.IgnoreWater=true
        local hit=Workspace:Raycast(ray.Origin,ray.Direction*1200,params)
        if not hit then return nil end
        local player=playerFromHit(hit.Instance)
        if not player then return nil end
        local aim=Dax.Features.Aimbot
        if aim and aim.validEnemy and not aim.validEnemy(player) then return nil end
        if player==LP then return nil end
        return player
    end
    local function click()
        if mouse1press and mouse1release then
            task.spawn(function()
                local pressed=false
                local ok=pcall(function()
                    mouse1press()
                    pressed=true
                    task.wait(0.035)
                    mouse1release()
                    pressed=false
                end)
                if pressed then pcall(mouse1release) end
                if not ok then pcall(mouse1release) end
            end)
            return true
        end
        if mouse1click then
            task.spawn(function() pcall(mouse1click) end)
            return true
        end
        return false
    end
    function Dax.Features.Triggerbot.update()
        if not Config.Combat.Triggerbot or not App.Alive then
            trackedTarget=nil
            firedForTarget=false
            clearSince=nil
            return
        end
        local menu=Dax.UI.Window
        if menu and menu.Visible then return end
        if UIS:GetFocusedTextBox() then return end
        local target=targetUnderCrosshair()
        if not target then
            if trackedTarget then
                clearSince=clearSince or tick()
                if tick()-clearSince>=0.15 then
                    trackedTarget=nil
                    firedForTarget=false
                    clearSince=nil
                end
            end
            return
        end
        clearSince=nil
        if target~=trackedTarget then
            trackedTarget=target
            targetSince=tick()
            firedForTarget=false
        end
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            firedForTarget=true
            return
        end
        if firedForTarget then return end
        local now=tick()
        if now-targetSince<Config.Combat.TriggerDelay then return end
        firedForTarget=click()
    end
end
