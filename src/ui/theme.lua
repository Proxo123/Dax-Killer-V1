return function(Dax)
    local TweenService=Dax.Services.TweenService
    Dax.UI.Theme={
        BG=Color3.fromRGB(8,8,14),
        Panel=Color3.fromRGB(14,14,22),
        Card=Color3.fromRGB(18,18,28),
        Stroke=Color3.fromRGB(45,40,70),
        Text=Color3.fromRGB(235,235,245),
        Dim=Color3.fromRGB(120,115,140),
        Accent=Color3.fromRGB(125,92,255),
        Accent2=Color3.fromRGB(255,74,140),
        Success=Color3.fromRGB(70,220,140),
        Danger=Color3.fromRGB(255,70,90),
    }
    function Dax.UI.accent()
        local a=Dax.Config.UI.Accent
        return Color3.fromRGB(a[1],a[2],a[3])
    end
    function Dax.UI.tween(obj,props,t,delay)
        local info=TweenInfo.new(t or .2,delay and Enum.EasingStyle.Back or Enum.EasingStyle.Quad,delay and Enum.EasingDirection.Out or Enum.EasingDirection.Out)
        local tw=TweenService:Create(obj,info,props)
        tw:Play()
        return tw
    end
end
