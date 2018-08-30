# ##############################################################################
#
# getapp 1.0.1
#
# Downloads an executable (BIN file) and executes it with arguments of the
# script which sources this one. BIN files are cached for future reuse.
#
# Following variables must be defined in the parent script:
# BIN_URL - URL of the executable
# BIN_MD5 - MD5 of the executable
#
# Additionally GETAPP_CACHE_DIR variable can be specified to change default
# cache directory which is ".getapp-cache" in directory of the calling script.
#
# GETAPP_DEBUG can be set to non-zero value for more verbosity.
#
#
# Example usage:
#
#    #!/bin/bash
#    BIN_MD5="1a03e1c3e676393d4ebe4487fab293e2"
#    BIN_VER="0.1.0"
#    BIN_URL="https://github.com/gergelyk/git-rsync/releases/download/$BIN_VER/git-rsync"
#    source $(dirname $0)/getapp.sh
#
# Author:  Grzegorz Krason
# License: MIT
# URL: https://github.com/gergelyk/linux-utils
#
# ##############################################################################

# check if this script is sourced
if [[ $_ == $0 ]]; then
    echo "Script $0 needs to be sourced"
    exit 1
fi

# initialize variables
PARENT_SCRIPT_DIR=$(dirname $0)
if [ -z "$GETAPP_CACHE_DIR" ]; then
    CACHE_DIR=$PARENT_SCRIPT_DIR/.getapp-cache
else
    CACHE_DIR=$GETAPP_CACHE_DIR
fi
BIN_NAME=${BIN_URL##*/}
BIN_PATH=$CACHE_DIR/$BIN_NAME

# print debug info
if [ ! -z "$GETAPP_DEBUG" ]; then
    echo "----------------------"
    echo "GETAPP VARRIABLES:"
    echo "  PARENT_SCRIPT_DIR=$PARENT_SCRIPT_DIR"
    echo "  CACHE_DIR=$CACHE_DIR"
    echo "  BIN_NAME=$BIN_NAME"
    echo "  BIN_PATH=$BIN_PATH"
    echo "----------------------"
fi

# create cache
mkdir -p $CACHE_DIR

# check if BIN file already exists in cache and if MD5 matches
NEED_TO_DOWNLOAD=1
if [[ -f $BIN_PATH ]]; then
    if echo "$BIN_MD5  $BIN_PATH" | md5sum -c &> /dev/null; then
        NEED_TO_DOWNLOAD=0
    else
        rm -f $BIN_PATH
    fi
fi

# download BIN file if needed
if [ $NEED_TO_DOWNLOAD -ne 0 ]; then
    echo "Downloading $BIN_NAME..."

    wget -q --show-progress $BIN_URL -P $CACHE_DIR ||
        { echo "Download of $BIN_NAME unsuccessful: wget failed"; exit 1; }

    echo "$BIN_MD5 $BIN_PATH" | md5sum -c &> /dev/null ||
        { echo "Download of $BIN_NAME unsuccessful: checksum doesn't match"; exit 1; }

    chmod +x $BIN_PATH
fi

# run BIN file with arguments of the caller
eval $BIN_PATH "$@"
