
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

