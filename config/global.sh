#!/bin/bash
#Global configuration
declare -A gConf
gConf[dirStart]=${PWD}
gConf[dirInstall]=~/.bashscripts
gConf[dirSymlinks]=/usr/local/bin
gConf[dirTmp]=~/.bashscripts/tmp
gConf[colN]='\e[00m'
gConf[colH]='\e[01;36m'
gConf[colE]='\033[31m'
gConf[colS]='\e[32m'

declare -A errorMascots
errorMascots[1]='            __\n           / _)\n    .-^^^-/ /\n __/       /\n<__.|_|-|_|\n'
errorMascots[2]='''\^~~~~\   )  (   /~~~~^/\n ) *** \  {**}  / *** (\n  ) *** \_ ^^ _/ *** (\n  ) ****   vv   **** (\n   )_****      ****_(\n     )*** m  m ***( \n'''
errorMascots[3]='''  _____\n /     \ \n| () () |\n \  ^  /\n  |||||\n  |||||\n'''
errorMascots[4]='''     ,\n    _)\_\n     //}\n    (_;\ \n>>>===> \`==\n    /__/\n     ``\n'''
