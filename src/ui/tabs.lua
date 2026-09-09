return function(Dax)
    local TweenService=Dax.Services.TweenService
    local inst=Dax.UI.new
    local rail=Dax.UI.Rail
    local pageHost=Dax.UI.PageHost
    local accent=Dax.UI.accent()
    local line=Dax.UI.Line
    Dax.UI.Pages={}
    Dax.UI.TabButtons={}
    Dax.UI.ActiveTab=nil
    function Dax.UI.showTab(name)
        Dax.UI.ActiveTab=name
        for n,p in pairs(Dax.UI.Pages) do
            if n==name then
                p.Visible=true
                p.Position=UDim2.new(0,10,0,0)
                TweenService:Create(p,TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)}):Play()
            else
                p.Visible=false
            end
        end
        for n,tab in pairs(Dax.UI.TabButtons) do
            local active=n==name
            TweenService:Create(tab.Button,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=active and .08 or .55,TextColor3=active and Color3.new(1,1,1) or Color3.fromRGB(150,160,185)}):Play()
            tab.Indicator.Visible=active
            if active then TweenService:Create(tab.Indicator,TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,3,1,-10)}):Play() end
        end
    end
    function Dax.UI.addTab(name)
        local b=inst("TextButton",{AutoButtonColor=false,Text=name:upper(),Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(150,160,185),BackgroundColor3=Color3.fromRGB(18,24,40),BackgroundTransparency=.55,Size=UDim2.new(1,0,0,36),ZIndex=7},rail)
        Dax.UI.corner(b,8)
        Dax.UI.padding(b,14,8)
        Dax.UI.gradient(b,{Color3.fromRGB(24,34,58),Color3.fromRGB(12,16,28)},90)
        Dax.UI.stroke(b,line,.6)
        local indicator=inst("Frame",{BackgroundColor3=accent,BorderSizePixel=0,Size=UDim2.new(0,0,1,-10),Position=UDim2.new(0,4,.5,0),AnchorPoint=Vector2.new(0,.5),Visible=false,ZIndex=8},b)
        Dax.UI.corner(indicator,2)
        local p=inst("Frame",{Name=name,Visible=false,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=6},pageHost)
        local scroll=inst("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=accent,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,1,0)},p)
        Dax.UI.padding(scroll,14,14)
        inst("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
        Dax.UI.Pages[name]=p
        Dax.UI.TabButtons[name]={Button=b,Indicator=indicator}
        Dax.bind(b.MouseButton1Click,function() Dax.UI.showTab(name) end)
        return scroll
    end
end
