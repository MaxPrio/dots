"VPLUG
"-----

" Install vim-plug if not found
"if empty(glob('~/.vim/autoload/plug.vim'))
  "silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    "\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"endif

" Run PlugInstall if there are missing plugins
"autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
"  \| PlugInstall --sync | source $MYVIMRC
"\| endif


call plug#begin('~/.vim/plugged')

    Plug 'junegunn/vim-plug'
    Plug 'lyokha/vim-xkbswitch'
    Plug 'christoomey/vim-system-copy'
    " On-demand loading
    "Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

    " Plugin outside ~/.vim/plugged with post-update hook
    "Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }


call plug#end()
"============================================================================
    "filetype plugin indent on
    "syntax enable
    let mapleader = "," " map leader to comma
    set undolevels=1000
    set backspace=indent,eol,start
    set lazyredraw          " redraw only when we need to.

"PLAGINS SPECIFIC
"
"vim-xkbswitch
    let g:XkbSwitchEnabled = 1
    let g:XkbSwitchIMappings = ['ru']

"system-copy
    "[cp|cv]+motion

    "cpiw - copy word into system clipboard
    "cpi' - copy inside single quotes to system clipboard
    "cvi' - paste inside single quotes from system clipboard
    "cP   - copy the current line.
    "cV   - paste the content of system clipboard to the next line.

    "to declare custom copy or paste command use:
        "let g:system_copy#copy_command='xclip -sel clipboard'
        "let g:system_copy#paste_command='xclip -sel clipboard -o'
    "to suppress the message:
        "let g:system_copy_silent = 1
    "

"INTERFACE 
    
    hi clear CursorLine
    hi link CursorLine CursorColumn
    hi clear CursorLineNr
    hi link CursorLineNr CursorColumn
    fu! ToggleCurline ()
      if &cursorline
        set nocursorline
        set nocursorcolumn
      else
        set cursorline
        set cursorcolumn
      endif
    endfunction
    map <silent><leader>cl :call ToggleCurline()<CR>






    set ruler
    set relativenumber
    set number
    set linebreak
    set showbreak=↪❭
    set visualbell
    set cmdheight=2
    set showcmd             " show command in bottom bar
    set so=7    "Set 7 lines to the cursor
    set wildmenu            " visual autocomplete for command menu
    "set list               "show hidden chars
    set listchars=tab:▱▱,eol:¬,trail:~,space:‿

"LINES indentation, tabs, folding.
    "
    "indentation, 
    filetype indent on      " load filetype-specific indent files
    set autoindent
    set smartindent

    "tabs
    set tabstop=2     " number of visual spaces per TAB
    set softtabstop=2    " number of spaces in tab when editing
    set expandtab       " tabs are spaces
    set shiftwidth=2
    set smarttab

    "folding
    "set foldmethod=indent   " fold based on indent level
    "set foldenable          " enable folding
    "set foldlevelstart=0   " closed by default
    "set foldcolumn=1
    "

"SEARCH
    "
    set incsearch           " search as characters are entered
    "set hlsearch            " highlight matches
    set ignorecase
    set smartcase
    "set showmatch           " highlight matching [{()}]

"MAPPINGS
    "movements
    inoremap jk <esc>
    vnoremap jk <esc>
    "toggle hidden chars.
    nnoremap <silent><leader>hl :set list!<CR>
    "unhighlight
    nnoremap <silent><leader>sl :nohlsearch<CR>
    "buffer list
    nnoremap ]b :bn<CR>
    nnoremap [b :bp<CR>
    nnoremap [[b <C-^>
    nnoremap []b :ls<CR>:b

"SPELL CHECK
"set spelllang=en
"set spell
