return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local LP=Dax.LP
    local Players=Dax.Services.Players
    local Workspace=Dax.Services.Workspace
    local UIS=Dax.Services.UIS
    local VIM=game:GetService("VirtualInputManager")
    local lastFire=0
    local function onEnemy()
        local cam=Dax.Camera
        if not cam then return false end
        local ray=cam:ViewportPointToRay(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances={LP.Character}
        params.IgnoreWater=true
        local hit=Workspace:Raycast(ray.Origin,ray.Direction*1200,params)
        if not hit then return false end
        local model=hit.Instance:FindFirstAncestorOfClass("Model")
        if not model then return false end
        local player=Players:GetPlayerFromCharacter(model)
        if not player then return false end
        local aim=Dax.Features.Aimbot
        if aim and aim.validEnemy then return aim.validEnemy(player) end
        return player~=LP
    end
    local function click()
        if mouse1click then
            mouse1click()
            return
        end
        local pos=UIS:GetMouseLocation()
        VIM:SendMouseButtonEvent(pos.X,pos.Y,0,true,game,1)
        task.defer(function() VIM:SendMouseButtonEvent(pos.X,pos.Y,0,false,game,1) end)
    end
    function Dax.Features.Triggerbot.update()
        if not Config.Combat.Triggerbot or not App.Alive then return end
        local menu=Dax.UI.Window
        if menu and menu.Visible then return end
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
        if not onEnemy() then return end
        local now=tick()
        if now-lastFire<Config.Combat.TriggerDelay then return end
        lastFire=now
        click()
    end
end
