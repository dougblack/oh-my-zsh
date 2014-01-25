function git_status_grep() {
    line_begin='^\s*'
    changed=$(git status -s | grep $line_begin$1 | wc -l | tr -d ' ' )
    if [[ $changed -gt 0 ]]; then
        echo "%{$fg[$2]%}$1:$changed%{$fg[black]%}"
    else
        echo ""
    fi
}

function git_modified_count() {
names=(M \?\? D A R)
colors=(black black black black black)
output=""
for (( i = 1; i <= $#names; i++ )) do 
    column=$(git_status_grep $names[$i] $colors[$i])
    if [ -n "$column" ]; then
        if [ -n "$output" ]; then
            output="$output $column"
        else
            output="$output$column"
        fi
    fi
done
echo " [$output]"
}

function get_background_job_count() {
num_jobs=$(jobs | wc -l | tr -d ' ')
if [[ $num_jobs -gt 0 ]]; then
    echo " [$num_jobs]"
fi
}

ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
ZSH_THEME_GIT_PROMPT_CLEAN=""

#Customized git status, oh-my-zsh currently does not allow render dirty status before branch

function git_custom_status() {
  local cb=$(current_branch)
  if [ -n "$cb" ]; then
      ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[black]%}$(get_background_job_count)"
      echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$ZSH_THEME_GIT_PROMPT_SUFFIX$(parse_git_dirty)"
  fi
}

RPS1=""

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
BLUE=`print_color 4`

PROMPT='
%{$fg[black]%}${_time} ${RED}%~ ${BLUE}$(git_custom_status) %{$fg[green]%}$(virtualenv_info)%{$reset_color%}
%(?.${GREEN}.${RED})%B>%b %{$reset_color%}'
