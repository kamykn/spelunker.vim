scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#get_buffer#all()
	let l:window_text_list = getline(1, '$')
	let l:window_text = join(l:window_text_list, "\n")

	let l:window_text = s:filter_uri(l:window_text)
	let l:window_text = s:filter_back_quoted_string(l:window_text)

	echo l:window_text
endfunction

function! s:filter_uri(text)
	if g:spelunker_disable_url = 1
		return
	endif

	" FYI: https://vi.stackexchange.com/questions/3990/ignore-urls-and-email-addresses-in-spell-file/24534#24534
	return substitute(a:text, '\w\+:\/\/[^[:space:]]\+', '', 'g')
endfunction

function! s:filter_back_quoted_string(text)
	" for shell command
	" ex) `ls -la`
	if g:spelunker_disable_back_quoted_string = 1
		return
	endif

	return substitute(a:text, '`\_.\+`', '', 'g')
endfunction
