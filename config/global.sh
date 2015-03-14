#!/bin/bash
#Global configuration
declare -A gConf
gConf[dirStart]=${PWD}
gConf[dirInstall]=~/.bashscripts
gConf[dirSymlinks]=/usr/local/bin
gConf[dirTmp]=/.bashscripts/tmp
gConf[colN]='\e[00m'
gConf[colH]='\e[01;36m'
gConf[colE]='\033[31m'
gConf[colS]='\e[32m'
gConf[errorMascot]='            __\n           / _)\n    .-^^^-/ /\n __/       /\n<__.|_|-|_| '

