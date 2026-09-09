return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local Theme=Dax.UI.Theme
    local inst=Dax.UI.new
    local toastHolder=inst("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,300,1,-30),Position=UDim2.new(1,-315,0,15),ZIndex=20},Dax.UI.Gui)
    inst("UIListLayout",{Padding=UDim.new(0,8),VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right},toastHolder)
    function Dax.UI.notify(text)
        if not Config.UI.Notifications or not App.Alive then return end
        local f=inst("Frame",{BackgroundColor3=Color3.fromRGB(10,12,22),BackgroundTransparency=.05,Size=UDim2.new(0,280,0,44),Position=UDim2.new(0,40,0,0),ZIndex=25},toastHolder)
        Dax.UI.corner(f,10)
        Dax.UI.stroke(f,Dax.UI.accent(),.8)
        Dax.UI.gradient(f,{Color3.fromRGB(18,24,42),Color3.fromRGB(10,12,22)},90)
        local bar=inst("Frame",{BackgroundColor3=Dax.UI.accent(),BorderSizePixel=0,Size=UDim2.new(0,3,1,-14),Position=UDim2.new(0,7,0,7),ZIndex=26},f)
        Dax.UI.corner(bar,3)
        Dax.UI.label(f,text,UDim2.new(1,-24,1,0),UDim2.new(0,18,0,0),12,Color3.fromRGB(235,238,248),Enum.Font.Code).ZIndex=26
        Dax.UI.tween(f,{Position=UDim2.new(0,0,0,0)},.28)
        task.delay(2.6,function()
            if f and f.Parent then
                local out=Dax.Services.TweenService:Create(f,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0,50,0,0),BackgroundTransparency=1})
                out:Play()
                out.Completed:Connect(function() if f then f:Destroy() end end)
            end
        end)
    end
    App.Notify=Dax.UI.notify
end
