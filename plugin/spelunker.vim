" Checking camel case words spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

if exists('g:loaded_spelunker')
	finish
endif
let g:loaded_spelunker = 1

let s:save_cpo = &cpo
set cpo&vim

" for Unit Test
if !exists('g:spelunker_plugin_path')
	let g:spelunker_plugin_path = expand('<sfile>:p:h:h')
endif

if !exists('g:enable_spelunker_vim')
	let g:enable_spelunker_vim = 1
endif

if !exists('g:enable_spelunker_vim_on_readonly')
	let g:enable_spelunker_vim_on_readonly = 0
endif

if !exists('g:spelunker_target_min_char_len')
	let g:spelunker_target_min_char_len = 4
endif

if !exists('g:spelunker_max_suggest_words')
	let g:spelunker_max_suggest_words = 15
endif

if !exists('g:spelunker_max_hi_words_each_buf')
	let g:spelunker_max_hi_words_each_buf = 100
endif

if !exists('g:spelunker_disable_auto_group')
  let g:spelunker_disable_auto_group = 0
endif

if !exists('g:spelunker_disable_backquoted_checking')
  let g:spelunker_disable_backquoted_checking = 0
endif

if !exists('g:spelunker_disable_uri_checking')
  let g:spelunker_disable_uri_checking = 0
endif

if !exists('g:spelunker_disable_email_checking')
  let g:spelunker_disable_email_checking = 0
endif

if !exists('g:spelunker_disable_acronym_checking')
  let g:spelunker_disable_acronym_checking = 0
endif

if !exists('g:spelunker_disable_account_name_checking')
  let g:spelunker_disable_account_name_checking = 0
endif

let g:spelunker_check_type_buf_lead_write = 1
let g:spelunker_check_type_cursor_hold = 2

" include SpellBad, SpellCap, SpellRare and SpellLocal
let g:spelunker_highlight_all = 1
" only SpellBad
let g:spelunker_highlight_spell_bad = 2

" [setting default] ===========================================================
if !exists('g:spelunker_check_type')
	let g:spelunker_check_type = g:spelunker_check_type_buf_lead_write
endif

if !exists('g:spelunker_highlight_type')
	let g:spelunker_highlight_type = g:spelunker_highlight_all
endif

" [spelunker_spell_bad_group] ===========================================================

if !exists('g:spelunker_spell_bad_group')
	let g:spelunker_spell_bad_group = 'SpelunkerSpellBad'
endif

let s:spelunker_spell_bad_hi_list = ""
try
	let s:spelunker_spell_bad_hi_list = execute('highlight ' . g:spelunker_spell_bad_group)
catch
finally
	if strlen(s:spelunker_spell_bad_hi_list) == 0
		execute ('highlight ' . g:spelunker_spell_bad_group . ' cterm=underline ctermfg=247 gui=underline guifg=#9E9E9E')
	endif
endtry

" [spelunker_complex_or_compound_word_group] =======================================================

if !exists('g:spelunker_complex_or_compound_word_group')
	let g:spelunker_complex_or_compound_word_group = 'SpelunkerComplexOrCompoundWord'
endif

let s:spelunker_complex_or_compound_word_hi_list = ""
try
	let s:spelunker_complex_or_compound_word_hi_list = execute('highlight ' . g:spelunker_complex_or_compound_word_group)
catch
finally
	if strlen(s:spelunker_complex_or_compound_word_hi_list) == 0
		execute ('highlight ' . g:spelunker_complex_or_compound_word_group . ' cterm=underline ctermfg=NONE gui=underline guifg=NONE')
	endif
endtry

" [open fix list] ========================================================================
nnoremap <silent> <Plug>(spelunker-correct-from-list) :call spelunker#correct_from_list()<CR>
if !hasmapto('<Plug>(spelunker-correct-from-list)')
	silent! nmap <unique> Zl <Plug>(spelunker-correct-from-list)
endif

nnoremap <silent> <Plug>(spelunker-correct-all-from-list) :call spelunker#correct_all_from_list()<CR>
if !hasmapto('<Plug>(spelunker-correct-all-from-list)')
	silent! nmap <unique> ZL <Plug>(spelunker-correct-all-from-list)
endif

" [correct word] =========================================================================
nnoremap <silent> <Plug>(spelunker-correct) :call spelunker#correct()<CR>
if !hasmapto('<Plug>(spelunker-correct)')
	silent! nmap <unique> Zc <Plug>(spelunker-correct)
