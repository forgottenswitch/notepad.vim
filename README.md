# notepad.vim

Provides conventional, Notepad-like behaviours and key bindings,
like being always in Insert mode, or having Shift select text.
That is, `:set insertmode` and `:behave mswin` with additional tweaks.

Caveats:

* Plugins are likely not to be designed for `:set insertmode` compatibility, and so may misbehave.
* Terminal is likely to intercept Shift-Up,Down,Home,End

## Installation

* Install [pathogen](https://github.com/tpope/vim-pathogen).
* Install [vim-sensible](https://github.com/tpope/vim-sensible).
* Do `cd ~/.vim/bundle`, then `git checkout`, `ln -s`, or `cp -r` this repo.

## License

Vim license. See `:help license`.
