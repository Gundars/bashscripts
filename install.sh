#!/bin/bash
# Install other scripts from this directory to system
# Usage: git clone https://github.com/Gundars/bashscripts.git ~/.bashscripts && sudo bash install.sh
source ~/.bashscripts/lib/commons.sh

cd ${gConf[dirInstall]}
git pull origin master
SCRIPTS=(gcobranch gitmerge guorigin buildenv gitpress)
for SCRIPT in ${SCRIPTS[@]}
do
	if [ ! -h ${gConf[dirSymlinks]}/$SCRIPT ]; then
		echo "Installing $SCRIPT"
	    sudo ln -s ${gConf[dirInstall]}/scripts/$SCRIPT.sh ${gConf[dirSymlinks]}/$SCRIPT
	else
		SYMLINK=$(readlink -f ${gConf[dirSymlinks]}/$SCRIPT)
		if [[ $SYMLINK != ${gConf[dirInstall]}/scripts/$SCRIPT.sh ]]; then
			echo "Relinking existing $SCRIPT"
			sudo rm ${gConf[dirSymlinks]}/$SCRIPT
			sudo ln -s ${gConf[dirInstall]}/scripts/$SCRIPT.sh ${gConf[dirSymlinks]}/$SCRIPT
		else
			echo "$SCRIPT already installed"
		fi
	fi
done
if [ ! -h ${gConf[dirSymlinks]}/updatebashscripts ]; then
	sudo ln -s ${gConf[dirInstall]}/install.sh ${gConf[dirSymlinks]}/updatebashscripts
fi
cd ${gConf[dirStart]}
