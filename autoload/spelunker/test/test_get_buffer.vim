scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_get_buffer#test()
	call s:test_all()
	call s:test_displayed()
endfunction

function! s:test_all()
	call spelunker#test#open_unit_test_buffer('words', 'highlight.txt')
	call assert_equal(['aple banan lemn', 'apple_banana_lemon', 'AppleBananaLemon'], spelunker#get_buffer#all())
endfunction

function! s:test_displayed()
	call spelunker#test#open_unit_test_buffer('words', 'check.txt')
	call assert_equal(['appl banan'], spelunker#get_buffer#all())
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