endif

nnoremap <silent> <Plug>(spelunker-correct-all) :call spelunker#correct_all()<CR>
if !hasmapto('<Plug>(spelunker-correct-all)')
	silent! nmap <unique> ZC <Plug>(spelunker-correct-all)
endif

" [open fix list] ========================================================================
nnoremap <silent> <Plug>(spelunker-correct-feeling-lucky) :call spelunker#correct_feeling_lucky()<CR>
if !hasmapto('<Plug>(spelunker-correct-feeling-lucky)')
	silent! nmap <unique> Zf <Plug>(spelunker-correct-feeling-lucky)
endif

nnoremap <silent> <Plug>(spelunker-correct-all-feeling-lucky) :call spelunker#correct_all_feeling_lucky()<CR>
if !hasmapto('<Plug>(spelunker-correct-all-feeling-lucky)')
	silent! nmap <unique> ZF <Plug>(spelunker-correct-all-feeling-lucky)
endif

" vmap/vnoremapはxmap(visual-modeだけ)が作られる前の古い方法で、後方互換のため
" 利用します。
" vmapだと visual-mode の他、selec-mode にもマップされます
" このマップは除去可能なら除去します
if exists(':sunmap') == 2
  function! s:sunmap(map) abort
    call execute(':sunmap ' . a:map)
  endfunction
else
  function! s:sunmap(map) abort
    " no work
  endfunction
endif

" [spell good] ===========================================================================
vnoremap <silent> <Plug>(add-spelunker-good) zg :call spelunker#check()<CR>
if !hasmapto('<Plug>(add-spelunker-good)')
	silent! vmap <unique> Zg <Plug>(add-spelunker-good)
	call s:sunmap('Zg')
endif

nnoremap <silent> <Plug>(add-spelunker-good-nmap)
		\	:call spelunker#execute_with_target_word('spellgood')<CR> :call spelunker#check()<CR>
if !hasmapto('<Plug>(add-spelunker-good-nmap)')
	silent! nmap <unique> Zg <Plug>(add-spelunker-good-nmap)
endif

" [undo spell good] ======================================================================
vnoremap <silent> <Plug>(undo-spelunker-good) zug :call spelunker#check()<CR>
if !hasmapto('<Plug>(undo-spelunker-good)')
	silent! vmap <unique> Zug <Plug>(undo-spelunker-good)
	call s:sunmap('Zug')
endif

nnoremap <silent> <Plug>(undo-spelunker-good-nmap)
		\	:call spelunker#execute_with_target_word('spellundo')<CR> :call spelunker#check()<CR>
if !hasmapto('<Plug>(undo-spelunker-good-nmap)')
	silent! nmap <unique> Zug <Plug>(undo-spelunker-good-nmap)
endif

" [temporary spell good] =================================================================
vnoremap <silent> <Plug>(add-temporary-spelunker-good) zG :call spelunker#check()<CR>
if !hasmapto('<Plug>(add-temporary-spelunker-good)')
	silent! vmap <unique> ZG <Plug>(add-temporary-spelunker-good)
	call s:sunmap('ZG')
endif

nnoremap <silent> <Plug>(add-temporary-spelunker-good-nmap)
		\	:call spelunker#execute_with_target_word('spellgood!')<CR> :call spelunker#check()<CR>
if !hasmapto('<Plug>(add-temporary-spelunker-good-nmap)')
	silent! nmap <unique> ZG <Plug>(add-temporary-spelunker-good-nmap)
endif

" [undo temporary spell good] ============================================================
vnoremap <silent> <Plug>(undo-temporary-spelunker-good) zuG :call spelunker#check()<CR>
if !hasmapto('<Plug>(undo-temporary-spelunker-good)')
	silent! vmap <unique> ZUG <Plug>(undo-temporary-spelunker-good)
	call s:sunmap('ZUG')
endif

nnoremap <silent> <Plug>(undo-temporary-spelunker-good-nmap)
		\	:call spelunker#execute_with_target_word('spellundo!')<CR> :call spelunker#check()<CR>
if !hasmapto('<Plug>(undo-temporary-spelunker-good-nmap)')
	silent! nmap <unique> ZUG <Plug>(undo-temporary-spelunker-good-nmap)
endif

" [spell bad] ============================================================================
vnoremap <silent> <Plug>(add-spelunker-bad) zw :call spelunker#check()<CR>
if !hasmapto('<Plug>(add-spelunker-bad)')
	silent! vmap <unique> Zw <Plug>(add-spelunker-bad)
	call s:sunmap('Zw')
