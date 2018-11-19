" Vim plugin of checking words spell on the code.
" Version 1.0.0
" Author kamykn
" License VIM LICENSE

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! white_list_vim#init_white_list()
	" :help function-list
	let l:wl =  ['nr', 'printf', 'shellescape', 'fnameescape', 'strtrans', 'tolower', 'toupper', 'matchend', 'matchstr', 'matchstrpos', 'matchlist', 'stridx', 'strridx', 'strlen', 'strchars', 'strwidth', 'strdisplaywidth', 'submatch', 'strpart', 'strcharpart', 'strgetchar', 'iconv', 'byteidx', 'byteidxcomp', 'len', 'deepcopy', 'ceil', 'trunc', 'fmod', 'asin', 'acos', 'atan', 'sinh', 'tanh', 'isnan', 'sha', 'islocked', 'funcref', 'getbufvar', 'setbufvar', 'getwinvar', 'gettabvar', 'gettabwinvar', 'setwinvar', 'settabvar', 'settabwinvar', 'garbagecollect', 'virtcol', 'wincol', 'winline', 'screencol', 'screenrow', 'getcurpos', 'getpos', 'setpos', 'screenattr', 'screenchar', 'getline', 'setline', 'cindent', 'lispindent', 'nextnonblank', 'prevnonblank', 'searchpos', 'searchpair', 'searchpairpos', 'searchdecl', 'getcharsearch', 'setcharsearch', 'getftime', 'localtime', 'strftime', 'reltime', 'reltimestr', 'reltimefloat', 'argc', 'argidx', 'arglistid','argv', 'bufexists', 'buflisted', 'bufloaded', 'bufname', 'bufnr', 'tabpagebuflist', 'tabpagenr', 'tabpagewinnr', 'winnr', 'bufwinid', 'bufwinnr', 'winbufnr', 'getbufline', 'findbuf', 'getid', 'gotoid', 'tabwin', 'getbufinfo', 'gettabinfo', 'getwininfo', 'getchangelist', 'getjumplist', 'getcmdline', 'getcmdpos', 'setcmdpos', 'getcmdtype', 'getcmdwintype', 'getcompletion', 'getqflist', 'setqflist', 'getloclist', 'setloclist', 'pumvisible', 'foldclosedend', 'foldlevel', 'foldtext', 'foldtextresult', 'clearmatches', 'getmatches', 'hlexists', 'hlid', 'synid', 'syni', 'dattr', 'dtrans', 'synstack', 'synconcealed', 'matchadd', 'matchaddpos', 'matcharg', 'matchdelete', 'setmatches', 'spellbadword', 'spellsuggest', 'soundfold', 'histadd', 'histdel', 'histget', 'histnr', 'browsedir', 'getchar', 'getcharmod', 'feedkeys', 'inputlist', 'inputsecret', 'inputdialog', 'inputsave', 'inputrestore', 'getfontname', 'getwinpos', 'getwinposx', 'getwinposy', 'serverlist', 'startserver', 'expr', 'winheight', 'winwidth', 'screenpos', 'winrestcmd', 'winsaveview', 'winrestview', 'hasmapto', 'mapcheck', 'maparg', 'wildmenumode', 'notequal', 'inrange', 'notmatch', 'alloc', 'autochdir', 'settime', 'canread', 'readraw', 'sendexpr', 'sendraw', 'evalexpr', 'evalraw', 'getbufnr', 'getjob', 'setoptions', 'js', 'getchannel', 'sendkeys', 'getattr', 'getcursor', 'getscrolled', 'getaltscreen', 'getsize', 'getstatus', 'gettitle', 'gettty', 'setansicolors', 'getansicolors', 'stopall', 'visualmode', 'changenr', 'cscope', 'filetype', 'eventhandler', 'getpid', 'libcall', 'libcallnr', 'undofile', 'undotree', 'getreg', 'getregtype', 'setreg', 'shiftwidth', 'wordcount', 'taglist', 'tagfiles', 'luaeval', 'mzeval', 'perleval', 'py', 'pyeval', 'pyxeval']

	" :help option-list
	let l:wl += ['allowrevins', 'ari', 'altkeymap', 'akm', 'ambiwidth', 'ambw', 'antialias', 'autochdir', 'acd', 'arabic', 'arab', 'arabicshape', 'arshape', 'autoindent', 'ai', 'autoread', 'ar', 'autowrite', 'autowriteall', 'awa', 'bg', 'bs', 'backupcopy', 'bkc', 'backupdir', 'bdir', 'backupext', 'bex', 'backupskip', 'bsk', 'balloondelay', 'bdlay', 'ballooneval', 'beval', 'balloonevalterm', 'bevalterm', 'balloonexpr', 'bexpr', 'belloff', 'bo', 'bioskey', 'biosk', 'breakat', 'brk', 'breakindent', 'bri', 'breakindentopt', 'briopt', 'browsedir', 'bsdir', 'bufhidden', 'bh', 'buflisted', 'buftype', 'bt', 'casemap', 'cmp', 'cdpath', 'cd', 'cedit', 'charconvert', 'ccv', 'cindent', 'cin', 'cinkeys', 'cink', 'cinoptions', 'cino', 'cinwords', 'cinw', 'cb', 'cmdheight', 'cmdwinheight', 'cwh', 'colorcolumn', 'commentstring', 'cms', 'cp', 'cpt', 'completefunc', 'cfu', 'completeopt', 'concealcursor', 'cocu', 'conceallevel', 'cole', 'conskey', 'consk', 'copyindent', 'ci', 'cpoptions', 'cpo', 'cryptmethod', 'cscopepathcomp', 'cspc', 'cscopeprg', 'csprg', 'cscopequickfix', 'csqf', 'cscoperelative', 'csre', 'cscopetag', 'cst', 'cscopetagorder', 'csto', 'cscopeverbose', 'csverb', 'cursorbind', 'crb', 'cursorcolumn', 'cuc', 'cursorline', 'delcombine', 'deco', 'diffexpr', 'dex', 'diffopt', 'dg', 'dir', 'dy', 'eadirection', 'ead', 'edcompatible', 'endofline', 'eol', 'equalalways', 'equalprg', 'ep', 'errorbells', 'eb', 'errorfile', 'ef', 'errorformat', 'efm', 'esckeys', 'ek', 'eventignore', 'ei', 'expandtab', 'exrc', 'fileencoding', 'fenc', 'fileencodings', 'fencs', 'fileformat', 'fileformats', 'ffs', 'fileignorecase', 'fic', 'filetype', 'fillchars', 'fcs', 'fixendofline', 'fixeol', 'fkmap', 'fk', 'foldclose', 'fcl', 'foldcolumn', 'fdc', 'foldenable', 'foldexpr', 'fde', 'foldignore', 'fdi', 'foldlevel', 'fdl', 'foldlevelstart', 'fdls', 'foldmarker', 'fmr', 'foldmethod', 'fdm', 'foldminlines', 'fml', 'foldnestmax', 'fdn', 'foldopen', 'fdo', 'foldtext', 'fdt', 'formatexpr', 'fex', 'formatlistpat', 'flp', 'formatoptions', 'fo', 'formatprg', 'fp', 'fsync', 'gdefault', 'gd', 'grepformat', 'gfm', 'grepprg', 'gp', 'guicursor', 'gcr', 'guifont', 'gfn', 'guifontset', 'gfs', 'guifontwide', 'gfw', 'guiheadroom', 'ghr', 'guioptions', 'guipty', 'gui', 'guitablabel', 'gtl', 'guitabtooltip', 'gtt', 'helpfile', 'helpheight', 'hh', 'helplang', 'hlg', 'hl', 'hkmap', 'hk', 'hkmapp', 'hkp', 'hlsearch', 'hls', 'iconstring', 'ignorecase', 'ic', 'imactivatefunc', 'imaf', 'imactivatekey', 'imak', 'imcmdline', 'imc', 'imdisable', 'imd', 'iminsert', 'imi', 'imsearch', 'ims', 'imstatusfunc', 'imsf', 'imstyle', 'imst', 'includeexpr', 'inex', 'incsearch', 'indentexpr', 'inde', 'indentkeys', 'indk', 'infercase', 'insertmode', 'im', 'isfname', 'isf', 'isident', 'isi', 'iskeyword', 'isk', 'isprint', 'isp', 'joinspaces', 'js', 'keymap', 'kmp', 'keymodel', 'keywordprg', 'kp', 'langmap', 'lmap', 'langmenu', 'lm', 'langremap', 'lrm', 'laststatus', 'lazyredraw', 'lz', 'linebreak', 'lbr', 'linespace', 'lsp', 'lispwords', 'lw', 'listchars', 'lcs', 'loadplugins', 'lpl', 'luadll', 'mzschemedll', 'mzschemegcdll', 'macatsui', 'makeef', 'mef', 'makeencoding', 'menc', 'makeprg', 'matchpairs','mps', 'matchtime', 'maxcombine', 'mco', 'maxfuncdepth', 'mfd', 'maxmapdepth', 'mmd', 'maxmem', 'maxmempattern', 'mmp', 'maxmemtot', 'mmt', 'menuitems', 'mis', 'mkspellmem', 'msm', 'modeline', 'modelines', 'mls', 'mousefocus', 'mousef', 'mousehide', 'mh', 'mousemodel', 'mousem', 'mouseshape', 'mousetime', 'mouset', 'mzquantum', 'mzq', 'nrformats', 'nf', 'numberwidth', 'nuw', 'omnifunc', 'ofu', 'opendevice', 'odev', 'operatorfunc', 'opfunc', 'osfiletype', 'packpath', 'pastetoggle', 'patchexpr', 'pex', 'patchmode', 'perldll', 'preserveindent', 'previewheight', 'pvh', 'previewwindow', 'pvw', 'printdevice', 'pdev', 'printencoding', 'penc', 'printexpr', 'pexpr', 'printfont', 'pfn', 'printheader', 'pheader', 'printmbcharset', 'pmbcs', 'printmbfont', 'pmbfn', 'printoptions', 'popt', 'pumheight', 'ph', 'pumwidth', 'pw', 'pythondll', 'pythonhome', 'pythonthreedll', 'pythonthreehome', 'pyxversion', 'quoteescape', 'qe', 'ro', 'redrawtime', 'rdt', 'regexpengine', 'relativenumber', 'rnu', 'renderoptions', 'rop', 'restorescreen', 'revins', 'ri', 'rightleft', 'rl', 'rightleftcmd', 'rlc', 'rubydll', 'ru', 'rulerformat', 'ruf', 'runtimepath', 'rtp', 'scr', 'scrollbind', 'scb', 'scrolljump', 'sj', 'scrolloff', 'scrollopt', 'sbo','sel', 'selectmode', 'slm', 'sessionoptions', 'ssop', 'shellcmdflag', 'shcf', 'shellpipe', 'sp', 'shellquote', 'shq', 'shellredir', 'srr', 'shellslash', 'shelltemp', 'stmp', 'shelltype', 'shellxescape', 'sxe', 'shellxquote', 'sxq', 'shiftround', 'sr', 'shiftwidth', 'sw', 'shortmess', 'shm', 'shortname', 'sn', 'showbreak', 'sbr', 'showcmd', 'sc', 'showfulltag', 'sft', 'showmatch', 'sm', 'showmode', 'smd', 'showtabline', 'stal', 'sidescroll', 'ss', 'sidescrolloff', 'siso', 'signcolumn', 'scl', 'smartcase', 'scs', 'smartindent', 'si', 'smarttab', 'sta', 'softtabstop', 'sts', 'spellcapcheck', 'spc', 'spellfile', 'spf', 'spelllang', 'spl', 'spellsuggest', 'sps', 'splitbelow', 'sb', 'splitright', 'spr', 'startofline', 'statusline', 'stl', 'su', 'suffixesadd', 'sua', 'swapfile', 'swf', 'swapsync', 'sws', 'switchbuf', 'swb', 'synmaxcol', 'smc', 'tabline', 'tal', 'tabpagemax', 'tpm', 'tabstop', 'tagbsearch', 'tagcase', 'tc', 'taglength', 'tl', 'tagrelative', 'tagstack', 'tgst', 'tcldll', 'termbidi', 'tbidi', 'termencoding', 'tenc', 'termguicolors','tgc', 'termwinkey', 'twk', 'termwinscroll', 'twsl', 'termwinsize', 'tws', 'textauto', 'textmode', 'tx', 'textwidth', 'tw', 'tsr', 'tildeop', 'timeoutlen', 'tm', 'titlelen', 'titleold', 'titlestring', 'tb', 'toolbariconsize', 'tbis', 'ttimeout', 'ttimeoutlen', 'ttm', 'ttybuiltin', 'tbi', 'ttyfast', 'tf', 'ttymouse', 'ttym', 'ttyscroll', 'tsl', 'ttytype', 'tty', 'undodir', 'udir', 'undofile', 'udf', 'undolevels', 'ul', 'undoreload', 'ur', 'updatecount', 'uc', 'updatetime', 'ut', 'vbs', 'verbosefile', 'vfile', 'viewdir', 'vdir', 'viewoptions', 'vop', 'viminfo', 'viminfofile', 'vif', 'virtualedit', 've', 'visualbell', 'weirdinvert', 'wiv', 'whichwrap', 'ww', 'wildchar', 'wc', 'wildcharm', 'wcm', 'wildignore', 'wildignorecase', 'wic', 'wildmenu', 'wmnu', 'wildmode', 'wim', 'wildoptions', 'winaltkeys', 'wak', 'wi', 'winheight', 'wh', 'winfixheight', 'wfh', 'winfixwidth', 'wfw', 'winminheight', 'wmh', 'winminwidth', 'wmw', 'winptydll', 'winwidth', 'wiw', 'wrapmargin', 'wm', 'wrapscan', 'ws', 'writeany', 'wa', 'writebackup', 'wb', 'writedelay', 'wd']

	" keywords
	let l:wl += ['redir', 'echom', 'setlocal', 'scriptencoding', 'cjk', 'netrw']

	" http://vimdoc.sourceforge.net/htmldoc/vimindex.html
	" 5. Command

	return l:wl
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
