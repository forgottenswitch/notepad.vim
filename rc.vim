" Colors
colors desert
" Consider these encodings when opening a file
set fileencodings=ucs-bom,utf-8,default,latin-1,cp1251

" Make plugins be noticed
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
" Load Vim defaults
if v:version > 740 || (v:version == 740 && has("patch2111"))
  unlet! skip_defaults_vim | source $VIMRUNTIME/defaults.vim
endif
" Disable obsolete features
set nocompatible
" Enable file type specific plugins
filetype plugin indent on
" Enable syntax highlighing
syntax on
" Set Insert mode (rather than Normal) as the default
set insertmode
" Show line numbers column
set nu
" Disable automatic line breaking
set textwidth=0 wrapmargin=0
" Tab inserts spaces
" Use ":setlocal noexpandtab" where undesired (Makefiles, etc.)
set expandtab
" Show Syntax menu (gvim)
let do_syntax_sel_menu = 1| runtime! synmenu.vim|

command! -nargs=+ SetIfExists call SetIfExistsFunc(<f-args>)
function! SetIfExistsFunc(setting, value)
  if exists("+" . a:setting)
    exec "set " . a:setting . "=" . a:value
  endif
endfunction

" Do not bell
SetIfExists belloff all

" Fix .md files
autocmd BufNewFile,BufRead *.md set filetype=markdown

