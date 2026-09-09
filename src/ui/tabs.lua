return function(Dax)
    local UI=Dax.UI
    local T=UI.Theme
    local inst=UI.new
    local rail=UI.Rail
    local pageHost=UI.PageHost

    local TAB_H,TAB_GAP=34,3
    local STRIDE=TAB_H+TAB_GAP

    UI.Pages={}
    UI.TabButtons={}
    UI.TabOrder={}
    UI.ActiveTab=nil

    -- One indicator that slides between tabs, instead of a per-button indicator
    -- that had to be shown and hidden. It also sits outside the button so the
    -- button's own padding cannot push it out of place.
    local indicator=inst("Frame",{Name="Indicator",BorderSizePixel=0,Size=UDim2.fromOffset(3,TAB_H-10),Position=UDim2.fromOffset(-10,5),ZIndex=5,Visible=false},rail)
    UI.corner(indicator,2)
    local indGrad=UI.gradient(indicator,{T.White,T.White},90)
    UI.onAccent(function(a,a2) if indicator.Parent then UI.setGradient(indGrad,{a2,a}) end end)

    -- CanvasGroup lets a page cross-fade with a single property. Older executor
    -- environments may not have it, in which case pages slide without fading.
    local hasCanvasGroup=pcall(function() Instance.new("CanvasGroup"):Destroy() end)

    function UI.showTab(name)
        if UI.ActiveTab==name then return end
        UI.ActiveTab=name
        UI.closePopover()

        for n,p in pairs(UI.Pages) do
            if n==name then
                p.Visible=true
                p.Position=UDim2.fromOffset(14,0)
                if hasCanvasGroup then p.GroupTransparency=1 end
                UI.tween(p,{Position=UDim2.fromOffset(0,0)},.26,UI.Motion.Smooth)
                if hasCanvasGroup then UI.tween(p,{GroupTransparency=0},.22) end
            else
                p.Visible=false
            end
        end

        for n,tab in pairs(UI.TabButtons) do
            local active=n==name
            UI.tween(tab.Button,{BackgroundTransparency=active and .86 or 1},UI.Motion.Base)
            UI.tween(tab.Label,{TextColor3=active and T.White or T.Faint},UI.Motion.Base)
            UI.tween(tab.Dot,{BackgroundColor3=active and UI.accent2() or T.Faint,BackgroundTransparency=active and 0 or .45},UI.Motion.Base)
        end

        local idx=table.find(UI.TabOrder,name) or 1
        indicator.Visible=true
        UI.tween(indicator,{Position=UDim2.fromOffset(-10,(idx-1)*STRIDE+5)},.26,UI.Motion.Smooth)
    end

    function UI.addTab(name)
        local order=#UI.TabOrder+1
        table.insert(UI.TabOrder,name)

        local b=inst("TextButton",{
            Name=name,
            Text="",
            AutoButtonColor=false,
            BackgroundColor3=T.Raise,
            BackgroundTransparency=1,
            Size=UDim2.new(1,0,0,TAB_H),
            Position=UDim2.fromOffset(0,(order-1)*STRIDE),
            ZIndex=4,
        },rail)
        UI.corner(b,UI.Radius.Row)
        UI.paint(b,"BackgroundColor3",function(a) return a:Lerp(T.Void,.55) end)

        local dot=inst("Frame",{BackgroundColor3=T.Faint,BackgroundTransparency=.45,BorderSizePixel=0,Size=UDim2.fromOffset(5,5),Position=UDim2.new(0,13,.5,-2),ZIndex=5},b)
        UI.corner(dot,3)

        local lbl=UI.label(b,string.upper(name),UDim2.new(1,-34,1,0),UDim2.fromOffset(26,0),11,T.Faint,UI.Font.Strong)
        lbl.ZIndex=5

        UI.hover(b,
            function()
                if UI.ActiveTab~=name then
                    UI.tween(b,{BackgroundTransparency=.94},UI.Motion.Fast)
                    UI.tween(lbl,{TextColor3=T.Dim},UI.Motion.Fast)
                end
            end,
            function()
                if UI.ActiveTab~=name then
                    UI.tween(b,{BackgroundTransparency=1},UI.Motion.Fast)
                    UI.tween(lbl,{TextColor3=T.Faint},UI.Motion.Fast)
                end
            end)

        local page
        if hasCanvasGroup then
            page=inst("CanvasGroup",{Name=name,Visible=false,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=3},pageHost)
        else
            page=inst("Frame",{Name=name,Visible=false,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=3},pageHost)
        end

        local scroll=inst("ScrollingFrame",{
            BackgroundTransparency=1,
            BorderSizePixel=0,
            ScrollBarThickness=4,
            ScrollBarImageColor3=T.Control,
            ScrollBarImageTransparency=.2,
            CanvasSize=UDim2.new(),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Size=UDim2.new(1,0,1,0),
            ZIndex=3,
        },page)
        UI.padding(scroll,14,14,10,18)
        UI.list(scroll,11)

        UI.Pages[name]=page
        UI.TabButtons[name]={Button=b,Label=lbl,Dot=dot}
        Dax.bind(b.MouseButton1Click,function() UI.showTab(name) end)
        return scroll
    end
end
