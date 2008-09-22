#!/bin/sh

# Script that is designed to fast setup a home directory on a 
# greg machine, this is *not* going to setup firefox and friends
# but will setup vimrc bashrc etc

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
		# Posix me harder method, this method should be 100% 
		# posix happy, and should provide a reasonable realpath
		# even without any advanced shell / env features
		# NOTE: this method is basic and might not canoc a path
		# as well as readlink / realpath
		function realpath() { 
			# Not no modern tricks are used so that we should be
			# able to run on the most ridiculous of shells
			# (This means nested subshells are out of the question)
			DNAME=`dirname $1`
			PTH=`cd ${DNAME} && pwd`
			FILE=${PTH}/$1

			# Can happen if dirname does odd things
			# dirname doesnt really bail, it just returns
			# . as the dir if the file is not valid, we ask the 
			# shell to check if the file exists 
			# TODO: Check this applies for /bin/sh
			if [ -e ${FILE} ]; then 
				echo ${FILE}
			else
				return 1
			fi
		}
	else
		# Readlink method (readlink is not a posix standard 
		# so really really arcane systems will lack it)
		function realpath() { 
			readlink -f $1
		}
	fi
fi

pushd ~/.dotfiles

for file in `find -maxdepth 1 -type f -exec basename {} \;`; do
	# We default to a hardlink by normal, 
	# since it saves a small amount 
	# of I/O
	rm ~/${file}
	ln -fv ""$(realpath ${file})""  ~/${file} 
done

for dir in `find -maxdepth 1 -type d -not -name .hg \
	-not -name . -not -name .. `; do
	rm ~/${dir}
	ln -sfv $(realpath ${dir}) ~/${dir}
done

popd

pushd ~/.scripts

find -maxdepth 1 -type f -exec chmod -v 755 {} \;

echo "Finsihed creating home environment"
