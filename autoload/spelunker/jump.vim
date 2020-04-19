" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#jump#jump_matched(is_search_next)
	let l:spell_bad_list = []
	let l:current_line = line(".")
	let l:start_line = l:current_line

	let l:is_first_loop = 1
	let l:end_line = s:get_end_of_line(a:is_search_next)
	let l:is_enable_wrapscan = s:is_enable_wrapscan()

	let l:filtered_buffer = spelunker#get_buffer#all()

	" 表示範囲だけhighlightしている場合もあるので、1行ずつチェックしていく
	while 1
		let l:matched_pos = -1

		let l:spell_bad_list = spelunker#spellbad#get_spell_bad_list([get(l:filtered_buffer, l:current_line - 1, '')])

		if len(l:spell_bad_list) > 0
			for word in l:spell_bad_list
				let l:pattern = spelunker#matches#get_match_pattern(word)

				let l:start_pos = s:get_start_pos(l:current_line, a:is_search_next, l:is_first_loop)
				let l:tmp_matched_pos = s:get_matched_pos(l:current_line, l:pattern, l:start_pos, a:is_search_next)

				let l:matched_pos = s:get_match_pos(l:matched_pos, l:tmp_matched_pos, a:is_search_next)
			endfor
		endif

		if l:matched_pos >= 0
			break
		endif

		if !l:is_enable_wrapscan && l:current_line == l:end_line
			" wrapscanが有効ではなく、最後の行にたどり着いた場合
			break
		elseif l:is_first_loop != 1 && l:start_line == l:current_line
			" 周回してきて、同じ行に戻ってきた場合
			break
		endif

		let l:current_line = s:get_next_line(a:is_search_next, l:current_line)
		let l:is_first_loop = 0
	endwhile

	if l:matched_pos >= 0
		call cursor(l:current_line, l:matched_pos + 1)
	endif
endfunction

function s:get_matched_pos(current_line, pattern, start_pos, is_search_next)
	if a:is_search_next == 1
		return match(getline(a:current_line), a:pattern, a:start_pos)
	endif

	" 逆順の場合、最後にマッチするポジションを返す
	let l:last_matched_pos = -1
	while 1
		let l:match_start_pos = l:last_matched_pos + 1
		let l:matched_pos = match(getline(a:current_line), a:pattern, l:match_start_pos)

		if a:start_pos - 1 < l:matched_pos || l:matched_pos == -1
			break
		endif

		let l:last_matched_pos = l:matched_pos
	endwhile

	return l:last_matched_pos
endfunction

function s:get_start_pos(current_line, is_search_next, is_first_loop)
	if a:is_first_loop == 1
		" カーソルの位置よりも後を探す
		let l:start_pos = col('.')
		if a:is_search_next == 1
			let l:start_pos = l:start_pos + 1
		else
			let l:start_pos = l:start_pos - 1
		endif
	else
		if a:is_search_next == 1
			let l:start_pos = 0
		else
			let l:start_pos = strchars(getline(a:current_line))
		endif
	endif

	return l:start_pos
endfunction

function s:get_next_line(is_search_next, current_line)
	let l:end_line = line("$")
	if a:is_search_next == 1
		if a:current_line >= l:end_line
			return 0
		endif
	else
		if a:current_line <= 0
			return l:end_line
		endif
	endif

	let l:move_next = s:get_move_next(a:is_search_next)
	return a:current_line + l:move_next
endfunction

function s:get_move_next(is_search_next)
	if a:is_search_next == 1
		return 1
	else
		return -1
	endif
endfunction

function s:get_match_pos(matched_pos, tmp_matched_pos, is_search_next)
	if a:is_search_next == 1
		let l:matched_pos = a:matched_pos >= 0 ?
					\ min([a:matched_pos, a:tmp_matched_pos]) :
					\ a:tmp_matched_pos
	else
		let l:matched_pos = a:matched_pos >= 0 ?
					\ max([a:matched_pos, a:tmp_matched_pos]) :
					\ a:tmp_matched_pos
	endif

	return l:matched_pos
endfunction

function s:get_end_of_line(is_search_next)
	if a:is_search_next == 1
		return line("$")
	else
		return 0
	endif
endfunction

function s:is_enable_wrapscan()
	redir => wrapscan_setting_capture
	silent execute "set wrapscan?"
	redir END

	" ex) '      wrapscan' -> 'wrapscan'
	let l:wrapscan_setting_capture = substitute(l:wrapscan_setting_capture, '\v(\n|\s)\C', '', 'g')
	return l:wrapscan_setting_capture == 'wrapscan'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
