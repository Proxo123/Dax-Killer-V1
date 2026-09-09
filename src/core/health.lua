return function(Dax)
    local App=Dax.App
    local LP=Dax.LP
    local Players=Dax.Services.Players
    function Dax.trackPlayerHealth(player)
        if player==LP or App.HealthRefs[player] then return end
        local function bindNrpbs(nrpbs)
            if not nrpbs or App.HealthRefs[player] then return end
            task.spawn(function()
                local health=nrpbs:WaitForChild("Health",5)
                if not health or not health:IsA("ValueBase") or App.HealthRefs[player] then return end
                local maxHealth=nrpbs:FindFirstChild("MaxHealth") or nrpbs:FindFirstChild("OMaxHealth")
                App.HealthRefs[player]={Health=health,MaxHealth=maxHealth}
            end)
        end
        if player:FindFirstChild("NRPBS") then bindNrpbs(player.NRPBS) end
        Dax.bind(player.ChildAdded,function(child) if child.Name=="NRPBS" then bindNrpbs(child) end end)
    end
    function Dax.getPlayerHealth(player,hum)
        local refs=App.HealthRefs[player]
        if not refs then Dax.trackPlayerHealth(player) refs=App.HealthRefs[player] end
        if refs and refs.Health and refs.Health.Parent then
            local max=100
            if refs.MaxHealth and refs.MaxHealth:IsA("ValueBase") then max=refs.MaxHealth.Value end
            return refs.Health.Value,math.max(max,1)
        end
        local nrpbs=player:FindFirstChild("NRPBS")
        local health=nrpbs and nrpbs:FindFirstChild("Health")
        local maxHealth=nrpbs and (nrpbs:FindFirstChild("MaxHealth") or nrpbs:FindFirstChild("OMaxHealth"))
        if health and health:IsA("ValueBase") then
            local max=maxHealth and maxHealth:IsA("ValueBase") and maxHealth.Value or 100
            return health.Value,math.max(max,1)
        end
        if hum then return hum.Health,math.max(hum.MaxHealth,1) end
        return 0,100
    end
    function Dax.isPlayerAlive(player)
        local ch=player.Character
        local hum=ch and ch:FindFirstChildOfClass("Humanoid")
        local root=ch and ch:FindFirstChild("HumanoidRootPart")
        if not ch or not root then return false end
        local health=Dax.getPlayerHealth(player,hum)
        if health<=0 then return false end
        if ch:GetAttribute("DIED")==true or player:GetAttribute("DIED")==true then return false end
        if root.Position.Y<-100 then return false end
        local localRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if localRoot and root.Position.Y<localRoot.Position.Y-120 then return false end
        return true
    end
    function Dax.formatHealth(health) return tostring(math.max(0,math.floor(health+.5))) end
    Dax.bind(Players.PlayerRemoving,function(player) App.HealthRefs[player]=nil end)
end
