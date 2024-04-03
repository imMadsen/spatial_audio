const SoundMap = new Map();
const SoundInstanceMap = new Map();
let SoundPairs = [];

const SoundPromises = new Map();

async function EnsureSound(soundId) {
    if (!SoundPromises.has(soundId)) {
        let resolve;

        const promise = new Promise(function(_resolve){
            resolve = _resolve;
        });

        SoundPromises.set(soundId, {
            promise,
            resolve,
        })
    }

    await SoundPromises.get(soundId).promise

    return SoundMap.get(soundId)
}

window.addEventListener('message', (event) => {
    const { type, sound: soundId, args } = event.data;

    function PlayerUpdate() {
        Howler.pos(args.position.x, args.position.y, args.position.z);
        Howler.orientation(args.orientation.x, args.orientation.y, args.orientation.z, 0, 0, 1);

        for (const [sound, soundInstance] of SoundPairs) {
            const distance = Math.hypot((args.position.x - soundInstance.position.x), (args.position.y - soundInstance.position.y), (args.position.z - soundInstance.position.z))
            const volume = Math.max((1 - (distance / sound.distance)) * sound.volume, 0)
            sound.ref.volume(volume, soundInstance.ref)
        }
    }

    function Create() {
        const howl = new Howl({
            src: args.src,
            loop: args.loop,
            onload: () => {
                EnsureSound(soundId);
                SoundPromises.get(soundId).resolve();
            }
        })

        SoundMap.set(soundId, {
            ref: howl,
            distance: args.distance,
            volume: args.volume,
        })
    }

    async function Play() {
        const sound = await EnsureSound(soundId)
        const soundInstance = {
            ref: sound.ref.play(),
            position: { x: 0, y: 0, z: 0 }
        };

        sound.ref.pannerAttr({
            panningModel: 'HRTF',
            rolloffFactor: 1,
            distanceModel: 'linear',
        }, soundInstance.ref);  
        
        SoundInstanceMap.set(args.soundInstance, soundInstance)
        SoundPairs.push([sound, soundInstance]);

        if (args.creationTime)
            sound.ref.seek(((new Date().getTime() / 1000) - args.creationTime) % sound.ref.duration(), soundInstance.ref)

        function clean() {
            SoundPairs = SoundPairs.filter((([_sound, _soundInstance]) => _sound === sound && _soundInstance === soundInstance) )
            SoundInstanceMap.delete(args.soundInstance)
        } 

        sound.ref.on("end", () => {
            if (!soundInstance.loop) {
                clean();
            }
        }, soundInstance.ref)

        sound.ref.on("stop", () => {
            clean();
        }, soundInstance.ref)
    };

    async function Position() {
        const sound = await EnsureSound(soundId)
        const soundInstance = SoundInstanceMap.get(args.soundInstance);

        soundInstance.position = args.position
        sound.ref.pos(args.position.x, args.position.y, args.position.z, soundInstance.ref)
    }

    async function Loop() {
        const sound = await EnsureSound(soundId)
        const soundInstance = SoundInstanceMap.get(args.soundInstance);
        
        soundInstance.loop = args.loop
        sound.ref.loop(args.loop, soundInstance.ref)
    }

    async function Stop() {
        const sound = await EnsureSound(soundId)
        const soundInstance = SoundInstanceMap.get(args.soundInstance);
        soundInstance.stop = true
        sound.ref.stop(soundInstance.ref)
    }
    
    const actions = {
        PlayerUpdate,
        Create,
        Play,
        Position,
        Loop,
        Stop
    }

    actions[type]();
});

window.addEventListener("DOMContentLoaded", () => {
    fetch(`https://spatial_audio/ready`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        }
    })
})