endif

nnoremap <silent> <Plug>(add-spell-bad-nmap)
		\	:call spelunker#execute_with_target_word('spellwrong')<CR> :call spelunker#check()<CR>
if !hasmapto('<Plug>(add-spell-bad-nmap)')
	silent! nmap <unique> Zw <Plug>(add-spell-bad-nmap)
endif

" [undo spell bad] =======================================================================
vnoremap <silent> <Plug>(undo-spelunker-bad) zuw :call spelunker#check()<CR>
if !hasmapto('<Plug>(undo-spelunker-bad)')
	silent! vmap <unique> Zuw <Plug>(undo-spelunker-bad)
	call s:sunmap('Zuw')
endif

nnoremap <silent> <Plug>(undo-spelunker-bad-nmap)
		\	:call spelunker#execute_with_target_word('spellundo')<CR> :call spelunker#check()<CR>
if !hasmapto('<Plug>(undo-spelunker-bad-nmap)')
	silent! nmap <unique> Zuw <Plug>(undo-spelunker-bad-nmap)
endif

" [temporary spell bad] ==================================================================
vnoremap <silent> <Plug>(add-temporary-spelunker-bad) zW :call spelunker#check()<CR>
if !hasmapto('<Plug>(add-temporary-spelunker-bad)')
	silent! vmap <unique> ZW <Plug>(add-temporary-spelunker-bad)
	call s:sunmap('ZW')
endif

nnoremap <silent> <Plug>(add-temporary-spelunker-bad-nmap)
		\	:call spelunker#execute_with_target_word('spellwrong!')<CR> :call spelunker#check()<CR>
if !hasmapto('<Plug>(add-temporary-spelunker-bad-nmap)')
	silent! nmap <unique> ZW <Plug>(add-temporary-spelunker-bad-nmap)
endif

" [temporary spell bad] ==================================================================
vnoremap <silent> <Plug>(undo-temporary-spelunker-bad) zuW :call spelunker#check()<CR>
if !hasmapto('<Plug>(undo-temporary-spelunker-bad)')
	silent! vmap <unique> ZUW <Plug>(undo-temporary-spelunker-bad)
	call s:sunmap('ZUW')
endif

nnoremap <silent> <Plug>(undo-temporary-spelunker-bad-nmap)
		\	:call spelunker#execute_with_target_word('spellundo!')<CR> :call spelunker#check()<CR>
if !hasmapto('<Plug>(undo-temporary-spelunker-bad-nmap)')
	silent! nmap <unique> ZUW <Plug>(undo-temporary-spelunker-bad-nmap)
endif

" [add all spell bad to dict] ==================================================================
:command! SpelunkerAddAll call spelunker#add_all_spellgood() | call spelunker#check()

" [jump next spell bad]===============================================================
nnoremap <silent> <Plug>(spelunker-jump-next) :call spelunker#jump_next()<CR>
if !hasmapto('<Plug>(spelunker-jump-next)')
	silent! nmap <unique> ZN <Plug>(spelunker-jump-next)
endif

" [jump next spell bad]===============================================================
nnoremap <silent> <Plug>(spelunker-jump-prev) :call spelunker#jump_prev()<CR>
if !hasmapto('<Plug>(spelunker-jump-prev)')
	silent! nmap <unique> ZP <Plug>(spelunker-jump-prev)
endif

" [toggle feature]===============================================================
nnoremap <silent> <Plug>(spelunker-toggle) :call spelunker#toggle()<CR>
if !hasmapto('<Plug>(spelunker-toggle)')
	silent! nmap <unique> ZT <Plug>(spelunker-toggle)
endif

" [toggle in the buffer feature]===============================================================
nnoremap <silent> <Plug>(spelunker-toggle-buffer) :call spelunker#toggle_buffer()<CR>
if !hasmapto('<Plug>(spelunker-toggle-buffer)')
	silent! nmap <unique> Zt <Plug>(spelunker-toggle-buffer)
endif

" [augroup] ==================================================================
if g:spelunker_disable_auto_group == 0
  augroup spelunker
    autocmd!
    autocmd BufWinEnter,BufWritePost * call spelunker#check()
    autocmd CursorHold * call spelunker#check_displayed_words()
  augroup END
endif

let &cpo = s:save_cpo
unlet s:save_cpo
