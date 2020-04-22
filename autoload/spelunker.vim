" Plugin that improved vim spelling.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#check_displayed_words()
	if s:is_runnable() == 0
		call s:clear_matches()
		return 0
	endif

	if g:spelunker_check_type != g:spelunker_check_type_cursor_hold
		return 0
	endif

	call spelunker#words#check_display_area()
	return 1
endfunction

function! spelunker#check()
	if s:is_runnable() == 0
		call s:clear_matches()
		return 0
	endif

	if g:spelunker_check_type != g:spelunker_check_type_buf_lead_write
		return 0
	endif

	call spelunker#words#check()
	return 1
endfunction

function! spelunker#check_and_echo_list()
	if s:is_runnable() == 0
		return 0
	endif

	call spelunker#cases#reset_case_counter()
	" ホワイトリスト作るとき用のオプション
	let l:orig_spelunker_target_min_char_len = g:spelunker_target_min_char_len
	let g:spelunker_target_min_char_len = 1

	let l:window_text_list = spelunker#get_buffer#all()
	let l:spell_bad_list = spelunker#spellbad#get_spell_bad_list(l:window_text_list)

	" ホワイトリスト作るとき用のオプション
	let g:spelunker_target_min_char_len = l:orig_spelunker_target_min_char_len
	call spelunker#words#echo_for_white_list(l:spell_bad_list)
	return 1
endfunction

function! spelunker#execute_with_target_word(command)
	if s:is_runnable() == 0
		return 0
	endif

	let l:target_word = spelunker#words#search_target_word()
	if l:target_word == ''
		echo "There is no word under the cursor."
		return 0
	endif

	execute a:command . ' ' . tolower(l:target_word)
	return 1
endfunction

function! spelunker#add_all_spellgood()
	if s:is_runnable() == 0
		return 0
	endif

	let l:window_text_list = spelunker#get_buffer#all()
	let l:spell_bad_list = spelunker#spellbad#get_spell_bad_list(l:window_text_list)

	if len(l:spell_bad_list) == 0
		return 0
	endif

	for word in l:spell_bad_list
		execute 'silent! spellgood ' . tolower(word)
	endfor

	echon len(l:spell_bad_list) . ' word(s) added to the spellfile.'
	return 1
endfunction

function! spelunker#correct()
	if s:is_runnable() == 0
		return 0
	endif

	call spelunker#correct#correct(0)
	return 1
endfunction

function! spelunker#correct_all()
	if s:is_runnable() == 0
		return 0
	endif

	call spelunker#correct#correct(1)
	return 1
endfunction

function! spelunker#correct_from_list()
	if s:is_runnable() == 0
		return 0
	endif

	let l:is_correct_all = 0
	let l:is_feeling_lucky = 0
	call spelunker#correct#correct_from_list(l:is_correct_all, l:is_feeling_lucky)
	return 1
endfunction

function! spelunker#correct_all_from_list()
	if s:is_runnable() == 0
		return 0
	endif

	let l:is_correct_all = 1
	let l:is_feeling_lucky = 0
	call spelunker#correct#correct_from_list(l:is_correct_all, l:is_feeling_lucky)
	return 1
endfunction

function! spelunker#correct_feeling_lucky()
	if s:is_runnable() == 0
		return 0
	endif

	let l:is_correct_all = 0
	let l:is_feeling_lucky = 1
	call spelunker#correct#correct_from_list(l:is_correct_all, l:is_feeling_lucky)
	return 1
endfunction

function! spelunker#correct_all_feeling_lucky()
	if s:is_runnable() == 0
		return 0
	endif

	let l:is_correct_all = 1
	let l:is_feeling_lucky = 1
	call spelunker#correct#correct_from_list(l:is_correct_all, l:is_feeling_lucky)
	return 1
endfunction

" spell設定を戻す
function! spelunker#reduce_spell_setting(spell_setting)
	if a:spell_setting != "spell"
		setlocal nospell
	endif
endfunction

" 処理前のspell設定を取得
function! spelunker#get_current_spell_setting()
	redir => spell_setting_capture
		silent execute "setlocal spell?"
	redir END

	" ex) '      spell' -> 'spell'
	return substitute(l:spell_setting_capture, '\v(\n|\s)\C', '', 'g')
endfunction

" spelunkerでmatchしたposに移動
function! spelunker#jump_next()
	if s:is_runnable() == 0
		return 0
	endif

	call spelunker#jump#jump_matched(1)
	return 1
endfunction

function! spelunker#jump_prev()
	if s:is_runnable() == 0
		return 0
	endif

	call spelunker#jump#jump_matched(0)
	return 1
endfunction

" spelunkerの機能のon/off
function! spelunker#toggle()
	call spelunker#toggle#toggle()
	return 1
endfunction

" bufferごとのspelunkerの機能のon/off
function! spelunker#toggle_buffer()
	call spelunker#toggle#toggle_buffer()
	return 1
endfunction

function s:clear_matches()
	if spelunker#toggle#is_enabled_buffer() == 0
		call spelunker#matches#clear_current_buffer_matches()
	endif

	if spelunker#toggle#is_enabled_global() == 0
		call spelunker#matches#clear_matches()
	endif
endfunction

" 実行可能な条件のチェック
function s:is_runnable()
	if spelunker#toggle#is_enabled() == 0
		return 0
	endif

	if g:enable_spelunker_vim_on_readonly == 0 && &readonly
		return 0
	endif

	return 1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
