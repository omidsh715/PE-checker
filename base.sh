#!/bin/sh

C=$(printf '\033')
RED="${C}[1;31m"
SED_RED="${C}[1;31m&${C}[0m"
GREEN="${C}[1;32m"
SED_GREEN="${C}[1;32m&${C}[0m"
YELLOW="${C}[1;33m"
SED_YELLOW="${C}[1;33m&${C}[0m"
RED_YELLOW="${C}[1;31;103m"
SED_RED_YELLOW="${C}[1;31;103m&${C}[0m"
BLUE="${C}[1;34m"
SED_BLUE="${C}[1;34m&${C}[0m"

mountG="swap|/cdrom|/floppy|/dev/shm"


# Test if sed supports -E or -r
E=E
echo | sed -${E} 's/o/a/' 2>/dev/null
if [ $? -ne 0 ] ; then
	echo | sed -r 's/o/a/' 2>/dev/null
	if [ $? -eq 0 ] ; then
		E=r
	else
		echo "${RED}ERROR: there is a problem executing sed command."
        exit 1
	fi
fi


echo_not_found(){
  printf $GREEN"$1 Not Found\n"$NC
}


print_info(){
  printf "${BLUE}╚ $1\n"$NC
}


print_2title(){

  printf ${BLUE}"╔══════════╣ $GREEN$1\n"$NC # There are 10 "═"
}


ROOT_FOLDER="/"
commonrootdirsG="^/$|/bin$|/boot$|/.cache$|/cdrom|/dev$|/etc$|/home$|/lost+found$|/lib$|/lib32$|libx32$|/lib64$|lost\+found|/media$|/mnt$|/opt$|/proc$|/root$|/run$|/sbin$|/snap$|/srv$|/sys$|/tmp$|/usr$|/var$"


