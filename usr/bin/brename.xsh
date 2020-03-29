#!/usr/bin/env xonsh

"""Renames group of files/directories in batch mode.

   Usage:
     ren [FILE1 [FILE2] ...]

   If files are not defined, everything in current directory is considered.
   After invoking the command, text editor will be opened. Just do the changes, save the file and exit.
"""

import sys
from pathlib import Path


def collect_tasks():
    old = [Path(p) for p in sys.argv[1:]] or pg`*`
    txt = '\n'.join(str(f) for f in old)
    tmp = $(mktemp).strip()

    echo @(txt) > @(tmp)
    $EDITOR @(tmp)
    new = $(cat @(tmp)).splitlines()

    tasks = {fo: fn for fo,fn in zip(old, new) if str(fo) != fn}
    return tasks


def confirm(tasks):
    if not tasks:
        print('Nothing to rename.')
        return

    width = max(map(len, map(str, tasks))) + len(repr(str()))
    for fo,fn in tasks.items():
        print(('{fo:{width}} -> {fn}').format(fo=ascii(str(fo)), fn=ascii(fn), width=width))

    confirm = input('Are you sure you would like to apply changes above? [yes/no]: ')
    if confirm != 'yes':
        print('Operation canceled.')
        return

    return True


def execute(tasks):
    cnt = 0
    for fo,fn in tasks.items():
        try:
            fo.rename(fn)
            cnt+=1
        except Exception as ex:
            print(ex)
            print('Following file cannot be renamed: {fo}'.format(fo=repr(str(fo))))

    print('{cnt} file(s) successfully renamed.'.format(cnt=cnt))


def main():

    tasks = collect_tasks()
    if confirm(tasks):
        execute(tasks)

main()
