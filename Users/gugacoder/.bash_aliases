alias ls='ls -Ga'
alias l='ls'
alias ll='ls -lh'

alias top='htop'
alias jobs='jobs -l'
alias gitsee='git -p ls-tree -r --name-only'
alias wget-all='wget --recursive --no-parent --no-host-directories'

alias grep='grep --color=always'
alias ?='grep --color=always'
alias ??='grep -iRI --color=always'

alias iargs='xargs -I{}'

alias cp='cp -r'
alias rm='rm -ri'

alias port='sudo port'

alias gitlog='git log --date=short --pretty="%C(Yellow)%h %C(reset)%ad (%C(Green)%cr%C(reset))%x09 %C(Cyan)%an: %C(reset)%s"'

alias sed='sed -E'

alias search='find . -name'
alias f='find . -name'
alias d='find . -type d -name'

alias trim='iargs echo {}'
alias uncolor="sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g'"

alias ++='svn st | grep ! | cut -d\  -f8 | xargs -I{} svn rm {} ; svn st | grep ? | cut -d\  -f8 | xargs -I{} svn add {}'
