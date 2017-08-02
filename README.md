GUI-like customizations for vim.

- `Ctrl-S` saves
- `Ctrl-T` selects
  * `1` for by-chars, `2` for by-lines, `3` for rectangle, `a` for select-all
  * `C` then copies, `X` cuts
- `Ctrl-Z` undoes, `Ctrl-O Ctrl-Z` suspends
- `Ctrl-V` pastes
- `Ctrl-A` enters the `:` prompt

[List of keybindings](SHORTCUTS.txt).  Cursor keys are expected to be provided
by keyboard layout, such as [qwaf](https://github.com/forgottenswitch/qwaf).
For ergonomics, CapsLock should be made a Control as well.

Misfeatures:
* Breaks plugins where they do not expect `set insertmode`
* Terminal emulators by default intercept `Shift-Up,Down,Home,End`

Installation
------------
- Back up the `~/.vim` and `~/.vimrc` somewhere.
- `git clone` this repo as `~/.vim`
- `git submodule update --init --recursive`
- Put into `~/.vimrc`:
```
source $HOME/.vim/rc.vim
```
