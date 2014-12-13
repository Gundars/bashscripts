Bash Scripts
===========
Collection of bash scripts

###Installation
Execute following line in bash shell:
```
$ git clone https://github.com/Gundars/bashscripts.git ~/.bashscripts && sudo ln -s ~/.bashscripts/gcobranch.sh /usr/local/bin/gcobranch && sudo chmod 0744 /usr/local/bin/gcobranch
```

###gcobranch
Checks out and pulls specified {branch} in all git repos found in each of specified {dir}

Syntax: 
```sh
$ gcobranch {branch} {dir1} [{dir2} {dir3}...]
```
