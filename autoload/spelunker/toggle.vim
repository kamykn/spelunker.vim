" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#toggle#set_syntax()
	" [spelunker_spell_bad_group] ===========================================================

	if !exists('g:spelunker_spell_bad_group')
		let g:spelunker_spell_bad_group = 'SpelunkerSpellBad'
	endif

	if !exists('s:spelunker_spell_bad_style')
		let s:spelunker_spell_bad_style = 'cterm=underline ctermfg=247 gui=underline guifg=#9E9E9E'
	endif

	let l:spelunker_spell_bad_hi_list = ""
	try
		let l:spelunker_spell_bad_hi_list = execute('highlight ' . g:spelunker_spell_bad_group)
	catch
	finally
		if strlen(l:spelunker_spell_bad_hi_list) == 0 || l:spelunker_spell_bad_hi_list =~# '\v<cleared>$'
			if s:spelunker_spell_bad_style =~# '^links to\>'
				execute('highlight link ' . g:spelunker_spell_bad_group . ' ' . substitute(s:spelunker_spell_bad_style, '^links to\s*', '', ''))
			else
				execute('highlight '      . g:spelunker_spell_bad_group . ' ' .            s:spelunker_spell_bad_style)
			endif
		else
			let s:spelunker_spell_bad_style = substitute(trim(l:spelunker_spell_bad_hi_list), '^\V' . g:spelunker_spell_bad_group . '\v\s+xxx\s+', '', '')
		endif
	endtry

	" [spelunker_complex_or_compound_word_group] =======================================================

	if !exists('g:spelunker_complex_or_compound_word_group')
		let g:spelunker_complex_or_compound_word_group = 'SpelunkerComplexOrCompoundWord'
	endif

	if !exists('s:spelunker_complex_or_compound_word_style')
		let s:spelunker_complex_or_compound_word_style = 'cterm=underline ctermfg=NONE gui=underline guifg=NONE'
	endif

	let l:spelunker_complex_or_compound_word_hi_list = ""
	try
		let l:spelunker_complex_or_compound_word_hi_list = execute('highlight ' . g:spelunker_complex_or_compound_word_group)
	catch
	finally
		if strlen(l:spelunker_complex_or_compound_word_hi_list) == 0 || l:spelunker_complex_or_compound_word_hi_list =~# '\v<cleared>$'
			if s:spelunker_complex_or_compound_word_style =~# '^links to\>'
				execute('highlight link ' . g:spelunker_complex_or_compound_word_group . ' ' . substitute(s:spelunker_complex_or_compound_word_style, '^links to\s*', '', ''))
			else
				execute('highlight '      . g:spelunker_complex_or_compound_word_group . ' ' .            s:spelunker_complex_or_compound_word_style)
			endif
		else
			let s:spelunker_complex_or_compound_word_style = substitute(trim(l:spelunker_complex_or_compound_word_hi_list), '^\V' . g:spelunker_complex_or_compound_word_group . '\v\s+xxx\+', '', '')
		endif
	endtry
endfunction

function! spelunker#toggle#toggle()
	let g:enable_spelunker_vim = g:enable_spelunker_vim == 1 ? 0 : 1

	" 今開いているbufferも連動させる
	if exists('b:enable_spelunker_vim')
		if g:enable_spelunker_vim == 1
			let b:enable_spelunker_vim = 1
		else
			let b:enable_spelunker_vim = 0
		endif
	endif

	call spelunker#toggle#init_buffer(1, g:enable_spelunker_vim)

	if g:enable_spelunker_vim == 1
		echom 'Spelunker.vim is now enabled.'
	else
		echom 'Spelunker.vim has been disabled.'
	endif
endfunction

function! spelunker#toggle#toggle_buffer()
	if !exists('b:enable_spelunker_vim')
		" 初回はglobalスコープの方を反転させる
		let b:enable_spelunker_vim = g:enable_spelunker_vim == 1 ? 0 : 1
	else
		let b:enable_spelunker_vim = b:enable_spelunker_vim == 1 ? 0 : 1
	endif

	call spelunker#toggle#init_buffer(2, b:enable_spelunker_vim)

	if b:enable_spelunker_vim == 1
		echom 'Spelunker.vim is now enabled in a buffer.'
	else
		echom 'Spelunker.vim has been disabled in a buffer.'
	endif
endfunction

function! spelunker#toggle#init_buffer(mode, is_enabled)
	if a:is_enabled == 1
		call spelunker#toggle#set_syntax()

		if a:mode == 1 " for global
			call spelunker#check()
		elseif a:mode == 2 " for buffer
			call spelunker#check_displayed_words()
		endif
	elseif a:is_enabled == 0
		if a:mode == 1 " for global
			call spelunker#matches#clear_matches()
		elseif a:mode == 2 " for buffer
			call spelunker#matches#clear_current_buffer_matches()
		endif
	endif
endfunction

function! spelunker#toggle#is_enabled()
	if !exists('b:enable_spelunker_vim')
		if spelunker#toggle#is_enabled_global() == 1
			return 1
		endif

		return 0
	else
		" b:enable_spelunker_vimがあればbuffer優先
		if spelunker#toggle#is_enabled_buffer() == 1
			return 1
		else
			return 0
		endif

		if spelunker#toggle#is_enabled_global() == 0
			return 0
		endif

		return 1
	endif
endfunction

function! spelunker#toggle#is_enabled_global()
	if g:enable_spelunker_vim == 1
		return 1
	endif

	return 0
endfunction


function! spelunker#toggle#is_enabled_buffer()
	if exists('b:enable_spelunker_vim') && b:enable_spelunker_vim == 1
		return 1
	endif

	return 0
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
