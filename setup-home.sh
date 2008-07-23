#!/bin/bash

# Script that is designed to fast setup a home directory on a 
# greg machine, this is *not* going to setup firefox and friends
# but will setup vimrc bashrc etc

ln -sfv ~/.real-config/.vimrc ~/.vimrc
ln -sfv ~/.real-config/.gvimrc ~/.gvimrc
ln -sfv ~/.real-config/.vim ~/.vim
