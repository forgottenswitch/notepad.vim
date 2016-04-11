# notepad.vim

Provides conventional, Notepad-like behaviours and key bindings,
like being always in Insert mode, or having Shift select text.
That is, `:set insertmode` and `:behave mswin` with additional tweaks.

Caveats:

* Plugins are likely not to be designed for `:set insertmode` compatibility, and so may misbehave.
* Terminal is likely to intercept Shift-Up,Down,Home,End

## Installation

* If you do not want to touch your current configuration:
   - Do `mkdir ~/.notepad.vim`
   - Do `echo > ~/.notepad.vim/rc.vim`, as it would be the vimrc of notepad.vim
   - Add an `alias` to your `~/.bashrc`:
       * `alias notepad.vim='vim -u ~/notepad.vim/rc.vim --cmd "let &runtimepath = substitute(&runtimepath, \"[._]vim\", \".notepad.vim\", \"g\")"'`
   - Proceed with installation using `~/.notepad.vim` in place of `~/.vim`
   - Afterwards, open a new terminal window and do `notepad.vim ~/.notepad.vim/rc.vim`
* Install [pathogen](https://github.com/tpope/vim-pathogen).
* Install [vim-sensible](https://github.com/tpope/vim-sensible).
* Do `cd ~/.vim/bundle`, then `git checkout`, `ln -s`, or `cp -r` this repo.

## Post-installation, or Plugins

If you want the "full version" with additional plugins, then
(using `~/.notepad.vim` instead of `~/.vim` if installed there):
- Edit `~/.vim/bundle/notepad.vim/dependencies` to your liking, now or later.
- Do `cd ~/.vim/bundle && sh notepad.vim/update.sh`

To update the plugins:
* Add an `alias` to `~/.bashrc`:
    - `alias notepad.vim.update="(cd ~/.vim/bundle && sh notepad.vim/update.sh)"`
* Then do `notepad.vim.update` whenever you want the plugins to be updated.

To disable a plugin, say scrooloose's [syntastic](https://github.com/scrooloose/syntastic):
* First, add an `alias` to `~/.bashrc`:
    - `alias notepad.vim.disable="(cd ~/.vim/bundle && sh notepad.vim/update.sh --off)"`
* Do `notepad.vim.disable scrooloose syntastic`. This will:
    - Remove `syntastic` folder from `bundle/`
    - Comment out `scrooloose syntastic` line in `bundle/notepad.vim/dependencies`

To re-enable the plugin, uncomment it in `~/.vim/bundle/notepad.vim/dependencies`, then run `notepad.vim.update`.

### Adding a plugin

First, the plugin could just be `git checkout`-ed into `bundle/`, as usual with pathogen.
However, this has the disadvantage of being hard-to-remember what-is-what.

So, the `bundle/notepad.vim/dependencies` file could be edited, adding a new entry.
There, a comment is possible, providing a reminder of what the [vim-sleuth](https://github.com/tpope/vim-sleuth), etc. is.
Then run `notepad.vim.update`.

Finally, the plugin may not be destined for `:set insertmode`.
If this is the case, check the plugin documentation for workaround, and then either:
* Report the issue to plugin maintainer and wait for it to be fixed.
* Fix it yourself, adding a vimscript file containing the fixes to `~/.vim/after/plugin/`.
  The fixes file should probably have the same name as the plugin it fixes, and must end with ".vim".

## License

Vim license. See `:help license`.

