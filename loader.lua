local VERSION="88858fd"
local REPO="https://raw.githubusercontent.com/Proxo123/Dax-Killer-V1/"..VERSION.."/src/"
local ORDER={
    "core/bootstrap.lua",
    "core/config.lua",
    "core/util.lua",
    "core/health.lua",
    "features/weapons.lua",
    "core/persistence.lua",
    "ui/menu.lua",
    "features/esp.lua",
    "features/aimbot.lua",
    "features/triggerbot.lua",
    "features/crosshair.lua",
    "features/runtime.lua",
    "init.lua",
}
local function loadModule(path)
    local source=game:HttpGet(REPO..path.."?v="..tostring(os.time()))
    local chunk,err=loadstring(source,"@"..path)
    if not chunk then error("[DaxKiller] compile failed "..path..": "..tostring(err)) end
    return chunk()
end
local Dax={Repo=REPO}
for _,path in ipairs(ORDER) do
    local module=loadModule(path)
    if type(module)=="function" then module(Dax) end
end
