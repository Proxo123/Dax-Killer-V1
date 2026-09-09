return function(Dax)
    local App=Dax.App
    local Config=Dax.Config
    local HttpService=Dax.Services.HttpService
    local folder="SolVapeProfiles"
    local AUTOSAVE_NAME="_autosave"
    local META_FILE="_meta.json"
    local persistent=type(writefile)=="function" and type(readfile)=="function"
    if persistent and type(makefolder)=="function" then
        pcall(function() if type(isfolder)~="function" or not isfolder(folder) then makefolder(folder) end end)
    end
    local memoryProfiles={}
    local savedProfiles={"default"}
    local function profilePath(n) return folder.."/"..n..".json" end
    local function sanitizeName(n) n=tostring(n or ""):gsub("[^%w_%-]",""):sub(1,32) return n=="" and "default" or n end
    function Dax.listSavedProfiles()
        local names={}
        local seen={}
        if persistent and type(listfiles)=="function" then
            local ok,files=pcall(function() return listfiles(folder) end)
            if ok and type(files)=="table" then
                for _,file in ipairs(files) do
                    local name=file:match("^(.+)%.json$")
                    if name and name~="_autosave" and name~="_meta" and not seen[name] then seen[name]=true table.insert(names,name) end
                end
            end
        end
        for name in pairs(memoryProfiles) do
            if name~="_autosave" and name~="_meta" and not seen[name] then seen[name]=true table.insert(names,name) end
        end
        table.sort(names)
        if #names==0 then table.insert(names,"default") end
        savedProfiles=names
        if not table.find(savedProfiles,App.Profile) then App.Profile=savedProfiles[1] end
        return savedProfiles
    end
    local function readProfileEncoded(name)
        local encoded=memoryProfiles[name]
        if persistent and not encoded then
            local ok,data=pcall(function() return readfile(profilePath(name)) end)
            if ok then encoded=data end
        end
        return encoded
    end
    local function writeProfileEncoded(name,encoded)
        name=sanitizeName(name)
        memoryProfiles[name]=encoded
        if persistent then
            local ok,err=pcall(function() writefile(profilePath(name),encoded) end)
            if not ok then return false,err end
        end
        return true
    end
    local function writeMeta()
        if not persistent then return end
        pcall(function() writefile(folder.."/"..META_FILE,HttpService:JSONEncode({LastProfile=App.Profile,Profiles=Dax.listSavedProfiles()})) end)
    end
    function Dax.applyConfig(data,profileName)
        if type(data)~="table" then return false end
        Dax.mergeValid(Config,data)
        Dax.normalize()
        App.Profile=sanitizeName(profileName or App.Profile)
        Dax.listSavedProfiles()
        Dax.refreshAll()
        if Dax.UI.GuiScale then Dax.UI.GuiScale.Scale=Config.UI.Scale/100 end
        App.Target=nil
        if Dax.Features.Weapons and Dax.Features.Weapons.sync then Dax.Features.Weapons.sync() end
        writeMeta()
        return true
    end
    function Dax.saveAutosave()
        Dax.normalize()
        local encoded=HttpService:JSONEncode(Config)
        memoryProfiles[AUTOSAVE_NAME]=encoded
        if persistent then pcall(function() writefile(profilePath(AUTOSAVE_NAME),encoded) end) writeMeta() end
    end
    App.SaveAutosave=Dax.saveAutosave
    function Dax.saveProfile()
        Dax.normalize()
        local n=sanitizeName(App.Profile)
        local ok,err=writeProfileEncoded(n,HttpService:JSONEncode(Config))
        if not ok then Dax.UI.notify("Save failed: "..tostring(err)) return end
        Dax.listSavedProfiles()
        writeMeta()
        if Dax.UI.refreshProfilePicker then Dax.UI.refreshProfilePicker() end
        Dax.UI.notify("Saved profile: "..n)
    end
    function Dax.loadProfileByName(name)
        name=sanitizeName(name)
        local encoded=readProfileEncoded(name)
        if not encoded then Dax.UI.notify("Profile not found: "..name) return false end
        local ok,data=pcall(function() return HttpService:JSONDecode(encoded) end)
        if not ok or not Dax.applyConfig(data,name) then Dax.UI.notify("Invalid profile: "..name) return false end
        if Dax.UI.refreshProfilePicker then Dax.UI.refreshProfilePicker() end
        Dax.UI.notify("Loaded profile: "..name)
        return true
    end
    function Dax.loadAutosaveOrLast()
        Dax.listSavedProfiles()
        local encoded=readProfileEncoded(AUTOSAVE_NAME)
        if persistent then
            local ok,metaData=pcall(function() return readfile(folder.."/"..META_FILE) end)
            if ok and metaData then
                local okMeta,meta=pcall(function() return HttpService:JSONDecode(metaData) end)
                if okMeta and type(meta)=="table" and meta.LastProfile then App.Profile=sanitizeName(meta.LastProfile) end
            end
        end
        if encoded then
            local ok,data=pcall(function() return HttpService:JSONDecode(encoded) end)
            if ok and Dax.applyConfig(data,App.Profile) then return true end
        end
        if App.Profile~="default" then
            encoded=readProfileEncoded(App.Profile)
            if encoded then
                local ok,data=pcall(function() return HttpService:JSONDecode(encoded) end)
                if ok and Dax.applyConfig(data,App.Profile) then return true end
            end
        end
        return false
    end
    function Dax.resetProfile()
        if Dax.Features.Weapons and Dax.Features.Weapons.restore then Dax.Features.Weapons.restore() end
        for k in pairs(Config) do Config[k]=nil end
        Dax.mergeValid(Config,Dax.deepCopy(Dax.Defaults))
        Dax.normalize()
        Dax.refreshAll()
        if Dax.UI.GuiScale then Dax.UI.GuiScale.Scale=Config.UI.Scale/100 end
        App.Target=nil
        if Dax.Features.Weapons and Dax.Features.Weapons.sync then Dax.Features.Weapons.sync() end
        Dax.saveAutosave()
        Dax.UI.notify("Settings reset")
    end
    function Dax.createProfile()
        local base="Profile"
        local n=1
        while table.find(savedProfiles,base..n) do n+=1 end
        App.Profile=base..n
        Dax.listSavedProfiles()
        if Dax.UI.refreshProfilePicker then Dax.UI.refreshProfilePicker() end
        Dax.saveProfile()
    end
    Dax.Persistent=persistent
end
