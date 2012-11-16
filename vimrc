" Chen Bin's vimrc
" shameless copied from Tsung-Hsiang (Sean) Chang <vgod@vgod.tw>
" Fork me on GITHUB git://github.com/redguardtoo/vimrc.git

" For pathogen.vim: auto load all plugins in .vim/bundle

let g:pathogen_disabled = []
if !has('gui_running')
   call add(g:pathogen_disabled, 'powerline')
endif

call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" detect OS
function! MySys()
  if has("win32")
    return "win32"
  elseif has("unix")
    let uname = system('uname')
     if uname =~? "CYGWIN"
       return "cygwin"
     else
       return "unix"
     endif
  elseif has("win32unix")
    return "cygwin"
  else
    return "mac"
  endif
endfunction

" General Settings

set nocompatible	" not compatible with the old-fashion vi mode
set bs=2		" allow backspacing over everything in insert mode
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set autoread		" auto read when file is changed from outside
set number              " show line numbers
set ignorecase          " ignore case when searching

filetype on           " Enable filetype detection
filetype indent on    " Enable filetype-specific indenting
filetype plugin on    " Enable filetype-specific plugins

syntax on		" syntax highlight
set hlsearch		" search highlighting

if has("gui_running")	" GUI color and font settings
  set guifont=YaHei_Consolas_Hybrid:h13:cANSI
  set background=dark
  set t_Co=256          " 256 color mode
  set cursorline        " highlight current line
  colors moria
  highlight CursorLine          guibg=#003853 ctermbg=24  gui=none cterm=none
  " NO menu,toolbar ...
  set guioptions-=m
  set guioptions-=T
  set guioptions-=l
  set guioptions-=L
  set guioptions-=r
  set guioptions-=R

  if MySys()=="win32"
    "start gvim maximized
    if has("autocmd")
      au GUIEnter * simalt ~x
    endif
  endif
else
" terminal color settings
  colors vgod
endif

set clipboard=unnamed	" yank to the system register (*) by default
set showmatch		" Cursor shows matching ) and }
set showmode		" Show current mode
set wildchar=<TAB>	" start wild expansion in the command line using <TAB>
set wildmenu            " wild char completion menu

" ignore these files while expanding wild chars
set wildignore=*.o,*.class,*.pyc

set autoindent		" auto indentation
set incsearch		" incremental search
set nobackup		" no *~ backup files
set copyindent		" copy the previous indentation on autoindenting
set ignorecase		" ignore case when searching
set smartcase		" ignore case if search pattern is all lowercase,case-sensitive otherwise
set smarttab		" insert tabs on the start of a line according to context

