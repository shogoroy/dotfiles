.PHONY: \
	clean

all: \
	clean \
	install

install: \
	init-nvim

clean:
	-rm ~/.config/nvim/init.vim

init-nvim: \
	~/.config/nvim/init.vim

~/.config/nvim:
	mkdir -p ~/.config/nvim

~/.config/nvim/init.vim: ~/.config/nvim
	ln -sf $(CURDIR)/nvim/init.vim ~/.config/nvim/init.vim
