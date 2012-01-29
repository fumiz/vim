" 二重読み込み防止
if exists('g:loaded_hello')
  finish
endif
let g:loaded_hello = 1

" .vimrcで変更できる設定の定義
" この場合g:hello_stringという変数が.vimrcで定義れていない場合に
" デフォルト値として'VimScript'を使うことになっている
if !exists('g:hello_string')
  let g:hello_string = 'VimScript'
endif

" コマンドの定義(ユーザ定義のコマンドは大文字で始まる必要があるらしい)
command! ShowHello call s:show_hello()

" コマンドの本体
function! s:show_hello()
  echo "hello " . g:hello_string . "!"
endfunction

