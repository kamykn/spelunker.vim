"=============================================================================
" File: Spelunker ctrlp plugin
" Author: Tsuyoshi CHO
" Created: 2019-11-09
"=============================================================================

scriptencoding utf-8

if exists('g:loaded_ctrlp_spell') && g:loaded_ctrlp_spell
  finish
endif
let g:loaded_ctrlp_spell = 1

let s:save_cpo = &cpo
set cpo&vim

let s:ctrlp_builtins = ctrlp#getvar('g:ctrlp_builtins')

let g:ctrlp_ext_vars = get(g:, 'ctrlp_ext_vars', []) + [
      \  {
      \    'init'   : 'ctrlp#spelunker#init()',
      \    'accept' : 'ctrlp#spelunker#accept',
      \    'lname'  : 'spelunker spellbad',
      \    'sname'  : 'spell',
      \    'enter'  : 'ctrlp#spelunker#enter()',
      \    'exit'   : 'ctrlp#spelunker#exit()',
      \    'type'   : 'line',
      \    'nolim'  : 1
      \  }
      \]

let s:id = s:ctrlp_builtins + len(g:ctrlp_ext_vars)
unlet s:ctrlp_builtins

function! s:spellbadlist() abort
  let l:window_text_list = spelunker#get_buffer#all()
  let l:spell_bad_list = spelunker#spellbad#get_spell_bad_list(l:window_text_list)

  return uniq(sort(l:spell_bad_list))
endfunction

function! ctrlp#spelunker#id() abort
  return s:id
endfunction

function! ctrlp#spelunker#init() abort
  return s:spellbadlist
endfunction

function! ctrlp#spelunker#accept(mode, str) abort
  call ctrlp#exit()

  let l:pattern = spelunker#matches#get_match_pattern(a:str)
  call cursor(1, 1)
  silent! call search(l:pattern, 'cWs')
endfunction

function! ctrlp#spelunker#enter() abort
  let s:spellbadlist = s:spellbadlist()
endfunction

function! ctrlp#spelunker#exit()
  unlet s:spellbadlist
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
