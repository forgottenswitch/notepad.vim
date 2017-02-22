" Disable obsolete features
set nocompatible
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

" Fix .md files
autocmd BufNewFile,BufRead *.md set filetype=markdown

" Do not overwrite output of commands, such as "!norm ga",
" with "-- INSERT --"
au InsertEnter * call notepad#DisableShowMode()
au InsertLeave * call notepad#EnableShowMode()
function! notepad#DisableShowMode()
  set noshowmode
endfunction
function! notepad#EnableShowMode()
  set showmode
endfunction

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


" Ctrl-U inserts input as-is, like Ctrl-V in shell,
" and/or Ctrl-Shift-U Unicode input in Gtk+.
" The mapping won't work right there, and must be delayed.
function! notepad#Bind_ctrl_u_to_raw_insert()
    inoremap <C-u> <C-v>
endfunction
autocmd VimEnter * call notepad#Bind_ctrl_u_to_raw_insert()

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

" Tab also completes
function! notepad#CompleteOrTab()
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
inoremap <Tab> <C-R>=notepad#CompleteOrTab()<cr>


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
command! -nargs=+ NapC call NapFunc("", ":", "<cr>", <f-args>)
command! -nargs=+ NapCsil call NapFunc("<silent>", ":", "<cr>", <f-args>)
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
Nap <C-a> :
vnoremap <C-a> :
" Ctrl-S saves
NapC <C-s> w!
" Ctrl-F searches
Nap <C-f> /
" Ctrl-G goes to next match
let g:surround_no_insert_mappings = 1
Nap <C-g> n
" F6/Ctrl-B switch window/file
Nap <F6> <c-w>w
Nap <S-F6> <c-w>W
Nap <c-b> :b!<space>

" F7 toogles raw-inserting (allows to paste without auto-indent)
NapC <F7> set\ invpaste\ paste?\|\ set\ pastetoggle=<F7>

" F4 goes to next/prev compiling error
NapCsil <F4> cnext
NapCsil <S-F4> cprev
" F3 goes to next/prev occurence of word
Nap <F3> *
Nap <S-F3> #
" F8 goes to next/prev syntax error
NapCsil <F8> lnext
NapCsil <S-F8> lprev

" Ctrl-Alt-c shows errors if any
NapC <c-a-c> copen\|cwin

" Ctrl-W for window operations
" Not conventional, but useful
Nap <c-w> <c-w>

" Ctrl-F4 closes file
" Ctrl-W C does the same
" Use :q to close a window
NapC <C-F4> confirm\ bw
NapC <C-w>c confirm\ bw

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
function! notepad#Home()
    let l:pos = getpos(".")
    norm! ^
    let l:pos1 = getpos(".")
    if l:pos[2] == l:pos1[2]
        norm! g0
    endif
endfunction
NapC <Home> call\ notepad#Home()

" End alterates between last and last non-blank
" (but not when selecting)
"
function! notepad#End()
    let l:pos = getpos(".")
    norm! $l
    let l:pos1 = getpos(".")
    if l:pos[2] == l:pos1[2]
        norm! g_l
    endif
endfunction
NapC <End> call\ notepad#End()

" In terminal, selection could be extended with no Shift
if has("gui_running")
else
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
endif


" Ctrl-Backspace/Delete delete a word
" Bug: Undo gets to wrong end of word with Ctrl-Backspace
Nap <C-BS> "_db
Nap <C-Delete> "_de
Nap  "_db

" Backspace deletes a selection
vnoremap <BS> "_x


" Ctrl-L goes to line
function! notepad#GotoLine(...)
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
command! -nargs=* GotoLine call notepad#GotoLine(<f-args>)
NapC <C-l> GotoLine


" Ctrl-T is a selection key
"
" Unbind the Vim Ctrl-T
inoremap <c-t> <c-o>:<esc>
"
" Ctrl-T 1 or 0 selects
" Ctrl-T 2 selects line-wise
" Ctrl-T 4 selects rectangular
" Ctrl-T 3 selects rectangular as much as possible
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
" Ctrl-T Ctrl-L clears search highlights
NapC <C-t><C-l> nohlsearch\|if\ has('diff')\|diffupdate\|endif\|redraw!


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


" Ctrl-T Ctrl-S saves as
"
Nap <C-t><C-s> :w<space><c-r>=bufname("")<cr>


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


" Ctrl-T Ctrl-N inserts a file-specific string (N also asks for)
"
function! notepad#InsertFileSpecificString(ask)
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
command! AskingFileSpecificString call notepad#InsertFileSpecificString(1)
command! InsertFileSpecificString call notepad#InsertFileSpecificString(0)
NapC <C-t><C-n> InsertFileSpecificString
NapC <C-t>n AskingFileSpecificString

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
" Ctrl-O 2/1 navigate Excuberant Ctags and Vim help
Nap <C-o>1 <C-t>
Nap <C-o>2 <C-]>
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
" Ctrl-OO edits the file under cursor
Nap <C-o><C-o> gf
"
" Ctrl-OE "explores"
function! notepad#Explorer()
  Sexplore!
endfunction
NapC <C-o><C-e> call\ notepad#Explorer()
"
" Ctrl-O F4/F8 show errors
NapC <C-o><F4> cwin
NapC <C-o><F8> lwin
"
" Ctrl-O Ctrl-K/Backspace cut forward/backward
map <C-o><C-k> <C-t><C-k>
map <C-o><C-h> <C-t><C-h>
map <C-o><bs> <C-t><bs>
imap <C-o><C-k> <C-t><C-k>
imap <C-o><C-h> <C-t><C-h>
imap <C-o><bs> <C-t><bs>

