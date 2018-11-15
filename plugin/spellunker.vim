" Checking camel case words spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

if exists('g:loaded_spellunker')
	finish
endif
let g:loaded_spellunker = 1

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:enable_spellunker')
	let g:enable_spellunker = 1
endif

if !exists('g:spellunker_min_char_len')
	let g:spellunker_min_char_len = 4
endif

if !exists('g:spellunker_max_suggest_words')
	let g:spellunker_max_suggest_words = 20
endif

if !exists('g:spellunker_compound_word_group')
	let g:spellunker_compound_word_group = 'SpellunkerCompoundWord'
endif

if !exists('g:spellunker_spell_bad_group')
	let g:spellunker_spell_bad_group = 'SpellunkerSpellBad'
endif

let s:spellunker_spell_bad_hi_list = ""
let s:spellunker_compound_word_hi_list = ""
try
	let s:spellunker_spell_bad_hi_list = execute('highlight ' . g:spellunker_spell_bad_group)
	let s:spellunker_compound_word_hi_list = execute('highlight ' . g:spellunker_compound_word_group)
catch
finally
	if strlen(s:spellunker_spell_bad_hi_list) == 0 && strlen(s:spellunker_compound_word_hi_list) == 0
		execute ('highlight ' . g:spellunker_spell_bad_group . ' cterm=underline ctermfg=59 gui=underline guifg=#5C6370')
		execute ('highlight ' . g:spellunker_compound_word_group . ' cterm=underline ctermfg=NONE gui=underline guifg=NONE')
	endif
endtry

nnoremap <silent> <Plug>(open-spellunker-fix-list) :call spellunker#open_fix_list()<CR>
if !hasmapto('<Plug>(open-spellunker-fix-list)')
	silent! nmap <unique> Z= <Plug>(open-spellunker-fix-list)
endif

" vnoremapは古い方法の後方互換です

" [spell good] ==============================================================
vnoremap <silent> <Plug>(add-spellunker-good) zg :call spellunker#check()<CR>
if !hasmapto('<Plug>(add-spellunker-good)')
	silent! vmap <unique> Zg <Plug>(add-spellunker-good)
endif

nnoremap <silent> <Plug>(add-spellunker-good-nmap)
		\	:call spellunker#execute_with_target_word('spellgood')<CR> :call spellunker#check()<CR>
if !hasmapto('<Plug>(add-spellunker-good-nmap)')
	silent! nmap <unique> Zg <Plug>(add-spellunker-good-nmap)
endif

" [undo spell good] ==============================================================
vnoremap <silent> <Plug>(undo-spellunker-good) zug :call spellunker#check()<CR>
if !hasmapto('<Plug>(undo-spellunker-good)')
	silent! vmap <unique> Zug <Plug>(undo-spellunker-good)
endif

nnoremap <silent> <Plug>(undo-spellunker-good-nmap)
		\	:call spellunker#execute_with_target_word('spellundo')<CR> :call spellunker#check()<CR>
if !hasmapto('<Plug>(undo-spellunker-good-nmap)')
	silent! nmap <unique> Zug <Plug>(undo-spellunker-good-nmap)
endif

" [temporary spell good] ==============================================================
vnoremap <silent> <Plug>(add-temporary-spellunker-good) zG :call spellunker#check()<CR>
if !hasmapto('<Plug>(add-temporary-spellunker-good)')
	silent! vmap <unique> ZG <Plug>(add-temporary-spellunker-good)
endif

nnoremap <silent> <Plug>(add-temporary-spellunker-good-nmap)
		\	:call spellunker#execute_with_target_word('spellgood!')<CR> :call spellunker#check()<CR>
if !hasmapto('<Plug>(add-temporary-spellunker-good-nmap)')
	silent! nmap <unique> ZG <Plug>(add-temporary-spellunker-good-nmap)
endif

" [undo temporary spell good] ==============================================================
vnoremap <silent> <Plug>(undo-temporary-spellunker-good) zuG :call spellunker#check()<CR>
if !hasmapto('<Plug>(undo-temporary-spellunker-good)')
	silent! vmap <unique> ZUG <Plug>(undo-temporary-spellunker-good)
endif

nnoremap <silent> <Plug>(undo-temporary-spellunker-good-nmap)
		\	:call spellunker#execute_with_target_word('spellundo!')<CR> :call spellunker#check()<CR>
if !hasmapto('<Plug>(undo-temporary-spellunker-good-nmap)')
	silent! nmap <unique> ZUG <Plug>(undo-temporary-spellunker-good-nmap)
endif

" [spell bad] ==============================================================
vnoremap <silent> <Plug>(add-spellunker-bad) zw :call spellunker#check()<CR>
if !hasmapto('<Plug>(add-spellunker-bad)')
	silent! vmap <unique> Zw <Plug>(add-spellunker-bad)
endif

nnoremap <silent> <Plug>(add-spell-bad-nmap)
		\	:call spellunker#execute_with_target_word('spellwrong')<CR> :call spellunker#check()<CR>
if !hasmapto('<Plug>(add-spell-bad-nmap)')
	silent! nmap <unique> Zw <Plug>(add-spell-bad-nmap)
endif

" [undo spell bad] ==============================================================
vnoremap <silent> <Plug>(undo-spellunker-bad) zuw :call spellunker#check()<CR>
if !hasmapto('<Plug>(undo-spellunker-bad)')
	silent! vmap <unique> Zuw <Plug>(undo-spellunker-bad)
endif

nnoremap <silent> <Plug>(undo-spellunker-bad-nmap)
		\	:call spellunker#execute_with_target_word('spellundo')<CR> :call spellunker#check()<CR>
if !hasmapto('<Plug>(undo-spellunker-bad-nmap)')
	silent! nmap <unique> Zuw <Plug>(undo-spellunker-bad-nmap)
endif

" [temporary spell bad] ==============================================================
vnoremap <silent> <Plug>(add-temporary-spellunker-bad) zW :call spellunker#check()<CR>
if !hasmapto('<Plug>(add-temporary-spellunker-bad)')
	silent! vmap <unique> ZW <Plug>(add-temporary-spellunker-bad)
endif

nnoremap <silent> <Plug>(add-temporary-spell-bad-nmap)
		\	:call spellunker#execute_with_target_word('spellwrong!')<CR> :call spellunker#check()<CR>
if !hasmapto('<Plug>(add-temporary-spell-bad-nmap)')
	silent! nmap <unique> ZW <Plug>(add-temporary-spell-bad-nmap)
endif

" [temporary spell bad] ==============================================================
vnoremap <silent> <Plug>(undo-temporary-spell-bad) zuW :call spellunker#check()<CR>
if !hasmapto('<Plug>(undo-temporary-spellunker-bad)')
	silent! vmap <unique> ZUW <Plug>(undo-temporary-spellunker-bad)
endif

nnoremap <silent> <Plug>(undo-temporary-spellunker-bad-nmap)
		\	:call spellunker#execute_with_target_word('spellundo!')<CR> :call spellunker#check()<CR>
if !hasmapto('<Plug>(undo-temporary-spellunker-bad-nmap)')
	silent! nmap <unique> ZUW <Plug>(undo-temporary-spellunker-bad-nmap)
endif


augroup spellunker
	autocmd!
	autocmd BufWinEnter,BufWritePost * call spellunker#check()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
