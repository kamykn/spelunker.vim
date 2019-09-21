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
		let b:match_id_dict = spelunker#matches#delete_matches(keys(b:match_id_dict), b:match_id_dict)
	else
		call spelunker#check()
	endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
