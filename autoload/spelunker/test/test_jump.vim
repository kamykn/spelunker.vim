" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_jump#test()
	call s:test_jump_matched()
endfunction

function! s:test_jump_matched()
	" cursor pos reset
	call spelunker#test#open_unit_test_buffer('jump', 'jump_matched.txt')
	call cursor(1,1)
	call spelunker#test#assert_cursor_pos(1, 1)

	" spelunker#jump#jump_matched(1)
	call spelunker#jump#jump_matched(1)
	call spelunker#test#assert_cursor_pos(2, 8)

	call spelunker#jump#jump_matched(1)
	call spelunker#test#assert_cursor_pos(2, 13)

	call spelunker#jump#jump_matched(1)
	call spelunker#test#assert_cursor_pos(3, 1)

	call spelunker#jump#jump_matched(1)
	call spelunker#test#assert_cursor_pos(1, 1)

	" spelunker#jump#jump_matched(0)
	call spelunker#jump#jump_matched(0)
	call spelunker#test#assert_cursor_pos(3, 1)

	call spelunker#jump#jump_matched(0)
	call spelunker#test#assert_cursor_pos(2, 13)

	call spelunker#jump#jump_matched(0)
	call spelunker#test#assert_cursor_pos(2, 8)

	call spelunker#jump#jump_matched(0)
	call spelunker#test#assert_cursor_pos(1, 1)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
