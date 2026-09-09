return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local Players=Dax.Services.Players
    local Workspace=Dax.Services.Workspace
    local LP=Dax.LP
    local bridge=Instance.new("ObjectValue")
    bridge.Name="SilentTarget"
    bridge:SetAttribute("Enabled",false)
    bridge:SetAttribute("Redirects",0)
    bridge.Parent=Dax.UI.Gui
    local tracerO=Dax.draw("Line",{Visible=false,Color=Color3.new(),Thickness=3,Transparency=.8})
    local tracer=Dax.draw("Line",{Visible=false,Color=Dax.c3(Config.UI.Accent),Thickness=1,Transparency=1})
    local function targetPart(player)
        local char=player.Character
        return char and (char:FindFirstChild("Hitbox") or char:FindFirstChild(Config.Combat.TargetPart) or char:FindFirstChild("Head"))
    end
    local function acquire()
        local camera=Dax.Camera
        if not camera then return nil end
        local center=camera.ViewportSize/2
        local best,bestDistance=nil,Config.Combat.FOV
        local aim=Dax.Features.Aimbot
        for _,player in ipairs(Players:GetPlayers()) do
            local valid=aim and aim.validEnemy and aim.validEnemy(player)
            if valid then
                local part=targetPart(player)
                if part then
                    local point,on=Dax.project(part.Position)
                    if on then
                        local distance=(point-center).Magnitude
                        local visible=not Config.Combat.WallCheck or (aim and aim.visibleTo and aim.visibleTo(player,part))
                        if visible and distance<bestDistance then
                            best=part
                            bestDistance=distance
                        end
                    end
                end
            end
        end
        return best
    end
    local actorSource=[=[
local env=getgenv()
local RS=game:GetService("ReplicatedStorage")
local CoreGui=game:GetService("CoreGui")
local remote=RS:FindFirstChild("###zzz###")
if not remote then return end
local state=env._UnnamedSilentAimActor
if not state then
    state={}
    env._UnnamedSilentAimActor=state
    local function findBridge()
        if state.Bridge and state.Bridge.Parent then return state.Bridge end
        local root=(type(gethui)=="function" and gethui()) or CoreGui
        local gui=root:FindFirstChild("UnnamedCheatsMenu",true)
        state.Bridge=gui and gui:FindFirstChild("SilentTarget")
        return state.Bridge
    end
    local function readVec3(buf,offset)
        return Vector3.new(buffer.readf32(buf,offset),buffer.readf32(buf,offset+4),buffer.readf32(buf,offset+8))
    end
    local function writeVec3(buf,offset,value)
        buffer.writef32(buf,offset,value.X)
        buffer.writef32(buf,offset+4,value.Y)
        buffer.writef32(buf,offset+8,value.Z)
    end
    local function writeCFrame(buf,offset,value)
        local components={value:GetComponents()}
        for i=1,12 do buffer.writef32(buf,offset+(i-1)*4,components[i]) end
    end
    local function cloneBuffer(source)
        local size=buffer.len(source)
        local copy=buffer.create(size)
        local ok=pcall(function() buffer.copy(copy,0,source,0,size) end)
        if not ok then
            for i=0,size-1 do buffer.writeu8(copy,i,buffer.readu8(source,i)) end
        end
        return copy
    end
    local function rewrite(source,target)
        local size=buffer.len(source)
        local cfOffset,hitOffset,firstHit,tailOrigin,tailHit
        if size==104 then
            cfOffset,hitOffset=40,88
        elseif size==130 then
            cfOffset,hitOffset,firstHit,tailOrigin,tailHit=40,88,9,106,118
        elseif size==131 then
            cfOffset,hitOffset,firstHit,tailOrigin,tailHit=41,89,11,107,119
        elseif size==144 then
            cfOffset,hitOffset,firstHit=40,88,9
        else
            return nil
        end
        local copy=cloneBuffer(source)
        local origin=readVec3(copy,cfOffset)
        local hit=target.Position
        if (hit-origin).Magnitude<.01 then return nil end
        writeCFrame(copy,cfOffset,CFrame.lookAt(origin,hit))
        writeVec3(copy,hitOffset,hit)
        if firstHit then writeVec3(copy,firstHit,hit) end
        if tailOrigin then writeVec3(copy,tailOrigin,origin) end
        if tailHit then writeVec3(copy,tailHit,hit) end
        return copy
    end
    state.OldFire=hookfunction(remote.FireServer,newcclosure(function(self,...)
        if self==remote then
            local bridge=findBridge()
            local target=bridge and bridge:GetAttribute("Enabled") and bridge.Value
            if target and target:IsA("BasePart") and target:IsDescendantOf(workspace) then
                local args=table.pack(...)
                local bufferIndex,refsIndex=nil,nil
                for i=1,args.n do
                    if typeof(args[i])=="buffer" then bufferIndex=i
                    elseif type(args[i])=="table" and typeof(args[i][4])=="Instance" then refsIndex=i end
                end
                if bufferIndex and refsIndex then
                    local ok,patched=pcall(rewrite,args[bufferIndex],target)
                    if ok and patched then
                        args[bufferIndex]=patched
                        local refs=table.clone(args[refsIndex])
                        refs[4]=target
                        args[refsIndex]=refs
                        bridge:SetAttribute("Redirects",(bridge:GetAttribute("Redirects") or 0)+1)
                        return state.OldFire(self,table.unpack(args,1,args.n))
                    end
                end
            end
        end
        return state.OldFire(self,...)
    end))
end
]=]
    local installed=0
    if type(getactors)=="function" and type(run_on_actor)=="function" then
        local ok,actors=pcall(getactors)
        if ok then
            for _,actor in ipairs(actors) do
                local success=pcall(run_on_actor,actor,actorSource)
                if success then installed+=1 end
            end
        end
    end
    local silent={Bridge=bridge,Tracer=tracer,TracerOutline=tracerO,Installed=installed}
    function silent.update()
        local enabled=Config.Combat.SilentAim and App.Alive
        local target=enabled and acquire() or nil
        App.SilentTarget=target
        bridge.Value=target
        bridge:SetAttribute("Enabled",enabled and target~=nil)
        local camera=Dax.Camera
        if enabled and Config.Combat.SilentTracer and target and camera then
            local point,on=Dax.project(target.Position)
            if on then
                local center=camera.ViewportSize/2
                tracerO.From=center
                tracerO.To=point
                tracerO.Visible=true
                tracer.From=center
                tracer.To=point
                tracer.Color=Dax.c3(Config.UI.Accent)
                tracer.Visible=true
                return
            end
        end
        tracerO.Visible=false
        tracer.Visible=false
    end
    Dax.Features.SilentAim=silent
end
