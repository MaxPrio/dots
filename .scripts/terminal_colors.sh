#!/bin/bash

nc="$(tput sgr0)"

black="$(tput setaf 0)"
white="$(tput setaf 15)"
gray="$(tput setaf 8)"
gray_br="$(tput setaf 7)"

red="$(tput setaf 1)"
red_br="$(tput setaf 9)"
red_256="\e[38;5;196m"
green="$(tput setaf 2)"
green_br="$(tput setaf 10)"
yellow="$(tput setaf 3)"
yellow_br="$(tput setaf 11)"
blue="$(tput setaf 4)"
blue_br="$(tput setaf 12)"
purple="$(tput setaf 5)"
purple_br="$(tput setaf 13)"
cyan="$(tput setaf 6)"
cyan_br="$(tput setaf 14)"

nf="\033[0m"
bold="\033[1m"
blink="\033[5m"
invrs="\033[7m"

if [ $1 ]
then
printf "%-14.14s %-14.14s\n"\
    "${black}BLACK" "${white}WHITE"\
    "${gray}GRAY_D" "${gray_br}GRAY_L"\
    "${red}RED" "${red_br}RED_BR"\
    "${green}GREEN" "${green_br}GREEN_BR"\
    "${yellow}YELLOW" "${yellow_br}YELLOW_BR"\
    "${blue}BLUE" "${blue_br}BLUE_BR"\
    "${purple}PURPLE" "${purple_br}PURPLE_BR"\
    "${cyan}CYAN" "${cyan_br}CYAN_BR"\
    ${nc}
echo -e "normal$bold bold ${invrs}invrs$nf$blink blink$nf normal"
echo -n 'echo -e  "${blink}${red_256}Bright red and blink $nf" -> '
echo -e "${blink}${red_256}Bright red and blink $nf\n"
fi
