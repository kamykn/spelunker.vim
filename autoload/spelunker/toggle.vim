" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#toggle#toggle()
	let g:enable_spelunker_vim = g:enable_spelunker_vim == 1 ? 0 : 1

	if g:enable_spelunker_vim == 0
		" matchからの削除処理を利用してハイライト削除
		let l:window_id = win_getid()
		let b:match_id_dict[l:window_id] =
			\ spelunker#matches#delete_matches(keys(b:match_id_dict[l:window_id]), b:match_id_dict[l:window_id])
	else
		if g:spelunker_check_type == g:spelunker_check_type_buf_lead_write
			call spelunker#check()
		elseif g:spelunker_check_type == g:spelunker_check_type_cursor_hold
			call spelunker#check_displayed_words()
		endif
	endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
