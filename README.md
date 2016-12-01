Notepad.vim
===========

`Ctrl-ZXCV`-ish vim config (a more complete `:set insertmode` and `:behave mswin`).

[Keybindings list](SHORTCUTS.txt).
HJKL keys could be provided with [qwaf](https://github.com/forgottenswitch/qwaf).

Running
-------
- Back up the `~/.vim` and `~/.vimrc` somewhere.
- Install [pathogen](https://github.com/tpope/vim-pathogen).
- Do `cd ~/.vim/bundle`, then `git checkout` this repo.

Caveats
-------
* Breaks plugins, as they do not expect `set insertmode`
* Terminal emulators by default intercept `Shift-Up,Down,Home,End`
* Misses clipboard integration, text objects.
  Word navigation could not work depending on the terminal.

Plugin manager
--------------
Plugins could be listed in `~/.vim/bundle/notepad.vim/dependencies`,
and updated with the following shell command:
```sh
sh ~/.vim/bundle/notepad.vim/update.sh
```
They are then installed into `~/.vim/bundle`.
