" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#toggle#toggle()
	let g:enable_spelunker_vim = g:enable_spelunker_vim == 1 ? 0 : 1

	" onにするときは今開いているbufferも連動させる
	if g:enable_spelunker_vim == 1
		let b:enable_spelunker_vim = 1
	endif

	call spelunker#toggle#init_buffer(1, g:enable_spelunker_vim)

	if g:enable_spelunker_vim == 1
		echom 'Spelunker.vim on. (global)'
	else
		echom 'Spelunker.vim off. (global)'
	endif
endfunction

function! spelunker#toggle#toggle_buffer()
	if !exists('b:enable_spelunker_vim')
		let b:enable_spelunker_vim = 1
	endif

	let b:enable_spelunker_vim = b:enable_spelunker_vim == 1 ? 0 : 1
	call spelunker#toggle#init_buffer(2, b:enable_spelunker_vim)

	if b:enable_spelunker_vim == 1
		echom 'Spelunker.vim on. (buffer)'
	else
		echom 'Spelunker.vim off. (buffer)'
	endif
endfunction

function! spelunker#toggle#init_buffer(mode, is_enabled)
	if a:is_enabled == 0
		if a:mode == 1 " for global
			call spelunker#matches#clear_matches()
		elseif a:mode == 2 " for buffer
			call spelunker#matches#clear_current_buffer_matches()
		endif
	elseif a:is_enabled == 1
		if g:spelunker_check_type == g:spelunker_check_type_buf_lead_write
			call spelunker#check()
		elseif g:spelunker_check_type == g:spelunker_check_type_cursor_hold
			call spelunker#check_displayed_words()
		endif
	endif
endfunction

function! spelunker#toggle#is_enabled()
	if spelunker#toggle#is_enabled_buffer() == 0 || spelunker#toggle#is_enabled_global() == 0
		return 0
	endif

	return 1
endfunction

function! spelunker#toggle#is_enabled_global()
	if g:enable_spelunker_vim == 0
		return 0
	endif
	return 1
endfunction


function! spelunker#toggle#is_enabled_buffer()
	if exists('b:enable_spelunker_vim') && b:enable_spelunker_vim == 0
		return 0
	endif

	return 1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