" git commit message wrap
au BufNewFile,BufRead *.git/* setl textwidth=72

" C/C++: Do not highlight {} inside () as error
let c_no_curly_error = 1

" Highlights
"  trailing space as _
"  off-the-screen as $
"  tab as |
set list lcs=trail:_,extends:$,precedes:$,tab:\|\ 

" Line indents (from Yggdroot/indentLine)
"  sacrifice correctness for speed
"  use a custom character: | ¦ ┆ │ ┊
let g:indentLine_faster = 1
if $LANG == "C"
  let g:indentLine_char = '|'
else
  let g:indentLine_char = '¦'
endif

" Do not overwrite output of commands, such as "!norm ga",
" with "-- INSERT --"
au InsertEnter * call rc#DisableShowMode()
au InsertLeave * call rc#EnableShowMode()
function! rc#DisableShowMode()
  set noshowmode
endfunction
function! rc#EnableShowMode()
  set showmode
endfunction

" In Help, Enter follows a hyperlink, H goes backward in history, Shift-H forward
" (Backspace/Delete were not used due to them varying between terminals)
command! -nargs=0 MapEnterToFollowIfHelp call rc#MapEnterToFollowIfHelpFunc(<f-args>)
function! rc#MapEnterToFollowIfHelpFunc()
  if &syntax == "help"
    inoremap <buffer> <cr> <C-o><C-]>
    inoremap <buffer> h <C-o><C-t>
    inoremap <buffer> H <C-o>:tag<cr>
    "
    " Consistency with radare2
    inoremap <buffer> u <C-o><C-t>
    inoremap <buffer> U <C-o>:tag<cr>
    inoremap <buffer> f <C-o><C-]>
    inoremap <buffer> g <C-o><C-]>
  endif
endfunction
au Syntax * MapEnterToFollowIfHelp

"== Shift selects
behave mswin
" Mouse works in terminal
set mouse=a
" Allow cursor to go 1 character past end of line
set virtualedit=onemore
" Make End go to end of line not the last character
noremap <end> <end><right>
inoremap <end> <end><right>

"== When selected with shift, C/X copies/cuts
"
if has("gui_running")
  vnoremap c mQ"+y`Q<esc>
  vnoremap x "+x
  snoremap c <c-o>mQ<c-o>"+y<c-o>`Q<esc>
  snoremap x <c-o>"+x
else
  vnoremap c mQy`Q<esc>
  snoremap c <c-o>mQ<c-o>y<c-o>`Q<esc>
  snoremap x <c-o>x
endif

"== When selected with shift, T/Tab indents, D/U/Shift-Tab deindents
"= ('I' is not used so as not to clash with iW/is/ib/ip/iB text objects)
vnoremap t >gv
vnoremap <Tab> >gv
snoremap t >gv
snoremap <Tab> >gv
"
vnoremap d <gv
vnoremap u <gv
vnoremap <S-Tab> <gv
snoremap d <gv
snoremap u <gv
snoremap <S-Tab> <gv

"== When selected with shift, Shift-T / Space indent by a single column
"= (Shift-D/U/Space deindent).  Bug: Space / Shift-Space do not work.
command! -range -nargs=1 IndentLinesBy call IndentLinesByFunc(<f-args>)
function! IndentLinesByFunc(width)
  let l:saved_width = &shiftwidth
  if a:width > 0
    exec "set shiftwidth=" . (0+a:width)
    exec "norm! gv>gv"
  elseif a:width < 0
    exec "set shiftwidth=" . (0-a:width)
    exec "norm! gv<gv"
  endif
  exec "set shiftwidth=" . l:saved_width
endfunction
"
vnoremap T :IndentLinesBy 1<cr>
vnoremap <Space> :IndentLinesBy 1<cr>
snoremap T :IndentLinesBy 1<cr>
snoremap <Space> :IndentLinesBy 1<cr>
"
vnoremap D :IndentLinesBy -1<cr>
vnoremap U :IndentLinesBy -1<cr>
snoremap <S-Space> :IndentLinesBy -1<cr>
snoremap D :IndentLinesBy -1<cr>
snoremap U :IndentLinesBy -1<cr>
snoremap <S-Space> :IndentLinesBy -1<cr>

" Ctrl-Q inserts input as-is (e.g. Ctrl-Q Ctrl-I always gives TAB)
"= Provided by Vim.

" Ctrl-V pastes
" Ctrl-K cuts selection or line
if has("gui_running")
  inoremap <C-v> <C-o>"+gP
  nnoremap <C-v> "+gP
  snoremap <C-v> x"+gP
  vnoremap <C-v> x"+gP
  "
  nnoremap <C-k> "+dd
  inoremap <C-k> <c-o>"+dd
  snoremap <C-k> <c-o>"+x
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
"  It also adds <silent>
" NapV x y auto-starts the visual mode prior to command -- same as Nap x :normal!<space>vy<cr> | vnoremap x y
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
command! -nargs=+ NapC call NapFunc("<silent>", ":", "<cr>", <f-args>)
function! NapVFunc(prefix,bndprefix,postfix,key,bind)
  let l:ncmd = " ".a:prefix." ".a:key." :normal! v".a:bndprefix.a:bind.a:postfix."<cr>"
  let l:vcmd = " ".a:prefix." ".a:key." ".a:bndprefix.a:bind.a:postfix
  let l:iscmd = " ".a:prefix." ".a:key." <c-o>:normal! v".a:bndprefix.a:bind.a:postfix."<cr>"
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
  "echoerr "NapMap: ".l:nivs_cmd
  exec "nmap ".l:nivs_cmd
  exec "imap ".l:nivs_cmd
  exec "vmap ".l:nivs_cmd
  exec "smap ".l:nivs_cmd
endfunction
command! -nargs=+ NapMap call NapMapFunc(<f-args>)

""
" NapMap2 xyz n => NapMap x[z n | NapMap xOz n
"
function! NapMap2Func(key1, key2)
  let l:key11 = a:key1[0:0]."[".a:key1[2:-1]
  let l:key12 = a:key1[0:0]."O".a:key1[2:-1]
  call NapMapFunc(l:key11, a:key2)
  call NapMapFunc(l:key12, a:key2)
endfunction
command! -nargs=+ NapMap2 call NapMap2Func(<f-args>)


""
" Linux console compatibility
NapMap [25~ <S-F1>
NapMap [26~ <S-F2>
NapMap [28~ <S-F3>
NapMap [29~ <S-F4>
NapMap [31~ <S-F5>
NapMap [32~ <S-F6>
NapMap [33~ <S-F7>
NapMap [34~ <S-F8>
"
"_ Ctrl+level5+Left/Right/Backspace/Delete of qwaf
NapMap b <C-Left>
NapMap f <C-Right>
NapMap  <C-BS>
NapMap d <C-Delete>


""
" xterm normal/application mode compatibility
NapMap2 [1;2P <S-F1>
NapMap2 [1;2Q <S-F2>
NapMap2 [1;2R <S-F3>
NapMap2 [1;2S <S-F4>
NapMap2 [15;2~ <S-F5>
NapMap2 [17;2~ <S-F6>
NapMap2 [18;2~ <S-F7>
NapMap2 [19;2~ <S-F8>
NapMap2 [20;2~ <S-F9>
NapMap2 [21;2~ <S-F10>
NapMap2 [23;2~ <S-F11>
NapMap2 [24;2~ <S-F12>
"
NapMap2 [1;5P <C-F1>
NapMap2 [1;5Q <C-F2>
NapMap2 [1;5R <C-F3>
NapMap2 [1;5S <C-F4>
NapMap2 [15;5~ <C-F5>
NapMap2 [17;5~ <C-F6>
NapMap2 [18;5~ <C-F7>
NapMap2 [19;5~ <C-F8>
NapMap2 [20;5~ <C-F9>
NapMap2 [21;5~ <C-F10>
NapMap2 [23;5~ <C-F11>
NapMap2 [24;5~ <C-F12>
"
NapMap2 [1;5A <C-Up>
NapMap2 [1;5B <C-Down>
NapMap2 [1;5D <C-Left>
NapMap2 [1;5C <C-Right>
"
NapMap2 [1;2A <S-Up>
NapMap2 [1;2B <S-Down>
"
NapMap2 [1;6A <C-S-Up>
NapMap2 [1;6B <C-S-Down>
NapMap2 [1;6D <C-S-Left>
NapMap2 [1;6C <C-S-Right>
"
" Non-MSYS2 remaps
if $WINDIR == ""
  NapMap  <C-BS>
  NapMap2 [3;5~ <C-Delete>
endif
"
NapMap2 [1;5H <C-Home>
NapMap2 [1;5F <C-End>
"
NapMap2 [1;2H <S-Home>
NapMap2 [1;2F <S-End>
"
NapMap2 OH <Home>
NapMap2 OF <End>


" Ctrl-A executes a command
" Not conventional, but useful
"= Access command history with Ctrl-A Ctrl-F
Nap <C-a> :
vnoremap <C-a> :
" Ctrl-S saves
NapC <C-s> w!
" Ctrl-F searches
"= Access search history with Ctrl-F Ctrl-F
Nap <C-f> /
" Ctrl-O Ctrl-F searches backwards
Nap <C-o><C-f> ?
" Ctrl-G goes to next match
let g:surround_no_insert_mappings = 1
Nap <C-g> n
" Ctrl-O Ctrl-G goes to previous match
Nap <C-o><C-g> N
" Ctrl-N / Ctrl-P select completions
"= Provided by Vim.

" Ctrl-B switches files
"= Access file list with Ctrl-B Ctrl-D
Nap <c-b> :b!<space>

"== F6 switches windows
"= (ignoring error and location list ones)
function! NextWindowFunc(direction)
  let l:visited_windows = [ winnr() ]
  while 1
    if a:direction > 0
      wincmd w
    else
      wincmd W
    endif
    " ignore quickfix and location list windows
    if &ft != "qf"
      break
    endif
    let l:this_window = winnr()
    " avoid infinite loop
    if index(l:visited_windows, l:this_window) != -1
      break
    endif
    let l:visited_windows += [ l:this_window ]
  endwhile
endfunction
NapC <F6> call\ NextWindowFunc(1)
NapC <S-F6> call\ NextWindowFunc(-1)

" F7 toogles raw-inserting (allows to paste without auto-indent)
NapC <F7> set\ invpaste\ paste?\|\ set\ pastetoggle=<F7>

" F4 goes to next/prev compiling error
NapC <F4> cnext
NapC <S-F4> cprev
" F3 goes to next/prev occurence of word
Nap <F3> *
Nap <S-F3> #
" F8 goes to next/prev syntax error
NapC <F8> lnext
NapC <S-F8> lprev

" Ctrl-W for window operations
"= Not conventional, but useful - try e.g. Ctrl-W V,S, or Shift-L
Nap <c-w> <c-w>

" Ctrl-F4 closes file
NapC <C-F4> confirm\ bw
" Ctrl-W F4 does the same
NapC <C-w><F4> confirm\ bw

" Ctrl-Z undoes
NoremapC n <C-z> undo\|redraw
imap <C-z> <c-o>:norm <c-z><cr>
smap <C-z> <esc>:norm <c-z><cr>
vmap <C-z> <esc>:norm <c-z><cr>
" Ctrl-Y redoes
NoremapC n <C-y> redo\|redraw
imap <C-y> <c-o>:norm <c-y><cr>
smap <C-y> <esc>:norm <c-y><cr>
vmap <C-y> <esc>:norm <c-y><cr>

" Left/Right ignore end of line (but not when selecting)
set whichwrap+=[,],<,>
" Up/Down consider screen lines, not content ones
Nap <down> gj
Nap <up> gk

" Control-Right (if supported by terminal [emulator])
" goes to end of word, rather than start
nnoremap <C-Right> el
inoremap <C-Right> <c-o>e<c-o>l
vnoremap <C-Right> el
" Control-Left works when selecting
vnoremap <C-Left> b

" Alt-Left/Right navigate backward-forward
Nap <A-left> <C-o>
Nap <A-right> <C-i>

" Ctrl-Up/Down navigate/select paragraphs
Nap <C-Up> {
Nap <C-Down> }
Nap <C-S-Up> v{
Nap <C-S-Down> v}
vnoremap <C-S-Up> {
vnoremap <C-S-Down> }


" Home alterates between first non-blank and first
" (but not when selecting)
"
function! rc#Home()
  let l:pos = getpos(".")
  norm! ^
  let l:pos1 = getpos(".")
  if l:pos[2] == l:pos1[2]
    norm! g0
  endif
endfunction
NapC <Home> call\ rc#Home()

" End alterates between last and last non-blank
" (but not when selecting)
"
function! rc#End()
  let l:pos = getpos(".")
  norm! $l
  let l:pos1 = getpos(".")
  if l:pos[2] == l:pos1[2]
    norm! g_l
  endif
endfunction
NapC <End> call\ rc#End()

" Selection could be extended with no Shift
vnoremap <Left> <S-Left>
vnoremap <Right> <S-Right>
vnoremap <Up> <S-Up>
vnoremap <Down> <S-Down>
vnoremap <PageUp> <S-PageUp>
vnoremap <PageDown> <S-PageDown>
vnoremap <Home> ^
vnoremap <S-Home> g0
vnoremap <End> $
vnoremap <S-End> g_l


" Ctrl-Backspace/Delete delete a word
"  Bug: Undo gets to wrong end of word with Ctrl-Backspace
Nap <C-BS> "_db
Nap <C-Delete> "_de
Nap  "_db

" Backspace deletes a selection
vnoremap <BS> "_x


" Ctrl-L goes to line
function! rc#GotoLine(...)
  if a:0 < 1
    call inputsave()
    let l:lineno = input("Goto line: ")
    call inputrestore()
  else
    let l:lineno = a:1
  endif
  "
  let l:lineno1 = substitute(l:lineno, "[^0-9]", "", "g")
  if (l:lineno != l:lineno1) || (strlen(l:lineno1) == 0)
    return
  endif
  exec "norm! ".l:lineno1."G"
endfunction
command! -nargs=* GotoLine call rc#GotoLine(<f-args>)
NapC <C-l> GotoLine


" Ctrl-T is a selection key
"
"_ Unbind the Vim Ctrl-T
inoremap <c-t> <c-o>:<esc>
"
" Ctrl-T 1 or 0 selects
" Ctrl-T 2 selects line-wise
" Ctrl-T 3 selects rectangular as much as possible
" Ctrl-T 4 selects rectangular (unimplemented - currently the same as Ctrl-T 3)
"
" The explicit NapC A norm B is used instead of Nap A B,
" as the latter sometimes gets interpreted as Insert binding
NapC <C-t>0 norm!\ v
NapC <C-t>1 norm!\ v
NapC <C-t>2 norm!\ V
NapC <C-t>3 norm!\ <c-v><c-v>
NapC <C-t>4 norm!\ <c-v><c-v>
"
" Ctrl-T Ctrl-A executes ('selects') a menu command
source $VIMRUNTIME/menu.vim
Nap <C-t><C-a> :emenu<space>
"
" Ctrl-T a/g/G select all, to-start, to-end
NapC <C-t>a norm!\ Gvgg
NapC <C-t>g norm!\ vgg
NapC <C-t>G norm!\ vG
"
" Ctrl-T T/Ctrl-T resumes the last selection
NapC <C-t>t norm!\ gv
NapC <C-t><C-t> norm!\ gv
"
" Ctrl-T Left/Right shortcuts
NapV <C-t><left> h
NapV <C-t><right> l
"
" Ctrl-T Up/Down shortcuts
NapC <C-t><up> norm!\ V
NapC <C-t><down> norm!\ V
"
" Ctrl-T Home/End select to absolute line beginning/end
inoremap <C-t><Home> <c-o>vg0
inoremap <C-t><End> <c-o>vg_
vnoremap <C-t><Home> g0
vnoremap <C-t><End> g_
"
" Ctrl-T Ctrl-Home/End shortcuts
NapV <C-t><C-Home> gg
NapV <C-t><C-End> G
"
" Ctrl-T H clears highlights (from searching)
NapC <C-t>h nohlsearch\|if\ has('diff')\|diffupdate\|endif\|redraw!
"
" Ctrl-T M places a mark
Nap <C-t>m m
" Ctrl-T J goes to a mark
"= (or just J when there is a selection)
"= Also, pseudo-marks (<[{ are available
Nap <C-t>j `
vnoremap j `
snoremap j `
" Ctrl-T Shift-J lists marks
NapC <C-t>J marks


" Ctrl-T Ctrl-A does a "strong selection" ("as in Ctrl-A")
"
" Ctrl-T Ctrl-A Home/End act as Ctrl-T Ctrl-Home
NapV <C-t><C-a><Home> gg
NapV <C-t><C-a><End> G
"
" Ctrl-T Ctrl-A Up/Down selects paragraphs
NapV <C-t><C-a><Up> {
NapV <C-t><C-a><Down> }


" Ctrl-T S/Ctrl-S saves as
"
Nap <C-t><C-s> :w<space><c-r>=bufname("")<cr>
Nap <C-t>s :w<space><c-r>=bufname("")<cr>


" Ctrl-T Ctrl-K/Delete cuts forward
"
if has("gui_running")
  Nap <c-t><c-k> \"+d$
  Nap <c-t><delete> \"+d$
  xnoremap <c-t><c-k> "+x
  xnoremap <c-t><delete> "+x
else
  Nap <c-t><c-k> d$
  Nap <c-t><delete> d$
  xnoremap <c-t><c-k> x
  xnoremap <c-t><delete> x
endif
"
" Ctrl-T Ctrl-H/Backspace cuts backward
"
if has("gui_running")
  Nap <c-t><c-h> \"+dg0
  Nap <c-t><bs> \"+dg0
  xnoremap <c-t><c-h> "+x
  xnoremap <c-t><bs> "+x
else
  Nap <c-t><c-h> dg0
  Nap <c-t><bs> dg0
  xnoremap <c-t><c-h> x
  xnoremap <c-t><bs> x
endif

"
" Ctrl-T N opens a new tab
NapC <C-t>n tabnew
" Ctrl-T Ctrl-W closes window
" (not a tab, since it would be closed when no windows would be left)
NapC <C-t><C-w> close
"
" Ctrl-T PageUp/PageDown switch tabs
NapC <C-t><PageUp> tabprev
NapC <C-t><PageDown> tabnext
" Ctrl-T Ctrl-N/P switch tabs
"= The analogy is with Ctrl-N/P that switch completion choices
NapC <C-t><C-n> tabnext
NapC <C-t><C-p> tabprev
"
" Ctrl-T W closes window
NapC <C-t>w close
"
" Ctrl-T F4 closes file
NapC <C-t><F4> confirm\ bw


" Ctrl-T 8 describes current character
NapC <C-t>8 norm!\ ga

" Ctrl-T Ctrl-O reflows current paragraph
"
NapC <C-t><C-o> norm!\ gqip

" Ctrl-E goes to pair brace
Nap <C-e> %
vnoremap <C-e> %
Nap <C-t><C-e> v%
vnoremap <C-t><C-e> %


" Ctrl-O is source code key
"
" Ctrl-O 3/2/1 navigate Excuberant Ctags and Vim help
Nap <C-o>1 <C-t>
Nap <C-o>2 <C-]>
Nap <C-o>3 g]
"
" Ctrl-O Ctrl-A executes ("developer's") command-line
Nap <C-o><C-a> :!
"
" Ctrl-O Ctrl-Z suspends ("goes to developer's console")
Nap <C-o><C-z> <C-z>
" Ctrl-O Tilde does the same
Nap <C-o>` <C-z>
Nap <C-o>~ <C-z>
"
" Ctrl-O M runs make
NapC <C-o>m !make
"
" Ctrl-O PageUp/Down go to prev/next file
NapC <C-o><PageUp> confirm\ prev
NapC <C-o><PageDown> confirm\ next
" Ctrl-O Home/End rewind files
NapC <C-o><Home> confirm\ first
NapC <C-o><End> confirm\ last
"
" Ctrl-O E starts file opening with the path to current file
Nap <C-o>e :e<space><c-r>=bufname("")<cr>
" Ctrl-O Ctrl-E edits the file under cursor
Nap <C-o><C-e> gf
"
" Ctrl-O F4/F8 show errors/locations
NapC <C-o><F4> botright\ copen
NapC <C-o><F8> lopen
" Ctrl-O Ctrl-O/O do the same
NapC <C-o><C-o> botright\ copen
NapC <C-o>o lopen
"
" Ctrl-O Ctrl-N/P switch error lists
NapC <C-o><C-n> cnewer
NapC <C-o><C-p> colder
" Ctrl-O Ctrl-W close error list
NapC <C-o><C-w> cclose
"
" Ctrl-O N/P switch location lists
NapC <C-o>n lnewer
NapC <C-o>p lolder
" Ctrl-O W close location list
NapC <C-o>w lclose
"
" Ctrl-O Ctrl-R inserts a file-specific string (R also asks for)
"
function! rc#InsertFileSpecificString(ask)
  if !exists("b:FileSpecificString")
    let b:FileSpecificString = ""
  endif
  if a:ask != 0 || strlen(b:FileSpecificString) <= 0
    call inputsave()
    let b:FileSpecificString = input("File-specific string: ")
    call inputrestore()
  endif
  exec "norm! i".b:FileSpecificString
  exec "norm! l"
endfunction
command! AskingFileSpecificString call rc#InsertFileSpecificString(1)
command! InsertFileSpecificString call rc#InsertFileSpecificString(0)
NapC <C-o><C-r> InsertFileSpecificString
NapC <C-o>r AskingFileSpecificString
"
" Ctrl-O Ctrl-K/Backspace cut forward/backward
map <C-o><C-k> <C-t><C-k>
map <C-o><C-h> <C-t><C-h>
map <C-o><bs> <C-t><bs>
imap <C-o><C-k> <C-t><C-k>
imap <C-o><C-h> <C-t><C-h>
imap <C-o><bs> <C-t><bs>
"
" Ctrl-O Y toggles syntax checking on save
NapC <C-o>y SyntasticToggleMode
"
" Ctrl-O Ctrl-Y opens syntax errors list
NapC <C-o><C-y> Errors

"=

"== Indent width is controlled with :I<N>
"
command! -nargs=1 I call SetIndent(<f-args>)
function! SetIndent(n)
  exec "setl sw=" . a:n . ""
  exec "IndentLinesReset"
endfunction
