return function(Dax)
    Dax.Features.ESP={}
    local App=Dax.App
    local Config=Dax.Config
    local LP=Dax.LP
    local Players=Dax.Services.Players
    local Camera=Dax.Camera
    local skeletonPairs={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
    local bodyNames={"Head","UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftFoot","RightFoot"}
    local function makeESP(player)
        if player==LP or App.ESPObjects[player] then return end
        local d={BoxO=Dax.draw("Square",{Visible=false,Filled=false,Color=Color3.new(),Thickness=3}),Box=Dax.draw("Square",{Visible=false,Filled=false,Color=Color3.new(1,1,1),Thickness=1}),HealthO=Dax.draw("Square",{Visible=false,Filled=true,Color=Color3.new()}),Health=Dax.draw("Square",{Visible=false,Filled=true,Color=Color3.new(0,1,0)}),Name=Dax.draw("Text",{Visible=false,Center=true,Outline=true,Size=14,Font=2}),Info=Dax.draw("Text",{Visible=false,Center=true,Outline=true,Size=13,Font=2}),TracerO=Dax.draw("Line",{Visible=false,Color=Color3.new(),Thickness=3}),Tracer=Dax.draw("Line",{Visible=false,Thickness=1}),Skeleton={}}
        for i=1,#skeletonPairs do d.Skeleton[i]={O=Dax.draw("Line",{Visible=false,Color=Color3.new(),Thickness=3}),L=Dax.draw("Line",{Visible=false,Thickness=1})} end
        App.ESPObjects[player]=d
    end
    local function hideESP(d)
        for k,v in pairs(d) do
            if k=="Skeleton" then for _,s2 in ipairs(v) do s2.O.Visible=false s2.L.Visible=false end
            else v.Visible=false end
        end
    end
    local function destroyESP(player)
        local d=App.ESPObjects[player]
        if not d then return end
        hideESP(d)
        for k,v in pairs(d) do
            if k=="Skeleton" then for _,s2 in ipairs(v) do Dax.removeDraw(s2.O) Dax.removeDraw(s2.L) end
            else Dax.removeDraw(v) end
        end
        App.ESPObjects[player]=nil
    end
    local function bounds(char)
        local pts={}
        for _,n in ipairs(bodyNames) do
            local part=char:FindFirstChild(n)
            if part then
                local p,on=Dax.project(part.Position)
                if on then table.insert(pts,p) end
            end
        end
        if #pts<5 then return end
        local x1,y1,x2,y2=math.huge,math.huge,-math.huge,-math.huge
        for _,p in ipairs(pts) do x1=math.min(x1,p.X) y1=math.min(y1,p.Y) x2=math.max(x2,p.X) y2=math.max(y2,p.Y) end
        local h=y2-y1
        local px=math.max(4,h*.12)
        local py=math.max(4,h*.08)
        return Vector2.new(x1-px,y1-py),Vector2.new(x2-x1+px*2,h+py*2)
    end
    function Dax.Features.ESP.update(player,d)
        if not Config.ESP.Enabled then hideESP(d) return end
        local char=player.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        local root=char and char:FindFirstChild("HumanoidRootPart")
        if not Dax.isPlayerAlive(player) then hideESP(d) return end
        local health,maxHealth=Dax.getPlayerHealth(player,hum)
        local same=LP.Team~=nil and player.Team==LP.Team
        if same and not Config.ESP.ShowTeam then hideESP(d) return end
        local _,on=Dax.project(root.Position)
        local dist=(Camera.CFrame.Position-root.Position).Magnitude
        if not on or dist>Config.ESP.MaxDistance then hideESP(d) return end
        local pos,size=bounds(char)
        if not pos then hideESP(d) return end
        local color=Dax.c3(same and Config.ESP.TeamColor or Config.ESP.EnemyColor)
        local alpha=Config.ESP.Opacity/100
        local thick=Config.ESP.Thickness
        d.BoxO.Position=pos d.BoxO.Size=size d.BoxO.Thickness=thick+2 d.BoxO.Transparency=alpha*.85 d.BoxO.Visible=Config.ESP.Boxes
        d.Box.Position=pos d.Box.Size=size d.Box.Color=color d.Box.Thickness=thick d.Box.Transparency=alpha d.Box.Visible=Config.ESP.Boxes
        local displayHealth=math.max(0,health)
        local ratio=math.clamp(displayHealth/math.max(maxHealth,1),0,1)
        local bx=pos.X-8
        d.HealthO.Position=Vector2.new(bx-1,pos.Y-1) d.HealthO.Size=Vector2.new(6,size.Y+2) d.HealthO.Transparency=alpha*.85 d.HealthO.Visible=Config.ESP.Health
        d.Health.Position=Vector2.new(bx,pos.Y+size.Y*(1-ratio)) d.Health.Size=Vector2.new(4,math.max(2,size.Y*ratio)) d.Health.Color=Color3.fromRGB(255*(1-ratio),255*ratio,70) d.Health.Transparency=alpha d.Health.Visible=Config.ESP.Health
        local nameText=player.DisplayName
        if Config.ESP.Health then nameText=nameText.."  "..Dax.formatHealth(health).." HP" end
        d.Name.Text=nameText d.Name.Position=Vector2.new(pos.X+size.X/2,pos.Y-17) d.Name.Color=color d.Name.Transparency=alpha d.Name.Visible=Config.ESP.Names or Config.ESP.Health
        local infos={}
        if Config.ESP.Distance then table.insert(infos,tostring(math.floor(dist/3.571)).."m") end
        if Config.ESP.Health and not Config.ESP.Names then table.insert(infos,Dax.formatHealth(health).." HP") end
        d.Info.Text=table.concat(infos,"  •  ") d.Info.Position=Vector2.new(pos.X+size.X/2,pos.Y+size.Y+3) d.Info.Color=Color3.fromRGB(225,228,238) d.Info.Transparency=alpha d.Info.Visible=#infos>0
        local origin=Config.ESP.TracerOrigin=="Top" and Vector2.new(Camera.ViewportSize.X/2,0) or (Config.ESP.TracerOrigin=="Center" and Camera.ViewportSize/2 or Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y-2))
        local target=Vector2.new(pos.X+size.X/2,pos.Y+size.Y)
        d.TracerO.From=origin d.TracerO.To=target d.TracerO.Thickness=thick+2 d.TracerO.Transparency=alpha*.8 d.TracerO.Visible=Config.ESP.Tracers
        d.Tracer.From=origin d.Tracer.To=target d.Tracer.Color=color d.Tracer.Thickness=thick d.Tracer.Transparency=alpha d.Tracer.Visible=Config.ESP.Tracers
        for i,pair in ipairs(skeletonPairs) do
            local a,b=char:FindFirstChild(pair[1]),char:FindFirstChild(pair[2])
            local seg=d.Skeleton[i]
            if Config.ESP.Skeletons and a and b then
                local pa,oa=Dax.project(a.Position)
                local pb,ob=Dax.project(b.Position)
                if oa and ob then
                    seg.O.From=pa seg.O.To=pb seg.O.Thickness=thick+2 seg.O.Transparency=alpha*.8 seg.O.Visible=true
                    seg.L.From=pa seg.L.To=pb seg.L.Color=color seg.L.Thickness=thick seg.L.Transparency=alpha seg.L.Visible=true
                else seg.O.Visible=false seg.L.Visible=false end
            else seg.O.Visible=false seg.L.Visible=false end
        end
    end
    for _,p in ipairs(Players:GetPlayers()) do Dax.trackPlayerHealth(p) makeESP(p) end
    Dax.bind(Players.PlayerAdded,function(p) Dax.trackPlayerHealth(p) makeESP(p) end)
    Dax.bind(Players.PlayerRemoving,function(p) destroyESP(p) end)
end
