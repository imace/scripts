#!/bin/bash

echo "Backing up home directory"

# Either the following are caches, or they are handled 
# differently (e.g. they are config / dotfiles)
rsync -b -rtgv -O --max-size=1G -h --progress -s \
	--exclude "*~" \
	--include ".purple*" \
	--include ".mc*" \
	--include ".grip*" \
	--include ".Virtualbox*" \
	--include ".Skype" \
	--include ".thunderbird* "\
	--include ".com.oxygenxml/license.xml" \
	--include ".ssh/known_hosts" \
	--exclude ".scripts"\
	--exclude ".real-config"\
	--exclude ".viminfo" \
	--exclude ".IntelliJ*" \
	--exclude ".local/share/Trash*" \
	--exclude ".m2/repository/*" \
	--exclude ".maven/repo/*" \
	--exclude "projects*" \
	--exclude "workstation" \
	--exclude "\.*"\
	/home/greg/ /mnt/vault/backup/home/greg

