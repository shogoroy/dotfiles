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
	init-ctags

clean:
	-rm ~/.config/nvim \
		~/.vimrc \
		~/.zshrc \
		~/.ctags.d \
		~/.tmux.conf

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

init-ctags: ~/.ctags.d
~/.ctags.d:
	ln -sf $(CURDIR)/ctags.d ~/.ctags.d
