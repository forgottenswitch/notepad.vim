" Disable obsolete features
set nocompatible
" Set Insert mode (rather than Normal) as the default
set insertmode
" Show line numbers column
set nu!
" Disable automatic line breaking
set textwidth=0 wrapmargin=0
" Show Syntax menu (gvim)
let do_syntax_sel_menu = 1| runtime! synmenu.vim|


" Shift selects
behave mswin
" Mouse works in terminal
set mouse=a
" Allow cursor to go 1 character past end of line
set virtualedit=onemore
" Make End go to end of line not the last character
noremap <end> <end><right>
inoremap <end> <end><right>
" When selected with shift, C/X copies/cuts
snoremap c <c-o>mQ<c-o>y<c-o>`Q
snoremap x <c-o>x
" When selected with shift, C/X copies/cuts as with Ctrl-C/X
snoremap c <c-o>mQ<c-o>"+y<c-o>`Q
snoremap x <c-o>"+x
" Ctrl-V pastes as usual
" Use Ctrl-U to get raw-character-insertion
inoremap <c-u> <c-v>
inoremap <c-v> <c-o>"+gP
nnoremap <c-v> "+gP
snoremap <c-v> x"+gP
vnoremap <c-v> x"+gP
" Ctrl-K cuts selection or line
noremap <c-k> "+dd
inoremap <c-k> <c-o>"+dd
snoremap <c-k> <c-o>"+x
vnoremap <c-k> "+x


" Ctrl-S saves the file
nnoremap <c-s> :w!<cr>
" Shift-Q quits
noremap Q :confirm qall<cr>
" F6 switches window
noremap <F6> <c-w>w
" Ctrl-A executes a command
noremap <C-a> :
inoremap <C-a> <C-o>:
" Ctrl-S saves the file
nnoremap <c-s> :w!<cr>
" Shift-Q quits
noremap Q :confirm qall<cr>
" F6 switches window
noremap <F6> <c-w>w


" Tab also completes
function! TabDwim()
    if strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$'
        return "\<Tab>"
    else
        if &omnifunc != ''
            return "\<C-X>\<C-O>"
        elseif &dictionary != ''
            return "\<C-K>"
        else
            return "\<C-N>"
        endif
    endif
endfunction
inoremap <Tab> <C-R>=notepad#TabDwim()<cr>


" Key remapping utility
function! Map_in_modes(kind, args)
	let l:modes = substitute(a:args, "^ \*\\(\[^ \]\*\\).\*", "\\1", "")
	let l:mapping = substitute(a:args, "^ \*\[^ \]\* \*\\(.\*\\)", "\\1", "")
	let l:mapping1 = l:mapping
	let l:arg_silent = ""
	for c in split(l:modes, '\zs')
		if c == "i"
			let l:mapping1 = substitute(l:mapping, "^ \*\\(\[^ \]\*\\) \*\\(.\*\\)", "\\1 <C-o>\\2", "")
		elseif c == "S"
			let l:arg_silent = "<silent>"
			continue
		else
			let l:mapping1 = l:mapping
		endif
		"echom "binding ".c.a:kind."map ".l:mapping1
		execute c.a:kind."map ".l:arg_silent." ".l:mapping1
	endfor
endfunction
command! -nargs=1 Map call Map_in_modes("", "<args>")
command! -nargs=1 Nap call Map_in_modes("nore", "<args>")


" Space starts insert mode
noremap <space> i
" Backspace ends up in insert mode
noremap <bs> i<bs>
" Left/Right ignore end of line
" Left also ignores 1 character past end of line
noremap <left> <bs>
inoremap <left> <c-o><bs>
noremap <right> <space>
inoremap <right> <c-o><space>
snoremap <left> <left>
snoremap <right> <right>
" Left does not ignore 1 character past end of line
function! BackwardChar()
	normal h
	let l:pos = getcurpos()
	if l:pos[2] == 1
		normal k$l
	endif
endfunction
Nap Sinv <left> :call notepad#BackwardChar()<cr>
" Ctrl-S saves the file
Nap invs <c-s> :w!<cr>
" Ctrl-F searches
Nap invs <c-f> /
" Ctrl-G goes to next match
noremap <c-g> n/<up>
inoremap <c-g> <c-o>n<c-o>/<up>
cmap <c-g> <cr><c-g>
" F6/Ctrl-B switch window/file
Nap invs <F6> <c-w>w
Nap invs <S-F6> <c-w>W
Nap invs <c-b> :b!<space>
if exists(":BuffergatorOpen")
    Nap Sinvs <c-b> :BuffergatorOpen<cr>
endif
" Alt-Left/Right navigate tags
Nap invs <a-left> <c-t>
Nap invs <a-right> <c-]>
" F7 toogles auto-indenting
Map invs <F7> :set invpaste paste?<bar> set pastetoggle=<F7>
" F4 goes to next/prev compiling error
Nap Sinvs <F4> :cn<cr>
Nap Sinvs <S-F4> :cp<cr>
" Ctrl-Alt-C shows errors if any
Nap Sinvs <c-a-c> :copen<bar>cwin<cr>
" Ctrl-F4 closes the current buffer
Nap Sinvs <C-F4> :confirm q<cr>
Nap Sinvs O1;5S :confirm q<cr>
" Ctrl-d is like Normal mode 'd'
Nap invs <C-d> d

" Ctrl-Alt-l redraws
Nap invs <c-a-l> :nohlsearch<bar>redraw!<cr>

" Ctrl-z undoes, Ctrl-y redoes
imap <C-z> <c-o><c-z>
noremap <C-z> :undo<bar>redraw<cr>
imap <C-y> <c-o><c-y>
noremap <C-y> :redo<bar>redraw<cr>
Map vs <C-z> <esc><c-z>
Map vs <C-y> <esc><c-y>

