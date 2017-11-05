" Checking camel case words spelling.
" Version 1.0.0
" Author kmszk
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
	echo s:listOfCCSpellCheckHi
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

vnoremap <silent> <Plug>(AddCCSpellGood) zg :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddCCSpellGood)')
	silent! vmap <unique> Zg <Plug>(AddCCSpellGood)
endif

vnoremap <silent> <Plug>(UndoCCSpellGood) zug :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoCCSpellGood)')
	silent! vmap <unique> Zug <Plug>(UndoCCSpellGood)
endif

vnoremap <silent> <Plug>(AddTemporaryCCSpellGood) zG :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddTemporaryCCSpellGood)')
	silent! vmap <unique> ZG <Plug>(AddTemporaryCCSpellGood)
endif

vnoremap <silent> <Plug>(UndoTemporaryCCSpellGood) zuG :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoTemporaryCCSpellGood)')
	silent! vmap <unique> ZUG <Plug>(UndoTemporaryCCSpellGood)
endif

vnoremap <silent> <Plug>(AddCCSpellBad) zw :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddCCSpellBad)')
	silent! vmap <unique> Zw <Plug>(AddCCSpellBad)
endif

vnoremap <silent> <Plug>(UndoCCSpellBad) zuw :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoCCSpellBad)')
	silent! vmap <unique> Zuw <Plug>(UndoCCSpellBad)
endif

vnoremap <silent> <Plug>(AddTemporaryCCSpellBad) zW :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(AddTemporaryCCSpellBad)')
	silent! vmap <unique> ZW <Plug>(AddTemporaryCCSpellBad)
endif

vnoremap <silent> <Plug>(UndoTemporaryCCSpellBad) zuW :call CCSpellCheck#check()<CR>
if !hasmapto('<Plug>(UndoTemporaryCCSpellBad)')
	silent! vmap <unique> ZUW <Plug>(UndoTemporaryCCSpellBad)
endif


augroup CCSpellCheck
	autocmd!
	autocmd BufWinEnter,BufWritePost * call CCSpellCheck#check()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
