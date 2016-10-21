Notepad.vim
===========

Provides conventional, Notepad-like behaviours and key bindings,
like being always in Insert mode, or having Shift select text.
That is, `:set insertmode` and `:behave mswin` with additional tweaks.

Caveats:
* Plugins are likely not to be designed for
  `:set insertmode` compatibility, and so may misbehave.
* Terminal is likely to intercept Shift-Up,Down,Home,End

# Installation
- Back up the `~/.vim` and `~/.vimrc` somewhere.
- Install [pathogen](https://github.com/tpope/vim-pathogen).
- Do `cd ~/.vim/bundle`, then `git checkout` this repo.
- Run `sh notepad.vim/update.sh` to install recommended plugins.

# Vim plugins
Plugins could be listed in `bundle/notepad.vim/dependencies`, and updated with
```sh
cd ~/.vim/bundle
sh notepad.vim/update.sh
```

Fixing a plugin misbehaving with `:set insertmode` could be done in the
`~/.vim/after/plugin/` dir.
The fixes file should probably have the same name as the plugin it fixes,
and must end with ".vim".

# License
Vim license.
