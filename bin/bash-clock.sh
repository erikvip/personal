while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-28));tput setab 8; date;tput rc;done &
