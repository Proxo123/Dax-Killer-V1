return function(Dax)
    local TweenService=Dax.Services.TweenService
    local App=Dax.App
    local UI=Dax.UI

    UI.Theme={
        Void=Color3.fromRGB(10,11,15),
        Panel=Color3.fromRGB(18,20,26),
        Raise=Color3.fromRGB(24,27,35),
        Row=Color3.fromRGB(28,32,41),
        RowHover=Color3.fromRGB(35,40,51),
        Control=Color3.fromRGB(42,47,59),
        Line=Color3.fromRGB(38,42,53),
        LineSoft=Color3.fromRGB(30,34,43),
        Text=Color3.fromRGB(232,234,240),
        TextSoft=Color3.fromRGB(213,217,227),
        Dim=Color3.fromRGB(142,147,163),
        Faint=Color3.fromRGB(90,95,110),
        Knob=Color3.fromRGB(185,191,206),
        KnobHover=Color3.fromRGB(210,215,227),
        Success=Color3.fromRGB(61,214,140),
        Warn=Color3.fromRGB(255,184,77),
        Danger=Color3.fromRGB(255,77,94),
        White=Color3.fromRGB(255,255,255),
        Black=Color3.fromRGB(0,0,0),
    }

    UI.Radius={Window=14,Card=11,Row=8,Control=7,Pill=64}

    UI.Motion={
        Fast=.12,
        Base=.18,
        Slow=.26,
        Ease=Enum.EasingStyle.Quad,
        Smooth=Enum.EasingStyle.Quint,
        Spring=Enum.EasingStyle.Back,
        Dir=Enum.EasingDirection.Out,
    }

    UI.Font={
        Body=Enum.Font.GothamMedium,
        Strong=Enum.Font.GothamBold,
        Heavy=Enum.Font.GothamBlack,
        Mono=Enum.Font.Code,
    }

    local T=UI.Theme

    function UI.accent()
        local a=Dax.Config.UI.Accent
        return Color3.fromRGB(a[1] or 124,a[2] or 92,a[3] or 255)
    end

    -- Gradient partner for the accent. Derived rather than fixed so the two-stop
    -- look survives whatever colour the user picks.
    function UI.accent2()
        local h,s=Color3.toHSV(UI.accent())
        return Color3.fromHSV((h-.17)%1,math.clamp(s+.12,0,1),1)
    end

    function UI.mix(a,b,t) return a:Lerp(b,t) end
    function UI.onVoid(c,t) return c:Lerp(T.Void,t or .5) end

    -- Every accent-tinted property registers a painter here instead of baking the
    -- colour in at build time, so changing the accent repaints the whole menu.
    local painters={}

    function UI.onAccent(fn)
        table.insert(painters,fn)
        pcall(fn,UI.accent(),UI.accent2())
        return fn
    end

    function UI.paint(obj,prop,map)
        return UI.onAccent(function(a,b)
            if obj and obj.Parent then obj[prop]=map and map(a,b) or a end
        end)
    end

    function UI.applyTheme()
        local a,b=UI.accent(),UI.accent2()
        for i=#painters,1,-1 do
            if not pcall(painters[i],a,b) then table.remove(painters,i) end
        end
        Dax.refreshAll()
    end

    App.RefreshTheme=UI.applyTheme

    function UI.tween(obj,props,dur,style,dir)
        local info=TweenInfo.new(dur or UI.Motion.Base,style or UI.Motion.Ease,dir or UI.Motion.Dir)
        local tw=TweenService:Create(obj,info,props)
        tw:Play()
        return tw
    end

    -- Ambient motion runs entirely on the engine. An infinite tween costs no Lua
    -- per frame, unlike the RenderStepped starfield this replaces.
    function UI.loop(obj,props,dur,style,reverses,delay)
        local info=TweenInfo.new(dur,style or Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,reverses and true or false,delay or 0)
        local tw=TweenService:Create(obj,info,props)
        tw:Play()
        return tw
    end
end
