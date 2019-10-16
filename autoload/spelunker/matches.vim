" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" match_idを先頭の1単語目の場合と２単語目の場合の大文字のケースで管理する必要が有ることに注意
" 例：{'strlen': 4, 'Strlen': 5}
function! spelunker#matches#add_matches(spell_bad_list, match_id_dict)
	let l:current_matched_list         = keys(a:match_id_dict)
	let l:word_list_for_delete_match   = l:current_matched_list " spellbadとして今回検知されなければ削除するリスト
	let l:match_id_dict                = a:match_id_dict

	for word in a:spell_bad_list
		if index(l:current_matched_list, word) == -1
			" 新しく見つかった場合highlightを設定する
			let l:highlight_group = g:spelunker_spell_bad_group
			if spelunker#white_list#is_complex_or_compound_word(word)
				let l:highlight_group = g:spelunker_complex_or_compound_word_group
			endif

			let l:pattern = spelunker#matches#get_match_pattern(word)

			let l:match_id = matchadd(l:highlight_group, l:pattern, 0)
			execute 'let l:match_id_dict.' . word . ' = ' . l:match_id
		else
			" すでにある場合には削除予定リストから単語消す
			let l:del_index = index(l:word_list_for_delete_match, word)
			call remove(l:word_list_for_delete_match, l:del_index)
		endif
	endfor

	return [l:word_list_for_delete_match, l:match_id_dict]
endfunction

" match系関数用のpattern生成関数
function spelunker#matches#get_match_pattern(word)
	" ここに来るwordはbuffer上と同じUpper case First or Lowercase
	" 大文字小文字無視オプションを使わない(事故るのを防止するため)
	" ng: xxxAttr -> [atTr]iplePoint
	" priorityはhlsearchと同じ0で指定して、検索時は検索が優先されるようにする
	"
	" #10 小文字で続く場合はormatという間違いでformatのように正しい単語をハイライトしてほしくない

	let l:uc_position = match(a:word, '\v[A-Z]\C', 0)
	if l:uc_position == 0
		let l:pattern = '\v[A-Z]@<!' . a:word . '[a-z]@!\C'
	else
		" start with lower case #10
		let l:pattern = '\v[A-Za-z]@<!' . a:word . '[a-z]@!\C'
	endif

	return l:pattern
endfunction

function! spelunker#matches#delete_matches(word_list_for_delete, match_id_dict)
	let l:match_id_dict = a:match_id_dict

	for l:word in a:word_list_for_delete
		let l:delete_match_id = get(l:match_id_dict, l:word, 0)
		if l:delete_match_id > 0
			try
				call matchdelete(l:delete_match_id)
			catch
				" エラー読み捨て
			finally
				let l:del_index = index(values(l:match_id_dict), l:delete_match_id)
				if l:del_index != 1
					call remove(l:match_id_dict, keys(l:match_id_dict)[l:del_index])
				endif
			endtry
		endif
	endfor

	return l:match_id_dict
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
