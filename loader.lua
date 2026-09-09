local REPO="https://raw.githubusercontent.com/Proxo123/Dax-Killer-V1/main/src/"
local ORDER={
    "core/bootstrap.lua",
    "core/config.lua",
    "core/util.lua",
    "core/health.lua",
    "ui/theme.lua",
    "ui/primitives.lua",
    "ui/notify.lua",
    "ui/window.lua",
    "ui/tabs.lua",
    "ui/controls.lua",
    "features/weapons.lua",
    "core/persistence.lua",
    "ui/pages.lua",
    "features/esp.lua",
    "features/aimbot.lua",
    "features/crosshair.lua",
    "features/runtime.lua",
    "init.lua",
}
local function loadModule(path)
    local source=game:HttpGet(REPO..path)
    local chunk,err=loadstring(source,"@"..path)
    if not chunk then error("[DaxKiller] compile failed "..path..": "..tostring(err)) end
    return chunk()
end
local Dax={Repo=REPO}
for _,path in ipairs(ORDER) do
    local module=loadModule(path)
    if type(module)=="function" then module(Dax) end
end
