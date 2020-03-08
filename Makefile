.PHONY: \
	clean

all: \
	clean \
	install

install: \
	init-nvim \
	init-vim \
	init-zsh \
	init-tmux \
	init-git \
	init-editorconfig

clean:
	-rm ~/.config/nvim \
		~/.vim\
		~/.vimrc \
		~/.zshrc \
		~/.tmux.conf \
		~/.gitconfig \
		~/.config/git \
		~/.editorconfig

init-nvim: \
	~/.config/nvim

~/.config:
	mkdir -p ~/.config

~/.config/nvim: ~/.config
	ln -sf $(CURDIR)/nvim ~/.config/nvim

init-vim: \
	~/.vim \
	~/.vimrc
~/.vim:
	ln -sf $(CURDIR)/vim ~/.vim
~/.vimrc:
	ln -sf $(CURDIR)/vimrc ~/.vimrc

init-zsh: \
	~/.zshrc

~/.zshrc:
	ln -sf $(CURDIR)/zshrc ~/.zshrc

init-tmux: ~/.tmux.conf
~/.tmux.conf:
	ln -sf $(CURDIR)/tmux.conf ~/.tmux.conf

init-git: \
	~/.gitconfig \
	~/.config/git
~/.gitconfig:
	ln -sf $(CURDIR)/gitconfig ~/.gitconfig
~/.config/git: ~/.config
	ln -sf $(CURDIR)/git ~/.config/git

init-editorconfig: ~/.editorconfig
~/.editorconfig:
	ln -sf $(CURDIR)/.editorconfig ~/.editorconfig
