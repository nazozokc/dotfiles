fish_add_path /home/nazozokc/.local/bin
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
