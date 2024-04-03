local SoundIncrementer = 0
local SoundInstanceIncrementer = 0
local SoundsMap = {}
local ServerSoundsMap = {}

function getCameraDirection()
    local cameraRotation = GetGameplayCamRot(0)

    local radiansZ = (cameraRotation.z * 0.0174532924)
    local radiansX = (cameraRotation.x * 0.0174532924)
    local xCos     = math.abs(math.cos(radiansX))

    return {
        x = (-math.sin(radiansZ) * xCos),
        y = (math.cos(radiansZ) * xCos),
        z = math.sin(radiansX),
    }
end

Citizen.CreateThread(function()
    local function _() -- This crazy "thingy" is to allow guard clauses
        local playerPed = GetPlayerPed(-1)

        if not DoesEntityExist(playerPed) then
            return
        end

        local playerCoordinates = GetEntityCoords(playerPed)
        local cameraDirection   = getCameraDirection()

        SendNUIMessage({
            type = 'PlayerUpdate',
            args = {
                position = playerCoordinates,
                orientation = cameraDirection
            }
        })
    end

    while true do
        _()
        Citizen.Wait(10)
    end
end)

function Create(args)
    if args.id == nil then
        SoundIncrementer = SoundIncrementer + 1
        args.id = SoundIncrementer
    end

    SendNUIMessage({
        type = 'Create',
        sound = args.id,
        args = args
    })

    return args.id
end

function Play(sound, creationTime)
    SoundInstanceIncrementer = SoundInstanceIncrementer + 1

    local soundInstance = SoundInstanceIncrementer
    SoundsMap[soundInstance] = sound

    SendNUIMessage({
        type = 'Play',
        sound = sound,
        args = {
            soundInstance = soundInstance,
            creationTime = creationTime,
        }
    })

    return soundInstance
end

function Stop(soundInstance)
    SendNUIMessage({
        type = 'Stop',
        sound = SoundsMap[soundInstance],
        args = {
            soundInstance = soundInstance
        }
    })
end

function Pause(soundInstance)
    SendNUIMessage({
        type = 'Pause',
        sound = SoundsMap[soundInstance],
        args = {
            soundInstance = soundInstance
        }
    })
end

function Seek(soundInstance, duration)
    SendNUIMessage({
        type = 'Seek',
        sound = SoundsMap[soundInstance],
        args = {
            soundInstance = soundInstance,
            duration = duration
        },
    })
end

function Position(soundInstance, position)
    SendNUIMessage({
        type = 'Position',
        sound = SoundsMap[soundInstance],
        args = {
            soundInstance = soundInstance,
            position = position
        },
    })
end

function Loop(soundInstance, loop)
    SendNUIMessage({
        type = 'Loop',
        sound = SoundsMap[soundInstance],
        args = {
            soundInstance = soundInstance,
            loop = loop
        },
    })
end

RegisterNetEvent("spatial_audio:addServerSound", function(soundInstanceTbl)
    if soundInstanceTbl.stop then
        return
    end

    local cSoundInstance = Play(soundInstanceTbl.sound, soundInstanceTbl.creation)
    ServerSoundsMap[soundInstanceTbl.soundInstance] = cSoundInstance
    
    local position = soundInstanceTbl.position
    if (position) then
        Position(cSoundInstance, position)
    end

    local loop = soundInstanceTbl.loop
    if (loop) then
        Loop(cSoundInstance, loop)
    end
end)

RegisterNetEvent("spatial_audio:action", function(action, soundInstance, args)
    local cSoundInstance = ServerSoundsMap[soundInstance]
    if (action == "Position") then
        Position(cSoundInstance, args)
    elseif (action == "Loop") then
        Loop(cSoundInstance, args)
    elseif (action == "Stop") then
        Stop(cSoundInstance)
    end
end)

RegisterNUICallback("ready", function(_, cb)
    TriggerEvent("spatial_audio:ready")
    TriggerServerEvent("spatial_audio:requestServerSounds")
    cb({})
end)

exports("Create", Create)
exports("Play", Play)
exports("Stop", Stop)
exports("Pause", Pause)
exports("Seek", Seek)
exports("Position", Position)
exports("Loop", Loop)
