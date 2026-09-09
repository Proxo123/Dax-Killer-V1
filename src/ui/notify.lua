return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local UI=Dax.UI
    local T=UI.Theme
    local inst=UI.new

    -- Screen level rather than inside the window, so notifications still appear
    -- while the menu is closed (load, unload, profile saves).
    local holder=inst("Frame",{
        Name="Toasts",
        BackgroundTransparency=1,
        AnchorPoint=Vector2.new(1,1),
        Position=UDim2.new(1,-16,1,-16),
        Size=UDim2.fromOffset(250,320),
        ZIndex=40,
    },UI.Gui)
    inst("UIListLayout",{
        Padding=UDim.new(0,7),
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,
        SortOrder=Enum.SortOrder.LayoutOrder,
    },holder)

    local KINDS={ok=T.Success,warn=T.Warn,bad=T.Danger,err=T.Danger}

    function UI.notify(text,kind)
        if not Config.UI.Notifications or not App.Alive then return end

        -- A UIListLayout owns its children's Position, so the slide has to happen
        -- on a card inside a wrapper the layout controls. The old code tweened the
        -- laid-out frame directly, which did nothing at all.
        local slot=inst("Frame",{BackgroundTransparency=1,ClipsDescendants=true,Size=UDim2.fromOffset(244,0),ZIndex=40},holder)
        local card=inst("Frame",{BackgroundColor3=T.Raise,BackgroundTransparency=.02,BorderSizePixel=0,Size=UDim2.fromOffset(244,42),Position=UDim2.fromOffset(28,0),ZIndex=41},slot)
        UI.corner(card,UI.Radius.Row)
        local cardStroke=UI.stroke(card,T.Line,1,.1)

        local bar=inst("Frame",{BackgroundColor3=KINDS[kind] or T.White,BorderSizePixel=0,AnchorPoint=Vector2.new(0,.5),Size=UDim2.fromOffset(3,18),Position=UDim2.new(0,10,.5,0),ZIndex=42},card)
        UI.corner(bar,2)
        if not KINDS[kind] then UI.paint(bar,"BackgroundColor3") end

        local msg=UI.label(card,text,UDim2.new(1,-32,1,0),UDim2.fromOffset(21,0),10,T.TextSoft,UI.Font.Mono)
        msg.TextWrapped=true
        msg.TextTruncate=Enum.TextTruncate.AtEnd
        msg.ZIndex=42

        UI.tween(slot,{Size=UDim2.fromOffset(244,42)},.28,UI.Motion.Smooth)
        UI.tween(card,{Position=UDim2.fromOffset(0,0)},.3,UI.Motion.Smooth)

        task.delay(2.6,function()
            if not slot or not slot.Parent then return end
            -- Everything fades, not just the card background: the old toast left
            -- its text and border to pop out of existence.
            UI.tween(card,{Position=UDim2.fromOffset(34,0),BackgroundTransparency=1},.24,UI.Motion.Ease,Enum.EasingDirection.In)
            UI.tween(cardStroke,{Transparency=1},.24)
            UI.tween(msg,{TextTransparency=1},.24)
            UI.tween(bar,{BackgroundTransparency=1},.24)
            local collapse=UI.tween(slot,{Size=UDim2.fromOffset(244,0)},.26,UI.Motion.Ease,Enum.EasingDirection.In)
            collapse.Completed:Connect(function() if slot then slot:Destroy() end end)
        end)
    end

    App.Notify=UI.notify
end
