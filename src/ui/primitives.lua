return function(Dax)
    local Theme=Dax.UI.Theme
    function Dax.UI.new(class,props,parent)
        local o=Instance.new(class)
        for k,v in pairs(props or {}) do o[k]=v end
        if parent then o.Parent=parent end
        return o
    end
    function Dax.UI.corner(parent,r)
        return Dax.UI.new("UICorner",{CornerRadius=UDim.new(0,r or 6)},parent)
    end
    function Dax.UI.stroke(parent,color,thickness)
        return Dax.UI.new("UIStroke",{Color=color or Theme.Stroke,Thickness=thickness or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},parent)
    end
    function Dax.UI.padding(parent,px,py)
        return Dax.UI.new("UIPadding",{PaddingTop=UDim.new(0,py or px),PaddingBottom=UDim.new(0,py or px),PaddingLeft=UDim.new(0,px),PaddingRight=UDim.new(0,px)},parent)
    end
    function Dax.UI.gradient(parent,colors,rot)
        local g=Dax.UI.new("UIGradient",{Rotation=rot or 90},parent)
        local seq={}
        for i,c in ipairs(colors) do seq[i]=ColorSequenceKeypoint.new((i-1)/(#colors-1),c) end
        g.Color=ColorSequence.new(seq)
        return g
    end
    function Dax.UI.label(parent,text,size,pos,fontSize,color,font)
        return Dax.UI.new("TextLabel",{BackgroundTransparency=1,Text=text,Size=size or UDim2.new(1,0,0,24),Position=pos or UDim2.new(),Font=font or Enum.Font.GothamMedium,TextSize=fontSize or 13,TextColor3=color or Color3.fromRGB(225,227,235),TextXAlignment=Enum.TextXAlignment.Left},parent)
    end
end
