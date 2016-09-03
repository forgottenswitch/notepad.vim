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
- In `~/.vim/bundle`, run: `notepad.vim/update.sh`.

# Adding a plugin
First, the plugin could just be `git checkout`-ed into `bundle/`, as usual with pathogen.
However, this has the disadvantage of being hard-to-remember what-is-what.

So, the `bundle/notepad.vim/dependencies` file could be edited, adding a new entry.
There, a comment is possible, providing a reminder of what the
[vim-sleuth](https://github.com/tpope/vim-sleuth), etc. is.
Then run `sh notepad.vim/update.sh`.

Finally, the plugin may not be destined for `:set insertmode`.
If this is the case, check the plugin documentation for workaround, and then either:
* Report the issue to plugin maintainer and wait for it to be fixed.
* Fix it yourself, adding a vimscript file containing the fixes
  to `~/.vim/after/plugin/`.
  The fixes file should probably have the same name as the plugin it fixes,
  and must end with ".vim".

# License
Vim license. See `:help license`.

