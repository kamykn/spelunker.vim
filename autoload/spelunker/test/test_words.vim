" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_words#test()
	call s:test_search_target_word()
	call s:test_format_spell_suggest_list()
	call s:test_cut_text_word_before()
	call s:test_replace_word()
	call s:test_check()
	call s:test_check_display_area()
	call s:test_highlight()
endfunction

function! s:test_search_target_word()
	call spelunker#test#open_unit_test_buffer('words', 'search_target_word.txt')

	" spelunker#words#search_target_word
	call cursor(1, 1)
	call assert_equal('aple', spelunker#words#search_target_word())

	call cursor(1, 6)
	call assert_equal('banan', spelunker#words#search_target_word())

	call cursor(1, 10)
	call assert_equal('banan', spelunker#words#search_target_word())
endfunction

function! s:test_format_spell_suggest_list()
	call spelunker#test#open_unit_test_buffer('words', 'search_target_word.txt')

	" spelunker#words#format_spell_suggest_list
	let l:result = spelunker#words#format_spell_suggest_list(['apple', 'banana', "It's", 'Pièces', 'a.b.c'], 'Apple')
	call assert_equal([['1: "Apple"', '2: "Banana"', '3: "A_b_c"'], ['Apple', 'Banana', 'A_b_c']], l:result)

	" #10 Documention -> Document Ion -> Documention
	" https://github.com/kamykn/spelunker.vim/issues/10
 	let b:camel_case_count = 100
	let l:result = spelunker#words#format_spell_suggest_list(['Document Ion'], 'Document Ion')
	call assert_equal([['1: "DocumentIon"'], ['DocumentIon']], l:result)
endfunction

function! s:test_cut_text_word_before()
	call spelunker#test#open_unit_test_buffer('words', 'search_target_word.txt')

	" spelunker#words#cut_text_word_before
	let l:result = spelunker#words#cut_text_word_before('applebananaorange', 'banana')
	call assert_equal('orange', l:result)

	let l:result = spelunker#words#cut_text_word_before('applebananaorange', 'melon')
	call assert_equal('applebananaorange', l:result)
endfunction

function! s:test_replace_word()
	call spelunker#test#open_unit_test_buffer('words', 'search_target_word.txt')

	" spelunker#words#replace_word
	call cursor(3, 6)
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(3, 6)
	call cursor(4, 6)
	call assert_equal('documention', expand("<cword>"))
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call cursor(4, 15)
	call assert_equal('documention', expand("<cword>"))
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))

	call spelunker#test#reload_buffer()

	call cursor(3, 6)
	call spelunker#words#replace_word('documention', 'documentation', 1)
	call assert_equal('documentation', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(3, 6)
	call cursor(4, 6)
	call assert_equal('documentation', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(4, 6)

	call spelunker#test#reload_buffer()

	" 単語の先頭
	call cursor(3, 1)
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(3, 1)

	" 単語の最後
	call cursor(4, 11)
	call spelunker#words#replace_word('documention', 'documentation', 0)
	call assert_equal('documentation', expand("<cword>"))
	call spelunker#test#assert_cursor_pos(4, 11)
endfunction

function! s:test_check()
	call spelunker#test#open_unit_test_buffer('words', 'check.txt')
	call spelunker#test#clear_matches()

	call spelunker#words#check()
	let l:result = getmatches()
	call assert_equal(4, len(l:result))

	call assert_equal('SpelunkerSpellBad', l:result[0]['group'])
	call assert_equal('\v[A-Za-z]@<!appl[a-z]@!\C', l:result[0]['pattern'])
	call assert_equal(0, l:result[0]['priority'])

	call assert_equal('SpelunkerSpellBad', l:result[1]['group'])
	call assert_equal('\v[A-Za-z]@<!banan[a-z]@!\C', l:result[1]['pattern'])
	call assert_equal(0, l:result[1]['priority'])

	call assert_equal('SpelunkerSpellBad', l:result[2]['group'])
	call assert_equal('\v[A-Za-z]@<!graape[a-z]@!\C', l:result[2]['pattern'])
	call assert_equal(0, l:result[2]['priority'])

	call assert_equal('SpelunkerSpellBad', l:result[3]['group'])
	call assert_equal('\v[A-Za-z]@<!lemone[a-z]@!\C', l:result[3]['pattern'])
	call assert_equal(0, l:result[3]['priority'])
endfunction

function! s:test_check_display_area()
	call spelunker#test#open_unit_test_buffer('words', 'check.txt')
	call spelunker#test#clear_matches()

	call spelunker#words#check_display_area()
	let l:result = getmatches()

	call assert_equal(2, len(l:result))

	call assert_equal('SpelunkerSpellBad', l:result[0]['group'])
	call assert_equal('\v[A-Za-z]@<!appl[a-z]@!\C', l:result[0]['pattern'])
	call assert_equal(0, l:result[0]['priority'])

	call assert_equal('SpelunkerSpellBad', l:result[1]['group'])
	call assert_equal('\v[A-Za-z]@<!banan[a-z]@!\C', l:result[1]['pattern'])
	call assert_equal(0, l:result[1]['priority'])
endfunction

function! s:test_highlight()
	call spelunker#test#open_unit_test_buffer('words', 'highlight.txt')

	call spelunker#words#highlight(['banana', 'apple', 'lemon', 'Banana', 'Apple', 'Lemon'])
	let l:result = getmatches()

	call assert_equal(8, len(l:result))

	call assert_equal('SpelunkerSpellBad', l:result[0]['group'])
	call assert_equal('\v[A-Za-z]@<!appl[a-z]@!\C', l:result[0]['pattern'])
	call assert_equal(0, l:result[0]['priority'])

	call assert_equal('SpelunkerSpellBad', l:result[1]['group'])
	call assert_equal('\v[A-Za-z]@<!banan[a-z]@!\C', l:result[1]['pattern'])
	call assert_equal(0, l:result[1]['priority'])

	call assert_equal('SpelunkerSpellBad', l:result[2]['group'])
	call assert_equal('\v[A-Za-z]@<!banana[a-z]@!\C', l:result[2]['pattern'])
	call assert_equal(0, l:result[2]['priority'])

	call assert_equal('SpelunkerSpellBad', l:result[3]['group'])
	call assert_equal('\v[A-Za-z]@<!apple[a-z]@!\C', l:result[3]['pattern'])
	call assert_equal(0, l:result[3]['priority'])

	call assert_equal('SpelunkerSpellBad', l:result[4]['group'])
	call assert_equal('\v[A-Za-z]@<!lemon[a-z]@!\C', l:result[4]['pattern'])
	call assert_equal(0, l:result[4]['priority'])

	call assert_equal('SpelunkerSpellBad', l:result[5]['group'])
	call assert_equal('\v[A-Z]@<!Banana[a-z]@!\C', l:result[5]['pattern'])
	call assert_equal(0, l:result[5]['priority'])

	call assert_equal('SpelunkerSpellBad', l:result[6]['group'])
	call assert_equal('\v[A-Z]@<!Apple[a-z]@!\C', l:result[6]['pattern'])
	call assert_equal(0, l:result[6]['priority'])

	call assert_equal('SpelunkerSpellBad', l:result[7]['group'])
	call assert_equal('\v[A-Z]@<!Lemon[a-z]@!\C', l:result[7]['pattern'])
	call assert_equal(0, l:result[7]['priority'])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
