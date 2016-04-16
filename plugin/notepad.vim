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


" Ctrl-U inserts input as-is, like Ctrl-V in shell,
" and/or Ctrl-Shift-U Unicode input in Gtk+.
" The mapping won't work right there, and must be delayed.
function! notepad#Bind_ctrl_u_to_raw_insert()
    inoremap <C-u> <C-v>
endfunction
autocmd VimEnter * call notepad#Bind_ctrl_u_to_raw_insert()

" Ctrl-V pastes
" Ctrl-K cuts selection or line
if has("x11")
    inoremap <C-v> <C-o>"+gP
    nnoremap <C-v> "+gP
    snoremap <C-v> x"+gP
    vnoremap <C-v> x"+gP
    "
    nnoremap <C-k> "+dd
    inoremap <C-k> <c-o>"+dd
    snoremap <C-k> <c-o>"+x
    vnoremap <C-k> "+x
elseif has("win16") || has("win32") || has("win64")
    inoremap <C-v> <C-o>"*gP
    nnoremap <C-v> "*gP
    snoremap <C-v> x"*gP
    vnoremap <C-v> x"*gP
    "
    nnoremap <C-k> "*dd
    inoremap <C-k> <c-o>"*dd
    snoremap <C-k> <c-o>"*x
    vnoremap <C-k> "+x
else
    inoremap <C-v> <C-o>gP
    nnoremap <C-v> gP
    snoremap <C-v> "*xgP
    vnoremap <C-v> "*xgP
    "
    nnoremap <C-k> dd
    inoremap <C-k> <c-o>dd
    snoremap <C-k> <c-o>x
    vnoremap <C-k> x
endif


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
" NapV x y auto-starts the visual mode prior to command -- same as Nap x :norm<space>vy<cr> | vnoremap x y
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
function! NapVFunc(prefix,bndprefix,postfix,key,bind)
    let l:ncmd = " ".a:prefix." ".a:key." :normal v".a:bndprefix.a:bind.a:postfix."<cr>"
    let l:vcmd = " ".a:prefix." ".a:key." ".a:bndprefix.a:bind.a:postfix
    let l:iscmd = " ".a:prefix." ".a:key." <c-o>:normal v".a:bndprefix.a:bind.a:postfix."<cr>"
    " echoerr "NapV: ".l:ncmd
    exec "nnoremap ".l:ncmd
    exec "inoremap ".l:iscmd
    exec "vnoremap ".l:vcmd
    exec "snoremap ".l:iscmd
endfunction
command! -nargs=+ NapV call NapVFunc("", "", "", <f-args>)


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
imap <C-z> <c-o>:norm <c-z><cr>
smap <C-z> <esc>:norm <c-z><cr>
vmap <C-z> <esc>:norm <c-z><cr>
" Ctrl-y redoes
NoremapC n <C-y> redo\|redraw
imap <C-y> <c-o>:norm <c-y><cr>
smap <C-y> <esc>:norm <c-y><cr>
vmap <C-y> <esc>:norm <c-y><cr>

" Up/Down work in visual mode
vnoremap <down> j
vnoremap <up> k
" Home/End work in visual mode
vnoremap <home> ^
vnoremap <end> $

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
	let l:pos = getpos(".")
	normal h
	if l:pos[2] == 1
		normal k$l
	endif
endfunction
NapC <left> call\ <SID>Left()
vnoremap <left> <bs>
" Up/Down consider screen lines, not content ones
noremap <down> gj
noremap <up> gk

" Alt-Left/Right navigate backward-forward
Nap <A-left> <C-o>
Nap <A-right> <C-i>

" Ctrl-T is a selection key
" The explicit NapC A norm B is used instead of Nap A B,
" as the latter sometimes gets interpreted as Insert binding
"
" Ctrl-T 0 selects
" Ctrl-T 1 selects line-wise
" Ctrl-T 2 selects rectangular
" Ctrl-T 3 selects rectangular as much as possible
NapC <C-t>0 norm\ v
NapC <C-t>1 norm\ V
NapC <C-t>2 norm\ <C-v>
NapC <C-t>3 norm\ <C-v>
"
" Ctrl-T S/L/R => select, linewise, rectangular
NapC <C-t>l norm\ V
NapC <C-t>s norm\ v
NapC <C-t>r norm\ <C-v>
"
" Ctrl-T Ctrl-A executes ('selects') a menu command
source $VIMRUNTIME/menu.vim
Nap <C-t><C-a> :emenu<space>
"
" Ctrl-T a/g/G
NapC <C-t>a norm\ Gvgg
NapC <C-t>g norm\ vgg
NapC <C-t>G norm\ vG
"
" Ctrl-T Left/Right shortcuts
NapV <C-t><left> h
NapV <C-t><right> l
"
" Ctrl-T Up/Down shortcuts
NapC <C-t><up> norm\ V
NapC <C-t><down> norm\ V
"
" Ctrl-T Home/End shortcuts
NapV <C-t><Home> ^
NapV <C-t><End> $
"
" Ctrl-T Ctrl-Home/End shortcuts
NapV <C-t><C-Home> gg
NapV <C-t><C-End> G


" Control + Double T is the Control-selection key
"
imap <C-t>t <C-t><C-t>
map <C-t>t <C-t><C-t>
" Ctrl-TT Home/End act as Ctrl-T Ctrl-Home
NapV <C-t><C-t><Home> gg
NapV <C-t><C-t><End> G
"
" Ctrl-TT Up/Down selects paragraphs
NapV <C-t><C-t><Up> {
NapV <C-t><C-t><Down> }


" Ctrl-O is the source code key
"
" Ctrl-O Left/Right navigate Excuberant Ctags and Vim help
Nap <C-o><left> <C-t>
Nap <C-o><right> <C-]>
"
" Ctrl-O H/L do the same
Nap <C-o>h <C-t>
Nap <C-o>l <C-]>
"
" Ctrl-O Ctrl-A executes ("developer's") command-line
Nap <C-o><C-a> :!
"
" Ctrl-O Ctrl-Z suspends ("goes to developer's console")
Nap <C-o><C-z> <C-z>
"
" Ctrl-O M runs make
NapC <C-o>m !make

