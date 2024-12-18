fx_version 'cerulean'

game 'gta5'

version '1.1.0'

lua54 'yes'

shared_scripts {
  'shared/Config.lua',
  'Init.lua',
  'shared/Shared.lua',
  'locales/initLocales.lua',
  'locales/Lang/*.lua',
  '@ox_lib/init.lua',

}

client_scripts {
  'client/Nui.lua',
  'client/Modules/Functions.lua',
  'client/Modules/Locations.lua',
  'client/Modules/Callback.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/Functions.lua',
  'server/Main.lua',
  'server/Modules/Callback.lua',
  'server/Modules/Command.lua'
}

files {
  'web/build/index.html',
  'web/build/**/*',
}



ui_page 'web/build/index.html'
