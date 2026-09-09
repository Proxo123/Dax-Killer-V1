return function(Dax)
    local App=Dax.App
    local env=Dax.env
    env.VapeFeatureMenu=App
    env.DrawingESP=App
    env.Aimbot=App
    env.RotatingXCrosshair=App
    env.DaxKiller=App
    local WeaponsFolder=Dax.Features.Weapons and Dax.Features.Weapons.Folder
    Dax.UI.notify(Dax.RestoredFrom and "Restored saved settings" or "loaded — INSERT opens menu")
    print("[DaxKiller] loaded ui=true resize=true profiles="..tostring(Dax.Persistent).." restored="..tostring(Dax.RestoredFrom).." esp=true aimbot=true crosshair=true weapons="..tostring(WeaponsFolder~=nil))
end
