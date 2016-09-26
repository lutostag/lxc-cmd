function lxd-ip {
    lxc-ls --fancy | grep -E "^$1[[:space:]]" | awk '{print $5}'
}

function lxd-waiting {
    while [ $(lxc-ip $1) == '-' ]; do sleep 0.1; done;
}

function lxd-ssh {
    grep -qF '#lxc' ~/.ssh/config || echo '#lxc' >> ~/.ssh/config
    sed '/^#lxc/q' < ~/.ssh/config > ~/.ssh/config_temp
    cat ~/.ssh/config_temp > ~/.ssh/config
    rm ~/.ssh/config_temp
    lxc list -c n4 | grep -Ev '^\+-' | tail -n +2 | tr -d ' ' | awk -F '|' '$3 != "" {ip=substr($3,1,index($3,"(")-1); print "Host "$2"\nForwardAgent yes\nUser ubuntu\nHostName " ip "\nHostKeyAlias "$2}' >> ~/.ssh/config
}

function lxe {
    if [ -z "$1" ]
    then
        lxc list --running -f
    else
        CREATE=0
        lxc-ls -1 | grep -qF $1 || lxc-clone -s "${2:-"clean"}" $1
        if [ $(lxc-ip $1) == '-' ]
        then 
            lxc-start -dn $1; lxc-waiting $1;
        fi
        lxc-ssh
    fi
}

function lxd-autocomplete {
    reply=( $(lxc-ls -1) )
}


compctl -K lxd-autocomplete lxe
