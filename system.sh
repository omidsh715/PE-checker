
. ./base.sh

if [ "$(command -v dmesg 2>/dev/null)" ]; then
    print_2title "Searching Signature verification failed in dmesg"
    (dmesg 2>/dev/null | grep "signature") || echo_not_found "dmesg"
    echo ""
fi

print_2title ".sh files in path"
print_info "https://book.hacktricks.xyz/linux-hardening/privilege-escalation#script-binaries-in-path"
for d in `echo $PATH | tr ":" "\n"`; do find $d -name "*.sh" 2>/dev/null; done
for d in `echo $PATH | tr ":" "\n"`; do find $d -type -f -executable 2>/dev/null; done


print_2title "Executable files potentially added by user (limit 70)"
find / -type f -executable -printf "%T+ %p\n" 2>/dev/null | grep -Ev "000|/site-packages|/python|/node_modules|\.sample|/gems|/cgroup/" | sort -r | head -n 70

echo ""

if [ "$(ls /opt 2>/dev/null)" ]; then
print_2title "Unexpected in /opt (usually empty)"
ls -la /opt
echo ""
fi


##-- IF) Unexpected folders in /
print_2title "Unexpected in root"
(find $ROOT_FOLDER -maxdepth 1 | grep -Ev "$commonrootdirsG" | sed -${E} "s,.*,${SED_RED},") || echo_not_found
echo ""

print_2title "check write permission on /etc/sudoers.d/"
if  [ -w '/etc/sudoers.d/' ]; then
  echo "You can create a file in /etc/sudoers.d/ and escalate privileges"
fi

print_2title "check read permission on /etc/sudoers.d/*"
for filename in /etc/sudoers.d/*; do
  if [ -r "$filename" ]; then
    echo "Sudoers file: $filename is readable" | sed -${E} "s,.*,${SED_RED},g"
  fi
done

print_2title "Superusers"
awk -F: '($3 == "0") {print}' /etc/passwd 2>/dev/null | sed -e "s,$sh_usrs,${SED_BLUE}," | sed -${E} "s,$nosh_usrs,${SED_BLUE}," | sed -${E} "s,$knw_usrs,${SED_BLUE}," | sed "s,$USER,${SED_BLUE}," | sed "s,root,${SED_BLUE},"
echo ""

print_2title "Last Logons"
(last -Faiw || last) 2>/dev/null | tail | sed -${E} "s,$sh_usrs,${SED_GREEN}," | sed -${E} "s,$nosh_usrs,${SED_RED}," | sed -${E} "s,$knw_usrs,${SED_GREEN}," | sed "s,$USER,${SED_GREEN}," | sed "s,root,${SED_RED},"


print_info "Check weird & unexpected proceses run by root: https://book.hacktricks.xyz/linux-hardening/privilege-escalation#processes"
  if [ -f "/etc/fstab" ] && cat /etc/fstab | grep -q "hidepid=2"; then
    echo "Looks like /etc/fstab has hidepid=2, so ps will not show processes of other users"
  fi


(ps fauxwww || ps auxwww | sort ) 2>/dev/null | grep -v "\[" | grep -v "%CPU" | while read psline; do
      echo "$psline"  | sed -${E} "s,$Wfolders,${SED_RED},g" | sed -${E} "s,$sh_usrs,${SED_RED}," | sed -${E} "s,$nosh_usrs,${SED_BLUE}," | sed -${E} "s,$rootcommon,${SED_GREEN}," | sed -${E} "s,$knw_usrs,${SED_GREEN}," | sed "s,$USER,${SED_BLUE}," | sed "s,root,${SED_RED}," | sed -${E} "s,$processesVB,${SED_GREEN},g" | sed "s,$processesB,${SED_RED}," | sed -${E} "s,$processesDump,${SED_RED},"
      if [ "$(command -v capsh)" ] && ! echo "$psline" | grep -q root; then
        cpid=$(echo "$psline" | awk '{print $2}')
        caphex=0x"$(cat /proc/$cpid/status 2> /dev/null | grep CapEff | awk '{print $2}')"
        if [ "$caphex" ] && [ "$caphex" != "0x" ] && echo "$caphex" | grep -qv '0x0000000000000000'; then
          printf "  └─(${DG}Caps${NC}) "; capsh --decode=$caphex 2>/dev/null | grep -v "WARNING:" | sed -${E} "s,$capsB,${SED_RED},g"
        fi
      fi
    done