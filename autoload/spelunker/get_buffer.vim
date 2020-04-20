scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#get_buffer#all()
	let l:window_text_list = getline(1, '$')

	let l:newline_character = s:get_newline_character()
	let l:window_text = join(l:window_text_list, l:newline_character)

	let l:window_text = spelunker#get_buffer#filter_uri(l:window_text)
	let l:window_text = spelunker#get_buffer#filter_backquoted_words(l:window_text, l:newline_character)

	return split(l:window_text, l:newline_character)
endfunction

function! spelunker#get_buffer#displayed()
	" filter済みのbufferを変数で保持する
	" 変数と実際のバッファーは行数が一致するようにする
	" filter済みのbufferで処理をしながら、foldの判定を実際のbufferで判定する
	let l:filtered_buffer = spelunker#get_buffer#all()

	let l:current_line = line('w0')
	let l:end_line = line('w$')

	let l:window_text_list = []

	while 1
		if foldclosed(l:current_line) > 0
			let l:current_line = foldclosedend(l:current_line) + 1
		endif

		if l:current_line > l:end_line
			break
		endif

		" 配列なので現在行-1のindexで取得
		let l:line = get(l:filtered_buffer, l:current_line - 1, '')
		if l:line != ''
			call add(l:window_text_list, l:line)
		endif

		let l:current_line = l:current_line + 1
	endwhile

	return  l:window_text_list
endfunction

function! s:get_newline_character()
	return  has('win32') || has('win64') ? "\r": "\n"
endfunction

function! spelunker#get_buffer#filter_uri(text)
	if g:spelunker_disable_uri_checking == 0
		return a:text
	endif

	" FYI: https://vi.stackexchange.com/questions/3990/ignore-urls-and-email-addresses-in-spell-file/24534#24534
	return substitute(a:text, '\w\+:\/\/[^[:space:]]\+', '', 'g')
endfunction

function! spelunker#get_buffer#filter_backquoted_words(text, newline_character)
	" for shell command
	" ex) `ls -la`
	if g:spelunker_disable_backquoted_checking == 0
		return a:text
	endif

	" [バッククオート内の文字列削除]
	" substituteを2回実行する
	" 関数のatomは後方参照出来ないので注意
	" 1回目: 改行を含む`以外の文字のマッチ
	" 2回目: マッチした文字列の改行以外を全部消す
	"
	" [考慮点]
	" 1: 改行を考慮
	" ex) ```
	"         `aaa
	"         bbb`
	"     ```
	" 2: 末尾のバッククオートを考慮
	" ex) ```
	"         aaaa`
	"         bbb`ccc
	"     ```
	return substitute(a:text, '`\([^`]*[' . a:newline_character . ']*\)\+`', '\=substitute(submatch(0), "[^' . a:newline_character . ']", "", "g")', 'g')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