" disable sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" TAB setting{
   set expandtab        "replace <TAB> with spaces
   set softtabstop=4
   set shiftwidth=4

   au FileType Makefile set noexpandtab
"}

" status line {
set laststatus=2
set statusline=%t       "tail of the filename
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%y      "filetype
set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file

function! HasPaste()
    if &paste
        return '[PASTE]'
    else
        return ''
    endif
endfunction
"}


if has("autocmd")
    autocmd BufNewFile,BufRead *.vb set ft=vbnet
    autocmd BufNewFile,BufRead *.{ps1,psm1,psd1} set ft=ps1
    autocmd BufNewFile,BufRead *.{md,markdown} set ft=markdown
    autocmd BufNewFile,BufRead *.json set ft=javascript
    autocmd BufNewFile,BufRead *.cshtml set ft=html

    autocmd BufNewFile,BufRead *.build set ft=xml
    " C/C++ specific settings
    autocmd FileType c,cpp,cc  set cindent comments=sr:/*,mb:*,el:*/,:// cino=>s,e0,n0,f0,{0,}0,^-1s,:0,=s,g0,h1s,p2,t0,+2,(2,)20,*30

    " auto reload vimrc when editing it
    autocmd! bufwritepost .vimrc source ~/.vimrc
endif

"Restore cursor to file position in previous editing session
set viminfo='10,\"100,:20,%,n~/.viminfo

"---------------------------------------------------------------------------
" Tip #382: Search for <cword> and replace with input() in all open buffers
"---------------------------------------------------------------------------
fun! Replace()
   let s:word = input("Replace " . expand('<cword>') . " with:")
   :exe 'bufdo! %s/\<' . expand('<cword>') . '\>/' . s:word . '/ge'
   :unlet! s:word
endfun

if has("autocmd")
   au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

   " @see https://www.antagonism.org/privacy/gpg-vi.shtml
   " Transparent editing of GnuPG-encrypted files
   " Based on a solution by Wouter Hanegraaff
   augroup encrypted
      au!
      " First make sure nothing is written to ~/.viminfo while editing
      " an encrypted file.
      autocmd BufReadPre,FileReadPre *.gpg,*.asc set viminfo=
      " We don't want a swap file, as it writes unencrypted data to disk.
      autocmd BufReadPre,FileReadPre *.gpg,*.asc set noswapfile
      " Switch to binary mode to read the encrypted file.
      autocmd BufReadPre,FileReadPre *.gpg set bin
      autocmd BufReadPre,FileReadPre *.gpg,*.asc let ch_save = &ch|set ch=2
      autocmd BufReadPost,FileReadPost *.gpg,*.asc
               \ '[,']!sh -c 'gpg --decrypt 2> /dev/null'
      " Switch to normal mode for editing
      autocmd BufReadPost,FileReadPost *.gpg set nobin
      autocmd BufReadPost,FileReadPost *.gpg,*.asc let &ch = ch_save|unlet ch_save
      autocmd BufReadPost,FileReadPost *.gpg,*.asc
               \ execute ":doautocmd BufReadPost " . expand("%:r")

      " Convert all text to encrypted text before writing
      autocmd BufWritePre,FileWritePre *.gpg set bin
      autocmd BufWritePre,FileWritePre *.gpg
               \ '[,']!sh -c 'gpg --default-recipient-self -e 2>/dev/null'
      autocmd BufWritePre,FileWritePre *.asc
               \ '[,']!sh -c 'gpg --default-recipient-self -e -a 2>/dev/null'
      " Undo the encryption so we are back in the normal text, directly
      " after the file has been written.
      autocmd BufWritePost,FileWritePost *.gpg,*.asc u
   augroup END
 endif

 "---------------------------------------------------------------------------
 " USEFUL SHORTCUTS
 "---------------------------------------------------------------------------
 "work with clipbord in vim-console
 " C-c is same as ESC which is good if you switch CAP and Ctrl key
 if MySys() == "unix"
    " two clipboards in X
    vmap <C-y> y:call system("xclip -i -selection clipboard", getreg("\""))<CR>:call system("xclip -i", getreg("\""))<CR>
 elseif MySys() == "cygwin"
    vmap <C-y> y:call system("putclip", getreg("\""))<CR>
 endif

 " set leader to ,
 let mapleader=","
 let g:mapleader=","

 " grep result window operation alias
 " " Do :help cope if you are unsure what cope is. It's super useful!
 map <leader>o :botright copen<cr>
 "<leader>cc is reserved for nerd comment
 map <leader>l :cclose<cr>
 map <leader>n :cn<cr>
 map <leader>p :cp<cr>
 map <leader>a :w!<CR>:!aspell check %<CR>:e! %<CR>

 " Spell checking
 map <leader>sn ]
 map <leader>sp [
 map <leader>sa zg
 map <leader>s? z=

 "Remove the Windows ^M
 noremap <leader>m :%s/\r//g<CR>

 "Switch to current dir
 map <leader>cd :cd %:p:h<cr>

 "Remove indenting on empty line
 map <F2> :%s/s*$//g<cr>:noh<cr>''

 " --- Smart way to move window {
 "  TIPS:
 "  C-W +/- increase/descrease window height
 "  C-W _ maxmize window height
 "  C-W = restore window size
 "  C-W | maxmize window width
 map <C-j> <C-W>j
 map <C-k> <C-W>k
 map <C-h> <C-W>h
 map <C-l> <C-W>l
 set wmw=0                     " set the min width of a window to 0 so we can maximize others
 set wmh=0                     " set the min height of a window to 0 so we can maximize others
 "}

 " --- Faster window resize {
 "  TIPS:
 "  C-W </ > resize window width
 if bufwinnr(1)
    " recommend using scroll pad
    map + <C-W>+
    map - <C-W>-
 endif
 "  }

 "replace the current word in all opened buffers
 map <leader>r :call Replace()<CR>

 " move around tabs. conflict with the original screen top/bottom
 " comment them out if you want the original H/L
 " go to prev tab
 map <S-H> gT
 " go to next tab
 map <S-L> gt

 " new tab
 map <C-t><C-t> :tabnew<CR>
 " close tab
 map <C-t><C-w> :tabclose<CR>

 " ,/ turn off search highlighting
 nmap <leader>/ :nohl<CR>

 " Bash like keys for the command line
 cnoremap <C-A>      <Home>
 cnoremap <C-E>      <End>
 cnoremap <C-K>      <C-U>

 " ,p toggles paste mode
 nmap <leader>p :set paste!<BAR>set paste?<CR>

 " allow multiple indentation/deindentation in visual mode
 vnoremap < <gv
 vnoremap > >gv

 " Writing Restructured Text (Sphinx Documentation) {
 " Ctrl-u 1:    underline Parts w/ #'s
 noremap  <C-u>1 yyPVr#yyjp
 inoremap <C-u>1 <esc>yyPVr#yyjpA
 " Ctrl-u 2:    underline Chapters w/ *'s
 noremap  <C-u>2 yyPVr*yyjp
 inoremap <C-u>2 <esc>yyPVr*yyjpA
 " Ctrl-u 3:    underline Section Level 1 w/ ='s
 noremap  <C-u>3 yypVr=
 inoremap <C-u>3 <esc>yypVr=A
 " Ctrl-u 4:    underline Section Level 2 w/ -'s
 noremap  <C-u>4 yypVr-
 inoremap <C-u>4 <esc>yypVr-A
 " Ctrl-u 5:    underline Section Level 3 w/ ^'s
 noremap  <C-u>5 yypVr^
 inoremap <C-u>5 <esc>yypVr^A
 "}

 "---------------------------------------------------------------------------
 " PROGRAMMING SHORTCUTS
 "---------------------------------------------------------------------------

 " Ctrl-[ jump out of the tag stack (undo Ctrl-])
 map <C-[> <ESC>:po<CR>

 " ,g generates the header guard
 map <leader>g :call IncludeGuard()<CR>
 fun! IncludeGuard()
    let basename = substitute(bufname(""), '.*/', '', '')
    let guard = '_' . substitute(toupper(basename), '\.', '_', "H")
    call append(0, "#ifndef " . guard)
    call append(1, "#define " . guard)
    call append( line("$"), "#endif // for #ifndef " . guard)
 endfun

 if has("autocmd") && exists("+omnifunc")
    " Enable omni completion. (Ctrl-X Ctrl-O)
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType css set omnifunc=csscomplete#CompleteCSS
    autocmd FileType c set omnifunc=ccomplete#Complete
    autocmd FileType java set omnifunc=javacomplete#Complete

    " use syntax complete if nothing else available
    autocmd Filetype *
             \	if &omnifunc == "" |
             \		setlocal omnifunc=syntaxcomplete#Complete |
             \	endif
 endif

 set cot-=preview "disable doc preview in omnicomplete

 if has("autocmd")
    " make CSS omnicompletion work for SASS and SCSS
    autocmd BufNewFile,BufRead *.scss             set ft=scss.css
    autocmd BufNewFile,BufRead *.sass             set ft=sass.css
 endif

 "---------------------------------------------------------------------------
 " ENCODING SETTINGS
 "---------------------------------------------------------------------------
 "set encoding=utf-8
 "set termencoding=utf-8
 "set fileencoding=utf-8
 "set fileencodings=ucs-bom,utf-8,big5,gb2312,latin1
 "
 "fun! ViewUTF8()
 "   set encoding=utf-8
 "   set termencoding=big5
 "endfun
 "
 "fun! UTF8()
 "   set encoding=utf-8
 "   set termencoding=big5
 "   set fileencoding=utf-8
 "   set fileencodings=ucs-bom,big5,utf-8,latin1
 "endfun
 "
 "fun! Big5()
 "   set encoding=big5
 "   set fileencoding=big5
 "endfun
 "
 set encoding=utf-8
 set fileencoding=chinese
 set fileencodings=ucs-bom,utf-8,chinese
 set ambiwidth=double
 set fenc=gbk
 
 "---------------------------------------------------------------------------
 " TAB SET
 "---------------------------------------------------------------------------
 
 set ts=4
 set expandtab
 set autoindent

 "---------------------------------------------------------------------------
 " PLUGIN SETTINGS
 "---------------------------------------------------------------------------


 " ------- vim-latex - many latex shortcuts and snippets {

 " IMPORTANT: win32 users will need to have 'shellslash' set so that latex
 " can be called correctly.
 set shellslash
 set grepprg=grep\ -nH\ $*
 " OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
 " 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
 " The following changes the default filetype back to 'tex':
 let g:tex_flavor='latex'

 "}


 " --- AutoClose - Inserts matching bracket, paren, brace or quote
 " fixed the arrow key problems caused by AutoClose
 if !has("gui_running")
    set term=linux
    imap OA <ESC>ki
    imap OB <ESC>ji
    imap OC <ESC>li
    imap OD <ESC>hi

    nmap OA k
    nmap OB j
    nmap OC l
    nmap OD h
 endif

 " --- taglist
 map <leader>t :TlistToggle<CR>

 " --- SuperTab
 let g:SuperTabDefaultCompletionType = "context"

 " --- EasyMotion
 "let g:EasyMotion_leader_key = '<Leader>m' " default is <Leader>w
 hi link EasyMotionTarget ErrorMsg
 hi link EasyMotionShade  Comment


 " --- TagBar
 " toggle TagBar with F7
 nnoremap <silent> <F7> :TagbarToggle<CR>
 " set focus to TagBar when opening it
 let g:tagbar_autofocus = 1

 " --- PowerLine
 " let g:Powerline_symbols = 'fancy' " require fontpatcher
