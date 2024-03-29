""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""            Vim Configuration File (Ubuntu/Linux only)                """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                            "
"                    Author: Jorge Calás Lozano                              "
"                    Email:  calas@qvitta.net                                "
"                                                                            "
"----------------------------------------------------------------------------"

"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default

set number      "add line numbers
set showbreak=…
set wrap linebreak nolist

" no backup or swap file
set nobackup
set noswapfile

"add some line space for easy reading
set linespace=4

"disable visual bell
" set visualbell t_vb=
set novisualbell

"try to make possible to navigate within lines of wrapped lines
nmap <Down> gj
nmap <Up> gk
set fo=l

"statusline setup
set statusline=%f       "tail of the filename

set statusline+=%{fugitive#statusline()}
"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

set statusline+=%h      "help file flag
set statusline+=%y      "filetype
set statusline+=%r      "read only flag
set statusline+=%m      "modified flag

"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*

set statusline+=%{StatuslineTrailingSpaceWarning()}

set statusline+=%{StatuslineLongLineWarning()}

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%=      "left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
set laststatus=2

"turn off needless toolbar on gvim/mvim
set guioptions-=T
set guioptions-=m
set guioptions-=r

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[trail]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction

"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction

"indent settings
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set autoindent

"folding settings
set foldmethod=syntax   "fold based on indent
set foldnestmax=10       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

set wildmode=list:longest   "make cmdline tab completion similar to bash
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing

"display tabs and trailing spaces
"set list
"set listchars=tab:\ \ ,extends:>,precedes:<
" disabling list because it interferes with soft wrap
set listchars=tab:»·,trail:·,eol:¬
" set list

set formatoptions-=o "dont continue comments when pushing o/O

"vertical/horizontal scroll off settings
" set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"necessary on some Linux distros for pathogen to properly load bundles
filetype off

"load pathogen managed plugins
call pathogen#runtime_append_all_bundles()

"load ftplugins and indent files
filetype plugin on
filetype indent on

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

"hide buffers when not displayed
set hidden

nmap <silent> <Leader>p :NERDTreeToggle<CR>
nmap <leader>p :NERDTreeToggle<CR>

"" make <c-l> clear the highlight as well as redraw
" nnoremap <C-L> :nohls<CR>
" inoremap <C-L> <C-O>:nohls<CR>

" map the leader key to ","
" let mapleader=','

"map edit VIMRC
map <leader>v :edit $MYVIMRC<CR>

" map open master.otl
map <leader>m :edit ~/Work/master.otl<CR>

au! BufRead,BufNewFile *.otl    set foldenable foldlevel=2

"map to bufexplorer
nnoremap <leader>b :BufExplorer<CR>

" map Ctrl-P to FuzzyFinder File
nnoremap <F12> :FufFile<CR>
" nnoremap <leader>f :FufFile <C-r>=fnamemodify(getcwd(), ':p')<CR><CR>

"map Q to something useful
noremap Q gq

"make Y consistent with C and D
nnoremap Y y$

"bindings for ragtag
inoremap <M-o>       <Esc>o
inoremap <C-j>       <Down>
let g:ragtag_global_maps = 1

"mark syntax errors with :signs
let g:syntastic_enable_signs=1

"key mapping for vimgrep result navigation
map <A-o> :copen<CR>
map <A-q> :cclose<CR>
map <A-j> :cnext<CR>
map <A-k> :cprevious<CR>

"snipmate setup
try
  source ~/.vim/snippets/support_functions.vim
catch
  source ~/vimfiles/snippets/support_functions.vim
endtry

autocmd vimenter * call s:SetupSnippets()

function! s:SetupSnippets()
    "if we're in a rails env then read in the rails snippets
    if filereadable("./config/environment.rb")
        call ExtractSnips("~/.vim/snippets/ruby-rails", "ruby")
        call ExtractSnips("~/.vim/snippets/eruby-rails", "eruby")
    endif

    call ExtractSnips("~/.vim/snippets/html", "eruby")
    call ExtractSnips("~/.vim/snippets/html", "xhtml")
    call ExtractSnips("~/.vim/snippets/html", "php")
endfunction

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction

vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

"define :HighlightLongLines command to highlight the offending parts of
"lines that are longer than the specified length (defaulting to 80)
command! -nargs=? HighlightLongLines call s:HighlightLongLines('<args>')
function! s:HighlightLongLines(width)
    let targetWidth = a:width != '' ? a:width : 79
    if targetWidth > 0
        exec 'match Todo /\%>' . (targetWidth) . 'v/'
    else
        echomsg "Usage: HighlightLongLines [natural number]"
    endif
endfunction

"key mapping for window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

nnoremap <silent> <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>:retab<CR>

nnoremap <silent> <F3> :redir @a<CR>:g//<CR>:redir END<CR>:new<CR>:put! a<CR>
nnoremap <silent> <F4> :redir >>matches.tmp<CR>:g//<CR>:redir END<CR>:new matches.tmp<CR>

map <A-p> :!cucumber -p gvim %

set virtualedit=all
" set cpoptions+=$

" For Emacs-style editing on the command-line: >
" start of line
:cnoremap <C-A>  <Home>
" back one character
:cnoremap <C-B>  <Left>
" delete character under cursor
:cnoremap <C-D>  <Del>
" end of line
:cnoremap <C-E>  <End>
" forward one character
:cnoremap <C-F>  <Right>
" recall newer command-line
:cnoremap <C-N>  <Down>
" recall previous (older) command-line
:cnoremap <C-P>  <Up>

" TODO: Find better key combinations for these
" back one word
:cnoremap <C-X><C-B>  <S-Left>
" forward one word
:cnoremap <C-X><C-F>  <S-Right>

" Scratch function copied from http://weblog.jamisbuck.org/2008/11/17/vim-follow-up
function! ToggleScratch()
  if expand('%') == g:ScratchBufferName
    quit
  else
    Sscratch
  endif
endfunction

map <leader>s :call ToggleScratch()<CR>

" Use ack (ack-grep) for grep searches
set grepprg=ack
set grepformat=%f:%l:%m

" Set paste mode (no indent)
set pastetoggle=<F2>

" Write with sudo
cmap w!! w !sudo tee % >/dev/null

" TODO: I haven't manage to make VIM to break long lines automatically, this
"       can be very useful on plain text files and other filetypes, but not
"       all.
"
"       In Ruby I could try to make the following:
"
"         *) Break long lines on comments (with comment mark at the beggining)
"         *) Highlight long code lines, so that I know I should break if possible.
"
" Text width
" set textwidth=80

" TODO: Study and maybe fix, sometimes it looks like it have a problem, but not
" sure yet.
"
" Setting the theme and terminal options
if has("gui_running")
 "tell the term has 256 colors
 set t_Co=256
else
  "dont load csapprox if there is no gui support - silences an annoying warning
  let g:CSApprox_loaded = 1
endif

if $COLORTERM == 'gnome-terminal' || $COLORTERM == 'Terminal'
  set term=gnome-256color
  colorscheme railscasts
  set guifont=Inconsolata\ Medium\ 9
else
  colorscheme default
endif

"if has("autocmd")
"  autocmd bufwritepost .vimrc source $MYVIMRC
"endif
"
au BufRead,BufNewFile /usr/local/nginx/conf/* set ft=nginx
au BufRead,BufNewFile /usr/local/nginx/sites-available/* set ft=nginx
au BufRead,BufNewFile /usr/local/nginx/sites-enabled/* set ft=nginx
au BufRead,BufNewFile /opt/nginx/conf/* set ft=nginx
au BufRead,BufNewFile /opt/nginx/sites-available/* set ft=nginx
au BufRead,BufNewFile /opt/nginx/sites-enabled/* set ft=nginx


au BufRead,BufNewFile Vagrantfile set ft=ruby
au BufRead,BufNewFile Guardfile set ft=ruby

au BufRead,BufNewFile *.yml set ft=yaml
au BufRead,BufNewFile *.ejs set ft=jst

function! ModeChange()
  if getline(1) =~ "^#!"
    if getline(1) =~ "/bin/"
      silent !chmod a+x <afile>
    endif
  endif
endfunction

" au BufWritePost * call ModeChange()

if exists(":Tabularize")
  nmap <Leader>a= :Tabularize /=<CR>
  vmap <Leader>a= :Tabularize /=<CR>
  nmap <Leader>a: :Tabularize /:\zs<CR>
  vmap <Leader>a: :Tabularize /:\zs<CR>
endif

inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction

" let Tlist_Auto_Open = 1

" Strip trailing whitespace
function! <SID>StripTrailingWhitespaces()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

nmap <leader>u 1GO# encoding: utf-8<CR><ESC>

nnoremap <F5> :GundoToggle<CR>

cnoremap %% <C-R>=expand('%:h').'/'<cr>

"Command-T configuration
map ,t :CommandTFlush<cr>\|:CommandT<CR>
map ,b :CommandTFlush<cr>\|:CommandTBuffer<CR>

map <silent> <Leader>e :CommandTFlush<cr>\|:CommandT<CR>
map <silent> <Leader>n :CommandTFlush<cr>\|:CommandTBuffer<CR>

map ,gv :CommandTFlush<cr>\|:CommandT app/views<cr>
map ,gc :CommandTFlush<cr>\|:CommandT app/controllers<cr>
map ,gm :CommandTFlush<cr>\|:CommandT app/models<cr>
map ,gh :CommandTFlush<cr>\|:CommandT app/helpers<cr>
map ,gl :CommandTFlush<cr>\|:CommandT lib<cr>
map ,gs :CommandTFlush<cr>\|:CommandT app/assets/stylesheets<cr>
map ,gf :CommandTFlush<cr>\|:CommandT features<cr>
map ,gg :topleft 100 :split Gemfile<cr>
map ,gt :CommandTFlush<cr>\|:CommandTTag<cr>
map ,f :CommandTFlush<cr>\|:CommandT<cr>
map ,F :CommandTFlush<cr>\|:CommandT %%<cr>


let g:CommandTMaxHeight=10
let g:CommandTMatchWindowAtTop=1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <F9> :call RunTestFile()<cr>
map <F10> :call RunTests('')<cr>
map <leader>t :call RunTestFile()<cr>
map <leader>T :call RunNearestTest()<cr>
map <leader>a :call RunTests('')<cr>

function! RunTestFile(...)
  if a:0
    let command_suffix = a:1
  else
    let command_suffix = ""
  endif

  " Run the tests for the previously-marked file.
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\)$') != -1
  if in_test_file
    call SetTestFile()
  elseif !exists("t:grb_test_file")
    return
  end
  call RunTests(t:grb_test_file . command_suffix)
endfunction

command! RunTests :call RunTests('')
command! RunTestFile :call RunTestFile('')

function! RunNearestTest()
  let spec_line_number = line('.')
  call RunTestFile(":" . spec_line_number . " -b")
endfunction

function! SetTestFile()
  " Set the spec file that tests will be run for.
  let t:grb_test_file=@%
endfunction

function! RunTests(filename)
  " Write the file and run tests for the given filename
  :w
  :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
  if match(a:filename, '\.feature$') != -1
    exec ":!script/features " . a:filename
  else
    if filereadable("script/test")
      exec ":!script/test " . a:filename
    elseif filereadable("Gemfile")
      exec ":!bundle exec rspec --color " . a:filename
    else
      exec ":!rspec --color " . a:filename
    end
  end
endfunction
