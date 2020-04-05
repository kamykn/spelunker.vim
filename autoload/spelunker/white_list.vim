" Vim plugin of checking words spell on the code.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! spelunker#white_list#init_white_list()
	if !exists('g:spelunker_white_list')
		let l:wl = []

		" Programming language keywords
		" Common
		let l:wl += ['elif', 'elseif', 'elsif', 'endfor', 'endforeach', 'endif', 'endswitch', 'esac']
		let l:wl += ['endwhile', 'endfunc', 'endfunction', 'endtry', 'xor', 'trait']

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

		" Elixir
		let l:wl += ['defp', 'defimpl', 'defmacro', 'defmacrop', 'defmodule', 'defprotocol', 'defstruct']

		" C: https://ja.wikipedia.org/wiki/キーワード_(C言語)
		let l:wl += ['typedef', 'noreturn']

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
		let l:wl += ['chmod', 'chown', 'rsync', 'uniq', 'git', 'svn', 'nohup']

		" Famous OSS or products
		let l:wl += ['apache', 'nginx', 'github', 'wikipedia', 'linux', 'unix', 'dos']
		let l:wl += ['sql', 'mysql', 'postgresql', 'postgre', 'vim', 'gvim', 'emacs', 'vscode']
		let l:wl += ['csh', 'bash', 'zsh', 'ksh', 'iphone', 'redis', 'memcached', 'aws', 'gcp']
		let l:wl += ['google', 'nvim', 'neovim', 'webkit']

		" Programming language name: https://ja.wikipedia.org/wiki/%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0%E8%A8%80%E8%AA%9E%E4%B8%80%E8%A6%A7
		let l:wl += ['php', 'kotlin', 'clojure', 'ecma', 'lisp', 'erlang', 'clang', 'golang']
		let l:wl += ['fortran', 'haskell', 'jsx', 'lua', 'matlab', 'scala', 'html', 'css']
		let l:wl += ['javascript', 'less', 'sass', 'scss', 'csharp', 'dotnet', 'perl']

		" Setting files
		let l:wl += ['ini', 'toml', 'yml', 'xml', 'json']

		" Image file type
		let l:wl += ['jpeg', 'jpg', 'gif', 'png', 'svg']

		" Top level domain: https://ja.wikipedia.org/wiki/%E3%83%88%E3%83%83%E3%83%97%E3%83%AC%E3%83%99%E3%83%AB%E3%83%89%E3%83%A1%E3%82%A4%E3%83%B3
		" 最近増えたものに関しては一旦保留
		let l:wl += ['com', 'org', 'biz', 'xxx', 'gov', 'edu', 'tel', 'arpa', 'bitnet', 'csnet']

		" Environment
		let l:wl += ['env', 'dev', 'prod', 'stg', 'qa', 'rc']

		" Acronyms and abbreviations
		let l:wl += ['config', 'conf', 'goto', 'eval', 'exec', 'init', 'calc', 'iter']
		let l:wl += ['auth', 'sync', 'del', 'bin', 'wasm', 'ttl', 'sec', 'dom', 'cmd']
		let l:wl += ['tls', 'ssl', 'tmp', 'etc', 'usr', 'pos', 'ptr', 'err', 'docs']
		let l:wl += ['lang', 'ajax', 'async', 'attr', 'elem', 'ctrl', 'alt']
		let l:wl += ['asc', 'desc', 'wifi', 'url', 'ascii', 'ansi', 'unicode']
		let l:wl += ['cnt', 'api', 'href', 'src', 'cui', 'gui', 'webhook', 'iframe']
		let l:wl += ['charset', 'os', 'num', 'expr', 'msg', 'std', 'ime', 'nav', 'img']
		let l:wl += ['util', 'utils', 'param', 'params']

		" Comment
		let l:wl += ['todo', 'fixme', 'fyi']

		" Protocols
		let l:wl += ['ssh', 'http', 'https', 'tcp', 'udp', 'ftp', 'ftps', 'sftp', 'imap', 'scp']

		" print
		let l:wl += ['printf', 'println', 'sprint', 'sprintf', 'sprintln', 'fprint', 'fprintf', 'fprintln']

		" timezone
		let l:wl += ['gmt', 'utc']

		" text encoding
		let l:wl += ['utf', 'euc', 'jis']

		" Other
		let l:wl += ['referer', 'localhost', 'serializer', 'mutex', 'autoload', 'varchar', 'popup', 'header']
		let l:wl += ['neo', 'fazzy']

		" Don't you think it is terrible?
		let l:wl += ['don', 'doesn', 'didn', 'ain', 'isn', 'wasn', 'aren', 'weren']

		let g:spelunker_white_list = l:wl
	endif
endfunction

" 複成語(complex)/複合語(compound)だと思われるものを検出するため、
" よくある接頭辞、接尾辞でチェックしてみる
" 間違ったスペルとして検出したワードに対して使用する
" ex) wrong_word = strlen -> OK
"     wrong_word = string -> NG: 予め除外しておく
"
" ex ) simple word -> gentle, man
" ex ) prefix -> re, un / suffix -> able, ly
" prefix + suffix = affix -> affix + simple word = complex word (ungentle)
" simple word + simple word = compound word (gentleman)
"
" FYI:https://www.cieej.or.jp/toefl/webmagazine/interview-lifelong/1508/
"
function! spelunker#white_list#is_complex_or_compound_word(wrong_word)
	let l:wrong_word = tolower(a:wrong_word)
	let l:common_word_prefix  = ['re', 'dis', 'pre', 'co', 'un', 'no']

	" function prefix
	let l:common_word_prefix += ['str', 'fprint', 'sprint', 'print', 'get', 'set', 'calc', 'sub']
	let l:common_word_prefix += ['match', 'byte', 'is', 'has', 'to']

	for l:prefix in l:common_word_prefix
		if stridx(l:wrong_word, l:prefix) == 0
			return 1
		endif
	endfor

	let l:common_word_suffix = ['able', 'ly', 'ness', 'pos', 'list', 'map', 'cmd', 'bg', 'fg', 'id', 'log', 'num']

	for l:suffix in l:common_word_suffix
		if stridx(l:wrong_word, l:suffix) + strlen(l:suffix) == strlen(l:wrong_word)
			return 1
		endif
	endfor

	return 0
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
