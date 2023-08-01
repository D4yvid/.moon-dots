# vim: set ts=4 sw=4 et:

msg "Mounting root filesystem"
# mount -o remount,rw / || emergency_shell

msg "Mounting other filesystems"
mount -a -t "nosysfs,nonfs,nonfs4,nosmbfs,nocifs" -O no_netdev || emergency_shell
