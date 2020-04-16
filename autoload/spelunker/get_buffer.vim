scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#get_buffer#all()
	let l:window_text_list = getline(1, '$')
	return s:filter(l:window_text_list)
endfunction

function! spelunker#get_buffer#displayed()
	let l:current_line = line("w0")
	let l:end_line = line("w$")

	let l:window_text_list = []

	while 1
		if foldclosed(l:current_line) > 0
			let l:current_line = foldclosedend(l:current_line) + 1
		endif

		if l:current_line > l:end_line
			break
		endif

		call add(l:window_text_list, getline(l:current_line))

		let l:current_line = l:current_line + 1
	endwhile

	return  s:filter(l:window_text_list)
endfunction

function! s:filter(window_text_list)
	let l:window_text = join(a:window_text_list, "\n")

	let l:window_text = s:filter_uri(l:window_text)
	let l:window_text = s:filter_back_quoted_string(l:window_text)

	return split(l:window_text, "\n")
endfunction

function! s:filter_uri(text)
	if g:spelunker_disable_url == 1
		return
	endif

	" FYI: https://vi.stackexchange.com/questions/3990/ignore-urls-and-email-addresses-in-spell-file/24534#24534
	return substitute(a:text, '\w\+:\/\/[^[:space:]]\+', '', 'g')
endfunction

function! s:filter_back_quoted_string(text)
	" for shell command
	" ex) `ls -la`
	if g:spelunker_disable_back_quoted_string == 1
		return
	endif

	return substitute(a:text, '`\_.\+`', '', 'g')
endfunction
