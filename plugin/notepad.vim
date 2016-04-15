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
inoremap <C-v> <C-o>"+gP
nnoremap <C-v> "+gP
snoremap <C-v> x"+gP
vnoremap <C-v> x"+gP

" Ctrl-U inserts input as-is, like Ctrl-V in shell,
" and/or Ctrl-Shift-U Unicode input in Gtk+.
" The mapping won't work right there, and must be delayed.
function! notepad#Bind_ctrl_u_to_raw_insert()
    inoremap <C-u> <C-v>
endfunction
autocmd VimEnter * call notepad#Bind_ctrl_u_to_raw_insert()

" Ctrl-K cuts selection or line
nnoremap <c-k> "+dd
inoremap <c-k> <c-o>"+dd
snoremap <c-k> <c-o>"+x
vnoremap <c-k> "+x


" Tab also completes
function! s:CompleteOrTab()
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
inoremap <Tab> <C-R>=<SID>CompleteOrTab()<cr>


" Space starts insert mode
noremap <space> i
" Backspace starts insert mode
noremap <bs> i


""
" Key remapping utility
" Defines mapping for use in Insert, Normal, Visual, Select modes.
"
"   Nap x y
" becomes
"   nnoremap x y      -- that is, when in Normal, execute 'y' as if no custom key-bindings are in effect.
"   inoremap x <c-o>y -- that is, when not in Insert, get to Normal for single command, and do y.
"   vnoremap x <c-o>y
"   snoremap x <c-o>y
"
" NapC x y does the same, but with 'y' surrounded by : and <cr> -- same as Nap x :y<cr>
" NapCsil x y does Nap x :y<cr> with a <silent>
"
" Should the binding have two commands, y and z, the following would need to be done:
"   nnoremap x yz              -- that is, when in Normal, execute y, execute z.
"   Noremap ivs x <c-o>y<c-o>z -- that is, when in Insert,Visual,Select, get to Normal for single command, execute y, do the same for z.
"     which becomes
"       inoremap x <c-o>y...
"       vnoremap ...
"       snoremap ...
"
function! NapFunc(prefix,bndprefix,postfix,key,bind)
    let l:ncmd = " ".a:prefix." ".a:key." ".a:bndprefix.a:bind.a:postfix
    let l:ivscmd = " ".a:prefix." ".a:key." <c-o>".a:bndprefix.a:bind.a:postfix
    " echoerr "Nap: ".l:ncmd
    exec "nnoremap ".l:ncmd
    exec "inoremap ".l:ivscmd
    exec "vnoremap ".l:ivscmd
    exec "snoremap ".l:ivscmd
endfunction
command! -nargs=+ Nap call NapFunc("", "", "", <f-args>)
command! -nargs=+ NapC call NapFunc("", ":", "<cr>", <f-args>)
command! -nargs=+ NapCsil call NapFunc("<silent>", ":", "<cr>", <f-args>)


""
" Noremap ivs x y => inoremap x y | vnoremap x y | snoremap x y
" Noremap i\  x y => inoremap x y | noremap x y
" There are also Nap..-like:
"  NoremapC, NoremapCsil
"
function! NoremapFunc(prefix,bndprefix,postfix,modes,key,bind)
    let l:mapcmd = " ".a:prefix." ".a:key." ".a:bndprefix.a:bind.a:postfix
    " echoerr "Noremap: ".l:mapcmd
    for m in split(a:modes, '\zs')
	exec l:m."noremap ".l:mapcmd
    endfor
endfunction
command! -nargs=+ Noremap call NoremapFunc("", "", "", <f-args>)
command! -nargs=+ NoremapC call NoremapFunc("", ":", "<cr>", <f-args>)
command! -nargs=+ NoremapCsil call NoremapFunc("<silent>", ":", "<cr>", <f-args>)

""
" NapMap => imap x y | vmap x y | smap x y | nmap x y
"
function! NapMapFunc(key1, key2)
    let l:nivs_cmd = " ".a:key1." ".a:key2
    " echoerr "NapMap: ".l:nivs_cmd
    exec "nmap ".l:nivs_cmd
    exec "imap ".l:nivs_cmd
    exec "vmap ".l:nivs_cmd
    exec "smap ".l:nivs_cmd
endfunction
command! -nargs=+ NapMap call NapMapFunc(<f-args>)
""
" xterm (VT220 ?) compatibility
"
NapMap O1;2Q <S-F2>
NapMap O1;2R <S-F3>
NapMap O1;2S <S-F4>
"
NapMap O1;5Q <C-F2>
NapMap O1;5R <C-F3>
NapMap O1;5S <C-F4>
"
NapMap [1;5D <C-Left>
NapMap [1;5B <C-Down>
NapMap [1;5A <C-Up>
NapMap [1;5C <C-Left>


" Ctrl-A executes a command
" Not conventional, but useful
Nap <c-a> :
" Ctrl-S saves
NapC <c-s> w!
" Ctrl-F searches
Nap <c-f> /
" Ctrl-G goes to next match
noremap <c-g> n/<up>
inoremap <c-g> <c-o>n<c-o>/<up>
cmap <c-g> <cr><c-g>
" F6/Ctrl-B switch window/file
Nap <F6> <c-w>w
Nap <S-F6> <c-w>W
Nap <c-b> :b!<space>

" Alt-Left/Right navigate tags backward-forward
Nap <a-left> <c-t>
Nap <a-right> <c-]>

" F7 toogles raw-inserting
NapC <F7> set\ invpaste\ paste?\|\ set\ pastetoggle=<F7>

" F4 goes to next/prev compiling error
NapCsil <F4> cn
NapCsil <S-F4> cp
" F3 goes to next/prev occurence of word
Nap <F3> *
Nap <S-F3> #

" Ctrl-Alt-c shows errors if any
NapC <c-a-c> copen\|cwin

" Ctrl-F4 closes file
NapC <C-F4> confirm\ q
" Ctrl-w for window operations
" Not conventional, but useful
Nap <c-w> <c-w>

" Ctrl-l redraws, also clearing search highlightings
NapC <c-l> nohlsearch\|if\ has('diff')\|diffupdate\|endif\|redraw!

" Ctrl-z undoes
NoremapC n <C-z> undo\|redraw
imap <C-z> <c-o><c-z>
smap <C-z> <esc><c-z>
vmap <C-z> <esc><c-z>
" Ctrl-y redoes
NoremapC n <C-y> redo\|redraw
imap <C-y> <c-o><c-y>
smap <C-y> <esc><c-y>
vmap <C-y> <esc><c-y>

" Left/Right ignore end of line
" Left also ignores 1 character past end of line
noremap <left> <bs>
inoremap <left> <c-o><bs>
noremap <right> <space>
inoremap <right> <c-o><space>
snoremap <left> <left>
snoremap <right> <right>
" Left does not ignore 1 character past end of line
function! s:Left()
	let l:pos = getcurpos()
	normal h
	if l:pos[2] == 1
		normal k$l
	endif
endfunction
NapC <left> call\ <SID>Left()

