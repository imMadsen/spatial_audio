fx_version 'cerulean'
games      { 'gta5' }
lua54      'yes'

author      'Rasmus Madsen & CharlesHacks#9999'
description '3D positional/Spatial audio library for FiveM.'
version     '0.0.1'

server_script "server.lua"
client_script "client.lua"

ui_page 'nui/nui.html'

files {
    'nui/nui.html',
    'nui/app.js',
    'nui/lib/*.js',
}