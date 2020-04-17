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
	call spelunker#test#open_unit_test_buffer('spellbad', 'get_spell_bad_list1.txt')
	let l:window_text_list = spelunker#get_buffer#all()
	let l:result = spelunker#spellbad#get_spell_bad_list(l:window_text_list)
	call assert_equal(['appl', 'Banan', 'Orag', 'banan', 'orag'], l:result)

	" Upper Case
	call spelunker#test#open_unit_test_buffer('spellbad', 'get_spell_bad_list2.txt')
	let l:window_text_list = spelunker#get_buffer#all()
	let l:result = spelunker#spellbad#get_spell_bad_list(l:window_text_list)
	call assert_equal(['HTMLF', 'FFFCC'], l:result)

	" control character
	call spelunker#test#open_unit_test_buffer('spellbad', 'get_spell_bad_list3_1.txt')
	let l:window_text_list = spelunker#get_buffer#all()
	let l:result = spelunker#spellbad#get_spell_bad_list(l:window_text_list)
	call assert_equal([], l:result)

	call spelunker#test#open_unit_test_buffer('spellbad', 'get_spell_bad_list3_2.txt')
	let l:window_text_list = spelunker#get_buffer#all()
	let l:result = spelunker#spellbad#get_spell_bad_list(l:window_text_list)
	call assert_equal(['Banan', 'Oage', 'Pach'], l:result)

	" char count
	call spelunker#test#open_unit_test_buffer('spellbad', 'get_spell_bad_list4.txt')
	let l:window_text_list = spelunker#get_buffer#all()
	let l:result = spelunker#spellbad#get_spell_bad_list(l:window_text_list)
	call assert_equal(['purp', 'purpl'], l:result)

	" 先頭大文字のケースしかない単語
	call spelunker#test#open_unit_test_buffer('spellbad', 'get_spell_bad_list5.txt')
	let l:window_text_list = spelunker#get_buffer#all()
	let l:result = spelunker#spellbad#get_spell_bad_list(l:window_text_list)
	call assert_equal([], l:result)

	" Edge cases
	" # #6 https://github.com/kamykn/spelunker.vim/pull/6
	" # 過去に[A-Z\s]が事故ってたため
	" # (引っかからないケース)
	call spelunker#test#open_unit_test_buffer('spellbad', 'get_spell_bad_list6.txt')
	let l:window_text_list = spelunker#get_buffer#all()
	let l:result = spelunker#spellbad#get_spell_bad_list(l:window_text_list)
	call assert_equal([], l:result)

	" set spelllang
	" # spelllangによる動作の違いのチェック
	call spelunker#test#open_unit_test_buffer('spellbad', 'get_spell_bad_list7.txt')
	let l:window_text_list = spelunker#get_buffer#all()
	let l:result = spelunker#spellbad#get_spell_bad_list(l:window_text_list)
	call assert_equal([], l:result)

	" en_usなどの国別の設定のケース
	setlocal spelllang=en_us

	let l:window_text_list = spelunker#get_buffer#all()
	let l:result = spelunker#spellbad#get_spell_bad_list(l:window_text_list)
	call assert_equal(['colour'], l:result)

	let g:spelunker_highlight_type = g:spelunker_highlight_spell_bad
	let l:window_text_list = spelunker#get_buffer#all()
	let l:result = spelunker#spellbad#get_spell_bad_list(l:window_text_list)
	call assert_equal([], l:result)

	let g:spelunker_highlight_type = g:spelunker_highlight_all
	let l:window_text_list = spelunker#get_buffer#all()
	let l:result = spelunker#spellbad#get_spell_bad_list(l:window_text_list)
	call assert_equal(['colour'], l:result)

	" 設定戻す
	setlocal spelllang=en
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
