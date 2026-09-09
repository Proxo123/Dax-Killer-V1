return function(Dax)
    local UI=Dax.UI
    local T=UI.Theme

    function UI.new(class,props,parent)
        local o=Instance.new(class)
        for k,v in pairs(props or {}) do o[k]=v end
        if parent then o.Parent=parent end
        return o
    end

    function UI.corner(parent,r)
        return UI.new("UICorner",{CornerRadius=typeof(r)=="UDim" and r or UDim.new(0,r or UI.Radius.Control)},parent)
    end

    function UI.stroke(parent,color,thickness,transparency)
        return UI.new("UIStroke",{
            Color=color or T.Line,
            Thickness=thickness or 1,
            Transparency=transparency or 0,
            ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
        },parent)
    end

    function UI.padding(parent,px,py,pr,pb)
        return UI.new("UIPadding",{
            PaddingTop=UDim.new(0,py or px),
            PaddingBottom=UDim.new(0,pb or py or px),
            PaddingLeft=UDim.new(0,px),
            PaddingRight=UDim.new(0,pr or px),
        },parent)
    end

    function UI.list(parent,pad,dir,align)
        return UI.new("UIListLayout",{
            Padding=UDim.new(0,pad or 8),
            FillDirection=dir or Enum.FillDirection.Vertical,
            HorizontalAlignment=align or Enum.HorizontalAlignment.Left,
            SortOrder=Enum.SortOrder.LayoutOrder,
        },parent)
    end

    function UI.setGradient(g,colors)
        local seq={}
        if #colors==1 then
            seq={ColorSequenceKeypoint.new(0,colors[1]),ColorSequenceKeypoint.new(1,colors[1])}
        else
            for i,c in ipairs(colors) do seq[i]=ColorSequenceKeypoint.new((i-1)/(#colors-1),c) end
        end
        g.Color=ColorSequence.new(seq)
        return g
    end

    function UI.gradient(parent,colors,rot)
        local g=UI.new("UIGradient",{Rotation=rot or 90},parent)
        UI.setGradient(g,colors)
        return g
    end

    -- stops: {{position,transparency},...}
    function UI.fade(g,stops)
        local seq={}
        for i,s in ipairs(stops) do seq[i]=NumberSequenceKeypoint.new(s[1],s[2]) end
        g.Transparency=NumberSequence.new(seq)
        return g
    end

    function UI.label(parent,text,size,pos,fontSize,color,font)
        return UI.new("TextLabel",{
            BackgroundTransparency=1,
            Text=text,
            Size=size or UDim2.new(1,0,0,20),
            Position=pos or UDim2.new(),
            Font=font or UI.Font.Body,
            TextSize=fontSize or 12,
            TextColor3=color or T.Text,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextYAlignment=Enum.TextYAlignment.Center,
            TextTruncate=Enum.TextTruncate.AtEnd,
        },parent)
    end

    -- Hover wiring always goes through Dax.bind so it is torn down on unload.
    function UI.hover(obj,enter,leave)
        Dax.bind(obj.MouseEnter,enter)
        Dax.bind(obj.MouseLeave,leave)
        return obj
    end

    function UI.hoverFill(obj,base,hovered,dur)
        return UI.hover(obj,
            function() UI.tween(obj,{BackgroundColor3=hovered},dur or UI.Motion.Fast) end,
            function() UI.tween(obj,{BackgroundColor3=base},dur or UI.Motion.Fast) end)
    end

    -- Momentary press feedback. The resting size is snapshotted once at bind time
    -- so repeated clicks cannot compound the offset.
    function UI.press(button,target,shrink)
        local s=shrink or 2
        local base=target.Size
        local small=UDim2.new(base.X.Scale,base.X.Offset-s,base.Y.Scale,base.Y.Offset-s)
        Dax.bind(button.InputBegan,function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then UI.tween(target,{Size=small},.06) end
        end)
        Dax.bind(button.InputEnded,function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then UI.tween(target,{Size=base},.10) end
        end)
    end
end
