return function(Dax)
    local App=Dax.App
    function Dax.c3(t) return Color3.fromRGB(t[1],t[2],t[3]) end
    function Dax.bind(signal,fn)
        local c=signal:Connect(fn)
        table.insert(App.Connections,c)
        return c
    end
    function Dax.draw(kind,props)
        local o=Drawing.new(kind)
        for k,v in pairs(props) do o[k]=v end
        table.insert(App.Drawings,o)
        return o
    end
    function Dax.removeDraw(o)
        pcall(function() o.Visible=false end)
        pcall(function() o:Remove() end)
    end
    function Dax.keyName(input)
        if input.UserInputType==Enum.UserInputType.Keyboard then return input.KeyCode.Name end
        return input.UserInputType.Name
    end
    function Dax.keyMatches(input,name) return Dax.keyName(input)==name end
    function Dax.project(pos)
        local p,on=Dax.Camera:WorldToViewportPoint(pos)
        return Vector2.new(p.X,p.Y),on and p.Z>0
    end
    function Dax.refreshAll()
        for _,fn in ipairs(App.Controls) do pcall(fn) end
    end
end
