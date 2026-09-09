return function(Dax)
    local Config=Dax.Config
    local cross={Angle=0,Arms={},AO={},Bends={},BO={}}
    for i=1,4 do
        cross.AO[i]=Dax.draw("Line",{Visible=false,Color=Color3.new(),Thickness=4})
        cross.Arms[i]=Dax.draw("Line",{Visible=false,Thickness=2})
        cross.BO[i]=Dax.draw("Line",{Visible=false,Color=Color3.new(),Thickness=4})
        cross.Bends[i]=Dax.draw("Line",{Visible=false,Thickness=2})
    end
    cross.DotO=Dax.draw("Circle",{Visible=false,Filled=true,Color=Color3.new(),Radius=3,NumSides=20})
    cross.Dot=Dax.draw("Circle",{Visible=false,Filled=true,Color=Color3.new(1,1,1),Radius=1.5,NumSides=20})
    function cross.update(dt)
        local enabled=Config.Crosshair.Enabled
        local col=Dax.c3(Config.Crosshair.Color)
        local center=Dax.Camera.ViewportSize/2
        local sign=Config.Crosshair.Direction=="Clockwise" and 1 or -1
        cross.Angle=(cross.Angle+Config.Crosshair.Speed*dt*sign)%360
        for i=1,4 do
            local a=math.rad(cross.Angle+(i-1)*90)
            local dir=Vector2.new(math.cos(a),math.sin(a))
            local side=Vector2.new(-dir.Y,dir.X)*sign
            local p1=center+dir*Config.Crosshair.Gap
            local p2=center+dir*(Config.Crosshair.Gap+Config.Crosshair.ArmLength)
            local p3=p2+side*Config.Crosshair.BendLength
            local ao,arm,bo,bend=cross.AO[i],cross.Arms[i],cross.BO[i],cross.Bends[i]
            ao.From=p1 ao.To=p2 ao.Thickness=Config.Crosshair.Thickness+2 ao.Visible=enabled
            arm.From=p1 arm.To=p2 arm.Color=col arm.Thickness=Config.Crosshair.Thickness arm.Visible=enabled
            bo.From=p2 bo.To=p3 bo.Thickness=Config.Crosshair.Thickness+2 bo.Visible=enabled
            bend.From=p2 bend.To=p3 bend.Color=col bend.Thickness=Config.Crosshair.Thickness bend.Visible=enabled
        end
        cross.DotO.Position=center cross.DotO.Visible=enabled and Config.Crosshair.CenterDot
        cross.Dot.Position=center cross.Dot.Color=col cross.Dot.Visible=enabled and Config.Crosshair.CenterDot
    end
    Dax.Features.Crosshair=cross
end
