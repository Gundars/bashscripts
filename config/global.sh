#!/bin/bash
#Global configuration
declare -A gConf
gConf[dirStart]=${PWD}
gConf[dirInstall]=~/.bashscripts
gConf[dirSymlinks]=/usr/local/bin
gConf[dirTmp]=/.bashscripts/tmp
gConf[colorNormal]='\e[00m'
gConf[colorHighlight]='\e[01;36m'
gConf[colorError]='\033[31m'
gConf[colorSuccess]='\e[32m'
gConf[errorMascot]='            __\n           / _)\n    .-^^^-/ /\n __/       /\n<__.|_|-|_| '

