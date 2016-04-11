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
   - Do `echo > ~/.notepad.vim/rc.vim`, as it would be the vimrc of notepad.vim.
   - Add an `alias` to your `~/.bashrc`:
       * `alias notepad.vim='vim -u ~/notepad.vim/rc.vim --cmd "let &runtimepath = substitute(&runtimepath, \"[._]vim\", \".notepad.vim\", \"g\")"'`
   - Proceed with installation using `~/.notepad.vim` in place of `~/.vim`
   - Afterwards, open a new terminal window and do `notepad.vim ~/.notepad.vim/rc.vim`
* Install [pathogen](https://github.com/tpope/vim-pathogen).
* Install [vim-sensible](https://github.com/tpope/vim-sensible).
* Do `cd ~/.vim/bundle`, then `git checkout`, `ln -s`, or `cp -r` this repo.

## Post-installation


If you want the "full version" with additional plugins, then
(using `~/.notepad.vim` instead of `~/.vim` if installed there):
- Edit `~/.vim/bundle/notepad.vim/dependencies` to your liking, now or later.
- Do `cd ~/.vim/bundle && sh notepad.vim/update.sh`
- The latter could also be `alias`-ed for later in your `~/.bashrc` or somewhere:
    * `alias notepad.vim.update="(cd ~/.vim/bundle && sh notepad.vim/update.sh)"`
    * ... or even be put in a user-local `cron` or `systemd` job.

## License

Vim license. See `:help license`.
