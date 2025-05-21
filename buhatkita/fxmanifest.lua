
fx_version "adamant"

game "gta5"

lua54 'yes'
author "siobei//kei"
description 'A simple carry script for FiveM'
shared_scripts{
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

client_scripts {
    'client.lua'
}

server_scripts{
    'server.lua'
}


