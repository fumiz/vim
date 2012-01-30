" extract branch name from .svn/entries

" 1. .vim/pluginに入れる
" 2. :ShowBranch
" 3. g:svn_branch_test_extract_regexに指定した正規表現でブランチ名を取り出し表示
"
" 正規表現の適用対象は.svn/entriesの5行目と6行目から取り出した
" SVNチェックアウト対象のルートからのパス
"
" デフォルトの正規表現は/branches/ブランチ名/*を想定
"
" .vimrcに次のように埋め込むことで編集中バッファに対応したブランチ名をステータスラインに表示する
" set statusline=%n\:%y%F\\|%{(&fenc!=''?&fenc:&enc).'\|'.&ff.'\|'}%m%r%=<%l/%L:%p%%>(%{g:get_current_svn_branch_name()})
"
" 参考にしたコード:
"   http://coderepos.org/share/browser/dotfiles/vim/kana/dot.vimrc?rev=7152
"   http://www.vim.org/scripts/script.php?script_id=1234

" 二重読み込み防止
if exists('g:loaded_svn_branch_test')
  finish
endif
let g:loaded_svn_branch_test = 1

" 設定の定義(.vimrcで変更できる)
if !exists('g:svn_branch_test_extract_regex')
  let g:svn_branch_test_extract_regex = '\/branches\/\([^\/]\+\)'
endif

" コマンドの定義
command! ShowBranch call s:show_branch()

" コマンドの本体
function! s:show_branch()
  echo g:get_current_svn_branch_name()
endfunction

" カレントディレクトリのSVNブランチ名を取得
function! g:get_current_svn_branch_name()
  return s:svn_branch_name(expand('%:p:h'))
endfunction

" 指定したディレクトリのSVNブランチ名を返す(キャッシュ対応)
let s:_svn_branch_name_cache = {}
function! s:svn_branch_name(dir)
  let cache_entry = get(s:_svn_branch_name_cache, a:dir, 0)

  if cache_entry is 0
    unlet cache_entry
    let cache_entry = s:_svn_branch_name(a:dir)
    let s:_svn_branch_name_cache[a:dir] = cache_entry
  endif

  return cache_entry
endfunction

" 指定したディレクトリのSVNブランチ名を返す
function! s:_svn_branch_name(dir)
  let head_file = s:_svn_branch_name_key_file_path(a:dir)
  return s:_svn_branch_name_extract(head_file)
endfunction

" 指定したディレクトリの.svn/entriesファイルパスを返す
function! s:_svn_branch_name_key_file_path(dir)
  return a:dir . '/.svn/entries'
endfunction

" .svn/entriesからブランチ名を抽出
function! s:_svn_branch_name_extract(entries_path)
  if !filereadable(a:entries_path)
    return ''
  endif

  let branch_line = s:_svn_branch_name_read(a:entries_path)
  let branch_name = matchlist(branch_line, g:svn_branch_test_extract_regex)[1]
  return branch_name
endfunction

" .svn/entriesからSVNのルート以下のパスを取得
function! s:_svn_branch_name_read(entries_path)
  let lines = readfile(a:entries_path, '', 6)
  if len(lines) != 6
    return ''
  endif

  " SVNのルートを取り出す。次のような文字列が格納されていることを想定している
  " branch_line->svn://svnroot/branches/mybranch/pa/th/to/module
  " root_path ->svn://svnroot
  let branch_line = lines[4]
  let root_path = lines[5]

  return branch_line[len(root_path):len(branch_line)-1]
endfunction
 
