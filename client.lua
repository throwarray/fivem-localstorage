local isReady = false
local YIELD = { waiting = false; response = nil; }
local EMPTY = {}

LocalStorage = { ready = false; }

function LocalStorage.isReady ()
    LocalStorage.ready = isReady
    return isReady
end;

function YIELD.SendMessage (fn, payload)
    local result = nil

    YIELD.response = nil

    SendNUIMessage({
        type = 'LOCAL_STORAGE';
        meta = fn;
        payload = payload or EMPTY;
    })

    YIELD.response = nil
    YIELD.waiting = true

    while YIELD.waiting do
        Citizen.Wait(0)
    end

    result = YIELD.response

    YIELD.response = nil

    isReady = true
    LocalStorage.isReady()

    return result
end;

function YIELD.resume(response)
    YIELD.response = response
    YIELD.waiting = false
end

function LocalStorage.getItem (key)
    return YIELD.SendMessage('getItem', { key })
end;

function LocalStorage.setItem (key, value)
    return YIELD.SendMessage('setItem', { key, value })
end;

function LocalStorage.hasItem (key)
    return YIELD.SendMessage('hasItem', { key })
end;

function LocalStorage.removeItem (key)
    return YIELD.SendMessage('removeItem', { key })
end;

function LocalStorage.getLength ()
    return YIELD.SendMessage('getLength')
end;

function LocalStorage.dump ()
    return YIELD.SendMessage('dump')
end;

function LocalStorage.key (i)
    return YIELD.SendMessage('key', { i })
end;

function LocalStorage.clear ()
    return YIELD.SendMessage('clear')
end;

Citizen.CreateThread(function ()
    RegisterNUICallback('localstorage', function (data, cb)
        if data.type ~= 'LOCAL_STORAGE' then return
        elseif data.meta == 'ready' then
            isReady = true
        elseif data.meta == 'sync-cb' then
            YIELD.resume(data.payload)
        end

        cb("")
    end)
    AddEventHandler('localstorage:getSharedObject', function (cb)
        if not isReady then
            SendNUIMessage({ type = 'LOCAL_STORAGE'; meta = 'ready'; })
        end
        while not isReady do
            Citizen.Wait(0)
        end
        LocalStorage.isReady()
        return cb(LocalStorage)
    end)
end)
