export LANG=ja_JP.UTF-8
BASH_CONFIG_BASE=$(dirname $(readlink -f ~/.bashrc))

# https://github.com/ogham/exa/issues/544#issuecomment-1094888689
export LS_COLORS="*.arw=38;5;133:*.bmp=38;5;133:*.cbr=38;5;133:*.cbz=38;5;133:*.cr2=38;5;133:*.dvi=38;5;133:*.eps=38;5;133:*.gif=38;5;133:*.heif=38;5;133:*.ico=38;5;133:*.jpeg=38;5;133:*.jpg=38;5;133:*.nef=38;5;133:*.orf=38;5;133:*.pbm=38;5;133:*.pgm=38;5;133:*.png=38;5;133:*.pnm=38;5;133:*.ppm=38;5;133:*.ps=38;5;133:*.raw=38;5;133:*.stl=38;5;133:*.svg=38;5;133:*.tif=38;5;133:*.tiff=38;5;133:*.webp=38;5;133:*.xpm=38;5;133:*.avi=38;5;135:*.flv=38;5;135:*.heic=38;5;135:*.m2ts=38;5;135:*.m2v=38;5;135:*.mkv=38;5;135:*.mov=38;5;135:*.mp4=38;5;135:*.mpeg=38;5;135:*.mpg=38;5;135:*.ogm=38;5;135:*.ogv=38;5;135:*.ts=38;5;135:*.vob=38;5;135:*.webm=38;5;135:*.wmvm=38;5;135:*.djvu=38;5;105:*.doc=38;5;105:*.docx=38;5;105:*.dvi=38;5;105:*.eml=38;5;105:*.eps=38;5;105:*.fotd=38;5;105:*.key=38;5;105:*.odp=38;5;105:*.odt=38;5;105:*.pdf=38;5;105:*.ppt=38;5;105:*.pptx=38;5;105:*.rtf=38;5;105:*.xls=38;5;105:*.xlsx=38;5;105:*.aac=38;5;92:*.alac=38;5;92:*.ape=38;5;92:*.flac=38;5;92:*.m4a=38;5;92:*.mka=38;5;92:*.mp3=38;5;92:*.ogg=38;5;92:*.opus=38;5;92:*.wav=38;5;92:*.wma=38;5;92:*.7z=31:*.a=31:*.ar=31:*.bz2=31:*.deb=31:*.dmg=31:*.gz=31:*.iso=31:*.lzma=31:*.par=31:*.rar=31:*.rpm=31:*.tar=31:*.tc=31:*.tgz=31:*.txz=31:*.xz=31:*.z=31:*.Z=31:*.zip=31:*.zst=31:*.asc=38;5;109:*.enc=38;5;109:*.gpg=38;5;109:*.p12=38;5;109:*.pfx=38;5;109:*.pgp=38;5;109:*.sig=38;5;109:*.signature=38;5;109:*.bak=38;5;244:*.bk=38;5;244:*.swn=38;5;244:*.swo=38;5;244:*.swp=38;5;244:*.tmp=38;5;244:*.~=38;5;244:pi=33:cd=33:bd=33:di=34;1:so=36:or=36:ln=36:ex=32;1:"
bind 'set colored-stats on'


__command_exist () {
    command -v $1 &> /dev/null
    return $?
}


__init_homebrew () {
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        alias abrew="arch -arch arm64 /opt/homebrew/bin/brew"
        alias brew=abrew
    fi

    if [[ -x /usr/local/bin/brew ]]; then
        alias ibrew="arch -arch x86_64 /usr/local/bin/brew"
        [[ "$(uname -p)" != "arm" ]] && alias brew=ibrew
    fi

    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
}


__peco_select_history () {
  local BUFFER
  BUFFER=$(fc -rln 1 | sed 's/^\s*//' | peco --layout=bottom-up)
  READLINE_LINE="$BUFFER"
  READLINE_POINT=${#BUFFER}
}

__peco_ghq_repository () {
  cd $(ghq list --full-path | peco --layout=bottom-up)
}

__init_keybinds () {
  bind -x '"\C-r":__peco_select_history'
  bind -x '"\C-g":__peco_ghq_repository'


  bind '"\C-n": history-search-forward'
  bind '"\C-p": history-search-backward'
}

__init_history () {
  export HISTFILE=~/.cache/bash/history
  mkdir -p $(dirname $HISTFILE)
  export HISTSIZE=1000
  export HISTFILESIZE=10000
  export HISTCONTROL=ignoreboth:erasedups
}

__init_pachage () {
  export AQUA_ROOT_DIR=$BASH_CONFIG_BASE/aqua
  export AQUA_GLOBAL_CONFIG=$BASH_CONFIG_BASE/aqua.yaml
}

__init_bash_config () {
  export PATH=/usr/local/bin:$BASH_CONFIG_BASE/aqua/bin:~/.cargo/bin:~/.local/bin:$PATH

  __init_homebrew
  __init_history
  __init_keybinds
  __init_pachage

  if __command_exist starship; then
    eval "$(starship init bash)"
    export STARSHIP_CONFIG=$BASH_CONFIG_BASE/starship.toml
  fi

  if __command_exist gls; then
    alias ls="gls --color=auto"
  elif [[ "$OS" == "Windows_NT" || "$(uname)" == Linux ]]; then
    alias ls="ls --color=auto"
  fi

  alias l=ls
  alias la="ls -a"
  alias ll="ls -l"
  alias llh="ls -lh"
  alias lla="ls -la"
  alias lh="ls -lh"


  __command_exist pbpaste && alias p=pbpaste
  __command_exist pbcopy && alias c=pbcopy

  [[ -f /usr/bin/otool ]] && alias ldd="/usr/bin/otool -L"

  __command_exist direnv &&  eval "$(direnv hook bash)"
}

__init_bash_config
