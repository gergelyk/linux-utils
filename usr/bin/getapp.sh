# ##############################################################################
#
# getapp 1.1.0
#
# Downloads an executable (APP file) and executes it with arguments of the
# script which sources this one. APP files are cached for future reuse.
#
# Following variables must be defined in the parent script:
# APP_URL - URL of the executable
# APP_MD5 - MD5 of the executable
#
# Additionally GETAPP_CACHE_DIR variable can be specified to change default
# cache directory which is ".getapp-cache" in directory of the calling script.
#
# GETAPP_DEBUG     can be set to non-zero value for more verbosity.
# GETAPP_NO_INVOKE can be set to non-zero value for skipping invocation of the command
#                  this can be used when custom invocation is needed
#
#
# Example usage:
#
#    #!/bin/bash
#    APP_MD5="1a03e1c3e676393d4ebe4487fab293e2"
#    APP_VER="0.1.0"
#    APP_URL="https://github.com/gergelyk/git-rsync/releases/download/$APP_VER/git-rsync"
#    source $(dirname $0)/getapp.sh
#
# Author:  Grzegorz Krason
# License: MIT
# URL: https://github.com/gergelyk/linux-utilsw
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
APP_NAME=${APP_URL##*/}
APP_PATH=$CACHE_DIR/$APP_NAME

# print debug info
if [ ! -z "$GETAPP_DEBUG" ]; then
    echo "----------------------"
    echo "GETAPP VARRIABLES:"
    echo "  PARENT_SCRIPT_DIR=$PARENT_SCRIPT_DIR"
    echo "  CACHE_DIR=$CACHE_DIR"
    echo "  APP_NAME=$APP_NAME"
    echo "  APP_PATH=$APP_PATH"
    echo "----------------------"
fi

# create cache
mkdir -p $CACHE_DIR

# check if APP file already exists in cache and if MD5 matches
NEED_TO_DOWNLOAD=1
if [[ -f $APP_PATH ]]; then
    if echo "$APP_MD5  $APP_PATH" | md5sum -c &> /dev/null; then
        NEED_TO_DOWNLOAD=0
    else
        rm -f $APP_PATH
    fi
fi

# download APP file if needed
if [ $NEED_TO_DOWNLOAD -ne 0 ]; then
    echo "Downloading $APP_NAME..."

    wget -q $APP_URL -P $CACHE_DIR ||
        { echo "Download of $APP_NAME unsuccessful: wget failed"; exit 1; }

    echo "$APP_MD5  $APP_PATH" | md5sum -c &> /dev/null ||
        { echo "Download of $APP_NAME unsuccessful: checksum doesn't match"; exit 1; }

    chmod +x $APP_PATH
fi

# run APP file with arguments of the caller
if [ -z "$GETAPP_NO_INVOKE" ]; then
    eval $APP_PATH "$@"
fi
