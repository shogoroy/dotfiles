#!/bin/sh
for dotfile in .?*; do
    case $dotfile in
        *.elc)
            continue;;
        ..)
            continue;;
        .git)
            continue;;
        *)
            ln -is "$PWD/$dotfile" $HOME
            ;;
    esac
done

ln -is "$PWD/.bashrc" "$HOME/.zshrc"

script .bashrc
