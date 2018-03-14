#!/bin/sh
for dotfile in .?*; do
    case $dotfile in
        *.elc)
            continue;;
        ..)
            continue;;
        .git)
            continue;;
        .DS_Store)
            continue;;
        .vim)
            continue;;
        *)
            ln -is "$PWD/$dotfile" $HOME
            ;;
    esac
done
