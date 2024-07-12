fx_version "cerulean"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

author 'OhPapa'
description 'Untamed Garage. A script that allows you to setup garage for jobs. It is equipped with buying wagons'
version '1.0.0'


client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua',
    '@mysql-async/lib/MySQL.lua',
}

shared_scripts {
    'shared/config.lua',
}
