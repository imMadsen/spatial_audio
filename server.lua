local Sounds = {}
local SoundIncrementer = 0

exports("Play", function(sound)
    SoundIncrementer = SoundIncrementer + 1
    local soundInstance = SoundIncrementer
    
    local soundInstanceTbl = {
        sound = sound,
        soundInstance = soundInstance,
        creation = os.time()
    }

    TriggerClientEvent("spatial_audio:addServerSound", -1, soundInstanceTbl)

    Sounds[soundInstance] = soundInstanceTbl

    return soundInstance
end)

exports("Position", function(soundInstance, position)
    Sounds[soundInstance].position = position
    TriggerClientEvent("spatial_audio:action", -1, "Position", soundInstance, position)
end)

exports("Loop", function(soundInstance, loop)
    Sounds[soundInstance].position = loop
    TriggerClientEvent("spatial_audio:action", -1, "Loop", soundInstance, loop)
end)

exports("Stop", function(soundInstance)
    TriggerClientEvent("spatial_audio:action", -1, "Stop", soundInstance)
end)

RegisterNetEvent("spatial_audio:requestServerSounds", function()
    for _, soundInstanceTbl in pairs(Sounds) do
        TriggerClientEvent("spatial_audio:addServerSound", source, soundInstanceTbl)
    end
end)