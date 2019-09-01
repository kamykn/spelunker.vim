" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#jump#jump_matched()
	let l:spell_bad_list = []
	let l:current_line = line(".")
	let l:start_line = l:current_line
	let l:end_line = line("w$")

	" 表示範囲だけhighlightしている場合もあるので、1行ずつチェックしていく
	while 1
		if l:current_line > l:end_line
			break
		endif

		let l:spell_bad_list = spelunker#spellbad#get_spell_bad_list(l:current_line, -1)

		let l:matched_pos = -1
		if len(l:spell_bad_list) > 0
			for word in l:spell_bad_list
				let l:pattern = spelunker#matches#get_match_pattern(word)

				let l:start_pos = 0
				if l:start_line == l:current_line
					let l:start_pos = col('.')
				endif

				let l:tmp_matched_pos = match(getline(l:current_line), l:pattern, l:start_pos)

				let l:matched_pos = l:matched_pos >= 0 ?
									\ min([l:matched_pos, l:tmp_matched_pos]) :
									\ l:tmp_matched_pos
			endfor
		endif

		if l:matched_pos >= 0
			break
		endif

		let l:current_line = l:current_line + 1
	endwhile

	call cursor(l:current_line, l:matched_pos + 1)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
