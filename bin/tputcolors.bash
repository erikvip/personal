#!/bin/bash 

# Hook calls to tput and if we're not running interactively, then just
# Return an empty strings. 
# This is necessary for pass through support when not running interactively
# and set -o errexit is on, which would normally cause tput to exit with an
# error status if $TERM is not defined due to an non-interactive session
tput() {
  tty -s && /usr/bin/tput $* || echo -n "";
}

# Reset - normal text
normal=$(tput sgr0);

# Standard color set
black=$(tput setaf 0);
red=$(tput setaf 1);
green=$(tput setaf 2);
yellow=$(tput setaf 3);
blue=$(tput setaf 4);
magenta=$(tput setaf 5);
cyan=$(tput setaf 6);
white=$(tput setaf 7);

# Extended ANSI colors
light_red=$(echo -e "\033[1;31m")
light_green=$(echo -e "\033[1;32m")
light_yellow=$(echo -e "\033[1;33m")
light_blue=$(echo -e "\033[1;34m")
light_magenta=$(echo -e "\033[1;35m")
light_cyan=$(echo -e "\033[1;36m")

# Text effects
bold=$(tput bold);
underline=$(tput smul);
end_underline=$(tput rmul);
blink=$(tput blink);
standout=$(tput smso);
end_standout=$(tput rmso);

# Cursor Positioning
#cursor_up="\033[1A";
cursor_up=$(tput cuu1);
cursor_down=$(tput cud1);


test_all() {
    echo -e "${light_red}light_red${normal}";
    column -t << EOF
${underline}Standard_color_set${normal}
${black}black${normal}  black
${red}red${normal}  red   
${green}green${normal}  green
${yellow}yellow${normal}    yellow
${blue}blue${normal}    blue
${magenta}magenta${normal}  magenta
${cyan}cyan${normal}    cyan
${white}white${normal}  white
${light_red}light_red${normal}    \033[1;31m
${light_green}light_green${normal}    \033[1;32m
${light_yellow}light_yellow${normal}    \034[1;33m
${light_blue}light_blue${normal}    \033[1;34m
${light_magenta}light_magenta${normal}    \033[1;35m
${light_cyan}light_cyan${normal}    \033[1;36m


EOF

   
}

# generates an 8 bit color table (256 colors) for
# reference purposes, using the \033[48;5;${val}m
# ANSI CSI+SGR (see "ANSI Code" on Wikipedia)
tputcolors_show_ansi_colors() {
    echo -en "\n   +  "
    for i in {0..35}; do
      printf "%2b " $i
    done

    printf "\n\n %3b  " 0
    for i in {0..15}; do
      echo -en "\033[48;5;${i}m  \033[m "
    done

    #for i in 16 52 88 124 160 196 232; do
    for i in {0..6}; do
      let "i = i*36 +16"
      printf "\n\n %3b  " $i
      for j in {0..35}; do
        let "val = i+j"
        echo -en "\033[48;5;${val}m  \033[m "
      done
    done

    echo -e "\n"

    echo 'To use colors, substitute number in: \033[48;5;NUMBERm';
}

#test_all
