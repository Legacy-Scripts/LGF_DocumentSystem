fx_version 'cerulean'
game 'gta5'
version '1.0.0'
lua54 'yes'
author "ENT510"
description "Document management system based on item metadata."

shared_scripts {
  'shared/Shared.lua',
  'shared/Lang.lua',
  'shared/Config.lua',
  '@ox_lib/init.lua',
  "framework/GetFramework.lua",
}

client_scripts {
  'client/**/*',
}

server_scripts {
  'server/config.lua',
  'server/main.lua',
}

files {
  'id_cards.json',
  'locales/*.json',
  "framework/legacy/*.lua",
  "framework/esx/*.lua",
  "framework/qbox/*.lua",
  'web/build/index.html',
  'web/build/**/*',
}

ui_page 'web/build/index.html'
