# FiveM Spatial Audio
"spatial_audio" resource allows for 3d/spatial audio. It also allows for the creation of sounds on the server and client. Sounds created on the server are automatically synced with clients. Sounds can be referenced using the `https://cfx-nui-my-resource`, or simply from the web.

This resource has 0 dependencies, but I would like to give a shout out to Howler.js by James Simpson for the amazing library, and chHyperSound by Charleshacks for the inspiration for this resource.

All contributions are appreciated (especially for documentation)

Copyright for portions of `nui/lib/howler.core.js` and `nui/lib/howler.spatial.js` are held by James Simpson of GoldFire Studios

## Usage

### client
A sound can be created using the "Create" method, this allows the file to be preloaded. Note setting a static "id" for a sound is important for server-side sounds.

```lua
AddEventHandler("spatial_audio:ready", function(args)
    local sound = exports["spatial_audio"]:Create({
        id = "MyServerSideSound",
        src = { "https://cfx-nui-test/assets/sound.ogg" },
        distance = 100, -- The distance from which the sound can be heard
        volume = 1
    })
end)
```

### server
Please notice that sounds create a Sound Instance when played, this also means that a sound can have more instances.

```lua
    local soundInstance = exports["spatial_audio"]:Play("MyServerSideSound")
    exports["spatial_audio"]:Position(soundInstance, vector3(0, 0, 0))
    exports["spatial_audio"]:Loop(soundInstance, true)
    -- exports["spatial_audio"]:Stop(soundInstance)
```
