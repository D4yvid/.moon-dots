# vim: set ts=4 sw=4 et:

if [ -x /sbin/udevd -o -x /bin/udevd ]; then
    _udevd=udevd
else
    msg_warn "cannot find udevd!"
    return
fi

msg "Starting device managment daemon (udevd)"
${_udevd} --daemon
udevadm trigger --action=add --type=subsystems
udevadm trigger --action=add --type=devices
udevadm settle
