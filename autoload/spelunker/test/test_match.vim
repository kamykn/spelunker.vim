" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#test#test_match#test()
	call s:test_get_match_pattern()
	let l:match_id_list = s:test_add_matches()
	call s:test_delete_matches(l:match_id_list)

	call s:test_clear_matches()
	call s:test_clear_buffer_matches()
	call s:test_is_exist_match_id()
endfunction

function! s:test_get_match_pattern()
	let l:word = 'banana'
	call assert_equal('\v[A-Za-z]@<!' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_match(spelunker#matches#get_match_pattern(l:word), 'orange_banana_apple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'orangebanana_apple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'orange_bananaapple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'Abanana')

	let l:word = 'Banana'
	call assert_equal('\v' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_match(spelunker#matches#get_match_pattern(l:word), 'OreangeBananaApple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'OreangeBananaapple' )

	" HTTP or HTTPS??
	let l:word = 'Spanner'
	call assert_equal('\v' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_match(spelunker#matches#get_match_pattern(l:word), 'HTTPSpanner')

	" # ISSUE/PR
	" #10 https://github.com/kamykn/spelunker.vim/pull/10
	let l:word = 'ormat' " <= typo 'format'
	call assert_equal('\v[A-Za-z]@<!' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'doormat')

	" # ISSUE/PR
	" #51 https://github.com/kamykn/spelunker.vim/issues/51
	let l:word = 'Gabrage' " <= typo 'format'
	call assert_equal('\v' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_match(spelunker#matches#get_match_pattern(l:word), 'ABCDGabrage')
endfunction

function! s:test_add_matches()
	" get_match_pattern "{{{
	call spelunker#test#open_unit_test_buffer('match', 'add_matches.txt')
	let l:match_id_list = spelunker#matches#add_matches(['apple', 'orange', 'melon', 'lemon'], {})
	call assert_equal([], l:match_id_list[0])
	" {'orange': 5, 'apple': 4, 'melon': 6, 'lemon': 7}
	call assert_equal(['orange', 'apple', 'melon', 'lemon'], keys(l:match_id_list[1]))

	let l:match_id_list = spelunker#matches#add_matches(['apple', 'orange', 'peach', 'grape'], l:match_id_list[1])
	call assert_equal(['melon', 'lemon'], l:match_id_list[0])
	" {'orange': 5, 'peach': 8, 'apple': 4, 'melon': 6, 'lemon': 7, 'grape': 9}
	call assert_equal(['orange', 'peach', 'apple', 'melon', 'lemon', 'grape'], keys(l:match_id_list[1]))

	return l:match_id_list
endfunction

function! s:test_delete_matches(match_id_list)
	let l:win_id = win_getid()
	call spelunker#test#open_unit_test_buffer('match', 'add_matches.txt')
	let l:match_id_list_after_delete = spelunker#matches#delete_matches(a:match_id_list[0], a:match_id_list[1], l:win_id)
	" {'orange': 5, 'peach': 8, 'apple': 4, 'grape': 9}
	call assert_equal(['orange', 'peach', 'apple', 'grape'], keys(l:match_id_list_after_delete))

	let l:all_ids = keys(l:match_id_list_after_delete)
	let l:match_id_list_after_delete = spelunker#matches#delete_matches(l:all_ids, l:match_id_list_after_delete, l:win_id)
	call assert_equal({}, l:match_id_list_after_delete)
endfunction

function! s:test_clear_matches()
	call spelunker#test#open_unit_test_buffer('match', 'clear_matches.txt')

	let l:win_id = win_getid()
	let b:match_id_dict = {}
	let [l:word_list_for_delete_match, b:match_id_dict[l:win_id]]
			\ = spelunker#matches#add_matches(['appl', 'orangg', 'banna'], {})

	call assert_notequal({}, b:match_id_dict[l:win_id])
	call spelunker#matches#clear_matches()
	call assert_equal({l:win_id: {}}, b:match_id_dict)
endfunction

function! s:test_clear_buffer_matches()
	call spelunker#test#open_unit_test_buffer('match', 'clear_matches.txt')

	let l:win_id = win_getid()
	let b:match_id_dict = {}
	let [l:word_list_for_delete_match, b:match_id_dict[l:win_id]]
			\ = spelunker#matches#add_matches(['appl', 'orangg', 'banna'], {})

	call assert_notequal({}, b:match_id_dict[l:win_id])
	call spelunker#matches#clear_current_buffer_matches()
	call assert_equal({l:win_id: {}}, b:match_id_dict)
endfunction

function! s:test_is_exist_match_id()
	call spelunker#test#open_unit_test_buffer('match', 'clear_matches.txt')

	let l:win_id = win_getid()
	let b:match_id_dict = {}
	let [l:word_list_for_delete_match, b:match_id_dict[l:win_id]]
			\ = spelunker#matches#add_matches(['appl', 'orangg', 'banna'], {})

	let l:exist_match_id = b:match_id_dict[l:win_id]['appl']
	call assert_equal(v:true, spelunker#matches#is_exist_match_id(l:exist_match_id))
	call assert_equal(v:false, spelunker#matches#is_exist_match_id(99999999))

	call clearmatches()
	call assert_equal(v:false, spelunker#matches#is_exist_match_id(l:exist_match_id))

	call spelunker#matches#clear_matches()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
