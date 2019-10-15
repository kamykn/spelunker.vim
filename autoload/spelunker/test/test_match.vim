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
endfunction

function! s:test_get_match_pattern()
	let l:word = 'banana'
	call assert_equal('\v[A-Za-z]@<!' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_match(spelunker#matches#get_match_pattern(l:word), 'orange_banana_apple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'orangebanana_apple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'orange_bananaapple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'Abanana')

	let l:word = 'Banana'
	call assert_equal('\v[A-Z]@<!' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_match(spelunker#matches#get_match_pattern(l:word), 'OreangeBananaApple')
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'OreangeBananaapple' )

	" HTTP or HTTPS??
	let l:word = 'Spanner'
	call assert_equal('\v[A-Z]@<!' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'HTTPSpanner')

	" # ISSUE/PR
	" #10 https://github.com/kamykn/spelunker.vim/pull/10
	let l:word = 'ormat' " <= typo 'format'
	call assert_equal('\v[A-Za-z]@<!' . l:word . '[a-z]@!\C', spelunker#matches#get_match_pattern(l:word))
	call assert_notmatch(spelunker#matches#get_match_pattern(l:word), 'doormat')
endfunction

function! s:test_add_matches()
	" get_match_pattern "{{{
	call spelunker#test#open_unit_test_buffer('case7')
	let l:match_id_list = spelunker#matches#add_matches(['apple', 'orange', 'melon', 'lemon'], {})
	call assert_equal([], l:match_id_list[0])
	call assert_equal({'orange': 9, 'apple': 8, 'melon': 10, 'lemon': 11}, l:match_id_list[1])

	let l:match_id_list = spelunker#matches#add_matches(['apple', 'orange', 'peach', 'grape'], l:match_id_list[1])
	call assert_equal(['melon', 'lemon'], l:match_id_list[0])
	call assert_equal({'orange': 9, 'peach': 12, 'apple': 8, 'melon': 10, 'lemon': 11, 'grape': 13}, l:match_id_list[1])

	return l:match_id_list
endfunction

function! s:test_delete_matches(match_id_list)
	let l:match_id_list_after_delete = spelunker#matches#delete_matches(a:match_id_list[0], a:match_id_list[1])
	call assert_equal({'orange': 9, 'peach': 12, 'apple': 8, 'grape': 13}, l:match_id_list_after_delete)

	let l:all_ids = keys(l:match_id_list_after_delete)
	let l:match_id_list_after_delete = spelunker#matches#delete_matches(l:all_ids, l:match_id_list_after_delete)
	call assert_equal({}, l:match_id_list_after_delete)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
