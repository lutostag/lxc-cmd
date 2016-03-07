function lxc-ip {
    lxc-ls --fancy | grep -E "^$1[[:space:]]" | awk '{print $3}'
}

function lxc-waiting {
    while [ $(lxc-ip $1) == '-' ]; do sleep 0.1; done;
}

function lxc-ssh {
    grep -qF '#lxc' ~/.ssh/config || echo '#lxc' >> ~/.ssh/config
    sed '/^#lxc/q' < ~/.ssh/config > ~/.ssh/config_temp
    cat ~/.ssh/config_temp > ~/.ssh/config
    rm ~/.ssh/config_temp
    lxc-ls --fancy | awk 'NR>2 && $3 != "-" {if(index($3,",") > 0) {ip=substr($3,1,index($3,",")-1) } else { ip=$3 }; print "Host "$1"\nForwardAgent yes\nUser ubuntu\nHostName " ip "\nHostKeyAlias "$1}' >> ~/.ssh/config
}

function lxc {
    if [ -z "$1" ]
    then
        lxc-ls --fancy | awk '$3 != "-" {print}'
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

function lxc-autocomplete {
    reply=( $(lxc-ls -1) )
}


compctl -K lxc-autocomplete lxc
