let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* RequireJsImport call s:requirejs_import(<f-args>)
function! s:requirejs_import(...)
  if len(a:000) == 0
    let l:path = input('Path: ')
  else
    let l:path = a:000[0]
  endif

  if strlen(l:path) <= 0
    return
  endif

  let l:cursor = getpos('.')
  let l:buf = requirejs_import#import(join(getline('1', '$'), "\n"), l:path)
  1,$delete
  put!=l:buf
  call setpos('.', l:cursor)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

