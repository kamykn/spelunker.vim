" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_toggle#test()
	call s:test_toggle(1) " test global toggle
	call s:test_toggle(2) " test local toggle
	call s:test_is_enabled()
	call s:test_is_enabled_global()
	call s:test_is_enabled_buffer()

	call s:force_enable()
endfunction

" toggle_mode
" 1: global mode
" 2: buffer mode
function! s:test_toggle(toggle_mode)

	" [case10-0] =====================================
	call spelunker#test#open_unit_test_buffer('toggle', 'toggle1.txt')
	call spelunker#test#init()

	call s:force_enable()

	call s:toggle(a:toggle_mode)

	" highlightがなくなっていることを確認
	call s:toggle(a:toggle_mode)
	let l:result = getmatches()
	call assert_equal(1, len(l:result))
	call assert_equal('SpelunkerSpellBad', l:result[0]['group'])
	call assert_equal('\v[A-Za-z]@<!appl[a-z]@!\C', l:result[0]['pattern'])
	call assert_equal(0, l:result[0]['priority'])
	call s:toggle(a:toggle_mode)
	let l:result = getmatches()
	call assert_equal([], l:result)

	" spelunker#check_displayed_words spelunker#check
	let g:spelunker_check_type = g:spelunker_check_type_buf_lead_write
	call assert_equal(0, spelunker#check_displayed_words())

	let g:spelunker_check_type = g:spelunker_check_type_cursor_hold
	call assert_equal(0, spelunker#check())

	" call assert_equal(0, spelunker#check_and_echo_list())

	" spelunker#jump_next spelunker#jump_prev
	call cursor(1,1)
	call assert_equal(0, spelunker#jump_next())
	call spelunker#test#assert_cursor_pos(1, 1)
	call assert_equal(0, spelunker#jump_prev())
	call spelunker#test#assert_cursor_pos(1, 1)

	call assert_equal(0, spelunker#add_all_spellgood())

	" register word dict test
	call assert_equal(0, spelunker#execute_with_target_word(''))

	" [case10-1] =====================================
	call s:toggle(a:toggle_mode)

	" spelunker#check_displayed_words spelunker#check "{{{
	let g:spelunker_check_type = g:spelunker_check_type_buf_lead_write
	call assert_equal(1, spelunker#check())

	let g:spelunker_check_type = g:spelunker_check_type_cursor_hold
	call assert_equal(1, spelunker#check_displayed_words())

	" call assert_equal(1, spelunker#check_and_echo_list())
	" }}}

	" spelunker#jump_next spelunker#jump_prev "{{{
	call cursor(1,1)
	call assert_equal(1, spelunker#jump_next())
	call spelunker#test#assert_cursor_pos(2, 1)
	call assert_equal(1, spelunker#jump_prev())
	call spelunker#test#assert_cursor_pos(1, 1)
	" }}}

	" spelunker#spellbad#get_spell_bad_list "{{{
	" call assert_equal(1, spelunker#add_all_spellgood())

	" register word dict test
	call spelunker#test#open_unit_test_buffer('toggle', 'toggle2.txt')
	call spelunker#test#init()
	call cursor(1,1)
	let l:line = spelunker#spellbad#get_spell_bad_list(1, -1)
	call assert_equal(['addgoodword'], l:line)

	call assert_equal(1, spelunker#execute_with_target_word('spellgood!'))
	let l:line = spelunker#spellbad#get_spell_bad_list(1, -1)
	call assert_equal([], l:line)

	call spelunker#test#reload_buffer()
	call cursor(2,1)
	let l:line = spelunker#spellbad#get_spell_bad_list(2, -1)
	call assert_equal([], l:line)

	call assert_equal(1, spelunker#execute_with_target_word('spellwrong!'))
	let l:line = spelunker#spellbad#get_spell_bad_list(2, -1)
	call assert_equal(['wrong'], l:line)
	" }}}

	" [case11-0] =====================================
	call s:toggle(a:toggle_mode)

	" spelunker#correct
	call spelunker#test#open_unit_test_buffer('toggle', 'toggle3.txt')
	call spelunker#test#init()
	call cursor(1, 2)
	call assert_equal(0, spelunker#correct())
	call assert_equal(0, spelunker#correct_all())
	call assert_equal(0, spelunker#correct_from_list())
	call assert_equal(0, spelunker#correct_all_from_list())
	call assert_equal(0, spelunker#correct_feeling_lucky())
	call assert_equal(0, spelunker#correct_all_feeling_lucky())
	call assert_equal('aple', expand("<cword>"))

	" [case11-1] =====================================
	call s:toggle(a:toggle_mode)

	" spelunker#correct
	call spelunker#test#reload_buffer()
	call spelunker#test#init()
	call cursor(1, 2)
	" call assert_equal(0, spelunker#correct())
	" call assert_equal(0, spelunker#correct_all())
	" call assert_equal(0, spelunker#correct_from_list())
	" call assert_equal(0, spelunker#correct_all_from_list())
	call assert_equal(1, spelunker#correct_feeling_lucky())
	call assert_equal('apple', expand("<cword>"))

	call spelunker#test#reload_buffer()
	call spelunker#test#init()
	call cursor(1, 2)
	call assert_equal(1, spelunker#correct_all_feeling_lucky())
	call assert_equal('apple', expand("<cword>"))
	call cursor(3, 8)
	call assert_equal('apple', expand("<cword>"))
	call cursor(4, 1)
	call assert_equal('apple', expand("<cword>"))

	" 編集中の変更を破棄
	call spelunker#test#reload_buffer()
endfunction

" toggle_mode
" 1: global mode
" 2: buffer mode
function! s:toggle(toggle_mode)
	if a:toggle_mode == 1
		call spelunker#toggle#toggle()
	elseif a:toggle_mode == 2
		call spelunker#toggle#toggle_buffer()
	endif
endfunction

function! s:test_is_enabled()
	call spelunker#test#open_unit_test_buffer('toggle', 'toggle1.txt')
	call spelunker#test#init()

	call assert_equal(1, spelunker#toggle#is_enabled())

	" disabled (global)
	call spelunker#toggle#toggle()
	call assert_equal(0, spelunker#toggle#is_enabled())

	" enabled (global)
	call spelunker#toggle#toggle()
	call assert_equal(1, spelunker#toggle#is_enabled())

	" disabled (global)
	call spelunker#toggle#toggle_buffer()
	call assert_equal(0, spelunker#toggle#is_enabled())

	" enabled (global)
	call spelunker#toggle#toggle_buffer()
	call assert_equal(1, spelunker#toggle#is_enabled())

	" enabled with global toggle
	call spelunker#toggle#toggle() " disabled (global)
	call spelunker#toggle#toggle_buffer() " disabled (buffer)
	call spelunker#toggle#toggle() " disabled (global)
	call assert_equal(1, spelunker#toggle#is_enabled())
endfunction

function! s:test_is_enabled_global()
	call spelunker#test#open_unit_test_buffer('toggle', 'toggle1.txt')
	call spelunker#test#init()

	call assert_equal(1, spelunker#toggle#is_enabled_global())

	" disabled (global)
	call spelunker#toggle#toggle()
	call assert_equal(0, spelunker#toggle#is_enabled_global())

	" enabled (global)
	call spelunker#toggle#toggle()
	call assert_equal(1, spelunker#toggle#is_enabled_global())
endfunction

function! s:test_is_enabled_buffer()
	call spelunker#test#open_unit_test_buffer('toggle', 'toggle1.txt')
	call spelunker#test#init()

	call assert_equal(1, spelunker#toggle#is_enabled_buffer())

	" disabled (global)
	call spelunker#toggle#toggle_buffer()
	call assert_equal(0, spelunker#toggle#is_enabled_buffer())

	" enabled (global)
	call spelunker#toggle#toggle_buffer()
	call assert_equal(1, spelunker#toggle#is_enabled_buffer())
endfunction

function! s:force_enable()
	let g:enable_spelunker_vim = 1
	let b:enable_spelunker_vim = 1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
