fx_version 'cerulean'
game 'gta5'

author 'MrPookiebear'
description 'Peacetime system with okokNotify + visual UI'
version '1.0.0'

ui_page 'ui/index.html'

client_scripts {
    'postals.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}

files {
    'ui/index.html',
    'ui/style.css',
    'ui/icon.svg'
}
