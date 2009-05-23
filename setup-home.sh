#!/bin/sh

# Script that is designed to fast setup a home directory on a 
# greg machine, this is *not* going to setup firefox and friends
# but will setup vimrc bashrc etc

UNAME=`uname`

# Since the environment is not yet available lets setup a varient of 
# realpath to do an absolute path on the file

# This is a direct copy of what hides in ~/.bash_alias

# This is an emulation of the venerable realpath command for 
# platforms that do not have it, its not as smart, and is more 
# likly to make mistakes, however it is better than nothing
# (realpath should have been in unix by default, alongside dirname, ls etc)
which realpath > /dev/null 2>&1
if [ $? -ne 0 ]; then
	which readlink > /dev/null 2>&1
	if [ $? -ne 0 ]; then 
		alias realpath=~/.scripts/sh-realpath.sh
	else
		# Readlink method (readlink is not a posix standard 
		# so really really arcane systems will lack it)
		realpath() { 
			readlink -f $1
		}
	fi
fi

cd ~/.dotfiles 1> /dev/null

echo "--------------------------------------------------------------------------------"
echo "Creating links for rc / config files"
echo "--------------------------------------------------------------------------------"

for file in `find -maxdepth 1 -type f -exec basename {} \;`; do
	# We default to a hardlink by normal, 
	# since it saves a small amount 
	# of I/O
	rm ~/${file}
	ln -fv ""`realpath ${file}`""  ~/${file} 
done

echo "--------------------------------------------------------------------------------"
echo "Creating symlinks for dirs"
echo "--------------------------------------------------------------------------------"

for dir in `find -maxdepth 1 -type d -not -name .hg \
	-not -name . -not -name .. `; do

	rm ~/${dir}

	# Some programs in their win32 varients do not like the home folders being
	# a cygwin style link, detect this and do the link with junction instead
	case "$UNAME" in
		CYGWIN*)
			# CYGWIN JUNCTION NONSENCE {{{
			echo "Building cygwin happy hardlinks"
			JUNCTION=`which junction 2> /dev/null`

			if [ -z ${JUNCTION} ]; then
				echo "Junction (NTFS symlink tool) not found, trying default location"
				# Take a guess that I have put it where I always install it
				if [ -e /opt/sysinternals/junction ]; then
					JUNCTION=/opt/sysinternals/junction
					echo "Found junction where i suspected it would be [ ${JUNCTION} ]"
					echo "--------------------------------------------------------------------------------" 
				else
					echo "Default location for junction is empty, downloading"
					# If we have curl or wget lets download it through the glory of tinternet
					CURL=`which curl 2> /dev/null`
					WGET=`which wget 2> /dev/null`

					if [ ! -z ${CURL} ]; then
						echo "Downloading sys internals tools with Curl"
						echo "--------------------------------------------------------------------------------" 
						curl 'http://live.sysinternals.com/Files/SysinternalsSuite.zip' > /tmp/sys-internals.zip
						echo "--------------------------------------------------------------------------------" 
					elif [ ! -z ${WGET} ]; then
						echo "Downloading sys internals tools with wget"
						echo "--------------------------------------------------------------------------------" 
						wget 'http://live.sysinternals.com/Files/SysinternalsSuite.zip' -o /tmp/sys-internals.zip
						echo "--------------------------------------------------------------------------------" 
					else
						echo "Could not download junction bailing out"
						exit 1
					fi

					if [ -e /tmp/sys-internals.zip ]; then
						if [ ! -e /opt/sysinternals ]; then
							mkdir /opt/sysinternals
						fi
						pushd /opt/sysinternals 1> /dev/null
						unzip /tmp/sys-internals.zip
						rm /tmp/sys-internals.zip
						popd 1> /dev/null
					fi

					JUNCTION=/opt/sysinternals/junction
				fi
			fi
			if [ ! -z ${JUNCTION} ]; then
				link=`realpath ~/${dir}`
				target=`realpath ${dir}`

				if [ ! -d ${link} ]; then
					echo ${JUNCTION} `cygpath -wa ${link}` `cygpath -wa ${target}` 
				else
					echo "Dir [ `realpath ~/${dir}` ] exists at the reparse point"
					echo "Not going to clobber, do this yourself with:"
					echo \'${JUNCTION} `cygpath -wa ${link}` `cygpath -wa ${target}`\'
				fi
			else
				echo "Could not create NTFS symlinks"
				exit 1
			fi
			# }}}
		;;
	*)
		ln -sfv `realpath ${dir}` `realpath ~`
		;;
	esac
done

cd ~/.scripts 1> /dev/null

find -maxdepth 1 -type f -exec chmod -v 755 {} \;

echo "Finished creating home environment"
# vim: set foldmethod=marker foldlevel=1 :
