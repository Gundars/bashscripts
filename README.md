Bash Scripts
===========
Collection of bash scripts

###Installation
Execute following line in bash shell as a user:
```
git clone https://github.com/Gundars/bashscripts.git ~/.bashscripts && sudo ln -s ~/.bashscripts/gcobranch.sh /usr/local/bin/gcobranch && sudo chmod 0744 /usr/local/bin/gcobranch && sudo ln -s ~/.bashscripts/gitmerge.sh /usr/local/bin/gitmerge && sudo chmod 0744 /usr/local/bin/gitmerge && sudo ln -s ~/.bashscripts/guorigin.sh /usr/local/bin/guorigin && sudo chmod 0744 /usr/local/bin/guorigin
```

###gcobranch
Checks out and pulls specified git {branch} in all git repos found in each of specified directories {dir}

Syntax: `$ gcobranch {branch} {dir1} [{dir2} {dir3}...]`

###gitmerge
Merges current branch with {branch}, pushes changes to origin. If no {branch} is specified, "development" is used

Syntax: `$ gitmerge [options] [branch]`

Options:
- `-p`  generate links to test/master pull requests

###guorigin
Update git origins from o-auth and SSH to native https in all git repos found in each of specified directories {dir}

Syntax: `$ guorigin {dir1} [{dir2} {dir3}...]`
