return function(Dax)
    local Players=game:GetService("Players")
    local RunService=game:GetService("RunService")
    local UIS=game:GetService("UserInputService")
    local HttpService=game:GetService("HttpService")
    local TweenService=game:GetService("TweenService")
    local CoreGui=game:GetService("CoreGui")
    local ReplicatedStorage=game:GetService("ReplicatedStorage")
    local Workspace=game:GetService("Workspace")
    local env=getgenv()
    for _,name in ipairs({"VapeFeatureMenu","DrawingESP","Aimbot","RotatingXCrosshair","DaxKiller"}) do
        local old=env[name]
        if old and type(old.Unload)=="function" then pcall(function() old:Unload() end) end
    end
    Dax.Services={Players=Players,RunService=RunService,UIS=UIS,HttpService=HttpService,TweenService=TweenService,CoreGui=CoreGui,ReplicatedStorage=ReplicatedStorage,Workspace=Workspace}
    Dax.LP=Players.LocalPlayer
    Dax.Camera=Workspace.CurrentCamera
    Dax.env=env
    Dax.App={Connections={},Drawings={},ESPObjects={},HealthRefs={},Controls={},Alive=true,Aiming=false,Target=nil,Profile="default"}
    Dax.UI={}
    Dax.Features={}
    local parent=(type(gethui)=="function" and gethui()) or CoreGui
    local gui=Instance.new("ScreenGui")
    gui.Name="DaxKillerMenu"
    gui.ResetOnSpawn=false
    gui.IgnoreGuiInset=true
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder=1000
    gui.Parent=parent
    Dax.App.Gui=gui
    Dax.UI.Gui=gui
end
