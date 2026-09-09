return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local LP=Dax.LP
    local Players=Dax.Services.Players
    local Workspace=Dax.Services.Workspace
    local UIS=Dax.Services.UIS
    local function validEnemy(p)
        if p==LP then return false end
        if Config.Combat.TeamCheck and LP.Team and p.Team==LP.Team then return false end
        return Dax.isPlayerAlive(p)
    end
    local function visibleTo(p,part)
        if not Config.Combat.WallCheck then return true end
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances={LP.Character}
        params.IgnoreWater=true
        local hit=Workspace:Raycast(Dax.Camera.CFrame.Position,part.Position-Dax.Camera.CFrame.Position,params)
        return hit==nil or (p.Character and hit.Instance:IsDescendantOf(p.Character))
    end
    local function acquire()
        local mouse=UIS:GetMouseLocation()
        local best,bestD=nil,Config.Combat.FOV
        for _,p in ipairs(Players:GetPlayers()) do
            if validEnemy(p) then
                local part=p.Character and p.Character:FindFirstChild(Config.Combat.TargetPart)
                if part then
                    local sp,on=Dax.project(part.Position)
                    if on then
                        local d=(sp-mouse).Magnitude
                        if d<bestD and visibleTo(p,part) then best,bestD=p,d end
                    end
                end
            end
        end
        return best
    end
    Dax.Features.Aimbot={
        validEnemy=validEnemy,
        visibleTo=visibleTo,
        acquire=acquire,
        FOV=Dax.draw("Circle",{Visible=false,Filled=false,Color=Dax.c3(Config.UI.Accent),Thickness=1,Transparency=.8,NumSides=64,Radius=Config.Combat.FOV}),
    }
    function Dax.Features.Aimbot.update(dt)
        local mouse=UIS:GetMouseLocation()
        local fov=Dax.Features.Aimbot.FOV
        fov.Position=mouse
        fov.Radius=Config.Combat.FOV
        fov.Color=Dax.c3(Config.UI.Accent)
        fov.Visible=Config.Combat.Enabled and Config.Combat.ShowFOV
        if Config.Combat.Enabled and App.Aiming then
            if App.Target and not validEnemy(App.Target) then App.Target=nil end
            if not App.Target or not Config.Combat.LockTarget then App.Target=acquire() end
            local part=App.Target and App.Target.Character and App.Target.Character:FindFirstChild(Config.Combat.TargetPart)
            if App.Target and part and validEnemy(App.Target) and visibleTo(App.Target,part) then
                local goal=CFrame.lookAt(Dax.Camera.CFrame.Position,part.Position)
                local smooth=Config.Combat.Smoothness/100
                Dax.Camera.CFrame=smooth<=0 and goal or Dax.Camera.CFrame:Lerp(goal,1-math.pow(1-math.clamp(smooth,.01,.95),dt*60))
            else
                App.Target=nil
            end
        elseif App.Target then
            App.Target=nil
        end
    end
end
