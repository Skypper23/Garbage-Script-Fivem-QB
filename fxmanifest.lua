fx_version 'cerulean'
game { 'gta5' }

author 'Mictih'
description 'My Script'
version '1.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_script {
    'client.lua'
}

server_script {
    'server.lua'
}

dependencies {
    'qb-core'
}