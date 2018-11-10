" Checking camel case words spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

if exists('g:loaded_CCSpellCheck')
	finish
endif
let g:loaded_CCSpellCheck = 1

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:EnableCCSpellCheck')
	let g:EnableCCSpellCheck = 1
endif

if !exists('g:CCSpellCheckMinCharacterLength')
	let g:CCSpellCheckMinCharacterLength = 4
endif

if !exists('g:CCSpellCheckMaxSuggestWords')
	let g:CCSpellCheckMaxSuggestWords = 50
endif

if !exists('g:CCSpellCheckMatchGroupName')
	let g:CCSpellCheckMatchGroupName = 'CCSpellBad'
endif

let s:listOfCCSpellCheckHi = ""
try
	let s:listOfCCSpellCheckHi = execute('highlight ' . g:CCSpellCheckMatchGroupName)
catch
finally
	if strlen(s:listOfCCSpellCheckHi) == 0
		execute ('highlight ' . g:CCSpellCheckMatchGroupName . ' cterm=reverse ctermfg=yellow gui=reverse guifg=yellow')
	endif
endtry

nnoremap <silent> <Plug>(OpenCCSpellFixList) :call CCSpellCheck#openFixList()<CR>
if !hasmapto('<Plug>(OpenCCSpellFixList)')
	silent! nmap <unique> Z= <Plug>(OpenCCSpellFixList)
endif

" vnoremapは古い方法の後方互換です

" [spellgood] ==============================================================
vnoremap <silent> <Plug>(AddCCSpellGood) zg :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddCCSpellGood)')
	silent! vmap <unique> Zg <Plug>(AddCCSpellGood)
endif

nnoremap <silent> <Plug>(AddCCSpellGoodNMap)
		\	:call CCSpellCheck#executeWithTargetWord('spellgood')<CR> :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddCCSpellGoodNMap)')
	silent! nmap <unique> Zg <Plug>(AddCCSpellGoodNMap)
endif

" [undo spellgood] ==============================================================
vnoremap <silent> <Plug>(UndoCCSpellGood) zug :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoCCSpellGood)')
	silent! vmap <unique> Zug <Plug>(UndoCCSpellGood)
endif

nnoremap <silent> <Plug>(UndoCCSpellGoodNMap)
		\	:call CCSpellCheck#executeWithTargetWord('spellundo')<CR> :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoCCSpellGoodNMap)')
	silent! nmap <unique> Zug <Plug>(UndoCCSpellGoodNMap)
endif

" [temporary spellgood] ==============================================================
vnoremap <silent> <Plug>(AddTemporaryCCSpellGood) zG :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddTemporaryCCSpellGood)')
	silent! vmap <unique> ZG <Plug>(AddTemporaryCCSpellGood)
endif

nnoremap <silent> <Plug>(AddTemporaryCCSpellGoodNMap)
		\	:call CCSpellCheck#executeWithTargetWord('spellgood!')<CR> :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddTemporaryCCSpellGoodNMap)')
	silent! nmap <unique> ZG <Plug>(AddTemporaryCCSpellGoodNMap)
endif

" [undo temporary spellgood] ==============================================================
vnoremap <silent> <Plug>(UndoTemporaryCCSpellGood) zuG :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoTemporaryCCSpellGood)')
	silent! vmap <unique> ZUG <Plug>(UndoTemporaryCCSpellGood)
endif

nnoremap <silent> <Plug>(UndoTemporaryCCSpellGoodNMap)
		\	:call CCSpellCheck#executeWithTargetWord('spellundo!')<CR> :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoTemporaryCCSpellGoodNMap)')
	silent! nmap <unique> ZUG <Plug>(UndoTemporaryCCSpellGoodNMap)
endif

" [spellbad] ==============================================================
vnoremap <silent> <Plug>(AddCCSpellBad) zw :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddCCSpellBad)')
	silent! vmap <unique> Zw <Plug>(AddCCSpellBad)
endif

nnoremap <silent> <Plug>(AddCCSpellBadNMap)
		\	:call CCSpellCheck#executeWithTargetWord('spellwrong')<CR> :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddCCSpellBadNMap)')
	silent! nmap <unique> Zw <Plug>(AddCCSpellBadNMap)
endif

" [undo spellbad] ==============================================================
vnoremap <silent> <Plug>(UndoCCSpellBad) zuw :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoCCSpellBad)')
	silent! vmap <unique> Zuw <Plug>(UndoCCSpellBad)
endif

nnoremap <silent> <Plug>(UndoCCSpellBadNMap)
		\	:call CCSpellCheck#executeWithTargetWord('spellundo')<CR> :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoCCSpellBadNMap)')
	silent! nmap <unique> Zuw <Plug>(UndoCCSpellBadNMap)
endif

" [temporary spellbad] ==============================================================
vnoremap <silent> <Plug>(AddTemporaryCCSpellBad) zW :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddTemporaryCCSpellBad)')
	silent! vmap <unique> ZW <Plug>(AddTemporaryCCSpellBad)
endif

nnoremap <silent> <Plug>(AddTemporaryCCSpellBadNMap)
		\	:call CCSpellCheck#executeWithTargetWord('spellwrong!')<CR> :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddTemporaryCCSpellBadNMap)')
	silent! nmap <unique> ZW <Plug>(AddTemporaryCCSpellBadNMap)
endif

" [temporary spellbad] ==============================================================
vnoremap <silent> <Plug>(UndoTemporaryCCSpellBad) zuW :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoTemporaryCCSpellBad)')
	silent! vmap <unique> ZUW <Plug>(UndoTemporaryCCSpellBad)
endif

nnoremap <silent> <Plug>(UndoTemporaryCCSpellBadNMap)
		\	:call CCSpellCheck#executeWithTargetWord('spellundo!')<CR> :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoTemporaryCCSpellBadNMap)')
	silent! nmap <unique> ZUW <Plug>(UndoTemporaryCCSpellBadNMap)
endif


augroup CCSpellCheck
	autocmd!
	autocmd BufWinEnter,BufWritePost * call CCSpellCheck#check()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
