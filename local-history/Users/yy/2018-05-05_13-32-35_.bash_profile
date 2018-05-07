#!/bin/bash

source ~/.bashrc

export C_INCLUDE_PATH=/usr/local/include:$C_INCLUDE_PATH
# export CPLUS_INCLUDE_PATH=~/mylibrary/:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=/usr/local/lib/:$LIBRARY_PATH
# export DYLD_LIBRARY_PATH=~/mylibrary/:$DYLD_LIBRARY_PATH

# for my header
export C_INCLUDE_PATH=~/Dropbox/Personal/Command/:$C_INCLUDE_PATH
