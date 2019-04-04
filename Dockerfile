FROM docker:dind AS docker
FROM golang:alpine AS go
FROM node:alpine AS node
FROM ubuntu:devel AS base

FROM base
LABEL maintainer "Shogoro Yoshida <shogoro.yoshida@gmail.com>"

ENV LANG ja_JP.UTF-8
ENV TZ Asia/Tokyo
ENV HOME /root
ENV GOPATH $HOME/local
ENV GOROOT /usr/local/go
ENV DOTFILES $HOME/.dotfiles
ENV SHELL /bin/zsh

WORKDIR $HOME

CMD ["/bin/zsh", "-c", "source ~/.zshrc"]
