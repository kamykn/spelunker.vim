" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_spellbad#test()
	call s:test_get_word_list_in_line()
	call s:test_get_spell_bad_list()
endfunction

function! s:test_get_word_list_in_line()
	call assert_equal(['this', 'car', 'func'], spelunker#spellbad#get_word_list_in_line('    $this->car->func()', []))
	call assert_equal(['apple'], spelunker#spellbad#get_word_list_in_line('    \tapple', []))
	call assert_equal(['apple', 'this'], spelunker#spellbad#get_word_list_in_line('apple\rthis', []))
endfunction

function! s:test_get_spell_bad_list()
	" 通常の引っかかるケース
	call spelunker#test#open_unit_test_buffer('case1')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal(['appl', 'Banan', 'Oran'], l:result)

	let l:result = spelunker#spellbad#get_spell_bad_list(6, -1)
	call assert_equal(['appl', 'banan', 'oran'], l:result)

	" First Upper Case and lower case
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 6)
	call assert_equal(['appl', 'Banan', 'Oran', 'banan', 'oran'], l:result)

	" Upper Case
	call spelunker#test#open_unit_test_buffer('case2')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 10)
	call assert_equal(['HTMLF', 'FFFCC'], l:result)

	" control character
	call spelunker#test#open_unit_test_buffer('case3')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal([], l:result)

	let l:result = spelunker#spellbad#get_spell_bad_list(9, -1)
	call assert_equal(['Banan', 'Oage', 'Pach'], l:result)

	" char count
	call spelunker#test#open_unit_test_buffer('case4')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal(['purp', 'purpl'], l:result)

	" First upper case word
	call spelunker#test#open_unit_test_buffer('case5')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, -1)
	call assert_equal([], l:result)

	" Edge cases
	call spelunker#test#open_unit_test_buffer('case6')
	let l:result = spelunker#spellbad#get_spell_bad_list(7, -1)
	call assert_equal([], l:result)

	" set spelllang
	call spelunker#test#open_unit_test_buffer('case8')
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 10)
	call assert_equal([], l:result)

	" en_usなどの国別の設定のケース
	setlocal spelllang=en_us

	let l:result = spelunker#spellbad#get_spell_bad_list(5, 10)
	call assert_equal(['colour'], l:result)

	let g:spelunker_highlight_type = g:spelunker_highlight_spell_bad
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 10)
	call assert_equal([], l:result)

	let g:spelunker_highlight_type = g:spelunker_highlight_all
	let l:result = spelunker#spellbad#get_spell_bad_list(5, 10)
	call assert_equal(['colour'], l:result)

	" 設定戻す
	setlocal spelllang=en
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
