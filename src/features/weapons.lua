return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local ReplicatedStorage=Dax.Services.ReplicatedStorage
    local WeaponsFolder=ReplicatedStorage:FindFirstChild("Weapons")
    local WeaponMods={Originals={},Connections={}}
    local rapidValues={FireRate=true,FireRate2=true,BFireRate=true,SFireRate=true}
    local function weaponValue(obj)
        if not obj or not obj:IsA("ValueBase") then return false end
        local name=obj.Name
        return name=="Spread" or name=="MaxSpread" or name=="RecoilControl"
            or name=="EquipTime" or name=="Auto" or name=="ReloadTime"
            or name=="Ammo" or name=="StoredAmmo" or rapidValues[name]==true
    end
    local function rememberWeaponValue(obj)
        if weaponValue(obj) and WeaponMods.Originals[obj]==nil then WeaponMods.Originals[obj]=obj.Value end
    end
    local function applyWeaponValue(obj)
        if not weaponValue(obj) then return end
        rememberWeaponValue(obj)
        if Config.Weapons.NoSpread and (obj.Name=="Spread" or obj.Name=="MaxSpread") then obj.Value=0 end
        if Config.Weapons.NoRecoil and obj.Name=="RecoilControl" then obj.Value=0 end
        if Config.Weapons.InstantEquip and obj.Name=="EquipTime" then obj.Value=0 end
        if Config.Weapons.AlwaysAuto and obj.Name=="Auto" then obj.Value=true end
        if Config.Weapons.InstantReload and obj.Name=="ReloadTime" then obj.Value=0 end
        if Config.Weapons.InfiniteAmmo and (obj.Name=="Ammo" or obj.Name=="StoredAmmo") then obj.Value=999999 end
        if Config.Weapons.RapidFire and rapidValues[obj.Name] then obj.Value=0.025 end
    end
    local function restoreWeaponValue(obj)
        if not weaponValue(obj) then return end
        local original=WeaponMods.Originals[obj]
        if original==nil then return end
        local active=(obj.Name=="Spread" or obj.Name=="MaxSpread") and Config.Weapons.NoSpread
            or obj.Name=="RecoilControl" and Config.Weapons.NoRecoil
            or obj.Name=="EquipTime" and Config.Weapons.InstantEquip
            or obj.Name=="Auto" and Config.Weapons.AlwaysAuto
            or obj.Name=="ReloadTime" and Config.Weapons.InstantReload
            or (obj.Name=="Ammo" or obj.Name=="StoredAmmo") and Config.Weapons.InfiniteAmmo
            or rapidValues[obj.Name] and Config.Weapons.RapidFire
        if not active then obj.Value=original end
    end
    local function scanWeapons(fn)
        if not WeaponsFolder then return 0 end
        local count=0
        for _,weapon in ipairs(WeaponsFolder:GetChildren()) do
            for _,obj in ipairs(weapon:GetDescendants()) do
                if weaponValue(obj) then fn(obj) count+=1 end
            end
        end
        return count
    end
    local function syncWeaponMods()
        if not WeaponsFolder then return end
        for obj,original in pairs(WeaponMods.Originals) do
            if obj.Parent and weaponValue(obj) then
                if obj.Name=="Spread" or obj.Name=="MaxSpread" then
                    obj.Value=Config.Weapons.NoSpread and 0 or original
                elseif obj.Name=="RecoilControl" then
                    obj.Value=Config.Weapons.NoRecoil and 0 or original
                elseif obj.Name=="EquipTime" then
                    obj.Value=Config.Weapons.InstantEquip and 0 or original
                elseif obj.Name=="Auto" then
                    obj.Value=Config.Weapons.AlwaysAuto and true or original
                elseif obj.Name=="ReloadTime" then
                    obj.Value=Config.Weapons.InstantReload and 0 or original
                elseif obj.Name=="Ammo" or obj.Name=="StoredAmmo" then
                    obj.Value=Config.Weapons.InfiniteAmmo and 999999 or original
                elseif rapidValues[obj.Name] then
                    obj.Value=Config.Weapons.RapidFire and 0.025 or original
                end
            end
        end
        scanWeapons(applyWeaponValue)
    end
    local function restoreWeaponMods()
        Config.Weapons.NoSpread=false
        Config.Weapons.NoRecoil=false
        Config.Weapons.InstantEquip=false
        Config.Weapons.AlwaysAuto=false
        Config.Weapons.InstantReload=false
        Config.Weapons.InfiniteAmmo=false
        Config.Weapons.RapidFire=false
        for obj in pairs(WeaponMods.Originals) do restoreWeaponValue(obj) end
    end
    if WeaponsFolder then
        scanWeapons(applyWeaponValue)
        table.insert(WeaponMods.Connections,Dax.bind(WeaponsFolder.DescendantAdded,function(obj)
            if weaponValue(obj) then applyWeaponValue(obj) end
        end))
    end
    App.ApplyWeaponMods=syncWeaponMods
    App.RestoreWeaponMods=restoreWeaponMods
    Dax.Features.Weapons={
        Folder=WeaponsFolder,
        sync=syncWeaponMods,
        restore=restoreWeaponMods,
        Mods=WeaponMods,
    }
end
