set aw sw=4 ai noesckeys
hi Search ctermbg=blue
hi Comment ctermfg=darkgreen
nnoremap  :noh<CR>
if has("autocmd")
        autocmd BufRead *.sql set filetype=mysql
        autocmd BufNewFile,BufRead *.json set ft=javascript
	autocmd BufRead Makefile set noexpandtab
	autocmd BufRead makefile set noexpandtab
	autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
endif

:if &term =~ "xterm*"
:set t_Co=8
:set t_Sb=[4%p1%dm
:set t_Sf=[3%p1%dm
:endif
:if &term =~ "xterm-256color"
:set t_Co=256
:colorscheme desert
:endif
syn on
if has("gui_macvim") 
	set gfn=Monaco:h14 noantialias
	colorscheme desert
	hi Normal guibg=black
	hi NonText guibg=black
endif
