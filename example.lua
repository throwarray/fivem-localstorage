local localStorage = nil
local coords = nil
local function echo (msg) print(msg) end

local function updatePosition ()
    TriggerEvent('localstorage:getSharedObject', function (obj)
        localStorage = obj
    end)

    while not localStorage do
        Citizen.Wait(0)
    end

    coords = localStorage.getItem('position')

    if coords ~= nil then
        echo('Update player position')
        coords = json.decode(coords)
        SetEntityCoords(
            GetPlayerPed(-1),
            coords.x,
            coords.y,
            coords.z - 1
        )
    end
end

local function savePosition ()
    echo('Save player position')
    coords = GetEntityCoords(GetPlayerPed(-1))
    localStorage.setItem('position', json.encode({
        x = coords.x;
        y = coords.y;
        z = coords.z;
    }))
end

AddEventHandler('playerSpawned', function ()
    echo('Player spawned')
    updatePosition()
end)

Citizen.CreateThread(function ()
    updatePosition() -- handle restart
    while true do
        Citizen.Wait(10000)
        savePosition()
    end
end)
