
########################################
# 補完

# 補完を有効にする
autoload -Uz compinit && compinit

# 先方予測機能
#autoload -Uz predict-on && predict-on

# 自動補完される余分なカンマなどを適宜削除してスムーズに入力できるようにする
setopt auto_param_keys

# コマンドライン引数で --prefix=/usr などの=以降でも補完する
setopt magic_equal_subst

# ファイルの種別を識別マーク表示
setopt list_types

# 補完候補をできるだけ詰めて表示する
setopt list_packed

# TAB補完時にメニューっぽくする
setopt auto_menu

# カーソル位置で補完する
setopt complete_in_word

# globを展開しないで候補の一覧から補完する
setopt glob_complete

# 補完時にヒストリを展開
setopt hist_expand

# エイリアス？
setopt complete_aliases

# 隠しファイルも補完する
setopt globdots

# ディレクトリにマッチした場合末尾に'/'をつける
setopt mark_dirs

# ビープ音を鳴らさない
setopt no_beep

# 数値順にソート(辞書順ではなく)
setopt numeric_glob_sort

# 補完で小文字を大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 補完メニューを選択できるようにする
zstyle ':completion:*:default' menu select=2

# 補完候補をグループ化
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*' group-name ''

# 補完候補に色をつける
zstyle ':completion:*:default' list-colors ""

# 補完候補の指定
# _oldlist: 前回の補完結果を再利用する。
# _complete: 補完する。(?)
# _match: globを展開しないで候補の一覧から補完する。
# _history: ヒストリのコマンドも補完候補とする。
# _ignored: 補完候補に出さないと指定したものも補完候補とする。
# _approximate: 似ている補完候補も補完候補とする。
# _prefix: カーソル以降を無視してカーソル位置までで補完する。
zstyle ':completion:*' completer _oldlist _complete _match _approximate _prefix

# 補完キャッシュを使う
zstyle ':completion:*' use-cache yes

# 詳細な情報を使う
zstyle ':completion:*' verbose yes

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo の後のコマンド名補完
zstyle ':completion:*:sudo:*' command-path /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /opt/bin

# ps の後のプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

# 補完してほしくないファイルは補完しない
zstyle ':completion:*:*:nvim:*:*files' ignored-patterns '*?.out' '*?.o' '*?.hi' '*?~' '*\#'
zstyle ':completion:*' ignored-patterns '.git'

########################################
# 設定

# コマンドのスペルを修正する
# setopt correct correct_all

# '#'以降をコメントとみなす
setopt interactive_comments

# Ctrl-dでログアウトしない
setopt ignore_eof

# Ctrl+Sで停止を無効
# stty stop undef

# Ctrl+Qで再開を無効
# stty start undef

# Ctrl+Sとかを使わない設定(?)
setopt no_flow_control

# 終了コードが0以外の時それを表示
# PROMPTで代用しました
#setopt print_exit_value

# ディレクトリ末尾の/を消す
setopt auto_remove_slash

########################################
# 表示

# 色を付ける
autoload -Uz colors && colors

# 文字化け対策
setopt print_eight_bit

########################################
# jobs

# バックグラウンドジョブの状態変化を即時報告する
setopt notify

# ログアウト時にバックグラウンドジョブをkillしない
setopt no_hup

# jobsでプロセスIDも出力する
setopt long_list_jobs

# 3秒以上かかった処理は詳細表示
REPORTTIME=2

########################################
# vcs_info

#autoload -Uz vcs_info
#zstyle ':vcs_info:*' max-exports 4
#zstyle ':vcs_info:*' formats '%s' '%b'
#zstyle ':vcs_info:*' actionformats '%s' '%b' '' '|%a'
#
#zstyle ':vcs_info:git:*' check-for-changes true # %cと%uを有効にする(でかいリポジトリだと重いらしい)
#zstyle ':vcs_info:git:*' formats '%s' '%b' '%u%c'
#zstyle ':vcs_info:git:*' actionformats '%s' '%b' '%u%c' '|%a'

#function decorate-branch_old ()
#{
#  LANG=en_US.UTF-8 vcs_info
#  [[ -n ${vcs_info_msg_0_} ]] &&
#  {
#    if [[ -n ${vcs_info_msg_3_} ]]
#    then
#      echo -e -n %{${fg_bold[red]}%}
#    elif [[ -n ${vcs_info_msg_2_} ]]
#    then
#      echo -e -n %{${fg_bold[yellow]}%}
#    else
#      echo -e -n %{${fg_bold[cyan]}%}
#    fi
#    echo -n "(${vcs_info_msg_0_})-[${vcs_info_msg_1_}${vcs_info_msg_3_}]${vcs_info_msg_2_}"
#    echo -e -n %{${reset_color}%}
#  }
#}

