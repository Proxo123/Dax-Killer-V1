return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local ReplicatedStorage=Dax.Services.ReplicatedStorage
    local WeaponsFolder=ReplicatedStorage:FindFirstChild("Weapons")
    local WeaponMods={Originals={},Connections={}}
    local function weaponValue(obj)
        return obj and obj:IsA("ValueBase") and (obj.Name=="Spread" or obj.Name=="MaxSpread" or obj.Name=="RecoilControl")
    end
    local function rememberWeaponValue(obj)
        if weaponValue(obj) and WeaponMods.Originals[obj]==nil then WeaponMods.Originals[obj]=obj.Value end
    end
    local function applyWeaponValue(obj)
        if not weaponValue(obj) then return end
        rememberWeaponValue(obj)
        if Config.Weapons.NoSpread and (obj.Name=="Spread" or obj.Name=="MaxSpread") then obj.Value=0 end
        if Config.Weapons.NoRecoil and obj.Name=="RecoilControl" then obj.Value=0 end
    end
    local function restoreWeaponValue(obj)
        if not weaponValue(obj) then return end
        local original=WeaponMods.Originals[obj]
        if original==nil then return end
        if obj.Name=="Spread" or obj.Name=="MaxSpread" then
            if not Config.Weapons.NoSpread then obj.Value=original end
        elseif obj.Name=="RecoilControl" and not Config.Weapons.NoRecoil then
            obj.Value=original
        end
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
                end
            end
        end
        scanWeapons(applyWeaponValue)
    end
    local function restoreWeaponMods()
        Config.Weapons.NoSpread=false
        Config.Weapons.NoRecoil=false
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
