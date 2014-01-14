ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg_bold[red]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

#Customized git status, oh-my-zsh currently does not allow render dirty status before branch
git_custom_status() {
  local cb=$(current_branch)
  if [ -n "$cb" ]; then
    echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

RPS1='$(git_custom_status) $EPS1'

function print_color () { 
    echo -ne "%{\e[38;05;${1}m%}"; 
}

preexec () {
   (( $#_elapsed > 1000 )) && set -A _elapsed $_elapsed[-1000,-1]
   typeset -ig _start=SECONDS
}

function get_time {
    local seconds=${1}
    local minutes=0
    local hours=0
    while [ $seconds -gt 60 ]; do
        ((minutes = minutes + 1))
        ((seconds = seconds - 60))
    done
    while [ $minutes -gt 60 ]; do
        ((hours = hours + 1))
        ((minutes = minutes - 60))
    done
    echo "$hours $minutes $seconds"
}

function precmd {
    DIR=$(pwd|sed -e "s!$HOME!~!");
    if [ ${#DIR} -gt 60 ]; then 
        cur="${DIR:0:27}...${DIR:${#DIR}-30}";
    else
        cur=${DIR}
    fi;
    set -A _elapsed $_elapsed $(( SECONDS-_start ))
    result="`get_time $_elapsed[-1]`"
    hours=$(echo $result | cut -f1 -d" ")
    minutes=$(echo $result | cut -f2 -d" ")
    seconds_int=$(echo $result | cut -f3 -d" ")
    if [ "$hours" -eq "0" ]; then
        if [ "$minutes" -eq "0" ]; then
            _time="$seconds_int"s
        else
            seconds=`printf "%02d" "$seconds_int"`
            _time="$minutes":"$seconds"
        fi
    else
        seconds=`printf "%02d" "$seconds_int"`
        minutes=`printf "%02d" "$minutes"`
        _time="$hours:$minutes:$seconds"
    fi
}

YELLOW=`print_color 226`
RED=`print_color 1`
GREEN=`print_color 2`

PROMPT='
%{$fg[black]%}${_time} ${RED}%~
%(?.${GREEN}.${RED})%B>%b '