# デコ
function decorate-branch_impl ()
{
  typeset -A git_info
  local line

  git_info[untracked]=0
  git_info[staged]=0
  git_info[modified]=0

  if read line
  then
    git_info[branch]=${${line}#* }
    while IFS= read line
    do
      case "${line[1,2]}" in
        \?\?)
          ((++git_info[untracked]))
          ;;
        ?\ )
          ((++git_info[staged]))
          ;;
        \ ?)
          ((++git_info[modified]))
          ;;
        *)
          ((++git_info[staged]))
          ((++git_info[modified]))
          ;;
      esac
    done
    if [[ ${git_info[untracked]} -ne 0 ]]
    then
      printf "%s" "%{${fg_bold[red]}%}"
    elif [[ ${git_info[staged]} -ne 0 || ${git_info[modified]} -ne 0 ]]
    then
      printf "%s" "%{${fg_bold[yellow]}%}"
    else
      printf "%s" "%{${fg_bold[cyan]}%}"
    fi
    printf "(%s)" ${git_info[branch]}
    [[ ${git_info[staged]} -ne 0 ]] && printf "%s %d staged" "%{${fg_bold[green]}%}" ${git_info[staged]}
    [[ ${git_info[modified]} -ne 0 ]] && printf "%s %d modified" "%{${fg_bold[yellow]}%}" ${git_info[modified]}
    [[ ${git_info[untracked]} -ne 0 ]] && printf "%s %d untracked" "%{${fg_bold[red]}%}" ${git_info[untracked]}
  fi
}

function decorate-branch ()
{
  git status --porcelain --branch 2> /dev/null | decorate-branch_impl
}

function decorate-prompt ()
{
  readonly local exit_code=$?
  printf "%s\n" "%{${reset_color}%}"
  [[ ${exit_code} -eq 0 ]] || printf "%s" "%{${fg_bold[red]}%}${exit_code} "
  case "${USER}" in
    root)
      printf "%s" "%{${fg_bold[red]}%}"
      ;;
    *)
      printf "%s" "%{${fg_bold[green]}%}"
      ;;
  esac
  printf "%s\n" "${USER}%{${fg_bold[green]}%}@${HOST} %{${fg_bold[blue]}%}${PWD} $(decorate-branch)"
  printf "%s" "%{${reset_color}%}%(!.#.$) "
}

########################################
# 実行直前に色をリセットする

function preexec ()
{
  printf "%s" ${reset_color}
  #echo -n -e "\e[m"
}

########################################
# プロンプト

# プロンプト文字列に変数の展開が使えるようになる？
setopt prompt_subst

# コピペしやすいようにコマンド実行後は右プロンプトを消す。
setopt transient_rprompt

# プロンプト表示前に実行される？
function precmd ()
{
  PROMPT="$(decorate-prompt)"
  #RPROMPT="$(decorate-branch_old)"
}

########################################
# run-help

alias run-help > /dev/null 2>&1 && unalias run-help
autoload -Uz run-help run-help-git run-help-openssl run-help-sudo

########################################
# EDITOR

type nvim > /dev/null 2>&1 && export EDITOR=nvim
# export VTE_CJK_WIDTH=1
#export XDG_CONFIG_HOME=${HOME}/.config

alias vim='printf "vimがいいのですか？でもnvimを起動しますね。" && read -k1 && nvim'

########################################
# PATH

export PATH="${PATH}:${HOME}/bin"
#export LD_LIBRARY_PATH="${HOME}/lib"

########################################
# aliasたち

alias ls='\ls --color=auto -F'
alias la='\ls --color=auto -F -A'
alias ll='\ls --color=auto -F -l -A'
alias grep='\grep --color=auto'

type xsel > /dev/null 2>&1 && alias pbcopy='xsel --clipboard --input' && alias pbpaste='xsel --clipboard --output'
type xdg-open > /dev/null 2>&1 && alias open=xdg-open

alias rm='\rm -i'
alias cp='\cp -i'
alias mv='\mv -i'

alias type='type -as'

# alias fcrontab='fcrontab -i'

alias history='\history 0'
alias historygrep='\history 0 | grep'

alias addp='git add -p'
alias gommit='git commit -v'
alias commit='git commit -v'
alias checkout='git checkout'
alias push='git push'
alias fetch='git fetch && git status'

alias nvimrc='${EDITOR} ${HOME}/.config/nvim/init.vim'
alias zshrc='${EDITOR} ${HOME}/.zshrc'
alias relogin='exec zsh -l'

# typo
#alias exho=echo

# alias -g GREP='| grep'
# alias -g SED='| sed'
# alias -g COPY='| pbcopy'

########################################
# compile

alias my-cc='clang -std=c11 -Wall -Wextra -pedantic-errors -O2'

