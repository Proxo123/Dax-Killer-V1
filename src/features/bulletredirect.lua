return function(Dax)
    local Config=Dax.Config
    local LP=Dax.LP
    local Players=Dax.Services.Players
    local Workspace=Dax.Services.Workspace
    local UIS=Dax.Services.UIS
    local RS=Dax.Services.ReplicatedStorage
    local Camera=Dax.Camera
    local State={oldNC=nil}
    local ShootNames={HitPart=true,Fire=true,Trail=true,CreateProjectile=true,ReplicateProjectile=true,["###zzz###"]=true}
    local function readVec3(buf,off)
        return Vector3.new(buffer.readf32(buf,off),buffer.readf32(buf,off+4),buffer.readf32(buf,off+8))
    end
    local function writeVec3(buf,off,v)
        buffer.writef32(buf,off,v.X)
        buffer.writef32(buf,off+4,v.Y)
        buffer.writef32(buf,off+8,v.Z)
    end
    local function plausiblePos(v)
        if v.X~=v.X or v.Y~=v.Y or v.Z~=v.Z then return false end
        if math.abs(v.X)>6000 or math.abs(v.Z)>6000 or v.Y<-400 or v.Y>1200 then return false end
        if math.abs(v.X)<0.05 and math.abs(v.Y)<0.05 and math.abs(v.Z)<0.05 then return false end
        return true
    end
    local function plausibleDir(v)
        local m=v.Magnitude
        return m>0.8 and m<1.2
    end
    local function validEnemy(p)
        if p==LP then return false end
        if Config.Combat.RedirectTeamCheck and LP.Team and p.Team==LP.Team then return false end
        return Dax.isPlayerAlive(p)
    end
    local function hitbox(char)
        return char and (char:FindFirstChild("Hitbox") or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
    end
    local function myPos()
        local char=LP.Character
        local head=char and char:FindFirstChild("Head")
        return head and head.Position or Camera.CFrame.Position
    end
    local function acquire()
        local origin=myPos()
        local best,bestD=nil,Config.Combat.RedirectMaxDist or 600
        for _,p in ipairs(Players:GetPlayers()) do
            if validEnemy(p) then
                local box=hitbox(p.Character)
                if box then
                    local d=(box.Position-origin).Magnitude
                    if d<bestD then best,bestD=box,d end
                end
            end
        end
        return best
    end
    local function analyze(buf,anchor)
        local len=buffer.len(buf)
        local positions={}
        local directions={}
        for off=0,len-12,4 do
            local v=readVec3(buf,off)
            if plausiblePos(v) then
                table.insert(positions,{off=off,v=v,dist=(v-anchor).Magnitude})
            elseif plausibleDir(v) then
                table.insert(directions,{off=off})
            end
        end
        table.sort(positions,function(a,b) return a.dist<b.dist end)
        local originOff=positions[1] and positions[1].off
        local origin=positions[1] and positions[1].v or anchor
        local hitOff=nil
        local hitDist=-1
        for _,item in ipairs(positions) do
            if item.off~=originOff then
                local d=(item.v-origin).Magnitude
                if d>hitDist then hitDist=d hitOff=item.off end
            end
        end
        if not hitOff and #positions>1 then hitOff=positions[#positions].off end
        return origin,hitOff,directions
    end
    local function redirectBuffer(buf,refs,box)
        if typeof(buf)~="buffer" or buffer.len(buf)<32 then return end
        local anchor=box.Position
        local origin,hitOff,directions=analyze(buf,anchor)
        local hitPos=box.Position
        local dir=hitPos-origin
        if dir.Magnitude<0.05 then dir=(hitPos-anchor).Unit else dir=dir.Unit end
        if hitOff then writeVec3(buf,hitOff,hitPos) end
        for _,item in ipairs(directions) do writeVec3(buf,item.off,dir) end
        if type(refs)=="table" then
            for i=#refs,1,-1 do
                local inst=refs[i]
                if typeof(inst)=="Instance" and inst:IsA("BasePart") and not inst:IsDescendantOf(LP.Character) then
                    refs[i]=box
                    break
                end
            end
        end
    end
    local function redirectArgs(name,args,box)
        local pos=box.Position
        if name=="HitPart" then
            args[1]=box
            if typeof(args[2])=="Vector3" then args[2]=pos end
            return true
        elseif name=="Fire" then
            args[1]=pos
            return true
        elseif name=="Trail" and type(args[1])=="table" then
            if type(args[1][5])=="string" then
                args[1][6]=box
                args[1][2]=pos
            end
            return true
        elseif name=="CreateProjectile" then
            args[3]=pos
            args[4]=box.CFrame
            args[10]=pos
            args[17]=pos
            args[18]=box
            args[19]=pos
            return true
        elseif name=="ReplicateProjectile" and type(args[1])=="table" then
            args[1][3]=pos
            args[1][4]=pos
            args[1][10]=pos
            return true
        end
        return false
    end
    local function onFire(self,args)
        if not Config.Combat.RedirectEnabled then return false end
        if checkcaller and checkcaller() then return false end
        local box=acquire()
        if not box then return false end
        local name=self.Name
        if name=="###zzz###" and typeof(args[1])=="buffer" then
            redirectBuffer(args[1],args[2],box)
            return true
        end
        if redirectArgs(name,args,box) then return true end
        if typeof(args[1])=="buffer" then
            redirectBuffer(args[1],args[2],box)
            return true
        end
        return false
    end
    local function unhook()
        if State.oldNC and hookmetamethod then
            pcall(function() hookmetamethod(game,"__namecall",State.oldNC) end)
        end
        State.oldNC=nil
    end
    local function install()
        unhook()
        if not hookmetamethod then return false end
        State.oldNC=hookmetamethod(game,"__namecall",function(self,...)
            local method=getnamecallmethod()
            if method~="FireServer" then return State.oldNC(self,...) end
            if checkcaller and checkcaller() then return State.oldNC(self,...) end
            if not (self:IsA("RemoteEvent") or self:IsA("UnreliableRemoteEvent")) then return State.oldNC(self,...) end
            local args={...}
            if not ShootNames[self.Name] and typeof(args[1])~="buffer" then return State.oldNC(self,...) end
            if onFire(self,args) then
                return self.FireServer(self,table.unpack(args))
            end
            return State.oldNC(self,...)
        end)
        return true
    end
    local ok=install()
    Dax.Features.Redirect={unhook=unhook,installed=ok}
end
