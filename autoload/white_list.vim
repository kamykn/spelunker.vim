" Vim plugin of checking words spell on the code.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! white_list#init_white_list()
	if !exists('g:spellunker_white_list')
		let l:wl = []

		" Programming language keywords
		" Common
		let l:wl += ['elseif', 'elsif', 'elif', 'endif', 'endfor', 'endforeach', 'endswitch']
		let l:wl += ['endwhile', 'endfunction', 'endtry', 'xor', 'trait']

		" JS: https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Reserved_Words
		let l:wl += ['let', 'const', 'var', 'typeof', 'instanceof']

		" PHP: http://php.net/manual/ja/reserved.keywords.php
		let l:wl += ['foreach', 'enddeclare', 'insteadof', 'isset']

		" Go: http://golang.jp/go_spec#Keywords
		let l:wl += ['func', 'chan', 'fallthrough', 'iota', 'imag', 'println']

		" Rust: https://qnighy.hatenablog.com/entry/2017/05/28/070000
		let l:wl += ['struct', 'impl', 'pub', 'mut', 'ref', 'fn', 'extern', 'mod', 'priv', 'proc', 'sizeof']

		" Ruby: http://secret-garden.hatenablog.com/entry/2015/06/30/000000
		let l:wl += ['nil', 'def', 'undef']

		" Clang: https://ja.wikipedia.org/wiki/キーワード_(C言語)
		let l:wl += ['typedef', 'noreturn']

		" Vim
		let l:wl += ['cword']

		" C++: https://ja.wikipedia.org/wiki/%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89_(C%2B%2B)
		let l:wl += ['nullptr', 'wchar', 'constexpr', 'alignof', 'decltype', 'typeid']
		let l:wl += ['noexcept', 'typename', 'alignas', 'asm', 'bitand', 'bitor', 'compl']

		" C#: https://docs.microsoft.com/ja-jp/dotnet/csharp/language-reference/keywords/
		let l:wl += ['readonly', 'sbyte', 'stackalloc', 'ascending']

		" Python: https://www.lifewithpython.com/2013/03/python-reserved-words.html
		" Java: https://ja.wikipedia.org/wiki/%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89_(Java)

		" Types
		" Common
		let l:wl += ['str', 'char', 'int', 'bool', 'dict', 'enum', 'void', 'uint', 'ulong', 'ushort']
		" Rust: https://qnighy.hatenablog.com/entry/2017/05/28/070000
		let l:wl += ['isize', 'usize', 'vec']
		" Go: http://golang.jp/go_spec#Constants
		let l:wl += ['uintptr']

		" Commands
		let l:wl += ['sudo', 'grep', 'awk', 'curl', 'wget', 'mkdir', 'rmdir', 'pwd']
		let l:wl += ['chmod', 'chown', 'rsync', 'uniq', 'git', 'svn']

		" Famous OSS or products
		let l:wl += ['apache', 'nginx', 'github', 'wikipedia', 'linux', 'unix', 'dos']
		let l:wl += ['mysql', 'postgresql', 'postgre', 'vim', 'gvim', 'emacs', 'vscode']
		let l:wl += ['csh', 'bash', 'zsh', 'ksh', 'iphone', 'redis', 'memcached', 'aws', 'gcp']
		let l:wl += ['google', 'nvim', 'neovim']

		" Programming language name: https://ja.wikipedia.org/wiki/%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0%E8%A8%80%E8%AA%9E%E4%B8%80%E8%A6%A7
		let l:wl += ['php', 'kotlin', 'clojure', 'ecma', 'lisp', 'erlang', 'clang', 'golang']
		let l:wl += ['fortran', 'haskell', 'jsx', 'lua', 'matlab', 'scala', 'html', 'css']
		let l:wl += ['less', 'sass', 'scss', 'csharp', 'dotnet']

		" Top level domain: https://ja.wikipedia.org/wiki/%E3%83%88%E3%83%83%E3%83%97%E3%83%AC%E3%83%99%E3%83%AB%E3%83%89%E3%83%A1%E3%82%A4%E3%83%B3
		let l:wl += ['com', 'org', 'biz', 'xxx', 'gov', 'edu', 'tel', 'arpa', 'bitnet', 'csnet']

		" Environment
		let l:wl += ['env', 'dev', 'prod', 'stg', 'qa', 'rc']

		" Acronyms and abbreviations
		let l:wl += ['config', 'conf', 'goto', 'eval', 'exec', 'init', 'calc', 'iter']
		let l:wl += ['auth', 'sync', 'del', 'bin', 'wasm', 'ttl', 'sec', 'dom', 'cmd']
		let l:wl += ['tls', 'ssl', 'tmp', 'etc', 'usr', 'pos', 'ptr', 'err', 'docs']
		let l:wl += ['lang', 'param', 'ajax', 'async', 'attr', 'elem', 'ctrl', 'alt']
		let l:wl += ['asc', 'desc', 'wifi', 'url', 'ascii', 'utf', 'ansi', 'unicode']
		let l:wl += ['cnt', 'api', 'href', 'src']

		" Comment
		let l:wl += ['todo', 'fixme', 'fyi']

		" Protocols
		let l:wl += ['ssh', 'http', 'https', 'tcp', 'udp', 'ftp', 'ftps', 'sftp', 'imap', 'scp']

		" Other
		let l:wl += ['referer', 'localhost', 'serializer', 'mutex', 'autoload', 'varchar', 'popup', 'header']

		" Don't you think it is terrible?
		let l:wl += ['don', 'doesn', 'didn', 'ain', 'isn', 'wasn', 'aren', 'weren']

		let g:spellunker_white_list = l:wl
	endif
endfunction

" 複合語だと思われるものを検出するため、
" よくある接頭辞、接尾辞でチェックしてみる
" 間違ったスペルとして検出したワードに対して使用する
" ex) wrong_word = strlen -> OK
"     wrong_word = string -> NG: 予め除外しておく
function! white_list#is_compound_word(wrong_word)
	let l:common_word_prefix  = ['re', 'dis', 'pre', 'co', 'un']
	let l:common_word_prefix += ['str', 'sprint', 'print', 'get', 'set', 'calc', 'sub']
	let l:common_word_prefix += ['match', 'byte', 'is', 'has', 'to']

	for prefix in l:common_word_prefix
		if stridx(a:wrong_word, prefix) == 0
			return 1
		endif
	endfor

	let l:common_word_suffix = ['able', 'pos', 'list', 'map', 'cmd', 'bg', 'fg', 'id', 'log', 'num']

	for suffix in l:common_word_suffix
		if stridx(a:wrong_word, suffix) + strlen(suffix) == strlen(a:wrong_word)
			return 1
		endif
	endfor

	return 0
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
