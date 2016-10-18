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
- Do `cd ~/.vim/bundle`, then `git checkout`, `ln -s`, or `cp -r` this repo.
- In `~/.vim/bundle`, run: `sh notepad.vim/update.sh`.

# Adding a plugin
First, the plugin could just be `git checkout`-ed into `bundle/`, as usual with pathogen.
However, this has the disadvantage of being hard-to-remember what-is-what.

So, the `bundle/notepad.vim/dependencies` file could be edited, adding a new entry.
There, a comment is possible, providing a reminder of what the
[vim-sleuth](https://github.com/tpope/vim-sleuth), etc. is.
Then run `sh notepad.vim/update.sh`.

Fixing a plugin misbehaving with `:set insertmode` could be done in the
`~/.vim/after/plugin/` dir.
The fixes file should probably have the same name as the plugin it fixes,
and must end with ".vim".

# License
Vim license. See `:help license`.

