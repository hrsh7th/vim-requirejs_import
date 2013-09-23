try
set noexpandtab
set expandtab
set softtabstop=2
set tabstop=4

let s:path = 'path/to/library/Library'

let s:buf_first_define = join([
      \ 'define([], function () {',
      \ '})'
      \ ], "\n")

let s:buf_append_define = join([
      \ 'define(["path/to/library/Module"], function (Module) {',
      \ '})'
      \ ], "\n")

let s:buf_first_define_multiline = join([
      \ 'define([',
      \ '], function (',
      \ ') {',
      \ '})'
      \ ], "\n")

let s:buf_append_define_multiline = join([
      \ 'define([',
      \ '  "path/to/library/Module"',
      \ '], function (',
      \ '  Module',
      \ ') {',
      \ '})'
      \ ], "\n")

" 最初の定義を判定できる
if requirejs_import#is_first_def(s:buf_first_define)
  echo 'ok'
else
  throw 'can not detected first define.'
endif
if requirejs_import#is_first_def(s:buf_first_define_multiline)
  echo 'ok'
else
  throw 'can not detected first define.'
endif
if !requirejs_import#is_first_def(s:buf_append_define)
  echo 'ok'
else
  throw 'can not detected first define.'
endif
if !requirejs_import#is_first_def(s:buf_append_define_multiline)
  echo 'ok'
else
  throw 'can not detected first define.'
endif

" 最初の引数を判定できる
if requirejs_import#is_first_arg(s:buf_first_define)
  echo 'ok'
else
  throw 'can not detected first arg.'
endif
if requirejs_import#is_first_arg(s:buf_first_define_multiline)
  echo 'ok'
else
  throw 'can not detected first arg.'
endif
if !requirejs_import#is_first_arg(s:buf_append_define)
  echo 'ok'
else
  throw 'can not detected first arg.'
endif
if !requirejs_import#is_first_arg(s:buf_append_define_multiline)
  echo 'ok'
else
  throw 'can not detected first arg.'
endif

" 引数部分をすべて削除できる
if stridx(requirejs_import#clean_def(s:buf_append_define_multiline), 'define([]') >= 0
  echo 'ok'
else
  throw 'can not clean def.'
endif
if stridx(requirejs_import#clean_arg(s:buf_append_define_multiline), 'function ()') >= 0
  echo 'ok'
else
  throw 'can not clean arg.'
endif

" 最初の定義を追加できる
if stridx(requirejs_import#append_def(s:buf_first_define, '"test"'), 'define(["test"]') >= 0
  echo 'ok'
else
  throw 'can not append def.'
endif
if stridx(requirejs_import#append_def(s:buf_first_define_multiline, '"test"'), 'define(["test"]') >= 0
  echo 'ok'
else
  throw 'can not append def.'
endif
if stridx(requirejs_import#append_arg(s:buf_first_define, 'test'), 'function (test)') >= 0
  echo 'ok'
else
  throw 'can not append def.'
endif
if stridx(requirejs_import#append_arg(s:buf_first_define_multiline, 'test'), 'function (test)') >= 0
  echo 'ok'
else
  throw 'can not append def.'
endif

" 複数行の定義かどうか判定できる
if requirejs_import#is_def_multiline(s:buf_append_define_multiline)
  echo 'ok'
else
  throw 'can not detect def multiline.'
endif
if !requirejs_import#is_def_multiline(s:buf_append_define)
  echo 'ok'
else
  throw 'can not detect def multiline.'
endif
if requirejs_import#is_arg_multiline(s:buf_append_define_multiline)
  echo 'ok'
else
  throw 'can not detect arg multiline.'
endif
if !requirejs_import#is_arg_multiline(s:buf_append_define)
  echo 'ok'
else
  throw 'can not detect arg multiline.'
endif

" 複数定義に追加できる
let s:appended_buf_append_define = join([
      \ 'define(["path/to/library/Module", "test"], function (Module) {',
      \ '})'
      \ ], "\n")
if stridx(requirejs_import#append_def(s:buf_append_define, '"test"'), s:appended_buf_append_define) >= 0
  echo 'ok'
else
  throw 'can not append not first def.'
endif
let s:appended_buf_append_define = join([
      \ 'define(["path/to/library/Module"], function (Module, Test) {',
      \ '})'
      \ ], "\n")
if stridx(requirejs_import#append_arg(s:buf_append_define, 'Test'), s:appended_buf_append_define) >= 0
  echo 'ok'
else
  throw 'can not append not first arg.'
endif

" 複数行定義に追加ができる
let s:appended_buf_append_define_multiline = join([
      \ 'define([',
      \ '  "path/to/library/Module",',
	  \ '  "test"',
      \ '], function (',
      \ '  Module',
      \ ') {',
      \ '})'
      \ ], "\n")
if stridx(requirejs_import#append_def(s:buf_append_define_multiline, '"test"'), s:appended_buf_append_define_multiline) >= 0
  echo 'ok'
else
  throw 'can not append multiline not first def.'
endif
let s:appended_buf_append_define_multiline = join([
      \ 'define([',
      \ '  "path/to/library/Module"',
      \ '], function (',
      \ '  Module,',
	  \ '  Test',
      \ ') {',
      \ '})'
      \ ], "\n")
if stridx(requirejs_import#append_arg(s:buf_append_define_multiline, 'Test'), s:appended_buf_append_define_multiline) >= 0
  echo 'ok'
else
  throw 'can not append multiline not first arg.'
endif

" 変数名のパースができる
if requirejs_import#path2name(s:path) == 'Library'
  echo 'ok'
else
  throw 'can not create name.'
endif

" インデントが取得できる
set noexpandtab
set tabstop=4
if requirejs_import#get_indent() == "\t"
  echo 'ok'
else
  throw 'can not get indent1.'
endif

set expandtab
set softtabstop=4
if requirejs_import#get_indent() == "    "
  echo 'ok'
else
  throw 'can not get indent2.'
endif

set expandtab
set softtabstop=2
if requirejs_import#get_indent() == "  "
  echo 'ok'
else
  throw 'can not get indent3.'
endif

catch
  echo v:exception
endtry
let g:requirejs_import#debug = 0
