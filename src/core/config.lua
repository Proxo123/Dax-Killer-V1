return function(Dax)
    local Config={
        UI={MenuKey="Insert",PanicKey="End",Scale=100,Notifications=true,Accent={125,92,255}},
        Combat={Enabled=true,AimKey="MouseButton2",TeamCheck=true,WallCheck=true,TargetPart="Head",FOV=200,Smoothness=12,LockTarget=true,ShowFOV=true,Triggerbot=false,TriggerDelay=0.08},
        ESP={Enabled=true,Boxes=true,Skeletons=true,Tracers=true,Names=true,Distance=true,Health=true,ShowTeam=true,MaxDistance=2500,Thickness=1,Opacity=95,TracerOrigin="Bottom",EnemyColor={255,74,92},TeamColor={70,180,255}},
        Crosshair={Enabled=true,Color={255,255,255},Gap=5,ArmLength=15,BendLength=9,Thickness=2,Speed=120,Direction="Clockwise",CenterDot=false},
        Weapons={NoSpread=false,NoRecoil=false}
    }
    Dax.Config=Config
    Dax.App.Config=Config
    function Dax.deepCopy(t)
        local n={}
        for k,v in pairs(t) do n[k]=type(v)=="table" and Dax.deepCopy(v) or v end
        return n
    end
    Dax.Defaults=Dax.deepCopy(Config)
    function Dax.mergeValid(dst,src)
        if type(src)~="table" then return end
        for k,v in pairs(src) do
            if dst[k]~=nil then
                if type(dst[k])=="table" and type(v)=="table" then Dax.mergeValid(dst[k],v)
                elseif type(dst[k])==type(v) then dst[k]=v end
            end
        end
    end
    function Dax.normalize()
        local Config=Dax.Config
        Config.UI.Scale=math.clamp(Config.UI.Scale,75,130)
        Config.Combat.FOV=math.clamp(Config.Combat.FOV,30,600)
        Config.Combat.Smoothness=math.clamp(Config.Combat.Smoothness,0,100)
        Config.Combat.TriggerDelay=math.clamp(Config.Combat.TriggerDelay,0.02,0.5)
        Config.ESP.MaxDistance=math.clamp(Config.ESP.MaxDistance,100,5000)
        Config.ESP.Thickness=math.clamp(Config.ESP.Thickness,1,4)
        Config.ESP.Opacity=math.clamp(Config.ESP.Opacity,20,100)
        Config.Crosshair.Speed=math.clamp(Config.Crosshair.Speed,0,360)
        Config.Crosshair.Gap=math.clamp(Config.Crosshair.Gap,0,20)
        Config.Crosshair.ArmLength=math.clamp(Config.Crosshair.ArmLength,5,35)
        Config.Crosshair.BendLength=math.clamp(Config.Crosshair.BendLength,2,25)
        Config.Crosshair.Thickness=math.clamp(Config.Crosshair.Thickness,1,5)
    end
end
