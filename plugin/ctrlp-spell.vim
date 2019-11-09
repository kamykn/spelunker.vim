let s:save_cpo = &cpo
set cpo&vim

" global variable option

command! CtrlPSpell :call ctrlp#init(ctrlp#spelunker#id())

let &cpo = s:save_cpo
unlet s:save_cpo