function my-cxx ()
{
  clang++ -std=c++1z -Weverything -Wno-c++98-compat -Wno-c++98-compat-pedantic -pedantic-errors -O2 -stdlib=libc++ -I../include -Iinclude "$@" -lc++abi
}

function my-runc ()
{
  my-cc -o /tmp/a.out "$1" && shift && /tmp/a.out "$@"
}

function my-runcxx ()
{
  my-cxx -o /tmp/a.out "$1" && shift && /tmp/a.out "$@"
}

# sandbox用(?)
function my-ghc ()
{
  if [[ -e .cabal-sandbox ]]
  then
    ghc -package-db .cabal-sandbox/*.conf.d "$@"
  else
    ghc "$@"
  fi
}

########################################
# utility

# ぐぐる
function google ()
{
  [[ -z $* ]] && set -- `head -1` && open "https://www.google.com/#q=$*"
}

# ほぐる
function hoogle ()
{
  [[ -z $* ]] && set -- `head -1` && open "https://www.haskell.org/hoogle/?hoogle=$*"
}

# /tmp/trash に移動
function trash ()
{
  mkdir -p /tmp/trash && mv -fv "$@" /tmp/trash
}

# ♪
function music-play ()
{
  mplayer "$@" > /dev/null 2>&1 < /dev/null || echo Error: cannot play >&2
}
alias -s {mp3,flac,m4a}=music-play
alias -s py=python3
alias -s hs=runhaskell
alias -s c=my-runc
alias -s {cpp,cxx,cc}=my-runcxx
alias -s html=open

# 拡張子から圧縮形式を判別して解凍
function my-extract ()
{
  local i
  for i in "$@"
  do
    case ${i} in
      *.tgz | *.tar.gz ) tar -zxvf ${i} ;;
      *.tbz2 | *.tar.bz2 ) tar -jxvf ${i} ;;
      *.tar.xz ) tar -Jxvf ${i} ;;
      *.tar ) tar -xvf ${i} ;;
      *.gz ) gzip -dc ${i} ;;
      *.bz2 ) bzip2 -dc ${i} ;;
      *.xz ) xz -d ${i} ;;
      *.zip ) unzip ${i} ;;
      *.rar ) unrar x ${i} ;;
      * ) echo Error: unknown suffix. >&2 ;;
    esac
  done
}
alias -s {tgz,tbz2,tar,gz,bz2,xz,zip,rar}=my-extract

# 拡張子に合った圧縮形式で圧縮
function my-compress ()
{
  case $1 in
    *.tgz | *.tar.gz ) tar -zcvf "$@" ;;
    *.tbz2 | *.tar.bz2 ) tar -jcvf "$@" ;;
    *.tar.xz ) tar -Jcvf "$@" ;;
    *.tar ) tar -cvf "$@" ;;
    *.zip ) zip -r "$@" ;;
    *.rar ) rar a "$@" ;;
    * ) echo Error: unknown suffix. >&2 ;;
  esac
}

########################################
# キーバインド

# Emacs風キーバインド
bindkey -e

# Ctrl+arrow key
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# HOME,ENDで移動する
#bindkey "^[OH" beginning-of-line
bindkey "^[[7$" beginning-of-line
bindkey "^[[7~" beginning-of-line
#bindkey "^[OF" end-of-line
bindkey "^[[8$" end-of-line
bindkey "^[[8~" end-of-line

# Deleteキーで消す
bindkey "^[[3~" delete-char
bindkey "^[[3;2~" delete-char

# Shift+Tabで逆順補完
bindkey "^[[Z" reverse-menu-complete

########################################
# History

export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt EXTENDED_HISTORY

# ヒストリーファイルを共有する
setopt share_history

# 直前と同じコマンドラインは追加しない
setopt hist_ignore_dups

# 戦闘がスペースで始まる場合は追加しない
setopt hist_ignore_space

# 余分な空白を削除して追加
setopt hist_reduce_blanks

########################################
# auto cd , auto pushd , auto ls

# 勝手にcdする
setopt auto_cd

# cd時にpushdする
# popdコマンド全く使ってないし、いらないかな…
#setopt auto_pushd

# 同じディレクトリはpushしない
setopt pushd_ignore_dups

# 多い時は省略して表示
#function auto-ls ()
#{
#  local i
#  set -- "${(f)$(ls -C --color=always)}"
#  if (( 10 < $#* ))
#  then
#    for i in `seq 10`
#      echo ${*[$i]}
#    echo -e '\e[1;33m'etc...
#  else
#    ls
#  fi
#}

# cdしたときに自動的にls
function chpwd ()
{
  la
}

# 色付きターミナルの場合はカラフルにする
case ${TERM} in
  *color* ) [[ -e /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ;;
esac

# zsh-syntax-highlightingがなかった場合起動時にエラーコードが表示されるので、最後に何もしないコマンド
:
